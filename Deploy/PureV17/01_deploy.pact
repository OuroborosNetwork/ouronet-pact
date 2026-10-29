;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 1 of 8
;; This is STEP 1 of 8 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-0 must have run first, including the init steps between deploys.
;; 4 source file(s), 386,723 gas measured in the REPL gas model, 311,882 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;   1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact
;;
;; TOTAL: 1 interface(s), 4 module(s), 8 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
;;      interface  AutostakeUsageV4
;;      module     ATSU
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;      module     OUROBOROS
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
;;      module     TS01-A
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact
;;      module     TS01-C2
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact ====================
;; net: v1   ·   dev: v2   ;; AutostakeUsage V3 -> V4 (2026-10-29): XB_Coil -- a coil whose
;; FUNDER and RECIPIENT are separate accounts, so the AQP reward ladder can coil as
;; AQP|SC_NAME and credit a beneficiary who is not signing. C_Coil now delegates to it.
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AutostakeUsageV4
    @doc "Exposes Autostake Usage Functions, which involve Token Transfers"

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
    ;;
    ;;  [URC]
    ;;
    (defun URC_MultiCull:object (ats:string acc:string))
    (defun URC_SingleCull:[decimal] (ats:string acc:string position:integer))
    ;;
    ;;  [UDC]
    ;;
    (defun URCi_UnlimitedUncoilCumulator:object{IgnisCollectorV4.OutputCumulator} (ats:string account:string))
    (defun URCi_WithdrawRoyalties:object{IgnisCollectorV4.OutputCumulator} (ats:string target:string))
    (defun URCi_KickStart:object{IgnisCollectorV4.OutputCumulator} (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun URCi_Fuel:object{IgnisCollectorV4.OutputCumulator} (fueler:string ats:string reward-token:string amount:decimal))
    (defun URCi_Coil:object{IgnisCollectorV4.OutputCumulator} (coiler:string ats:string rt:string amount:decimal))
    (defun URCi_CoilTo:object{IgnisCollectorV4.OutputCumulator} (funder:string recipient:string ats:string rt:string amount:decimal))
    (defun URCi_Curl:object{IgnisCollectorV4.OutputCumulator} (curler:string ats1:string ats2:string rt:string amount:decimal))
    (defun URCi_ColdRecovery:object{IgnisCollectorV4.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Cull:object{IgnisCollectorV4.OutputCumulator} (culler:string ats:string))
    (defun URCi_HotRecovery:object{IgnisCollectorV4.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Recover:object{IgnisCollectorV4.OutputCumulator} (recoverer:string id:string nonce:integer))
    (defun URCi_Redeem:object{IgnisCollectorV4.OutputCumulator} (redeemer:string id:string nonce:integer))
    (defun URCi_DirectRecovery:object{IgnisCollectorV4.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Syphon:object{IgnisCollectorV4.OutputCumulator} (syphon-target:string ats:string syphon-amounts:[decimal]))
    (defun URCi_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator} (remover:string ats:string reward-token:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun AA_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string reward-token:string accounts-with-ats-data:[string])
    )
    (defun A_KickStart:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
    )
    ;;
    ;;  [C]
    ;;
    (defun CC_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string reward-token:string)
    )
    (defun C_WithdrawRoyalties:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string executee:string ats:string))
        ;;
    (defun C_KickStart:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun C_Fuel:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string reward-token:string amount:decimal))
    ;;XB_Coil is C_Coil with the funder and the recipient SPLIT, for a caller that must coil out of
    ;;one account and credit another -- the AQP reward ladder coiling as AQP|SC_NAME on behalf of a
    ;;beneficiary who is not signing. C_Coil KEEPS ITS OWN BODY rather than delegating: moving the
    ;;three legs behind an XB_ made `_ignis_price_sheet.py` re-quote C_Coil from `>= 93` to `87`
    ;;claimed exact, dropping both transfer legs. The duplication is pinned by assertion instead.
    ;;URCi_CoilTo is this one's cost mirror -- URCi_Coil cannot serve it, because a transfer's IGNIS
    ;;class depends on WHICH accounts it runs between.
    (defun XB_Coil:object{IgnisCollectorV4.OutputCumulator} (patron:string funder:string recipient:string ats:string rt:string amount:decimal))
    (defun C_Coil:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string rt:string amount:decimal))
    (defun C_Curl:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats1:string ats2:string rt:string amount:decimal))
        ;;
    (defun C_ColdRecovery:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string ra:decimal))
    (defun C_Cull:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string))
        ;;
    (defun C_HotRecovery:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string ra:decimal))
    (defun C_Recover:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string nonce:integer))
    (defun C_Redeem:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string id:string nonce:integer))
        ;;
    (defun C_DirectRecovery:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string ats:string ra:decimal))
        ;;
    (defun C_Syphon:object{IgnisCollectorV4.OutputCumulator} (patron:string executor:string executee:string ats:string syphon-amounts:[decimal]))


    ;;<=========================================================================>
    ;; ADDED 2026-10-12 -- interface-membership sweep (StoicSyntax-Prefixes.md Sec5,
    ;; owner ruling). Every one of these was already live in the module body; this
    ;; closes the gap between what the module DOES and what its interface SAYS it does.
    ;;<=========================================================================>
    (defun UEV_FuelableIndex (ats:string))
)
;;
(module ATSU GOV
    @doc "ATSU — the Autostake usage core, performing the token-moving operations on ATS \
        \ pools; implements AutostakeUsageV2. It provides URCi cost readers plus client ops \
        \ KickStart, Fuel, Coil, Curl, ColdRecovery, Cull, HotRecovery, Recover, Redeem, \
        \ DirectRecovery, Syphon, WithdrawRoyalties and RemoveSecondary. It complements ATS \
        \ (pool configuration) by executing the actual reward-token staking, recovery and \
        \ reward withdrawals."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements AutostakeUsageV4)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ATSU                               (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_ATSU                               (keyset-ref-guard (GOV|AutostakeKey)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ATSU_ADMIN)))
    (defcap GOV|ATSU_ADMIN ()
        (enforce-one
            "ATSU Autostake Admin not satisfed"
            [
                (enforce-guard GOV|MD_ATSU)
                (enforce-guard GOV|SC_ATSU)
            ]
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AutostakeKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|AutostakeKey)
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
    (defcap P|ATSU|CALLER ()
        true
    )
    (defcap P|ATSU|REMOTE-GOV ()
        true
    )
    (defcap P|TT ()
        (compose-capability (P|ATSU|REMOTE-GOV))
        (compose-capability (P|ATSU|CALLER))
        (compose-capability (SECURE))
    )
    (defcap P|DT1 ()
        (compose-capability (P|ATSU|REMOTE-GOV))
        (compose-capability (SECURE))
    )
    (defcap P|DT2 ()
        (compose-capability (P|ATSU|REMOTE-GOV))
        (compose-capability (P|ATSU|CALLER))
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
        (with-capability (GOV|ATSU_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ATSU_ADMIN)
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
        (with-capability (GOV|ATSU_ADMIN)
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
        (with-capability (GOV|ATSU_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (mg:guard (create-capability-guard (P|ATSU|CALLER)))
            )
            (ref-P|ATS::P|A_Add
                "ATSU|RemoteAtsGov"
                (create-capability-guard (P|ATSU|REMOTE-GOV))
            )

            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
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
    (defcap ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY (executor:string ats:string reward-token:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            ;;ATTRIBUTION, not authority. GOV|ATSU_ADMIN below decides WHETHER this may happen;
            ;;<executor> records WHO made it happen, and is enforced so the record cannot be a
            ;;name the caller invented. An admin op is exactly where this is tempting to skip --
            ;;the key has already opened the door -- and exactly where the audit trail is worth
            ;;most, because one key may be held by several people. (owner ruling 2026-09-21.)
            (ref-DALOS::CAP_EnforceAccountOwnership executor)
            (compose-capability (GOV|ATSU_ADMIN))
            (compose-capability (ATSU|C>X_REMOVE-SECONDARY ats reward-token))
        )
    )
    (defcap ATSU|C>REMOVE-SECONDARY (executor:string ats:string reward-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-ATS::CAP_Owner ats)
            ;;BINDS the NAMED executor to the pool owner. CAP_Owner proves that SOMEBODY holding
            ;;the pool owner's key is calling; this proves the account the caller WROTE DOWN is
            ;;that owner. Without it the executor is decorative and the event names whoever the
            ;;caller typed -- see StoicSyntax 2.2, "an UNENFORCED executor is worse than none".
            (ref-ATS::UEV_ExecutorIsOwnerKonto executor ats)
            (compose-capability (ATSU|C>X_REMOVE-SECONDARY ats reward-token))
        )
    )
    (defcap ATSU|C>X_REMOVE-SECONDARY (ats:string reward-token:string)
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (rt-position:integer (ref-ATS::URCv_RewardTokenPosition ats reward-token))
            )
            (enforce (> rt-position 0) "Primal RT cannot be removed")
            (ref-ATS::UEV_ParameterLockState ats false)
            (ref-ATS::UEV_ColdRecoveryState ats false)
            (ref-ATS::UEV_HotRecoveryState ats false)
            (ref-ATS::UEV_DirectRecoveryState ats false)
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>WITHDRAW-ROYALTIES (executor:string executee:string ats:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
                (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                (sum:decimal (fold (+) 0.0 royalties))
            )
            ;;THREE ROLES, and only two of them used to be visible. <executee> is where the
            ;;royalties GO -- it is checked for account TYPE and nothing else, deliberately: the
            ;;pool owner may pay their royalties to whomever they choose. The account that ACTS is
            ;;the pool owner, proven by CAP_Owner below and, before this sweep, named nowhere at
            ;;all. (patron/executor canon 2.2.)
            (ref-DALOS::UEV_EnforceAccountType executee false)
            (ref-ATS::CAP_Owner ats)
            ;;BINDS the NAMED executor to the pool owner. CAP_Owner proves that SOMEBODY holding
            ;;the pool owner's key is calling; this proves the account the caller WROTE DOWN is
            ;;that owner. Without it the executor is decorative and the event names whoever the
            ;;caller typed -- see StoicSyntax 2.2, "an UNENFORCED executor is worse than none".
            (ref-ATS::UEV_ExecutorIsOwnerKonto executor ats)
            (enforce (!= sum 0.0) (format "No Royalties to withdraw for ATS-Pair {}" [ats]))
            (compose-capability (P|DT2))
        )
    )
    ;;
    (defcap ATSU|C>KICKSTART (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Fix (audit finding #11M / M2): bounds the resulting KickStart index to \
            \ <= 100.0 on the owner-facing path, closing the unbounded genesis-ratio \
            \ inflation-attack surface against depositors who coil in after this pair \
            \ is kickstarted. Owners needing a higher ratio use A_KickStart, gated by \
            \ module governance instead of pool ownership. Layered per StoicSyntax \
            \ §14.7: thin event leaf, shared validation lives in ATSU|C>X_KICKSTART."
        @event
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (would-be-index:decimal (ref-U|ATS::UC_KickStartIndex rt-amounts rbt-request-amount))
            )
            (ref-ATS::CAP_Owner ats)
            (enforce (<= would-be-index 100.0) "KickStart index cannot exceed 100.0 via the owner path - use A_KickStart via module governance for a higher ratio")
            (compose-capability (ATSU|C>X_KICKSTART kickstarter ats rt-amounts rbt-request-amount))
        )
    )
    (defcap ATSU|C>ADMINISTRATIVE-KICKSTART (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative KickStart variant (audit finding #11M / M2, owner- \
            \ specified fix direction): forgoes pool ownership in favor of module \
            \ governance (GOV|ATSU_ADMIN), with no upper bound on the resulting index \
            \ (still subject to the same 0.1 floor as the owner path, via the shared \
            \ ATSU|C>X_KICKSTART core) - for legitimate ratios above the owner path's \
            \ 100.0 ceiling."
        @event
        (compose-capability (GOV|ATSU_ADMIN))
        (compose-capability (ATSU|C>X_KICKSTART kickstarter ats rt-amounts rbt-request-amount))
    )
    (defcap ATSU|C>X_KICKSTART (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Unevented core - shared validation for both ATSU|C>KICKSTART (owner) and \
            \ ATSU|C>ADMINISTRATIVE-KICKSTART (module governance). Fix (audit finding \
            \ #11M / M2): adds a shared >= 0.1 floor on the resulting index, same value \
            \ as syphon's own floor, on top of the pre-existing checks."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (index:decimal (ref-ATS::URC_Index ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (l1:integer (length rt-amounts))
                (l2:integer (length rt-lst))
                (would-be-index:decimal (ref-U|ATS::UC_KickStartIndex rt-amounts rbt-request-amount))
            )
            (ref-DALOS::UEV_EnforceAccountType kickstarter false)
            ;; Caller-input-only checks first (independent of live pool state), pool-state
            ;; checks last - lets bound violations be rejected before ever touching state.
            (enforce (= l1 l2) "RT-Amounts list does not correspond with the Number of the ATS-Pair Reward Tokens")
            (enforce (> rbt-request-amount 0.0) "RBT Request Amount must be greater than zero!")
            (enforce (>= would-be-index 0.1) "KickStart index must be at least 0.1")
            (enforce (= index -1.0) "Kickstarting can only be done on ATS-Pairs with -1 Index")
            (compose-capability (P|TT))
        )
    )
    ;;Module-local (no interface change): the single source for "can this pair be fuelled".
    ;;Shared by ATSU|C>FUEL and URCi_Fuel so the quote and the op refuse in the same words.
    (defun UEV_FuelableIndex (ats:string)
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (enforce
                (>= (ref-ATS::URC_Index ats) 0.1)
                "Fueling requires an ATS-Pair Index of at least 0.1"
            )
        )
    )
    (defcap ATSU|C>FUEL (ats:string reward-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-ATS::UEV_RewardTokenExistance ats reward-token true)
            ;;WORDING FIX (owner-authorised 2026-09-13). This read "Fueling cannot take place on a
            ;;negative Index", which described only part of its own condition: the bound is 0.1, so
            ;;an index of 0.05 is POSITIVE and still rejected, and that caller was told something
            ;;untrue about their own pair. The BOUND is correct and stays -- 0.1 is a deliberate
            ;;system floor, the same one ATSU|C>KICKSTART applies to <would-be-index> twelve lines
            ;;above, where it is already worded honestly as "KickStart index must be at least 0.1".
            ;;The two states this rejects are the -1.0 sentinel (URC_Index's "no RBT supply at all")
            ;;and a live pair whose index has fallen under the floor; the new message covers both.
            ;;Pinned in BOTH states by REPL/modules/ATS.repl <<ATS-G17>>.
            ;;REFUSAL PARITY (2026-09-15): this enforce used to be written out here, which meant
            ;;URCi_Fuel had no way to share it and quoted a confident "Succesfully fueled ..." for
            ;;pairs this line refuses. It now lives in UEV_FuelableIndex, called by BOTH, so the
            ;;preview and the exec cannot drift apart or word the same refusal differently.
            (UEV_FuelableIndex ats)
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>COIL (ats:string coil-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (h:bool (ref-ATS::UR_Hibernate ats))
            )
            (ref-ATS::UEV_RewardTokenExistance ats coil-token true)
            (enforce (not h) (format "Cannot Coil when {} has Hibernation turned on" [ats]))
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>CURL (ats1:string ats2:string curl-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (h1:bool (ref-ATS::UR_Hibernate ats1))
                (h2:bool (ref-ATS::UR_Hibernate ats2))
            )
            (ref-ATS::UEV_RewardTokenExistance ats1 curl-token true)
            (enforce (and (not h1) (not h2)) (format "Curl requires both {} and {} to have Hibernation set to off" [ats1 ats2]))
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>COLD_RECOVERY (recoverer:string ats:string ra:decimal usable-cold-recovery-position:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
                (cold-recovery-positions:integer (ref-ATS::UR_ColdRecoveryPositions ats))
            )
            (enforce (<= usable-cold-recovery-position cold-recovery-positions) 
                "Unavailable Positions for Cold Recovery!"
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_ColdRecoveryState ats true)
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>DEPLOY (ats:string acc:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists acc)
            (compose-capability (ATSU|C>NORMALIZE_LEDGER ats acc))
        )
    )
    (defcap ATSU|C>NORMALIZE_LEDGER (ats:string acc:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
                (dalos-admin:guard GOV|MD_ATSU)
                (autos-admin:guard GOV|SC_ATSU)
                (acc-g:guard (ref-DALOS::UR_AccountGuard acc))
                (sov:string (ref-DALOS::UR_AccountSovereign acc))
                (sov-g:guard (ref-DALOS::UR_AccountGuard sov))
                (gov-g:guard (ref-DALOS::UR_AccountGovernor acc))
            )
            (ref-ATS::UEV_id ats)
            (enforce-one
                "Invalid permission for normalizing ATS|Ledger Account Operations"
                [
                    (enforce-guard dalos-admin)
                    (enforce-guard autos-admin)
                    (enforce-guard acc-g)
                    (enforce-guard sov-g)
                    (enforce-guard gov-g)
                ]
            )
            (compose-capability (P|ATSU|CALLER))
        )
    )
    (defcap ATSU|C>CULL (culler:string ats:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership culler)
            (compose-capability (ATSU|C>NORMALIZE_LEDGER ats culler))
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATS|C>HOT_RECOVERY (recoverer:string ats:string ra:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_HotRecoveryState ats true)
            ;;The toggle and the Hot-RBT are INDEPENDENT: ATS|S>SWITCH-HOT-RECOVERY checks only
            ;;CAP_Owner and the previous toggle value, so a pool owner may switch recovery ON for a
            ;;pair that has no Hot-RBT. In that state the line above passes and the body would read
            ;;the DPOF properties table keyed by the BAR sentinel. Pinned by <<RT-H-003e>>, which
            ;;constructs exactly that state through the owner's own client op.
            (enforce
                (ref-ATS::URC_IzPresentHotRBT ats)
                (format "ATS-Pair {} has no Hot-RBT, so Hot Recovery is impossible" [ats])
            )
            (compose-capability (P|TT))
        )
    )
    (defcap ATS|C>RECOVER (recoverer:string id:string nonce:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (iz-rbt:bool (ref-DPOF::URC_IzRBT id))
            )
            (ref-DALOS::UEV_EnforceAccountType recoverer false)
            (enforce iz-rbt "Invalid Hot-RBT")
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>REDEEM (redeemer:string id:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (iz-rbt:bool (ref-DPOF::URC_IzRBT id))
            )
            (ref-DALOS::UEV_EnforceAccountType redeemer false)
            (enforce iz-rbt "Invalid Hot-RBT")
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATS|C>DIRECT_RECOVERY (recoverer:string ats:string ra:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_DirectRecoveryState ats true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATSU|C>SYPHON (executor:string ats:string syphon-amounts:[decimal])
        @event
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (l0:integer (length syphon-amounts))
                (l1:integer (length rt-lst))
                (syphoning:bool (ref-ATS::UR_Syphoning ats))
                (max-syphon:[decimal] (ref-ATS::URC_MaxSyphon ats))
                (max-syphon-sum:decimal (fold (+) 0.0 max-syphon))
                (input-syphon-sum:decimal (fold (+) 0.0 syphon-amounts))
                (resident-amounts:[decimal] (ref-ATS::UR_RewardTokenRUR ats 1))
                (supply-check:[bool] (zip (lambda (x:decimal y:decimal) (<= x y)) syphon-amounts resident-amounts))
                (tr-nr:integer (length (ref-U|LST::UC_Search supply-check true)))
            )
            (ref-ATS::CAP_Owner ats)
            ;;BINDS the NAMED executor to the pool owner. CAP_Owner proves that SOMEBODY holding
            ;;the pool owner's key is calling; this proves the account the caller WROTE DOWN is
            ;;that owner. Without it the executor is decorative and the event names whoever the
            ;;caller typed -- see StoicSyntax 2.2, "an UNENFORCED executor is worse than none".
            (ref-ATS::UEV_ExecutorIsOwnerKonto executor ats)
            (enforce syphoning "Syphoning must be turned ON for exec")
            (enforce (= l0 l1) "Invalid Amounts of Syphon Values")
            (enforce (> input-syphon-sum 0.0) "Invalid Syphon Amounts")
            (map
                (lambda
                    (sv:decimal)
                    (enforce (>= sv 0.0) "Unallowed Negative Syphon Values Detected !")
                )
                syphon-amounts
            )
            (enforce (<= input-syphon-sum max-syphon-sum) "Syphon Amounts surpassing pairs Syphon-Index")
            (enforce (= l0 tr-nr) "Invalid syphon amounts surpassing present resident Amounts")
            (compose-capability (P|TT))
        )
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_MultiCull:object (ats:string acc:string)
        @doc "Outputs <after-cull> <to-be-culled> <culled-values> and <summed-culled-values> values in an object. \
            \ Fix (audit finding #32N / N1): the 'nothing cullable yet' branch used to return a bare \
            \ [decimal] list instead of an object, violating this function's own declared :object \
            \ return type - XI_MultiCull's :object-typed binding made that a hard runtime crash \
            \ instead of a graceful 'nothing to cull yet' result. Confirmed live on mainnet via Pythia \
            \ dirty read (identical bug present in the deployed ouronet-ns.ATSU, on V1 interfaces) - \
            \ not yet triggered there only because every existing live account currently has something \
            \ already past its cull-time. This is a soft-failure fix: the outcome (nothing culled) is \
            \ unchanged, only the failure mode changes from a raw crash to a well-formed empty result."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-ATS:module{AutostakeV4} ATS)
                ;;
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
                (ng:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject ats))
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats acc))
                (p0l:integer (length p0))
                (boolean-lst:[bool]
                    (fold
                        (lambda
                            (acc:[bool] item:object{UtilityAtsV3.Awo})
                            (ref-U|LST::UC_AppL acc (ref-U|ATS::UC_IzCullable item))
                        )
                        []
                        p0
                    )
                )
                (zr-output:[decimal] (make-list (length (ref-ATS::UR_RewardTokens ats)) 0.0))
                (cullables:[integer] (ref-U|LST::UC_Search boolean-lst true))
                (immutables:[integer] (ref-U|LST::UC_Search boolean-lst false))
                (how-many-cullables:integer (length cullables))
            )
            (if (= how-many-cullables 0)
                {"after-cull"           : p0
                ,"to-be-culled"         : []
                ,"culled-values"        : []
                ,"summed-culled-values" : zr-output}
                (let
                    (
                        (after-cull:[object{UtilityAtsV3.Awo}]
                            (if (< how-many-cullables p0l)
                                (fold
                                    (lambda
                                        (acc:[object{UtilityAtsV3.Awo}] idx:integer)
                                        (ref-U|LST::UC_AppL acc (at (at idx immutables) p0))
                                    )
                                    []
                                    (enumerate 0 (- (length immutables) 1))
                                )
                                [zr]
                            )
                        )
                        (to-be-culled:[object{UtilityAtsV3.Awo}]
                            (fold
                                (lambda
                                    (acc:[object{UtilityAtsV3.Awo}] idx:integer)
                                    (ref-U|LST::UC_AppL acc (at (at idx cullables) p0))
                                )
                                []
                                (enumerate 0 (- (length cullables) 1))
                            )
                        )
                        (culled-values:[[decimal]]
                            (fold
                                (lambda
                                    (acc:[[decimal]] idx:integer)
                                    (ref-U|LST::UC_AppL acc (ref-ATS::URC_CullValue ats (at idx to-be-culled)))
                                )
                                []
                                (enumerate 0 (- (length to-be-culled) 1))
                            )
                        )
                        (summed-culled-values:[decimal] (ref-U|DEC::UC_AddHybridArray culled-values))
                    )
                    {"after-cull"           : after-cull
                    ,"to-be-culled"         : to-be-culled
                    ,"culled-values"        : culled-values
                    ,"summed-culled-values" : summed-culled-values}
                )
            )
        )
    )
    (defun URC_SingleCull:[decimal] (ats:string acc:string position:integer)
        @doc "Outputs <cull-output> as a value of RTs"
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                ;;
                (unstake-obj:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc position))
                (cull-output:[decimal] (ref-ATS::URC_CullValue ats unstake-obj))
            )
            cull-output
        )
    )
    (defun URCi_UnlimitedUncoilCumulator:object{IgnisCollectorV4.OutputCumulator}
        (ats:string account:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-ATS:module{AutostakeV4} ATS)
                ;;
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats account))
                (size:decimal (dec (length p0)))
                (smallest:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                (price:decimal (* size smallest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator price account trigger [])
        )
    )
    (defun URCi_WithdrawRoyalties:object{IgnisCollectorV4.OutputCumulator}
        (ats:string target:string)
        @doc "Cost preview for C_WithdrawRoyalties — a single multi-transfer of the \
            \ pool's nonzero-royalty reward-token legs to <target>, re-derived purely \
            \ via TFT URCi_MultiTransferCumulator (same nonzero-royalty filter as exec)."
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                (nonzero-idx:[integer]
                    (filter
                        (lambda (index:integer) (> (at index royalties) 0.0))
                        (enumerate 0 (- (length reward-tokens) 1))
                    )
                )
            )
            (ref-TFT::URCi_MultiTransferCumulator
                (map (lambda (index:integer) (at index reward-tokens)) nonzero-idx)
                ATS|SC_NAME
                target
                (map (lambda (index:integer) (at index royalties)) nonzero-idx)
            )
        )
    )
    (defun URCi_KickStart:object{IgnisCollectorV4.OutputCumulator}
        (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Cost preview for C_KickStart / A_KickStart (both delegate to XI_KickStart): \
            \ one reward-token transfer per rt (mapped purely), plus cold-mint + \
            \ cold-transfer. Cost-equivalent to XI_KickStart; the [index] output is the \
            \ pre-kickstart index (the exec value reflects post-write state)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                ;;
                (rbt-id:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (ref-TFT::URCi_Transfer (at idx rt-lst) kickstarter ATS|SC_NAME (at idx rt-amounts))
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Mint rbt-id ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer rbt-id ATS|SC_NAME kickstarter rbt-request-amount)
                )
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [index])
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV4.OutputCumulator}
        (fueler:string ats:string reward-token:string amount:decimal)
        @doc "Cost preview for C_Fuel — a single reward-token transfer into the ATS SC."
        ;;The op's own gate, not a copy of it. Without this the quote succeeded -- returning a
        ;;cost AND the post-text "Succesfully fueled ..." -- for a pair C_Fuel refuses outright.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001b>>.
        (UEV_FuelableIndex ats)
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
            )
            (ref-TFT::URCi_Transfer reward-token fueler ATS|SC_NAME amount)
        )
    )
    (defun URCi_Coil:object{IgnisCollectorV4.OutputCumulator}
        (coiler:string ats:string rt:string amount:decimal)
        @doc "Cost preview for C_Coil (flavor-B composer). Re-derives C_Coil's \
            \ Concatenate[transfer, mint, transfer] purely — calling each sub-op's \
            \ own cost reader (TFT URCi_Transfer, DPTF URCi_Mint) instead of the write \
            \ C_ — so it totals the IGNIS cost WITHOUT performing the coil. \
            \ Cost-equivalent to C_Coil's billed cumulator (same IGNIS; output list \
            \ mirrors the exec [c-rbt-amount])."
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                ;;
                (coil-data:object{AutostakeV4.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                )
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt coiler ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME coiler c-rbt-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
        )
    )
    (defun URCi_CoilTo:object{IgnisCollectorV4.OutputCumulator}
        (funder:string recipient:string ats:string rt:string amount:decimal)
        @doc "Cost preview for <XB_Coil>: the same Concatenate[transfer, mint, transfer] as \
            \ <URCi_Coil>, but with the two transfer ENDPOINTS kept apart. \
            \ \
            \ IT EXISTS BECAUSE <URCi_Coil> CANNOT BE REUSED, and the reason is a bug that was just \
            \ fixed one module over. A transfer's IGNIS class is chosen by <URC_TransferClasses>, \
            \ which reaches <URC_IzSimpleTransfer> and reads \
            \ `(UR_AccountRoleFeeExemption id receiver)` -- so the price depends on WHICH ACCOUNTS \
            \ the transfer runs between. <URCi_Coil> names <coiler> on both legs; quoting a coil \
            \ that funds from AQP|SC_NAME and credits a beneficiary through it would price both \
            \ legs against the wrong account. \
            \ \
            \ That is exactly the shape of the five-site patron/collector defect in 04_RPS.pact \
            \ (2026-10-29), where every cost mirror named the payer where the execution paid the \
            \ beneficiary, and was latent only because the two were the same account in a \
            \ self-collect. Reward eviction makes them NEVER the same, so this reader takes both."
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                ;;
                (coil-data:object{AutostakeV4.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                )
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt funder ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME recipient c-rbt-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
        )
    )
    (defun URCi_Curl:object{IgnisCollectorV4.OutputCumulator}
        (curler:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Cost preview for C_Curl (flavor-B composer): two chained coils across \
            \ ats1/ats2, re-derived purely via sub-op cost readers (no writes). \
            \ Cost-equivalent to C_Curl's billed cumulator; output mirrors [c-rbt2-amount]."
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                ;;
                (coil1-data:object{AutostakeV4.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                (coil2-data:object{AutostakeV4.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                )
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt curler ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt1 ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt2 ATS|SC_NAME false)
                )
                (ico4:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt2 ATS|SC_NAME curler c-rbt2-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [c-rbt2-amount])
        )
    )
    ;;
    (defun URCi_ColdRecovery:object{IgnisCollectorV4.OutputCumulator}
        (recoverer:string ats:string ra:decimal)
        @doc "Cost preview for C_ColdRecovery: flat 2x-biggest construct + cold-transfer \
            \ + cold-burn + (unlimited-uncoil when position=-1) + (fee-leg burns when a \
            \ non-redirected c-rbt fee exists). Re-derived purely via URC_ reads + sub-op \
            \ cost readers; the exec fold's XE_UpdateRUR side-writes don't affect cost."
        ;;The exec's OWN state guard, called rather than re-typed -- UEV_ColdRecoveryState is the very
        ;;function ATSU|C>COLD_RECOVERY uses, so the refusal is identical by construction and
        ;;cannot drift. It must precede the binding group below: Pact evaluates every binding in a
        ;;group before the body, and those bindings read state that does not exist for a pair in
        ;;this condition. Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001d>>.
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-ATS::UEV_ColdRecoveryState ats true)
        )
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra recoverer))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (c-rbt-precision:integer (ref-DPTF::UR_Decimals c-rbt))
                (fee-promile:decimal (ref-ATS::URCv_ColdRecoveryFee ats ra usable-cold-recovery-position))
                (c-rbt-fee-split:[decimal] (ref-U|ATS::UC_PromilleSplit fee-promile ra c-rbt-precision))
                (c-rbt-fee:decimal (at 1 c-rbt-fee-split))
                (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_ColdRecovery" "usage"))
                ;;
                (ico0:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                )
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (if (!= usable-cold-recovery-position -1)
                        EOC
                        (URCi_UnlimitedUncoilCumulator ats recoverer)
                    )
                )
                (ico4:object{IgnisCollectorV4.OutputCumulator}
                    (if (= c-rbt-fee 0.0)
                        EOC
                        (if c-fr
                            EOC
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                (map
                                    (lambda (idx:integer)
                                        (ref-DPTF::URCi_Burn (at idx rt-lst) ATS|SC_NAME)
                                    )
                                    (enumerate 0 (- (length rt-lst) 1))
                                )
                                []
                            )
                        )
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2 ico3 ico4] [])
        )
    )
    (defun URCi_Cull:object{IgnisCollectorV4.OutputCumulator}
        (culler:string ats:string)
        @doc "Cost preview for C_Cull: flat 2x-biggest construct + one transfer per \
            \ reward-token whose cumulative cull weight is nonzero. Cull weights are \
            \ derived purely via URC_MultiCull/URC_SingleCull (the same values the exec \
            \ XI_*Cull writers return), so this is output-exact, not just cost-equivalent."
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (c0:[decimal] (at "summed-culled-values" (URC_MultiCull ats culler)))
                (c1:[decimal] (URC_SingleCull ats culler 1))
                (c2:[decimal] (URC_SingleCull ats culler 2))
                (c3:[decimal] (URC_SingleCull ats culler 3))
                (c4:[decimal] (URC_SingleCull ats culler 4))
                (c5:[decimal] (URC_SingleCull ats culler 5))
                (c6:[decimal] (URC_SingleCull ats culler 6))
                (c7:[decimal] (URC_SingleCull ats culler 7))
                (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                ;;
                (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_Cull" "usage"))
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                )
                (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (if (!= (at idx cw) 0.0)
                                (ref-TFT::URCi_Transfer (at idx rt-lst) ATS|SC_NAME culler (at idx cw))
                                EOC
                            )
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] cw)
        )
    )
    ;;
    (defun URCi_HotRecovery:object{IgnisCollectorV4.OutputCumulator}
        (recoverer:string ats:string ra:decimal)
        @doc "Cost preview for C_HotRecovery (flavor-B composer): fixed 3x-biggest \
            \ construct + cold-transfer + cold-burn + hot-mint + hot-transfer, re-derived \
            \ purely via sub-op cost readers. Cost-equivalent to C_HotRecovery."
        ;;THE PREVIEW NEEDS ITS OWN COPY OF THE GUARD, and that is the whole lesson of this repair.
        ;;C_HotRecovery was fixed by hoisting its capability above the binding group -- but this
        ;;reader has its OWN eager `let` with the same two lines, so a QUOTE for a pair with no
        ;;Hot-RBT still died with `No value found in table ouronet-ns.DPOF_DPOF|T|Properties for
        ;;key: |` after the exec path was clean. A preview is what a UI calls before it ever
        ;;submits; it must refuse in the SAME WORDS as the op it previews, not louder and not
        ;;differently. (URC_RBT carries its guard for exactly this reason -- it is shared by both
        ;;paths, so one enforce covered both. Here the two paths do not share a reader, so the
        ;;guard has to be written twice.)
        ;;Pinned by RedTeam/[RT-H]_InputDomain.repl <<RT-H-003f>>.
        ;;Own let for the modref: the guard must run BEFORE the main binding group, and Pact
        ;;evaluates every binding in a group before its body -- so it cannot live in the let below.
        ;;Cross-module calls go through the interface modref (`::`), never `module.function`.
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            ;;ORDER MATTERS FOR PARITY, not just for safety. ATS|C>HOT_RECOVERY checks the
            ;;toggle first and the Hot-RBT second; a preview that checked them the other way round
            ;;refused for a TRUE but DIFFERENT reason than the op would give, which is its own kind
            ;;of lie. Same guards, same order, same message.
            (ref-ATS::UEV_HotRecoveryState ats true)
            (enforce
                (ref-ATS::URC_IzPresentHotRBT ats)
                (format "ATS-Pair {} has no Hot-RBT, so Hot Recovery is impossible" [ats])
            )
        )
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (h-rbt:string (ref-ATS::UR_HotRewardBearingToken ats))
                (new-nonce:integer (+ (ref-DPOF::UR_NoncesUsed h-rbt) 1))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "ATS|C_HotRecovery" "usage")
                        ATS|SC_NAME
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico4:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPOF::URCi_Mint h-rbt)
                )
                (ico5:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator h-rbt [new-nonce] false)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [])
        )
    )
    (defun URCi_Recover:object{IgnisCollectorV4.OutputCumulator}
        (recoverer:string id:string nonce:integer)
        @doc "Cost preview for C_Recover (flavor-B composer): DPOF nonce-transfer + \
            \ DPOF burn + cold-mint + cold-transfer, re-derived purely via sub-op cost \
            \ readers. Cost-equivalent to C_Recover."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator id [nonce] false)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPOF::URCi_Burn id)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico4:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME recoverer nonce-supply)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
        )
    )
    (defun URCi_Redeem:object{IgnisCollectorV4.OutputCumulator}
        (redeemer:string id:string nonce:integer)
        @doc "Cost preview for C_Redeem: DPOF nonce-transfer + DPOF burn + a \
            \ multi-transfer of the decay-earned reward-token split, plus (when a decay \
            \ fee is retained and not redirected) fee-leg burns. Re-derives the decay math \
            \ purely (same as exec); sub-op costs via URCi readers, no writes."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (precision:integer (ref-DPOF::UR_Decimals id))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData id nonce))
                (birth-date:time (at "mint-time" (at 0 meta-data-chain)))
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time birth-date))
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (h-promile:decimal (ref-ATS::UR_HotRecoveryStartingFeePromile ats))
                (h-decay:integer (ref-ATS::UR_HotRecoveryDecayPeriod ats))
                (h-fr:bool (ref-ATS::UR_HotRecoveryFeeRedirection ats))
                (total-time:decimal (* 86400.0 (dec h-decay)))
                (earned-rbt:decimal
                    (if (>= elapsed-time total-time)
                        nonce-supply
                        (floor (* nonce-supply (/ (- 1000.0 (* h-promile (- 1.0 (/ elapsed-time total-time)))) 1000.0)) precision)
                    )
                )
                (earned-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats earned-rbt))
                (total-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats nonce-supply))
                (fee-rts:[decimal] (zip (lambda (x:decimal y:decimal) (- x y)) total-rts earned-rts))
                (have-fee-rts:bool (!= (fold (+) 0.0 fee-rts) 0.0))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator id [nonce] false)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPOF::URCi_Burn id)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator rt-lst ATS|SC_NAME redeemer earned-rts)
                )
                (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                    (if have-fee-rts
                        (map
                            (lambda (idx:integer)
                                (ref-DPTF::URCi_Burn (at idx rt-lst) ATS|SC_NAME)
                            )
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                        [EOC]
                    )
                )
                (ico4:object{IgnisCollectorV4.OutputCumulator}
                    (if (and (not h-fr) (!= earned-rbt nonce-supply))
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                        EOC
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
        )
    )
    ;;
    (defun URCi_DirectRecovery:object{IgnisCollectorV4.OutputCumulator}
        (recoverer:string ats:string ra:decimal)
        @doc "Cost preview for C_DirectRecovery: cold-transfer + cold-burn + a \
            \ multi-transfer of the fee-adjusted reward-token split back to recoverer, \
            \ re-derived purely via sub-op cost readers."
        ;;The exec's OWN state guard, called rather than re-typed -- UEV_DirectRecoveryState is the very
        ;;function ATSU|C>DIRECT_RECOVERY uses, so the refusal is identical by construction and
        ;;cannot drift. It must precede the binding group below: Pact evaluates every binding in a
        ;;group before the body, and those bindings read state that does not exist for a pair in
        ;;this condition. Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001f>>.
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-ATS::UEV_DirectRecoveryState ats true)
        )
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (fee:decimal (ref-ATS::UR_DirectRecoveryFee ats))
                (c-rbt-remainder:decimal
                    (if (= fee 0.0)
                        ra
                        (at 0 (ref-U|ATS::UC_PromilleSplit fee ra (ref-DPTF::UR_Decimals c-rbt)))
                    )
                )
                (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                (release-amounts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats c-rbt-remainder))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator reward-tokens ATS|SC_NAME recoverer release-amounts)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    ;;
    (defun URCi_Syphon:object{IgnisCollectorV4.OutputCumulator}
        (syphon-target:string ats:string syphon-amounts:[decimal])
        @doc "Cost preview for C_Syphon: one transfer per reward-token whose \
            \ syphon-amount is > 0 (EOC for zero legs), mapped purely over the pool's \
            \ reward-token list. Cost-equivalent to C_Syphon."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (if (> (at idx syphon-amounts) 0.0)
                                (ref-TFT::URCi_Transfer (at idx rt-lst) ATS|SC_NAME syphon-target (at idx syphon-amounts))
                                EOC
                            )
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
        )
    )
    (defun URCi_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator}
        (remover:string ats:string reward-token:string)
        @doc "Cost preview for CC_RemoveSecondary — pure re-derivation of its 3-leg concat: one \
            \ ignis|token-issue construct + two full-amount transfers (reward-token in to \
            \ remover, primal-rt out from remover), moving the combined resident+unbound+ \
            \ royalty balance at the removed reward-token position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (remove-position:integer (at 0 (ref-U|LST::UC_Search rt-lst reward-token)))
                (primal-rt:string (at 0 rt-lst))
                (resident-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 1)))
                (unbound-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 2)))
                (royalty-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 3)))
                (remove-sum:decimal (+ (+ resident-sum unbound-sum) royalty-sum))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "ATS|CC_RemoveSecondary" "ats-secondary") ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    (ref-TFT::URCi_Transfer reward-token ATS|SC_NAME remover remove-sum)
                    (ref-TFT::URCi_Transfer primal-rt remover ATS|SC_NAME remove-sum)
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_KickStart:object{IgnisCollectorV4.OutputCumulator}
        (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Shared write path for both the owner (C_KickStart) and administrative \
            \ (A_KickStart) entrypoints (audit finding #11M / M2 fix). All bound and \
            \ authorization checks live in the composed capability chain \
            \ (ATSU|C>X_KICKSTART plus each leaf) - nothing here enforces."
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                ;;
                (rbt-id:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                ;;
                (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV4.OutputCumulator}] idx:integer)
                            (do
                                (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 true (at idx rt-amounts))
                                (ref-U|LST::UC_AppL acc
                                    (ref-TFT::C_Transfer patron kickstarter ATS|SC_NAME (at idx rt-lst) (at idx rt-amounts) true)
                                )
                            )
                        )
                        []
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-DPTF::C_Mint patron ATS|SC_NAME rbt-id rbt-request-amount false)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::C_Transfer patron ATS|SC_NAME kickstarter rbt-id rbt-request-amount true)
                )
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [index])
        )
    )
    ;;Protection: Class 3 — Custom: ATSU|C>DEPLOY
    (defun XI_DeployAccount (ats:string acc:string)
        (require-capability (ATSU|C>DEPLOY ats acc))
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-ATS::XE_SpawnAutostakeAccount ats acc)
            (XI_Normalize ats acc)
        )
    )
    ;;Protection: Class 3 — Custom: ATSU|C>NORMALIZE_LEDGER
    (defun XI_Normalize (ats:string acc:string)
        (require-capability (ATSU|C>NORMALIZE_LEDGER ats acc))
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-ATS:module{AutostakeV4} ATS)
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats acc))
                (p1:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 1))
                (p2:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 2))
                (p3:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 3))
                (p4:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 4))
                (p5:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 5))
                (p6:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 6))
                (p7:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc 7))
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
                (ng:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeNegativeUnstakeObject ats))
                (positions:integer (ref-ATS::UR_ColdRecoveryPositions ats))
                (elite:bool (ref-ATS::UR_EliteMode ats))
                (major-tier:integer (ref-DALOS::UR_Elite-Tier-Major acc))
                ;;
                (p0-znn:[object{UtilityAtsV3.Awo}] (if (and (!= p0 [zr]) (!= p0 [ng])) p0 [ng]))
                (p0-znz:[object{UtilityAtsV3.Awo}] (if (and (!= p0 [zr]) (!= p0 [ng])) p0 [zr]))
                (p1-znn:object{UtilityAtsV3.Awo} (if (and (!= p1 zr) (!= p1 ng)) p1 ng))
                (p1-znz:object{UtilityAtsV3.Awo} (if (and (!= p1 zr) (!= p1 ng)) p1 zr))
                (p2-znn:object{UtilityAtsV3.Awo} (if (and (!= p2 zr) (!= p2 ng)) p2 ng))
                (p2-znz:object{UtilityAtsV3.Awo} (if (and (!= p2 zr) (!= p2 ng)) p2 zr))
                (p3-znn:object{UtilityAtsV3.Awo} (if (and (!= p3 zr) (!= p3 ng)) p3 ng))
                (p3-znz:object{UtilityAtsV3.Awo} (if (and (!= p3 zr) (!= p3 ng)) p3 zr))
                (p4-znn:object{UtilityAtsV3.Awo} (if (and (!= p4 zr) (!= p4 ng)) p4 ng))
                (p4-znz:object{UtilityAtsV3.Awo} (if (and (!= p4 zr) (!= p4 ng)) p4 zr))
                (p5-znn:object{UtilityAtsV3.Awo} (if (and (!= p5 zr) (!= p5 ng)) p5 ng))
                (p5-znz:object{UtilityAtsV3.Awo} (if (and (!= p5 zr) (!= p5 ng)) p5 zr))
                (p6-znn:object{UtilityAtsV3.Awo} (if (and (!= p6 zr) (!= p6 ng)) p6 ng))
                (p6-znz:object{UtilityAtsV3.Awo} (if (and (!= p6 zr) (!= p6 ng)) p6 zr))
                (p7-znn:object{UtilityAtsV3.Awo} (if (and (!= p7 zr) (!= p7 ng)) p7 ng))
                (p7-znz:object{UtilityAtsV3.Awo} (if (and (!= p7 zr) (!= p7 ng)) p7 zr))
                (p2-zne:object{UtilityAtsV3.Awo} (if (and (!= p2 zr) (!= p2 ng)) p2 (if (>= major-tier 2) zr ng)))
                (p3-zne:object{UtilityAtsV3.Awo} (if (and (!= p3 zr) (!= p3 ng)) p3 (if (>= major-tier 3) zr ng)))
                (p4-zne:object{UtilityAtsV3.Awo} (if (and (!= p4 zr) (!= p4 ng)) p4 (if (>= major-tier 4) zr ng)))
                (p5-zne:object{UtilityAtsV3.Awo} (if (and (!= p5 zr) (!= p5 ng)) p5 (if (>= major-tier 5) zr ng)))
                (p6-zne:object{UtilityAtsV3.Awo} (if (and (!= p6 zr) (!= p6 ng)) p6 (if (>= major-tier 6) zr ng)))
                (p7-zne:object{UtilityAtsV3.Awo} (if (and (!= p7 zr) (!= p7 ng)) p7 (if (>= major-tier 7) zr ng)))
                ;;
                (c-pm1:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znz [p1-znn] [p2-znn] [p3-znn] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p1:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znn] [p3-znn] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p2:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znn] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p3:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znn] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p4:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znn] [p6-znn] [p7-znn]]))
                (c-p5:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znz] [p6-znn] [p7-znn]]))
                (c-p6:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znz] [p6-znz] [p7-znn]]))
                (c-ne:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-znz] [p3-znz] [p4-znz] [p5-znz] [p6-znz] [p7-znz]]))
                (c-el:[object{UtilityAtsV3.Awo}] (fold (+) [] [p0-znn [p1-znz] [p2-zne] [p3-zne] [p4-zne] [p5-zne] [p6-zne] [p7-zne]]))

            )
            (cond
                ((= positions -1) (XI_UUP ats acc c-pm1))
                ((= positions 1) (XI_UUP ats acc c-p1))
                ((= positions 2) (XI_UUP ats acc c-p2))
                ((= positions 3) (XI_UUP ats acc c-p3))
                ((= positions 4) (XI_UUP ats acc c-p4))
                ((= positions 5) (XI_UUP ats acc c-p5))
                ((= positions 6) (XI_UUP ats acc c-p6))
                ((not elite) (XI_UUP ats acc c-ne))
                (elite (XI_UUP ats acc c-el))
                true
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XE_UpP0, XE_UpP1, XE_UpP2, XE_UpP3,
    ;;Protection:          XE_UpP4, XE_UpP5, XE_UpP6, XE_UpP7
    (defun XI_UUP (ats:string acc:string data:[object{UtilityAtsV3.Awo}])
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
            )
            (ref-ATS::XE_UpP0 ats acc (drop -7 data))
            (ref-ATS::XE_UpP1 ats acc (at 0 (take 1 (take -7 data))))
            (ref-ATS::XE_UpP2 ats acc (at 0 (take 1 (take -6 data))))
            (ref-ATS::XE_UpP3 ats acc (at 0 (take 1 (take -5 data))))
            (ref-ATS::XE_UpP4 ats acc (at 0 (take 1 (take -4 data))))
            (ref-ATS::XE_UpP5 ats acc (at 0 (take 1 (take -3 data))))
            (ref-ATS::XE_UpP6 ats acc (at 0 (take 1 (take -2 data))))
            (ref-ATS::XE_UpP7 ats acc (at 0 (take -1 data)))
        )
    )
    ;;Enforce: read-and-write-in-one -- <size> is (length p0), and p0 is the list the write is built
    ;;          from. Relocating the bound means re-reading and re-measuring the same list.
    ;;Protection: Class 2 — SECURE
    (defun XIv_StoreUnstakeObject (ats:string acc:string position:integer obj:object{UtilityAtsV3.Awo})
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-ATS:module{AutostakeV4} ATS)
                (p0:[object{UtilityAtsV3.Awo}] (ref-ATS::UR_P0 ats acc))
                (size:integer (length p0))
            )
            
            (if (= position -1)
                (do
                    ;;UNTESTABLE-EXTERNALLY: XIv_StoreUnstakeObject sits behind (require-capability (SECURE)), and SECURE cannot be acquired from outside
                    ;;this module -- so no REPL negative test can reach this line. The guard is LIVE and
                    ;;does real work on the in-module path; it is NOT dead code. Distinguished from
                    ;;the UNREACHABLE marker deliberately: that marker means no input can trip the guard at all.
                    (enforce (< size 250) "Unstake Storage limited to 250 Elements. Cull your list to add more !")
                    (if (and
                            (= size 1)
                            (=
                                (at 0 p0)
                                (ref-ATS::UDC_MakeZeroUnstakeObject ats)
                            )
                        )
                        (ref-ATS::XE_UpP0 ats acc [obj])
                        (ref-ATS::XE_UpP0 ats acc (ref-U|LST::UC_AppL p0 obj))
                    )
                )
                
                (cond
                    ((= position 1) (ref-ATS::XE_UpP1 ats acc obj))
                    ((= position 2) (ref-ATS::XE_UpP2 ats acc obj))
                    ((= position 3) (ref-ATS::XE_UpP3 ats acc obj))
                    ((= position 4) (ref-ATS::XE_UpP4 ats acc obj))
                    ((= position 5) (ref-ATS::XE_UpP5 ats acc obj))
                    ((= position 6) (ref-ATS::XE_UpP6 ats acc obj))
                    ((= position 7) (ref-ATS::XE_UpP7 ats acc obj))
                    true
                )
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_MultiCull:[decimal] (ats:string acc:string)
        (require-capability (SECURE))
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (multi-cull-obj:object (URC_MultiCull ats acc))
                (after-cull:[object{UtilityAtsV3.Awo}] (at "after-cull" multi-cull-obj))
                (culled-values:[[decimal]] (at "culled-values" multi-cull-obj))
                (summed-culled-values:[decimal] (at "summed-culled-values" multi-cull-obj))
            )
            (ref-ATS::XE_UpP0 ats acc after-cull)
            summed-culled-values
        )
    )
    ;;Protection: Class 1 — Innate protection offered by XIv_StoreUnstakeObject
    (defun XI_SingleCull:[decimal] (ats:string acc:string position:integer)
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                ;;
                (cull-output:[decimal] (URC_SingleCull ats acc position))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (l:integer (length rt-lst))
                (empty:[decimal] (make-list l 0.0))
                (zr:object{UtilityAtsV3.Awo} (ref-ATS::UDC_MakeZeroUnstakeObject ats))
            )
            (if (!= cull-output empty)
                (XIv_StoreUnstakeObject ats acc position zr)
                true
            )
            cull-output
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator}
        (patron:string remover:string ats:string reward-token:string)
        @doc "Fix (audit finding #1C / C2): (1) the account list to reshape is ALWAYS derived on-chain \
            \ here via <ATS.URH_ExistingAutostakePairs ats> — never trusted from a caller — so removal can \
            \ no longer skip an account and leave its stored positions desynced from the live reward-token \
            \ list (was C2b/C2c's root enabler). (2) the royalty bucket (RUR 3) is now migrated into the \
            \ primal RT exactly like resident/unbonding (RUR 1/2) — previously it was silently deleted with \
            \ the removed row and permanently stranded in ATS|SC_NAME custody with no reward-token entry \
            \ left to reference it (was C2b). <remove-sum> now covers all three buckets on both transfer \
            \ legs, preserving the existing 1:1 primal-RT buyout design without altering it."
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (ats-sc:string (ref-ATS::GOV|ATS|SC_NAME))
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (remove-position:integer (at 0 (ref-U|LST::UC_Search rt-lst reward-token)))
                (primal-rt:string (at 0 rt-lst))
                (resident-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 1)))
                (unbound-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 2)))
                (royalty-sum:decimal (at remove-position (ref-ATS::UR_RewardTokenRUR ats 3)))
                (remove-sum:decimal (+ (+ resident-sum unbound-sum) royalty-sum))
                ;; Complete, on-chain-derived account list — never trusted from a caller (fix #1C/C2).
                (accounts-with-ats-data:[string] (ref-ATS::URH_ExistingAutostakePairs ats))
                ;;
                (ico1:object{IgnisCollectorV4.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "ATS|CC_RemoveSecondary" "ats-secondary")
                        ATS|SC_NAME
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                (ico2:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::C_Transfer patron ATS|SC_NAME remover reward-token remove-sum true)
                )
                (ico3:object{IgnisCollectorV4.OutputCumulator}
                    (ref-TFT::C_Transfer patron remover ATS|SC_NAME primal-rt remove-sum true)
                )
            )
            ;;1]The RT to be removed, is transfered to the remover, from the ATS|SC_NAME
                ;via ico2
            ;;2]The amount removed (resident + unbonding + royalty) is added back as Primal-RT
                ;via ico3
            ;;3]ROU Table is updated with the new DATA, now as primal RT — all three buckets
            (ref-ATS::XE_UpdateRUR ats primal-rt 1 true resident-sum)
            (ref-ATS::XE_UpdateRUR ats primal-rt 2 true unbound-sum)
            (ref-ATS::XE_UpdateRUR ats primal-rt 3 true royalty-sum)
            ;;4]EVERY client account with ledger data for this pair is reshaped to remove the RT
                ;position and keep balances aligned with the post-removal reward-token list
            (map
                (lambda
                    (kontos:string)
                    (ref-ATS::XE_ReshapeUnstakeAccount ats kontos remove-position)
                )
                accounts-with-ats-data
            )
            ;;5]Actually Remove the RT from the ATS-Pair
            (ref-ATS::XE_RemoveSecondary ats reward-token)
            ;;6]Update Data in the DPTF Token Properties
            (ref-DPTF::XE_UpdateRewardToken ats reward-token false)
            ;;7]Output ICO
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    (defun AA_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant. Fix (audit finding #1C / C2b): <accounts-with-ats-data> is now \
            \ IGNORED — XI_RemoveSecondary always re-derives the complete account list on-chain via \
            \ <ATS.URH_ExistingAutostakePairs ats> itself, so a caller-supplied list can no longer be \
            \ incomplete/stale and silently desync some accounts' stored positions. The parameter is kept \
            \ only for interface-signature compatibility (AutostakeUsageV2 is unchanged); do not rely on \
            \ its contents."
        (P|UEV_IMC)
        (with-capability (ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY executor ats reward-token)
            (XI_RemoveSecondary patron executor ats reward-token)
        )
    )
    (defun A_KickStart:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance (GOV|ATSU_ADMIN); resulting index is only bound by \
            \ the shared 0.1 floor, no ceiling - for legitimate ratios above 100.0. \
            \ \
            \ Executor: ENFORCED INDIRECTLY, by the operation's own first act -- XI_KickStart \
            \ sends the reward tokens with TFT::C_Transfer, where <executor> is the SENDER, so \
            \ DPTF|C>X-TRANSFER -> CAP_EnforceAccountOwnership proves it. \
            \ \
            \ NOTE THE TWO AUTHORITIES, which are easy to conflate: the capability's own \
            \ CAP_Owner (owner path) / GOV|ATSU_ADMIN (admin path) decides WHETHER the pool may \
            \ be kickstarted and says nothing about the executor -- they are different accounts \
            \ and both must sign. <executor> FUNDS it; the pool authority PERMITS it. \
            \ (patron/executor canon 2.2, indirect route named.)"
        (P|UEV_IMC)
        (with-capability (ATSU|C>ADMINISTRATIVE-KICKSTART executor ats rt-amounts rbt-request-amount)
            (XI_KickStart patron executor ats rt-amounts rbt-request-amount)
        )
    )
    (defun CC_RemoveSecondary:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string reward-token:string)
        @doc "Client Variant. XI_RemoveSecondary derives the complete account list itself via \
            \ <ATS.URH_ExistingAutostakePairs ats>."
        (P|UEV_IMC)
        (with-capability (ATSU|C>REMOVE-SECONDARY executor ats reward-token)
            (XI_RemoveSecondary patron executor ats reward-token)
        )
    )
    (defun C_WithdrawRoyalties:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string executee:string ats:string)
        @doc "Fix (audit finding #33N): C_MultiTransfer debits every leg unconditionally - a \
            \ reward-token with a zero accrued royalty (routine whenever a pool has more than \
            \ one registered RT and royalty hasn't accrued evenly across all of them) hit \
            \ DPTF's UEV_Amount (amount > 0.0) enforce and crashed the whole withdrawal. Now \
            \ filters to only the reward-token/royalty legs with a real (> 0.0) balance before \
            \ handing off to C_MultiTransfer - the RUR-reset loop below still zeroes every RT's \
            \ bucket, zero or not, so no accounting is skipped, only the doomed zero-amount leg."
        (P|UEV_IMC)
        (with-capability (ATSU|C>WITHDRAW-ROYALTIES executor executee ats)
            (let
                (
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                    (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                    (nonzero-idx:[integer]
                        (filter
                            (lambda (index:integer) (> (at index royalties) 0.0))
                            (enumerate 0 (- (length reward-tokens) 1))
                        )
                    )
                )
                ;;1]Set Royalties Values back to 0.0 for all RTs
                (map
                    (lambda
                        (index:integer)
                        (ref-ATS::XE_UpdateRUR ats (at index reward-tokens) 3 false (at index royalties))
                    )
                    (enumerate 0 (- (length reward-tokens) 1))
                )
                ;;2]Withdraw Royalties to Target - only the reward-tokens with a nonzero balance
                (ref-TFT::C_MultiTransfer
                    patron
                    ATS|SC_NAME
                    executee
                    (map (lambda (index:integer) (at index reward-tokens)) nonzero-idx)
                    (map (lambda (index:integer) (at index royalties)) nonzero-idx)
                    true
                )
            )
        )
    )
    (defun C_KickStart:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Owner-facing variant. Fix (audit finding #11M / M2): resulting index now \
            \ bounded to [0.1, 100.0] via ATSU|C>KICKSTART / ATSU|C>X_KICKSTART. \
            \ \
            \ Executor: ENFORCED INDIRECTLY, by the operation's own first act -- XI_KickStart \
            \ sends the reward tokens with TFT::C_Transfer, where <executor> is the SENDER, so \
            \ DPTF|C>X-TRANSFER -> CAP_EnforceAccountOwnership proves it. \
            \ \
            \ NOTE THE TWO AUTHORITIES, which are easy to conflate: the capability's own \
            \ CAP_Owner (owner path) / GOV|ATSU_ADMIN (admin path) decides WHETHER the pool may \
            \ be kickstarted and says nothing about the executor -- they are different accounts \
            \ and both must sign. <executor> FUNDS it; the pool authority PERMITS it. \
            \ (patron/executor canon 2.2, indirect route named.)"
        (P|UEV_IMC)
        (with-capability (ATSU|C>KICKSTART executor ats rt-amounts rbt-request-amount)
            (XI_KickStart patron executor ats rt-amounts rbt-request-amount)
        )
    )
    (defun C_Fuel:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string reward-token:string amount:decimal)
        @doc "Fuels an <ats> ATS-Pair, increasing it Index."
        (P|UEV_IMC)
        (let
            (
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
            )
            (with-capability (ATSU|C>FUEL ats reward-token)
                (ref-ATS::XE_UpdateRUR ats reward-token 1 true amount)
                (ref-TFT::C_Transfer patron executor ATS|SC_NAME reward-token amount true)
            )
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ATSU|C>COIL
    (defun XB_Coil:object{IgnisCollectorV4.OutputCumulator}
        (patron:string funder:string recipient:string ats:string rt:string amount:decimal)
        @doc "Autostakes <amount> of <rt> on <ats>, FUNDED BY <funder> and CREDITED TO <recipient>. \
            \ <C_Coil> is this with the two roles collapsed onto one account. \
            \ \
            \ WHY THE ROLES HAD TO SPLIT, 2026-10-29. A coil's first leg is a transfer OUT of the \
            \ coiler, so <TFT::C_Transfer> enforces account ownership on it. That is right for a \
            \ user coiling their own tokens, and it makes the AQP triplet reward ladder reachable \
            \ ONLY by the beneficiary -- the collect path coils as <collector>, which works solely \
            \ because the beneficiary is the one signing. Reward EVICTION has no such signature: \
            \ the FVT owner triggers it for somebody else. \
            \ \
            \ So the ladder now coils as <AQP|SC_NAME> -- whose ownership the AQP remote-governor \
            \ guard satisfies -- and credits the beneficiary directly. ONE core serves both collect \
            \ and evict, which is the whole point: a second ladder would be a fourth copy of a \
            \ computation this tree already warns is drifting (see URC_CollectLadderPreview). \
            \ \
            \ AMOUNTS ARE UNAFFECTED, which is what makes the two paths comparable. <c-rbt-amount> \
            \ is a pure function of (ats, rt, amount) through URC_RewardBearingTokenAmounts, and \
            \ <XE_UpdateRUR> takes no account, so no per-account ATS state depends on who coiled. \
            \ Only the transfer ENDPOINTS move. \
            \ \
            \ MODELLED ON <OUROBOROS::XB_Compress>, which exists for the identical reason: its own \
            \ doc says it omits the standard-account restriction 'so a SMART account (e.g. \
            \ AQP|SC_NAME custody) may normalize an IGNIS royalty leg'. P|UEV_IMC gates the caller \
            \ module; the <funder>'s transfer is authorized by whatever capability that caller holds \
            \ for it."
        (P|UEV_IMC)
        (with-capability (ATSU|C>COIL ats rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    ;;
                    ;;<ats>
                    (coil-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                    )
                    (input-amount:decimal (at "first-input-amount" coil-data))
                    (royalty-fee:decimal (at "royalty-fee" coil-data))
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        (ref-TFT::C_Transfer patron funder ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt c-rbt-amount false)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        (ref-TFT::C_Transfer patron ATS|SC_NAME recipient c-rbt c-rbt-amount true)
                    )
                )
                (ref-ATS::XE_UpdateRUR ats rt 1 true input-amount)
                (if (!= royalty-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats rt 3 true royalty-fee)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
            )  
        )
    )
    (defun C_Coil:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string rt:string amount:decimal)
        @doc "Autostakes an <rt> Token on <ats> ATS-Pair. \
            \ If Hibernate is on, retains the <c-rbt-amount>, which will then be hibernated \
            \ from the TALOS module, and sent as Hibernated H| Token to the <executor> \
            \ \
            \ \
            \ KEPT ITS OWN BODY, and the first attempt at this made it delegate to <XB_Coil>. That \
            \ was reverted on the evidence: `_ignis_price_sheet.py` reconstructs an op's price by \
            \ walking its body, and with the three legs moved behind an XB_ the generated sheet \
            \ re-quoted this op from `>= 93` (floor, 'composes other client ops') to `87` claimed \
            \ EXACT -- dropping both transfer legs and asserting a precision it does not have. \
            \ <URCi_Coil> settles which figure is true: it re-derives Transfer + Mint + Transfer and \
            \ says it is 'cost-equivalent to C_Coil's billed cumulator (same IGNIS)'. So 93 was \
            \ faithful and the delegation degraded a gate-enforced artefact. \
            \ \
            \ The duplication that buys back is three legs of boilerplate -- NOT the reward-ladder \
            \ arithmetic, which was the thing worth refusing to copy. It is converted into a pinned \
            \ equivalence instead: <XB_Coil> with funder == recipient must produce the identical \
            \ cumulator and the identical balance deltas as this function."
        (P|UEV_IMC)
        (with-capability (ATSU|C>COIL ats rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    ;;
                    ;;<ats>
                    (coil-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                    )
                    (input-amount:decimal (at "first-input-amount" coil-data))
                    (royalty-fee:decimal (at "royalty-fee" coil-data))
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        (ref-TFT::C_Transfer patron executor ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt c-rbt-amount false)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        (ref-TFT::C_Transfer patron ATS|SC_NAME executor c-rbt c-rbt-amount true)
                    )
                )
                (ref-ATS::XE_UpdateRUR ats rt 1 true input-amount)
                (if (!= royalty-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats rt 3 true royalty-fee)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
            )  
        )
    )
    (defun C_Curl:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Coils through 2 ATS-Pairs, outputting the <c-rbt2> to the <executor> \
            \ Both <ats1> and <ats2> must have <hibernation> off"
        (P|UEV_IMC)
        (with-capability (ATSU|C>CURL ats1 ats2 rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    ;;
                    ;;<ats1>
                    (coil1-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                    )
                    (input1-amount:decimal (at "first-input-amount" coil1-data))
                    (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                    (c-rbt1:string (at "rbt-id" coil1-data))
                    (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                    ;;
                    ;;<ats2>
                    (coil2-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                    )
                    (input2-amount:decimal (at "first-input-amount" coil2-data))
                    (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                    (c-rbt2:string (at "rbt-id" coil2-data))
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        (ref-TFT::C_Transfer patron executor ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt1 c-rbt1-amount false)
                    )
                    (ico3:object{IgnisCollectorV4.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt2 c-rbt2-amount false)
                    )
                    (ico4:object{IgnisCollectorV4.OutputCumulator}
                        (ref-TFT::C_Transfer patron ATS|SC_NAME executor c-rbt2 c-rbt2-amount true)
                    )
                )
                (ref-ATS::XE_UpdateRUR ats1 rt 1 true input1-amount)
                (ref-ATS::XE_UpdateRUR ats2 c-rbt1 1 true input2-amount)
                (if (!= royalty1-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats1 rt 3 true royalty1-fee)
                    true
                )
                (if (!= royalty2-fee 0.0)
                    (ref-ATS::XE_UpdateRUR ats2 c-rbt1 3 true royalty2-fee)
                    true
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [c-rbt2-amount])
            )
        )
    )
    (defun C_ColdRecovery:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string ra:decimal)
        (P|UEV_IMC)
        (with-capability (ATSU|C>DEPLOY ats executor)
            (XI_DeployAccount ats executor)
            (let
                (
                    (ref-ATS:module{AutostakeV4} ATS)
                    (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra executor))
                )
                (enforce (!= usable-cold-recovery-position 0) "Cold Recovery Unavailable! All existing Positions are used!")
                (with-capability (ATSU|C>COLD_RECOVERY executor ats ra usable-cold-recovery-position)
                    (let
                        (
                            (ref-U|LST:module{StringProcessorV2} U|LST)
                            (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                            (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                            (ref-TFT:module{TrueFungibleTransferV3} TFT)
                            ;;
                            (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                            (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                            (c-rbt-precision:integer (ref-DPTF::UR_Decimals c-rbt))
                            (fee-promile:decimal (ref-ATS::URCv_ColdRecoveryFee ats ra usable-cold-recovery-position))
                            (c-rbt-fee-split:[decimal] (ref-U|ATS::UC_PromilleSplit fee-promile ra c-rbt-precision))
                            (c-rbt-remainder:decimal (at 0 c-rbt-fee-split))
                            (c-rbt-fee:decimal (at 1 c-rbt-fee-split))
                            ;;
                            (positive-c-fr:[decimal]
                                ;;For true <c-fr>
                                ;:Remainder
                                (ref-ATS::URCv_RTSplitAmounts ats c-rbt-remainder)
                            )
                            (ng-c-fr:[decimal]
                                ;For false <c-fre>
                                ;Fee-Part
                                (ref-ATS::URCv_RTSplitAmounts ats c-rbt-fee)
                            )
                            ;;
                            (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_ColdRecovery" "usage"))
                            (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                            ;;

                            (ico0:object{IgnisCollectorV4.OutputCumulator}
                                ;;10 Flat IGNIS cost for Cold Recovery
                                (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME trigger [])
                            )
                            (ico1:object{IgnisCollectorV4.OutputCumulator}
                                (ref-TFT::C_Transfer patron executor ATS|SC_NAME c-rbt ra true)
                            )
                            (ico2:object{IgnisCollectorV4.OutputCumulator}
                                (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                            )
                            ;;
                            (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                            (cull-time:time (ref-ATS::URC_CullColdRecoveryTime ats executor))
                            ;;
                            (ico3:object{IgnisCollectorV4.OutputCumulator}
                                (if (!= usable-cold-recovery-position -1)
                                    EOC
                                    (URCi_UnlimitedUncoilCumulator ats executor)
                                )
                            )
                            (ico4:object{IgnisCollectorV4.OutputCumulator}
                                ;;Handle the Fee Part
                                (if (= c-rbt-fee 0.0)
                                    EOC
                                    (if c-fr
                                        EOC
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                            (fold
                                                (lambda
                                                    (acc:[object{IgnisCollectorV4.OutputCumulator}] idx:integer)
                                                    (do
                                                        (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx ng-c-fr))
                                                        (ref-U|LST::UC_AppL acc 
                                                            (ref-DPTF::C_Burn patron ATS|SC_NAME (at idx rt-lst) (at idx ng-c-fr))
                                                        )
                                                    )
                                                )
                                                []
                                                (enumerate 0 (- (length rt-lst) 1))
                                            )
                                            []
                                        )
                                    )
                                )
                            )
                        )
                        ;;Handle The Remainder
                        (map
                            (lambda
                                (index:integer)
                                (ref-ATS::XE_UpdateRUR ats (at index rt-lst) 2 true (at index positive-c-fr))
                                (ref-ATS::XE_UpdateRUR ats (at index rt-lst) 1 false (at index positive-c-fr))
                            )
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                        (XIv_StoreUnstakeObject ats executor usable-cold-recovery-position
                            { "reward-tokens"   : positive-c-fr
                            , "cull-time"       : cull-time}
                        )
                        (XI_Normalize ats executor)
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2 ico3 ico4] [])
                    )
                )
            )
        )
    )
    (defun C_Cull:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string)
        (P|UEV_IMC)
        (with-capability (ATSU|C>CULL executor ats)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (c0:[decimal] (XI_MultiCull ats executor))
                    (c1:[decimal] (XI_SingleCull ats executor 1))
                    (c2:[decimal] (XI_SingleCull ats executor 2))
                    (c3:[decimal] (XI_SingleCull ats executor 3))
                    (c4:[decimal] (XI_SingleCull ats executor 4))
                    (c5:[decimal] (XI_SingleCull ats executor 5))
                    (c6:[decimal] (XI_SingleCull ats executor 6))
                    (c7:[decimal] (XI_SingleCull ats executor 7))
                    (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                    (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                    ;;
                    (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_Cull" "usage"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    ;;
                    (ico1:object{IgnisCollectorV4.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME trigger [])
                    )
                    (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV4.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL acc
                                    (if (!= (at idx cw) 0.0)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 2 false (at idx cw))
                                            (ref-TFT::C_Transfer patron ATS|SC_NAME executor (at idx rt-lst) (at idx cw) true)
                                        )
                                        EOC
                                    )
                                )
                            )
                            []
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                    )
                    (ico2:object{IgnisCollectorV4.OutputCumulator}
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                    )
                )
                (XI_Normalize ats executor)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] cw)
            )
        )
    )
    (defun C_HotRecovery:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string ra:decimal)
        (P|UEV_IMC)
        ;;THE CAPABILITY IS ACQUIRED BEFORE THE `let`, and that ordering is load-bearing -- the same
        ;;repair C_Recover received on 2026-09-12, for the same reason, twenty lines below.
        ;;`UR_HotRewardBearingToken` returns the BAR sentinel for a pair with no Hot-RBT (nine of
        ;;the fifteen live pairs), and the `new-nonce` binding then read the DPOF properties table
        ;;keyed by "|", dying with `No value found in table ouronet-ns.DPOF_DPOF|T|Properties for
        ;;key: |` before any guard in ATS|C>HOT_RECOVERY could run. All three cap arguments are
        ;;plain defun parameters, so hoisting costs nothing and is the shape StoicSyntax asks for:
        ;;validation in the defcap, work in the body.
        ;;Pinned by RedTeam/[RT-H]_InputDomain.repl <<RT-H-003c>>/<<RT-H-003e>>.
        (with-capability (ATS|C>HOT_RECOVERY executor ats ra)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (h-rbt:string (ref-ATS::UR_HotRewardBearingToken ats))
                (present-time:time (at "block-time" (chain-data)))
                (meta-data-obj:object{AutostakeV4.ATS|Hot} {"mint-time" : present-time})
                (new-nonce:integer (+ (ref-DPOF::UR_NoncesUsed h-rbt) 1))
                ;;
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV4.OutputCumulator}
                            (ref-IGNIS::UDC_ConstructOutputCumulator 
                                (ref-IGNIS::UC_IgnisPrice "ATS|C_HotRecovery" "usage")
                                ATS|SC_NAME
                                (ref-IGNIS::URC_IsVirtualGasZero)
                                []
                            )
                        )
                        (ico2:object{IgnisCollectorV4.OutputCumulator}
                            (ref-TFT::C_Transfer patron executor ATS|SC_NAME c-rbt ra true)
                        )
                        (ico3:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                        )
                        (ico4:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPOF::C_Mint patron ATS|SC_NAME h-rbt ra [meta-data-obj])
                        )
                        (ico5:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPOF::C_Transfer patron ATS|SC_NAME executor h-rbt [new-nonce] true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [])
                )
        )
        )
    )
    (defun C_Recover:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string nonce:integer)
        (P|UEV_IMC)
        ;;THE CAPABILITY IS ACQUIRED BEFORE THE `let`, and that ordering is load-bearing.
        ;;FIXED 2026-09-12: it used to sit INSIDE the let body, so the eager binding group ran first
        ;;-- and for a token that is not reward-bearing `UR_RewardBearingToken` returns the BAR
        ;;sentinel, so the next binding looked up ATS pair `|` and died with
        ;;`No value found in table ouronet-ns.ATS_ATS|Pairs for key: |`. The cap's own
        ;;`(enforce iz-rbt "Invalid Hot-RBT")` -- written for exactly that input -- was never reached.
        ;;Both cap arguments are plain defun parameters, so hoisting costs nothing, and it is also the
        ;;shape StoicSyntax asks for: validation in the defcap, work in the body.
        (with-capability (ATS|C>RECOVER executor id nonce)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPOF::C_Transfer patron executor ATS|SC_NAME id [nonce] true)
                        )
                        (ico2:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPOF::C_Burn patron ATS|SC_NAME id nonce nonce-supply)
                        )
                        (ico3:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt nonce-supply false)
                        )
                        (ico4:object{IgnisCollectorV4.OutputCumulator}
                            (ref-TFT::C_Transfer patron ATS|SC_NAME executor c-rbt nonce-supply true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
                )
            )
        )
    )
    (defun C_Redeem:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string id:string nonce:integer)
        (P|UEV_IMC)
        ;;CAPABILITY BEFORE THE `let` -- same fix as C_Recover above, same cause.
        ;;FIXED 2026-09-12: it used to sit inside the let body, and the eager binding group reads
        ;;`(ats (UR_RewardBearingToken id))` then immediately `(rt-lst (UR_RewardTokenList ats))`.
        ;;For a token that is not reward-bearing `ats` is the BAR sentinel, so that second read looks
        ;;up ATS pair `|` and aborts before the cap can raise its own "Invalid Hot-RBT". Both cap
        ;;arguments are plain defun parameters, so the hoist is free.
        (with-capability (ATSU|C>REDEEM executor id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                (ref-ATS:module{AutostakeV4} ATS)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (precision:integer (ref-DPOF::UR_Decimals id))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData id nonce))
                ;;
                (birth-date:time (at "mint-time" (at 0 meta-data-chain)))
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time birth-date))
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (h-promile:decimal (ref-ATS::UR_HotRecoveryStartingFeePromile ats))
                (h-decay:integer (ref-ATS::UR_HotRecoveryDecayPeriod ats))
                (h-fr:bool (ref-ATS::UR_HotRecoveryFeeRedirection ats))
                ;;
                (total-time:decimal (* 86400.0 (dec h-decay)))
                (end-time:time (add-time birth-date (hours (* 24 h-decay))))
                (earned-rbt:decimal
                    (if (>= elapsed-time total-time)
                        nonce-supply
                        (floor (* nonce-supply (/ (- 1000.0 (* h-promile (- 1.0 (/ elapsed-time total-time)))) 1000.0)) precision)
                    )
                )
                (total-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats nonce-supply))
                (earned-rts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats earned-rbt))
                (fee-rts:[decimal] (zip (lambda (x:decimal y:decimal) (- x y)) total-rts earned-rts))
                (are-fee-rts:decimal (fold (+) 0.0 fee-rts))
                ;; Fix (audit finding #3C / C3): `are-fee-rts` is a summed :decimal fee amount, not a
                ;; predicate — feeding it straight into `if` (which requires :bool) made every call to
                ;; C_Redeem revert unconditionally, regardless of input (confirmed: Pact does not coerce
                ;; a decimal to bool either way, 0.0 included). `have-fee-rts` is the real boolean gate:
                ;; true only when the decay fee actually took a nonzero slice off the redemption.
                (have-fee-rts:bool (!= are-fee-rts 0.0))
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPOF::C_Transfer patron executor ATS|SC_NAME id [nonce] true)
                        )
                        (ico2:object{IgnisCollectorV4.OutputCumulator}
                            (ref-DPOF::C_Burn patron ATS|SC_NAME id nonce nonce-supply)
                        )
                        (ico3:object{IgnisCollectorV4.OutputCumulator}
                            (ref-TFT::C_MultiTransfer patron ATS|SC_NAME executor rt-lst earned-rts true)
                        )
                        (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                            (if have-fee-rts
                                (fold
                                    (lambda
                                        (acc:[object{IgnisCollectorV4.OutputCumulator}] idx:integer)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx fee-rts))
                                            (ref-U|LST::UC_AppL acc
                                                (ref-DPTF::C_Burn patron ATS|SC_NAME (at idx rt-lst) (at idx fee-rts))
                                            )
                                        )
                                    )
                                    []
                                    (enumerate 0 (- (length rt-lst) 1))
                                )
                                [EOC]
                            )
                        )
                        (ico4:object{IgnisCollectorV4.OutputCumulator}
                            (if (and (not h-fr) (!= earned-rbt nonce-supply))
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                                EOC
                            )
                        )
                    )
                    (map
                        (lambda
                            (idx:integer)
                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx earned-rts))
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
                )
            )
        )
    )
    (defun C_DirectRecovery:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string ats:string ra:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|C>DIRECT_RECOVERY executor ats ra)
            (let
                (
                    (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                    (fee:decimal (ref-ATS::UR_DirectRecoveryFee ats))
                    (c-rbt-remainder:decimal
                        (if (= fee 0.0)
                            ra
                            (at 0 (ref-U|ATS::UC_PromilleSplit fee ra (ref-DPTF::UR_Decimals c-rbt)))
                        )
                    )
                    (reward-tokens:[string] (ref-ATS::UR_RewardTokenList ats))
                    (release-amounts:[decimal] (ref-ATS::URCv_RTSplitAmounts ats c-rbt-remainder))
                )
                ;;0]Update ATS Data
                (map
                    (lambda
                        (index:integer)
                        (ref-ATS::XE_UpdateRUR ats (at index rt-lst) 1 false (at index release-amounts))
                    )
                    (enumerate 0 (- (length reward-tokens) 1))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                    [
                        ;;1]Transfer c-rbt to ATS|SC_NAME
                        (ref-TFT::C_Transfer patron executor ATS|SC_NAME c-rbt ra true)
                        ;;2]Burn it
                        (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                        ;;3]Release equivalnet RTs (minus fee)
                        (ref-TFT::C_MultiTransfer patron ATS|SC_NAME executor reward-tokens release-amounts true)
                    ] 
                    []
                )
            )
        )
    )
    (defun C_Syphon:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string executee:string ats:string syphon-amounts:[decimal])
        (P|UEV_IMC)
        (with-capability (ATSU|C>SYPHON executor ats syphon-amounts)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TFT:module{TrueFungibleTransferV3} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (folded-obj:[object{IgnisCollectorV4.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV4.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL acc
                                    (if (> (at idx syphon-amounts) 0.0)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx syphon-amounts))
                                            (ref-TFT::C_Transfer patron ATS|SC_NAME executee (at idx rt-lst) (at idx syphon-amounts) true)
                                        )
                                        EOC
                                    )

                                )
                            )
                            []
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                    )
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
            )
        )
    )

)

;; --- tables for 10_ATSU.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact ===============
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; OuroborosV3: already deployed and unchanged -- see LIVE_INTERFACES

;;
(module OUROBOROS GOV
    @doc "OUROBOROS — the OURO token / exchange core at the top of the Stage 1 stack, \
        \ implementing OuroborosV2. It compresses IGNIS gas into OURO and sublimates OURO \
        \ back out (C_Compress, C_Sublimate/C_SublimateV2), fuels the liquid Stoa index, \
        \ projects the Stoa liquindex and withdraws fees (C_Fuel, C_WithdrawFees). It acts \
        \ as the protocol's gas-to-token sink and treasury exchange."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements OuroborosV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_ORBR                               (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_ORBR                               (keyset-ref-guard ORBR|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ORBR_ADMIN)))
    (defcap GOV|ORBR_ADMIN ()
        (enforce-one
            "ORBR Admin not satisfed"
            [
                (enforce-guard GOV|MD_ORBR)
                (enforce-guard GOV|SC_ORBR)
            ]
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|OuroborosKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|OuroborosKey)
        )
    )
    (defun GOV|ORBR|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::GOV|OUROBOROS|SC_NAME)
        )
    )
    (defun GOV|ORBR|SC_STOA-NAME ()                     (create-principal (GOV|ORBR|GUARD)))
    (defun GOV|ORBR|GUARD ()                            (create-capability-guard (ORBR|NATIVE-AUTOMATIC)))

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
    (defcap P|ORBR|CALLER ()
        true
    )
    (defcap P|DALOS|REMOTE-GOV ()
        @doc "Dalos Remote Governor Capability"
        true
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
        (with-capability (GOV|ORBR_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ORBR_ADMIN)
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
        (with-capability (GOV|ORBR_ADMIN)
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
        (with-capability (GOV|ORBR_ADMIN)
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
                (ref-P|BRD:module{OuronetPolicyV2} BRD)
                (ref-P|DPTF:module{OuronetPolicyV2} DPTF)
                ;(ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|TFT:module{OuronetPolicyV2} TFT)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (mg:guard (create-capability-guard (P|ORBR|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "ORBR|RemoteDalosGov"
                (create-capability-guard (P|DALOS|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst ORBR|SC_KEY                               (GOV|OuroborosKey))
    (defconst ORBR|SC_NAME                              (GOV|ORBR|SC_NAME))
    (defconst ORBR|SC_STOA-NAME                         (GOV|ORBR|SC_STOA-NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap ORBR|GOV ()
        @doc "Governor Capability for the Ouroboros Smart DALOS Account"
        true
    )
    (defcap ORBR|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <kadena-konto> of OUROBOROS Smart Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap LIQUIDFUEL|C>ADMIN_FUEL ()
        @event
        (compose-capability (ORBR|GOV))
        (compose-capability (ORBR|NATIVE-AUTOMATIC))
        (compose-capability (P|ORBR|CALLER))
    )
    (defcap IGNIS|C>SUBLIMATE (client:string target:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (compose-capability (IGNIS|C>CONVERT client))
            (compose-capability (P|DALOS|REMOTE-GOV))
        )
    )
    (defcap IGNIS|C>COMPRESS (client:string)
        @event
        (compose-capability (IGNIS|C>CONVERT client))
    )
    (defcap IGNIS|C>CONVERT(client:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountType client false)
            (UEV_Exchange)
            (compose-capability (ORBR|GOV))
            (compose-capability (P|ORBR|CALLER))
        )
    )
    (defcap IGNIS|XB>COMPRESS (client:string)
        @doc "SC-account-tolerant compress authorization for INTERNAL module callers (registered OUROBOROS IMC — \
            \ e.g. AQP-FVT normalizing an IGNIS royalty leg to OURO before disposal). Same conversion as \
            \ IGNIS|C>COMPRESS but WITHOUT the standard-account restriction; the caller-module IMC gate (P|UEV_IMC in \
            \ XB_Compress) is the trust boundary."
        (compose-capability (IGNIS|XB>CONVERT client))
    )
    (defcap IGNIS|XB>CONVERT (client:string)
        (UEV_Exchange)
        (compose-capability (ORBR|GOV))
        (compose-capability (P|ORBR|CALLER))
    )
    (defcap OUROBOROS|C>WITHDRAW (executor:string id:string target:string)
        @doc "ATTRIBUTION (patron/executor canon 2.2, 2026-09-21). HANDOFF 4g, fifth instance: \
            \ <CAP_Owner id> proved the AUTHORITY -- the token owner may empty the fee purse -- \
            \ while the only account in the signature was <target>, the RECIPIENT. Authority \
            \ proven, actor unrecorded. <UEV_ExecutorIsKonto> supplies the missing half and the \
            \ ownership enforce is KEPT, not replaced: one proves the right exists, the other \
            \ proves who exercised it."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (ref-DPTF::CAP_Owner id)
            (ref-DPTF::UEV_ExecutorIsKonto executor id)
            (compose-capability (ORBR|GOV))
            (compose-capability (P|ORBR|CALLER))
        )
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
    (defun CT_EmptyCumulator ()
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_ProjectedStoaLiquindex:[decimal] ()
        @doc "Computes the Projected STOA Liquindex, considering STOA amount in reserves ready to be used as Fuel"
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATS:module{AutostakeV4} ATS)
                (orb-sc ORBR|SC_NAME)
                (present-stoa-balance:decimal (ref-coin::get-balance (ref-DALOS::UR_AccountStoa orb-sc)))
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
                (w-stoa-as-rt:[string] (ref-DPTF::UR_RewardToken w-stoa))
                (liquid-idx:string (at 0 w-stoa-as-rt))
                (present-index-value:decimal (ref-ATS::URC_Index liquid-idx))

                (p:integer (ref-ATS::UR_IndexDecimals liquid-idx))
                (rs:decimal (ref-ATS::URC_ResidentSum liquid-idx))
                (projected-sum:decimal (+ rs present-stoa-balance))
                (rbt-supply:decimal (ref-ATS::URC_PairRBTSupply liquid-idx))
                (projected-index-value:decimal
                    (if
                        (= rbt-supply 0.0)
                        -1.0
                        (floor (/ projected-sum rbt-supply) p)
                    )
                )
            )
            [present-index-value projected-index-value present-stoa-balance]
        )
    )
    (defun URCv_Compress:[decimal] (ignis-amount:decimal)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
            )
            (enforce (= (floor ignis-amount 0) ignis-amount) "Only whole Units of GAS(Ignis) can be compressed")
            (enforce (>= ignis-amount 1.00) "Only amounts greater than or equal to 1.0 can be used to compress gas")
            (ref-DPTF::UEV_Amount (ref-DALOS::UR_IgnisID) ignis-amount)
            (let
                (
                    (ouro-id:string (ref-DALOS::UR_OuroborosID))
                    (ouro-price:decimal (ref-DALOS::UR_OuroborosPrice))
                    (ouro-price-used:decimal (if (<= ouro-price 1.00) 1.00 ouro-price))
                    (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                    (raw-ouro-amount:decimal (floor (/ ignis-amount (* ouro-price-used 100.0)) ouro-precision))
                    (promile-split:[decimal] (ref-U|ATS::UC_PromilleSplit 15.0 raw-ouro-amount ouro-precision))
                    (ouro-remainder-amount:decimal (floor (at 0 promile-split) ouro-precision))
                    (ouro-fee-amount:decimal (at 1 promile-split))
                )
                [ouro-remainder-amount ouro-fee-amount]
            )
        )
    )
    (defun URCv_Sublimate:decimal (ouro-amount:decimal)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
            )
            ;;NOTE: the constant is 0.99, not the 1.0 the message advertises. Pinned AS WRITTEN
            ;;in REPL/modules/OUROBOROS.repl <<ORBR-G1>> (0.99 accepted, 0.98 refused) so the
            ;;test states what the code does rather than what the text claims. Left as-is: the
            ;;tolerance is deliberate (it absorbs a floor() at the caller), but the message is
            ;;misleading and should say 0.99 the next time this interface is bumped.
            (enforce (>= ouro-amount 0.99) "Only amounts greater than or equal to 1.0 can be used to make gas!")
            (ref-DPTF::UEV_Amount (ref-DALOS::UR_OuroborosID) ouro-amount)
            (let
                (
                    (ouro-price:decimal (ref-DALOS::UR_OuroborosPrice))
                    (ouro-price-used:decimal (if (<= ouro-price 1.00) 1.00 ouro-price))
                    (ignis-id:string (ref-DALOS::UR_IgnisID))
                )
                (enforce (!= ignis-id BAR) "Gas Token isnt properly set")
                (let
                    (
                        (ignis-precision:integer (ref-DPTF::UR_Decimals ignis-id))
                        (raw-ignis-amount-per-unit:decimal (floor (* ouro-price-used 100.0) ignis-precision))
                        (raw-ignis-amount:decimal (floor (* raw-ignis-amount-per-unit ouro-amount) ignis-precision))
                        (output-ignis-amount:decimal (floor raw-ignis-amount 0))
                    )
                    output-ignis-amount
                )
            )
        )
    )
    ;;
    (defun URCi_Compress:object{IgnisCollectorV4.OutputCumulator}
        (client:string ignis-amount:decimal)
        @doc "Cost preview for C_Compress (and cost-identical XB_Compress): client->ORBR IGNIS \
            \ transfer + IGNIS burn + OURO mint + ORBR->client OURO transfer. Output == \
            \ [ouro-remainder-amount], re-derived purely."
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-remainder-amount:decimal (at 0 (URCv_Compress ignis-amount)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer ignis-id client ORBR|SC_NAME ignis-amount)
                    (ref-DPTF::URCi_Burn ignis-id ORBR|SC_NAME)
                    (ref-DPTF::URCi_Mint ouro-id ORBR|SC_NAME false)
                    (ref-TFT::URCi_Transfer ouro-id ORBR|SC_NAME client ouro-remainder-amount)
                ]
                [ouro-remainder-amount]
            )
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV4.OutputCumulator} ()
        @doc "Cost preview for C_Fuel: when wrapped-STOA exists and the ORBR STOA balance is \
            \ positive, the wrap + ATSU fuel legs; otherwise EOC (no-op). Re-derived purely."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATSU:module{AutostakeUsageV4} ATSU)
                (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
                (orb-sc ORBR|SC_NAME)
                (present-stoa-balance:decimal (ref-coin::get-balance (ref-DALOS::UR_AccountStoa orb-sc)))
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
            )
            (if (and (!= w-stoa BAR) (> present-stoa-balance 0.0))
                (let
                    (
                        (liquid-idx:string (at 0 (ref-DPTF::UR_RewardToken w-stoa)))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-LIQUID::URCi_WrapStoa orb-sc present-stoa-balance)
                            (ref-ATSU::URCi_Fuel orb-sc liquid-idx w-stoa present-stoa-balance)
                        ]
                        []
                    )
                )
                EOC
            )
        )
    )
    (defun URCi_Sublimate:object{IgnisCollectorV4.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        @doc "Cost preview for C_Sublimate: client->ORBR OURO transfer + OURO burn + IGNIS mint \
            \ + ORBR->target IGNIS transfer. Output == [ignis-amount], re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-remainder-amount:decimal (at 0 (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision)))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer ouro-id client ORBR|SC_NAME ouro-amount)
                    (ref-DPTF::URCi_Burn ouro-id ORBR|SC_NAME)
                    (ref-DPTF::URCi_Mint ignis-id ORBR|SC_NAME false)
                    (ref-TFT::URCi_Transfer ignis-id ORBR|SC_NAME target ignis-amount)
                ]
                [ignis-amount]
            )
        )
    )
    (defun URCi_SublimateV2:object{IgnisCollectorV4.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        @doc "Cost preview for C_SublimateV2: (conditional) freeze client + wipe-slim the OURO \
            \ + unfreeze + IGNIS mint + ORBR->target IGNIS transfer. Output == [ignis-amount], \
            \ re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-remainder-amount:decimal (at 0 (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision)))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ouro-id client))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (not frozen-state)
                        (ref-DPTF::URCi_ToggleFreezeAccount ouro-id)
                        EOC
                    )
                    (ref-DPTF::URCi_WipeSlim ouro-id)
                    (ref-DPTF::URCi_ToggleFreezeAccount ouro-id)
                    (ref-DPTF::URCi_Mint ignis-id ORBR|SC_NAME false)
                    (ref-TFT::URCi_Transfer ignis-id ORBR|SC_NAME target ignis-amount)
                ]
                [ignis-amount]
            )
        )
    )
    (defun URCi_WithdrawFees:object{IgnisCollectorV4.OutputCumulator}
        (id:string target:string)
        @doc "Cost preview for C_WithdrawFees: the base token-issue IGNIS price + the ORBR-> \
            \ target transfer of the accrued fee supply, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (withdraw-amount:decimal (ref-DPTF::UR_AccountSupply id ORBR|SC_NAME))
                (price:decimal (ref-IGNIS::UC_IgnisDeter "fee-withdraw"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ORBR|SC_NAME trigger [])
                    (ref-TFT::URCi_Transfer id ORBR|SC_NAME target withdraw-amount)
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_Exchange ()
        ;;FIXED 2026-09-12: the two BAR checks are enforced in an OUTER let, above the role reads.
        ;;They used to sit BELOW a single binding group that already did
        ;;`(o-rm (UR_AccountRoleMint ouro-id orb-sc))`, and a `let` is EAGER -- so when ouro-id was
        ;;still BAR that read raised `DPTF ID | does not exist` before either enforce was consulted.
        ;;Setting OURO alone did not help: the gas-id read then aborted the same way. Both written
        ;;sentences were unreachable on the only chain state where they mean anything -- the boot
        ;;window, before the two ids are configured.
        ;;Splitting the group is enough: the id reads depend on nothing, the ROLE reads depend on the
        ;;ids, so the enforces go between them. Pinned by
        ;;REPL/Stage_01/[4.0]_Sovereign-Executor.repl <<TX4.0-CONFIG>>.
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (gas-id:string (ref-DALOS::UR_IgnisID))
            )
            (enforce (!= ouro-id BAR) "Ouroboros is not set")
            (enforce (!= gas-id BAR) "Ignis is not set")
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (orb-sc ORBR|SC_NAME)

                (o-rm:bool (ref-DPTF::UR_AccountRoleMint ouro-id orb-sc))
                (o-rb:bool (ref-DPTF::UR_AccountRoleBurn ouro-id orb-sc))
                (t1:bool (and o-rm o-rb))
                (g-rm:bool (ref-DPTF::UR_AccountRoleMint gas-id orb-sc))
                (g-rb:bool (ref-DPTF::UR_AccountRoleBurn gas-id orb-sc))
                (t2:bool (and g-rm g-rb))
                (t3:bool (and t1 t2))
            )
            ;;Checks Exchange Permission (the two BAR checks now live in the outer let above)
            ;;t3 = t1 AND t2, over four reads of the shape (UR_AccountRoleMint <id> orb-sc). Each of
            ;;those ends in
            ;;    (or <the account's role flag> (DALOS::UR_AutonomicRoles account))
            ;;and `UR_AutonomicRoles` is a PURE fold over a hardcoded list of smart-contract account
            ;;names -- not a table read. `ORBR|SC_NAME` resolves to `DALOS::GOV|OUROBOROS|SC_NAME`,
            ;;which IS one of the entries. So the right-hand side is a compile-time `true`, the `or`
            ;;short-circuits, and t1/t2/t3 hold for every possible chain state. Writing the role flags
            ;;with env-module-admin does not help -- they are ORed away.
            ;;Both facts are asserted in REPL/modules/OUROBOROS.repl <<ORB-G1>>, so this annotation
            ;;cannot rot silently: if the autonomic list ever drops OUROBOROS, that test goes red and
            ;;this guard becomes live. Kept as a fail-closed backstop for exactly that day.
            ;;UNREACHABLE BY CONSTRUCTION -- unlike the two BAR guards above (which were MUTE and were
            ;;repaired by splitting the binding group), no STATE can reach this one at all.
            (enforce t3 "Permission invalid for Ignis Exchange")
        ))
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XB_Compress:object{IgnisCollectorV4.OutputCumulator}
        (patron:string client:string ignis-amount:decimal)
        @doc "SC-account-tolerant IGNIS→OURO compress for INTERNAL module callers (registered OUROBOROS IMC). Same \
            \ conversion + fee as C_Compress (98.5% efficiency), but authorized by IGNIS|XB>COMPRESS which OMITS the \
            \ standard-account restriction — so a SMART account (e.g. AQP|SC_NAME custody) may normalize an IGNIS \
            \ royalty leg to OURO before disposal. P|UEV_IMC gates the caller module. The <client>'s IGNIS→ORBR \
            \ transfer is authorized by whatever cap the caller holds for <client> (e.g. P|FVT|REMOTE-GOV)."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ignis-to-ouro:[decimal] (URCv_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
            )
            (with-capability (IGNIS|XB>COMPRESS client)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        (ref-TFT::C_Transfer patron client ORBR|SC_NAME ignis-id ignis-amount true)
                        (ref-DPTF::C_Burn patron ORBR|SC_NAME ignis-id ignis-amount)
                        (ref-DPTF::C_Mint patron ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        (ref-TFT::C_Transfer patron ORBR|SC_NAME client ouro-id ouro-remainder-amount true)
                    ]
                    [ouro-remainder-amount]
                )
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_Compress:object{IgnisCollectorV4.OutputCumulator}
        (executor:string ignis-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ignis-to-ouro:[decimal] (URCv_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
                ;;#61L fix: removed the dead `total-ouro` binding (bound, never referenced
                ;;anywhere in the function body - only `ouro-remainder-amount`, the first
                ;;element, is actually minted/transferred). No functional change.
            )
            (with-capability (IGNIS|C>COMPRESS executor)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends GAS(Ignis) <ignis-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer executor executor ORBR|SC_NAME ignis-id ignis-amount true)
                        ;;02]Ouroboros burns GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Burn executor ORBR|SC_NAME ignis-id ignis-amount)
                        ;;03]Ouroboros mints OURO <ouro-remainder-amount>
                        (ref-DPTF::C_Mint executor ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        ;;04]Ouroboros transfers OURO <ouro-remainder-amount> to <executor>
                        (ref-TFT::C_Transfer executor ORBR|SC_NAME executor ouro-id ouro-remainder-amount true)
                    ]
                    [ouro-remainder-amount]
                )
            )
        )
    )
    (defun C_Fuel:object{IgnisCollectorV4.OutputCumulator} (patron:string )
        (P|UEV_IMC)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-ATSU:module{AutostakeUsageV4} ATSU)
                (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
                (orb-sc ORBR|SC_NAME)
                (orb-stoa ORBR|SC_STOA-NAME)
                (lq-stoa (ref-LIQUID::GOV|LIQUID|SC_STOA-NAME))
                (present-stoa-balance:decimal (ref-coin::get-balance (ref-DALOS::UR_AccountStoa orb-sc)))
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
            )
            (if (!= w-stoa BAR)
                (let
                    (
                        (w-stoa-as-rt:[string] (ref-DPTF::UR_RewardToken w-stoa))
                        (liquid-idx:string (at 0 w-stoa-as-rt))
                    )
                    (if (> present-stoa-balance 0.0)
                        (with-capability (LIQUIDFUEL|C>ADMIN_FUEL)
                            (install-capability (ref-coin::TRANSFER orb-stoa lq-stoa present-stoa-balance))
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-LIQUID::C_WrapStoa patron orb-sc present-stoa-balance)
                                    (ref-ATSU::C_Fuel patron orb-sc liquid-idx w-stoa present-stoa-balance)
                                ]
                                []
                            )
                        )
                        EOC
                    )
                )
                EOC
            )
        )
    )
    (defun C_Sublimate:object{IgnisCollectorV4.OutputCumulator}
        (executor:string executee:string ouro-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
            )
            (with-capability (IGNIS|C>SUBLIMATE executor executee)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends OURO <ouro-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer executor executor ORBR|SC_NAME ouro-id ouro-amount true)
                        ;;02]Ouroboros burns OURO <ouro-amount>
                        (ref-DPTF::C_Burn executor ORBR|SC_NAME ouro-id ouro-amount)
                        ;;03]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint executor ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;04]Ouroboros transfers GAS(Ignis) <ignis-amount> to <executee>
                        (ref-TFT::C_Transfer executor ORBR|SC_NAME executee ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_SublimateV2:object{IgnisCollectorV4.OutputCumulator}
        (executor:string executee:string ouro-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DALOS:module{OuronetDalosV3} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ouro-id executor))
            )
            (with-capability (IGNIS|C>SUBLIMATE executor executee)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Freeze Client Account for Ouro if not already frozen
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount executor (ref-DPTF::UR_Konto ouro-id) executor ouro-id true)
                            EOC
                        )
                        ;;02]Partialy wipe the required OURO
                        (ref-DPTF::C_WipeSlim executor (ref-DPTF::UR_Konto ouro-id) executor ouro-id ouro-amount)
                        ;;03]Unfreeze Client Account
                        (ref-DPTF::C_ToggleFreezeAccount executor (ref-DPTF::UR_Konto ouro-id) executor ouro-id false)
                        ;;04]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint executor ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;05]Ouroboros transfers GAS(Ignis) <ignis-amount> to <executee>
                        (ref-TFT::C_Transfer executor ORBR|SC_NAME executee ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_WithdrawFees:object{IgnisCollectorV4.OutputCumulator}
        (patron:string executor:string executee:string id:string)
        @doc "Withdraws the DPTF fees accrued on the OUROBOROS smart account for <id>. \
            \ Executor: the TOKEN OWNER, proven in OUROBOROS|C>WITHDRAW by CAP_Owner + \
            \ UEV_ExecutorIsKonto. Executee: the account CREDITED, enforced to be a standard \
            \ (non-smart) account -- it is merely credited and needs no signature, the same \
            \ conditional TFT::C_Transfer states for its own executee."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                (ref-TFT:module{TrueFungibleTransferV3} TFT)
                (withdraw-amount:decimal (ref-DPTF::UR_AccountSupply id ORBR|SC_NAME))
                (price:decimal (ref-IGNIS::UC_IgnisDeter "fee-withdraw"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (enforce (> withdraw-amount 0.0) (format "There are no {} fees to be withdrawn from {}" [id ORBR|SC_NAME]))
            (with-capability (OUROBOROS|C>WITHDRAW executor id executee)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;00]Compose base withdraw IGNIS Price
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ORBR|SC_NAME trigger [])
                        ;;01]Fees move from the Ouroboros Smart DALOS Account to the executee's Normal Ouronet Account.
                        ;;PROVISIONAL PATRON SLOT CLEARED (2026-09-21, _patronslots.py): this read
                        ;;`C_Transfer target ...`, because at the time this module had no <patron>
                        ;;parameter to thread and the recipient was the only account in scope. That
                        ;;is invisible to _callarity (the arity was right) and to every assertion
                        ;;(no swept callee read the slot), which is exactly why the registry
                        ;;existed to remember it. It is now the real patron.
                        (ref-TFT::C_Transfer patron ORBR|SC_NAME executee id withdraw-amount true)
                    ]
                    []
                )
            )
        )
    )

)

;; --- tables for 13_OUROBOROS.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact =================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; TalosStageOne_AdminV2: already deployed and unchanged -- see LIVE_INTERFACES

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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-ORBR:module{OuroborosV3} OUROBOROS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
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
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-BRD:module{BrandingV3} BRD)
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
                    (ref-BRD:module{BrandingV3} BRD)
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
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
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
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
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
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV3} DPTF)
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                    (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
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
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
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
                    (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
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
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                    (ref-SWP:module{SwapperV5} SWP)
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
                    (ref-SWP:module{SwapperV5} SWP)
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
                    (ref-SWP:module{SwapperV5} SWP)
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
                    (ref-SWP:module{SwapperV5} SWP)
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
                    (ref-SWP:module{SwapperV5} SWP)
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
                    (ref-SWP:module{SwapperV5} SWP)
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

;; ===== 1_SOVEREIGN/STAGE_01/3_Talos/03_TS01-C2.pact ================
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/03_Talos.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
;; TalosStageOne_ClientTwoV3: already deployed and unchanged -- see LIVE_INTERFACES

;;
(module TS01-C2 GOV
    @doc "TALOS Client Module for Stage 1, namely ATS VST LIQUID and OUROBOROS Modules"

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements TalosStageOne_ClientTwoV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_TS01-C2                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|TS01-C1_ADMIN)))
    (defcap GOV|TS01-C1_ADMIN ()                        (enforce-guard GOV|MD_TS01-C2))
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
    (defcap P|TS ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV3} DALOS)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (ref-P|DPOF:module{OuronetPolicyV2} DPOF)
                (ref-P|ATS:module{OuronetPolicyV2} ATS)
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|VST:module{OuronetPolicyV2} VST)
                (ref-P|LIQUID:module{OuronetPolicyV2} LIQUID)
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (ref-P|SWPT:module{OuronetPolicyV2} SWPT)
                (ref-P|SWP:module{OuronetPolicyV2} SWP)
                (ref-P|SWPI:module{OuronetPolicyV2} SWPI)
                (ref-P|SWPL:module{OuronetPolicyV2} SWPL)
                (ref-P|SWPLC:module{OuronetPolicyV2} SWPLC)
                (ref-P|SWPU:module{OuronetPolicyV2} SWPU)
                (ref-P|TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                (mg:guard (create-capability-guard (P|TALOS-SUMMONER)))
            )
            (ref-P|IGNIS::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|LIQUID::P|A_AddIMP mg)
            (ref-P|ORBR::P|A_AddIMP mg)
            ;;
            (ref-P|SWPT::P|A_AddIMP mg)
            (ref-P|SWP::P|A_AddIMP mg)
            (ref-P|SWPI::P|A_AddIMP mg)
            (ref-P|SWPL::P|A_AddIMP mg)
            (ref-P|SWPLC::P|A_AddIMP mg)
            (ref-P|SWPU::P|A_AddIMP mg)
            (ref-P|TS01-A::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
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
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;
    ;;  [ATS_Client]
    (defun ATS|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        @doc "Updates <pending-branding> for ATSPair <entity-id> costing 500 IGNIS"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-B|ATS:module{BrandingUsagePrimaryV3} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-B|ATS::C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun ATS|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-B|ATS:module{BrandingUsagePrimaryV3} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-B|ATS::C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    ;;
    (defun ATS|HOT-RBT|C_UpdatePendingBranding (patron:string executor:string entity-id:string logo:string description:string website:string social:[object{BrandingV3.SocialSchema}])
        @doc "Updates <pending-branding> for a HOT-RBT <entity-id> costing 150 IGNIS (Standard DPOF Costs)"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::HOT-RBT|C_UpdatePendingBranding patron executor entity-id logo description website social)
                )
            )
        )
    )
    (defun ATS|HOT-RBT|C_UpgradeBranding (patron:string executor:string entity-id:string months:integer)
        @doc "Similar to its DPTF, DPOF Variants"
        (with-capability (P|TS)
            (let
                (
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                )
                (ref-ATS::HOT-RBT|C_UpgradeBranding patron executor entity-id months)
                (ref-TS01-A::XB_DynamicFuelSTOA)
            )
        )
    )
    (defun ATS|HOT-RBT|C_Repurpose (patron:string executor:string executee:string hot-rbt:string nonce:integer)
        @doc "Repurposes a Hot-Rbt to a another Account, Can only be done by atspair owner"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::HOT-RBT|C_Repurpose patron executor executee hot-rbt nonce)
                )
                (format "Succesfully repurposed HOT-RBT {} Nonce {} to Account {}" [hot-rbt nonce srt])
            )
        )
    )
    ;;
    (defun ATS|C_Issue:list (patron:string executor:string ats:[string] index-decimals:[integer] reward-token:[string] rt-nfr:[bool] reward-bearing-token:[string] rbt-nfr:[bool])
        @doc "Issues and Autostake Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ATS::C_Issue patron executor ats index-decimals reward-token rt-nfr reward-bearing-token rbt-nfr)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                (at "output" ico)
            )
        )
    )
    (defun ATS|C_RotateOwnership (patron:string executor:string executee:string ats:string)
        @doc "Rotates ATSPair Ownership"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_RotateOwnership patron executor executee ats)
                )
                (format "Succesfully changed ownership for ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_Control (patron:string executor:string ats:string can-change-owner:bool syphoning:bool hibernate:bool)
        @doc "Controls the Properties of an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_Control patron executor ats can-change-owner syphoning hibernate)
                )
                (format "Succesfully controlled ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_UpdateRoyalty (patron:string executor:string ats:string royalty:decimal)
        @doc "Updates the Royalty value for an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_UpdateRoyalty patron executor ats royalty)
                )
                (format "Royalty for ATS-Pair {} updated Succesfully to {} Promile" [ats royalty])
            )
        )
    )
    (defun ATS|C_UpdateSyphon (patron:string executor:string ats:string syphon:decimal)
        @doc "Updates the Syphoning Index value for an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_UpdateSyphon patron executor ats syphon)
                )
                (format "Syphon Index for ATS-Pair {} updated Succesfully to {}" [ats syphon])
            )
        )
    )
    (defun ATS|C_SetHibernationFees (patron:string executor:string ats:string peak:decimal decay:decimal)
        @doc "Updates the Hibernation Fees an ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetHibernationFees patron executor ats peak decay)
                )
                (format "Hibernation Fees for ATS-Pair {} set to {} Promile-Peak and {} Promile-Decay per Day" [ats peak decay])
            )
        )
    )
    ;;
    (defun ATS|C_ToggleParameterLock (patron:string executor:string ats:string toggle:bool)
        @doc "Toggle ATSPair Parameter Lock"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ATS::C_ToggleParameterLock patron executor ats toggle)
                    )
                    (collect:bool (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XE_ConditionalFuelSTOA collect)
            )
        )
    )
    (defun ATS|C_AddSecondary (patron:string executor:string ats:string reward-token:string rt-nfr:bool)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_AddSecondary patron executor ats reward-token rt-nfr)
                )
                (if rt-nfr
                    (format "Succesfully Added {} as a secondary Reward Token for the ATS-Pair {} with Native-Fee-Recovery" [reward-token ats])
                    (format "Succesfully Added {} as a secondary Reward Token for the ATS-Pair {} without Native-Fee-Recovery" [reward-token ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_ControlColdRecoveryFees (patron:string executor:string ats:string c-nfr:bool c-fr:bool)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ControlColdRecoveryFees patron executor ats c-nfr c-fr)
                )
                (format "Succesfully controlled Cold Recovery Fees for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_SetColdRecoveryFees (patron:string executor:string ats:string fee-positions:integer fee-thresholds:[decimal] fee-array:[[decimal]])
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetColdRecoveryFees patron executor ats fee-positions fee-thresholds fee-array)
                )
                (format "Succesfully set Cold Recovery Fees for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_SetColdRecoveryDuration (patron:string executor:string ats:string soft-or-hard:bool base:integer growth:integer)
        @doc "Adds a Secondary RT to an ATSPair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetColdRecoveryDuration patron executor ats soft-or-hard base growth)
                )
                (format "Succesfully set Cold Recovery Duration for ATS-Pair {}" [ats])
                
            )
        )
    )
    (defun ATS|C_ToggleElite (patron:string executor:string ats:string toggle:bool)
        @doc "Toggles ATSPair Elite Functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ToggleElite patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Elite Mode for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Elite Mode for ATS-Pair {}" [ats])
                )
            )
        )
    )
    (defun ATS|C_ToggleUpgrade (patron:string executor:string ats:string toggle:bool)
        @doc "Sets can-upgrade for an ATS-Pair (audit finding #21L / L3). Gates C_Control \
            \ (can-change-owner/syphoning/hibernate) - false blocks C_Control entirely \
            \ until set back to true."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ToggleUpgrade patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully allowed further Property Upgrades (can-upgrade) for ATS-Pair {}" [ats])
                    (format "Succesfully blocked further Property Upgrades (can-upgrade) for ATS-Pair {} - C_Control is now disabled until this is turned back on" [ats])
                )
            )
        )
    )
    (defun ATS|C_SwitchColdRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Cold Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchColdRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Cold Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Cold Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_AddHotRBT (patron:string executor:string ats:string hot-rbt:string)
        @doc "Adds a Hot-RBT to an ATS-Pair immutably \
            \ Must be a non special DPOF Token with zero Supply \
            \ Ownership of this Token is transfered to the ATS|SC_NAME"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_AddHotRBT patron executor ats hot-rbt)
                )
                (format "Succesfully added DPOF {} as Hot-RBT for ATS-Pair {}" [hot-rbt ats])
            )
        )
    )
    (defun ATS|C_ControlHotRecoveryFee (patron:string executor:string ats:string h-fr:bool)
        @doc "Controls Hot Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_ControlHotRecoveryFee patron executor ats h-fr)
                )
                (format "Succesfully controlled Hot-Recovery Fee for ATS-Pair {}" [ats])
            )
        )
    )
    (defun ATS|C_SetHotRecoveryFee (patron:string executor:string ats:string promile:decimal decay:integer)
        @doc "Controls Hot Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetHotRecoveryFees patron executor ats promile decay)
                )
                (format "Succesfully set Hot-Recovery Fees for ATS-Pair {} to {} Promile and {} Days-Decay" [ats promile decay])
            )
        )
    )
    (defun ATS|C_SwitchHotRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Hot Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchHotRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Hot Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Hot Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    (defun ATS|C_SetDirectRecoveryFee (patron:string executor:string ats:string promile:decimal)
        @doc "Controls Direct Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SetDirectRecoveryFee patron executor ats promile)
                )
                (format "Succesfully set Direct-Recovery Fees for ATS-Pair {} to {} Promile" [ats promile])
            )
        )
    )
    (defun ATS|C_SwitchDirectRecovery (patron:string executor:string ats:string toggle:bool)
        @doc "Switches on or off Direct Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATS::C_SwitchDirectRecovery patron executor ats toggle)
                )
                (if toggle
                    (format "Succesfully switched on Direct Recovery for ATS-Pair {}" [ats])
                    (format "Succesfully switched off Direct Recovery for ATS-Pair {}" [ats])
                )
                
            )
        )
    )
    ;;
    ;;
    (defun ATS|CC_RemoveSecondary (patron:string executor:string ats:string reward-token:string)
        @doc "Controls Direct Recovery Fees"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::CC_RemoveSecondary patron executor ats reward-token)
                )
                (format "Succesfully removed RT {} from ATS-Pair {}" [reward-token ats])
            )
        )
    )
    (defun ATS|C_WithdrawRoyalties (patron:string executor:string executee:string ats:string)
        @doc "Withdraws ATS-Pair Royalties, if non-zero"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_WithdrawRoyalties patron executor executee ats)
                )
                (format "Succesfully withdrawn Royalties from ATS-Pair {} to Account {}" [ats st])
            )
        )
    )
    (defun ATS|C_KickStart (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Kickstarst an ATSPair, so that it starts at a given Index \
            \ Can only be done on a freshly created ATS-Pair"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ATSU::C_KickStart patron executor ats rt-amounts rbt-request-amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully Kickstarted ATS-Pair {} to an Index of {}" [ats (at 0 (at "output" ico))])
            )
        )
    )
    (defun ATS|C_Fuel (patron:string executor:string ats:string reward-token:string amount:decimal)
        @doc "Fuels an ATSPair with RT Tokens, increasing its Index"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (prev-index:decimal (ref-ATS::URC_Index ats))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Fuel patron executor ats reward-token amount)
                )
                (format "Succesfully fueld ATS-Pair {} increasing its index by {}"
                    [ats (- (ref-ATS::URC_Index ats) prev-index)]
                )
            )
        )
    )
    (defun ATS|C_Coil (patron:string executor:string ats:string rt:string amount:decimal)
        @doc "Coils an RT Token from a specific ATS-Pair, generating a RBT Token \
        \ Only works if <ats> has hibernation off."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ATSU::C_Coil patron executor ats rt amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully coiled {} {} on ATS-Pair {} generating {} RBT Tokens" [amount rt ats (at 0 (at "output" ico))])
            )
        )
    )
    (defun ATS|C_Curl (patron:string executor:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Curl double coils an RT Token in 2 chained ATS-Pairs \
            \ The RBT Token of <ats1> must be RBT Token in <ats2> \
            \ Both ATS-Pairs must have hibernation off for this to work."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ATSU::C_Curl patron executor ats1 ats2 rt amount)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully curled {} {} on ATS-Pairs {} and {} generating {} RBT Tokens of the second ATS-Pair" 
                    [amount rt ats1 ats2 (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_VestedCoil (patron:string executor:string ats:string coil-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        @doc "Coils a DPTF Token and Vests its output to <target-account> \
            \ Requires that: \
            \ *]Input DPTF is part of an ATSPair, the <ats> \
            \ *]That the RBT of <ats> has a vested counterpart \
            \ \
            \ Outputs the resulted Vested Cold-RBT Amount \
            \ Only the Owner of <coil-token> can execute thi function, \
            \ as this is prerequisite for Vesting"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ref-VST:module{VestingV3} VST)
                    ;;
                    (coil-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats coil-token amount)
                    )
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-ATSU::C_Coil patron executor ats coil-token amount)
                            (ref-VST::C_Vest patron executor target-account c-rbt c-rbt-amount offset duration milestones)
                        ]
                        []
                    )
                )
                (format "Succesfully coiled {} {} on ATS-Pair {} generating {} Vested RBT Tokens" [amount coil-token ats c-rbt-amount])
            )
        )
    )
    (defun ATS|C_VestedCurl (patron:string executor:string ats1:string ats2:string curl-token:string amount:decimal target-account:string offset:integer duration:integer milestones:integer)
        @doc "Same as <ATS|C_VestedCoil> but instead Curls the input Token. \
            \ Requires that : \
            \ *]Input DPTF is part of an ATSPair, the <ats1> \
            \ *]That the Cold-RBT Token of the <ats1> is RT in <ats2> \
            \ *]That Cold-RBT of <ats2> has a vested counterpat \
            \ \
            \ Outputs the resulted Vested Cold-RBT of <ats2>"
        (with-capability (P|TS)
            (let*
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATS:module{AutostakeV4} ATS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ref-VST:module{VestingV3} VST)
                    ;;
                    (coil1-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 curl-token amount)
                    )
                    (coil2-data:object{AutostakeV4.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats2 (at "rbt-id" coil1-data) (at "rbt-amount" coil1-data))
                    )
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-ATSU::C_Curl patron executor ats1 ats2 curl-token amount)
                            (ref-VST::C_Vest patron executor target-account (at "rbt-id" coil2-data) c-rbt2-amount offset duration milestones)
                        ]
                        []
                    )
                )
                (format "Succesfully curled {} {} on ATS-Pair {} and {} generating {} Vested RBT Tokens of the second ATS-Pair" 
                    [amount curl-token ats1 ats2 c-rbt2-amount]
                )
            )
        )
    )
    (defun ATS|C_Constrict (patron:string executor:string ats:string rt:string amount:decimal dayz:integer)
        @doc "Constricts an RT Token from a specific ATS-Pair, generating a RBT Token in HIbernated Form \
        \ Only works if <ats> has hibernation on."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_Constrict patron executor ats rt amount dayz)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully constricted {} {} on ATS-Pair {} generating {} Hibernated RBT Tokens" 
                    [amount rt ats (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_Brumate (patron:string executor:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        @doc "Brumate double coils an RT Token in 2 chained ATS-Pairs \
            \ The RBT Token of <ats1> must be RBT Token in <ats2> \
            \ Second ATS-Pair must have hibernation on for this to work."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_Brumate patron executor ats1 ats2 rt amount dayz)
                    )
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (format "Succesfully brumated {} {} on ATS-Pairs {} and {} generating {} Hibernated RBT Tokens of the second ATS-Pair" 
                    [amount rt ats1 ats2 (at 0 (at "output" ico))]
                )
            )
        )
    )
    (defun ATS|C_Syphon (patron:string executor:string executee:string ats:string syphon-amounts:[decimal])
        @doc "Syphons from an ATS Pair, extracting RTs and decreasing ATSPair Index. \
            \ Syphoning can be executed until the set up Syphon limit is achieved"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Syphon patron executor executee ats syphon-amounts)
                )
                (format "Succesfully syphoned {} RT Amount(s) from ATS-Pair {} to Target {}" [syphon-amounts ats st])
            )
        )
    )
    ;;
    (defun ATS|C_ColdRecovery (patron:string executor:string ats:string ra:decimal)
        @doc "Recovers Cold-RBT, disolving it, generating RTs cullable in the future. \
        \ Amount of RTs is determined by the ATS-Pair Index at the Cold Recovery Moment"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_ColdRecovery patron executor ats ra)
                )
                (format "Succesfully placed {} {} ATS-Pair RBT into Cold Recovery" [ra ats])
            )
        )
    )
    (defun ATS|C_Cull (patron:string executor:string ats:string)
        @doc "Culls an ATSPair, extracting RTs that are cullable. Fix (audit finding \
            \ #32N / N1): reports a distinct 'nothing to cull yet' message when nothing \
            \ was actually culled, instead of always claiming success - the underlying \
            \ crash-vs-graceful-empty-result fix lives in ATSU.URC_MultiCull."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ATSU::C_Cull patron executor ats)
                    )
                    (cw:[decimal] (at "output" ico))
                    (how-many-tokens:integer (length cw))
                    (total-culled:decimal (fold (+) 0.0 cw))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= total-culled 0.0)
                    (format "Nothing to Cull just yet for ATS-Pair {} - no positions have reached their cull-time" [ats])
                    (format "Succesfully Culled {} RT(s) Tokens with amounts of {} from ATS-Pair {}" [how-many-tokens cw ats])
                )
            )
        )
    )
    ;;
    (defun ATS|C_HotRecovery (patron:string executor:string ats:string ra:decimal)
        @doc "Converts a Cold-RBT to a Hot-RBT, preparing it for Hot Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_HotRecovery patron executor ats ra)
                )
                (format "Succesfully converted {} RBT to Hot-RBT on ATS-Pair {}" [ra ats])
            )
        )
    )
    (defun ATS|C_Reverse (patron:string executor:string id:string nonce:integer)
        @doc "Reverses a Hot-RBT Nonce, converting it to Cold-RBT in its entirety \
            \ as the Hot-RBT doesnt have segmentation turned on"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ats:string (ref-DPOF::UR_RewardBearingToken id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Recover patron executor id nonce)
                )
                (format "Succesfully Converted Hot-RBT {} Nonce {} back into the Native RBT of ATS-Pair {}" [id nonce ats])
            )
        )
    )
    (defun ATS|C_Redeem (patron:string executor:string id:string nonce:integer)
        @doc "Redeems a Hot-RBT, recovering RTs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV3} DPOF)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                    (ats:string (ref-DPOF::UR_RewardBearingToken id))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_Redeem patron executor id nonce)
                )
                (format "Succesfully Redeemed Hot-RBT {} Nonce {} back in RTs for ATS-Pair {}" [id nonce ats])
            )
        )
    )
    ;;
    (defun ATS|C_DirectRecovery (patron:string executor:string ats:string ra:decimal)
        @doc "Directly Recovers RBT to RTs using Direct Recovery"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ATSU:module{AutostakeUsageV4} ATSU)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ATSU::C_DirectRecovery patron executor ats ra)
                )
                (format "Succesfully recovered directly {} RBT Token on ATS-Pair {}" [ra ats])
            )
        )
    )
    ;;  [VST_Client]
    (defun VST|C_CreateFrozenLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Frozen Link, issuing a Special-DPTF as a frozen counterpart for another DPTF \
            \ A Frozen Link is immutable, and noted in the Token Properties of both DPTFs \
            \ A Special DPTF of the Frozen variety, is used for implementing the FROZEN Functionality for a DPTF Token \
            \ So called FROZEN Tokens are meant to be frozen on the account holding them, and only be used by that account, \
            \ for specific purposes only, defined by the <dptf> owner, which is also the owner of the Frozen Token. \
            \ Frozen Tokens can never be converted back to the original <dptf> Token they were created from \
            \ \
            \ Only the <dptf> owner can create Frozen Tokens to Target Accounts, \
            \ or designate other Smart Ouronet Accounts to create them \
            \ \
            \ Frozen Tokens can be used to add Swpair Liquidity, as if they were the initial <dptf> token \
            \ This can be done, when this functionality is turned on for the Swpair, and using a Frozen Token for adding Liquidity \
            \ generates a Frozen LP Token, which behaves similarly to the Frozen Token \
            \ that is, it can never be converted back to the SWPairs native LP, locking liquidity in place \
            \ Existing LPs can also be frozen, permanently locking liquidity \
            \ \
            \ VESTA will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_CreateFrozenLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Frozen Link for the DPTF {}, issuing the Frozen DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateReservationLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Reservation Link, issuing a Special-DPTF as a reserved counterpart for another DPTF \
            \ A Reservation Link is immutable, and noted in the Token Properties of both DPTFs \
            \ A Special DPTF of the Reserved variety, is used for implementing the RESERVED Functionality for a DPTF Token \
            \ So called RESERVED Tokens are meant to be frozen on the account holding them, and only be used by that account, \
            \ for specific purposes only, defined by the <dptf> owner, which is also the owner of the Reserved Token. \
            \ Reserved Tokens can never be converted back to the original <dptf> Token they were created from \
            \ \
            \ As opposed to frozen tokens, where only the <dptf> owner can generate them or designated Ouronet Accounts, \
            \ Reserved Tokens can be generated by clients, using as input the <dptf> Token, only when reservations are open by the <dptf> owner \
            \ That is, the <dptf> owner dictates when clients can generate reserved tokens from the input <dptf>, \
            \ and as such, reserved tokens can be used for special discounts when sales are planned with the main <dptf> Token, \
            \ as if they were the main <dptf> token. \
            \ \
            \ Reserved Tokens cannot be used to add liquidty on any Swpair. \
            \ \
            \ OURO will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_CreateReservationLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Reservation Link for the DPTF {}, issuing the Reserved DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateVestingLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Vesting Link, issuing a Special-DPOF as a vested counterpart for another DPTF \
            \ A Vesting Link is immutable, and noted in the Token Properties of both the DPTF and the Special DPOF \
            \ A Special DPOF of the Vested variety, is used for implementing the Vesting Functionality for a DPTF Token \
            \ The <dptf> owner has the ability to vest its <dptf> token into a vested counterpart \
            \ specifying a target account, an offset, a duration and a number of milestones as vesting parameters \
            \ \
            \ The Target account receives the vested token, and according to its input vested parameters, \
            \ can revert it back to the <dptf> counterpart, as vesting intervals expire \
            \ \
            \ Vested Tokens cannot be used to add liquidity on any Swpair \
            \ \
            \ If a Vested Counterpart is created for a Token that is a Cold-RBT in an ATS Pair, \
            \ the RT owner of that ATS Pair can <coil>|<curl> the RT Token, and subsequently <vest> the output Hot-RBT token, \
            \ thus creating an additional layer of locking, for the input <RT> token, by converting it in a Vested Hot-RBT \
            \ OURO, AURYN and ELITE-AURYN will be the first Tokens that will make use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_CreateVestingLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Vesting Link for the DPTF {}, issuing the Vested DPOF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateSleepingLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Sleeping Link, issuing a Special-DPOF as a sleeping counterpart for another DPTF \
            \ A Sleeping Link is immutable, and noted in the Token Properties of both the DPTF and the Special DPOF \
            \ A Special DPOF of the Sleeping variety, is used for implementing the Sleeping Functionality for a DPTF Token \
            \ A Sleeping DPOF is similar to a vested Token, however it has a single period after which it can be converted \
            \ in its entirety, at once, into the initial <dptf> \
            \ As opposed to Vested DPOF Tokens, multiple Sleeping DPOF Tokens, can be unified into a single Sleeping Token \
            \ using a weigthed mean to determine the final time when it can be converted back to the initial <dptf> \
            \ \
            \ As oposed to Vested Tokens, Sleeping Tokens can be used to add Swpair Liquidity, as if they were the initial <dptf> token \
            \ This can be done, when this functionality is turned on for the Swpair, and using a Sleeping Token for adding Liquidity \
            \ generates a Sleeping LP Token, which behaves similarly to the Sleeping Token, inheriting its sleeping date, \
            \ that is, it can be converted back to the SWPairs native LP, when its sleeping interval expires \
            \ Existing LPs can also be put to sleep, locking liquidity for a given period \
            \ \
            \ VESTA will be the first Token that will be making use of this functionality"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_CreateSleepingLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Sleeping Link for the DPTF {}, issuing the Sleeping DPOF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
                
            )
        )
    )
    (defun VST|C_CreateHibernatingLink:[string] (patron:string executor:string dptf:string)
        @doc "Creates a Hibernating Link, issuing a Special-DPOF as a hibernating counterpart for another DPTF \
            \ A Hibernating Link is immutable, and noted in the Token Properties of both DPTF and the Special DPOF \
            \ A Special DPOF of the Hibernating variety, is used for implementing the Hibernating Functionality for a DPTF Token \
            \ A Hibernating DPOF is similar to a sleeping Token, with a few particularities. \
            \ It has a day granularity, and up to 100 years can be used for hibernating. \
            \ \
            \ In direct contrast to a Sleeping DPOF, which has to be waited up for it to be converted back to its original DPTF \
            \ the Hibernated DPOF can be converted on Demand back into its original DPTF, however there is a fee to do so, \
            \ if the hibernation period hasnt elaspsed. This fee decreases from 800 promile down to zero at its awakening time \
            \ The fee is automaticaly burned, and cannot be recovered by any means. \
            \ \
            \ Similarly to Sleeping DPOFs, multiple batches can be merged, using the same algoritm implemented for mergind of Sleeping DPOFs"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-TS01-A:module{TalosStageOne_AdminV2} TS01-A)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_CreateHibernatingLink patron executor dptf)
                    )
                    (output-id:string (at 0 (at "output" ico)))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (ref-TS01-A::XB_DynamicFuelSTOA)
                [
                    (format "Succesfully generated a Hibernation Link for the DPTF {}, issuing the Hibernated DPTF {}" 
                        [dptf output-id]
                    )
                    output-id
                ]
            )
        )
    )
    ;;  [VST Freezing]
    (defun VST|C_Freeze (patron:string executor:string freeze-output:string dptf:string amount:decimal)
        @doc "Freezes a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (sfa:string (ref-I|OURONET::OI|UC_ShortAccount freeze-output))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Freeze patron executor freeze-output dptf amount)
                )
                (format "Succesfully freeze {} DPTF {} to Account {}" [amount dptf sfa])
            )
        )
    )
    (defun VST|C_RepurposeFrozen (patron:string executor:string executee:string dptf-to-repurpose:string repurpose-to:string)
        @doc "Repurposes a Frozen DPTF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeFrozen patron executor executee dptf-to-repurpose repurpose-to)
                )
                (format "Succesfully repurposed Frozen DPTF {} from {} to {}" [dptf-to-repurpose srf srt])
            )
        )
    )
    (defun VST|C_ToggleTransferRoleFrozenDPTF (patron:string executor:string s-dptf:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Frozen DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleFrozenDPTF patron executor s-dptf target toggle)
                )
                (format "Succefully toggled Transfer Role for the Frozen DPTF {}" [s-dptf])
            )
        )
    )
    ;;  [VST Reserving]
    (defun VST|C_Reserve (patron:string executor:string dptf:string amount:decimal)
        @doc "Reserves a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (sr:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Reserve patron executor dptf amount)
                )
                (format "Account {} succesfully reserved {} {} Tokens" [sr amount dptf])
            )
        )
    )
    (defun VST|C_Unreserve (patron:string executor:string r-dptf:string amount:decimal)
        @doc "Unreserves a DPTF Token"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unreserve patron executor r-dptf amount)
                )
                (format "Account {} succesfully unreserved {} {} Tokens" [su amount r-dptf])
            )
        )
    )
    (defun VST|C_RepurposeReserved (patron:string executor:string executee:string dptf-to-repurpose:string repurpose-to:string)
        @doc "Repurposes a Reserved DPTF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeReserved patron executor executee dptf-to-repurpose repurpose-to)
                )
                (format "Succesfully repurposed Reserved DPTF {} from {} to {}" [dptf-to-repurpose srf srt])
            )
        )
    )
    (defun VST|C_ToggleTransferRoleReservedDPTF (patron:string executor:string s-dptf:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Reserved DPTF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleReservedDPTF patron executor s-dptf target toggle)
                )
                (format "Succefully toggled Transfer Role for the Reserved DPTF {}" [s-dptf])
            )
        )
    )
    ;;  [VST Vesting]
    (defun VST|C_Vest (patron:string executor:string target-account:string dptf:string amount:decimal offset:integer seconds:integer milestones:integer)
        @doc "Vests a DPTF Token, generating ist Vested DPOF Counterspart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (sv:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Vest patron executor target-account dptf amount offset seconds milestones)
                )
                (format "Succesfully vested DPTF {} From Account {} to Account {}" [dptf sv sta])
            )
        )
    )
    (defun VST|C_Unvest (patron:string executor:string dpof:string nonce:integer)
        @doc "Culls the Vested DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unvest patron executor dpof nonce)
                )
                (format "Succesfully unvested DPOF {} Nonce {} to Account {}" [dpof nonce su])
            )
        )
    )
    (defun VST|C_RepurposeVested (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        @doc "Repurposes a Vested DPOF to another account"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeVested patron executor executee dpof-to-repurpose nonce repurpose-to)
                )
                (format "Succesfully repurposed Vested DPTF {} Nonce {}from {} to {}" [dpof-to-repurpose nonce srf srt])
            )
        )
    )
    ;;  [VST Sleeping]
    (defun VST|C_Sleep (patron:string executor:string target-account:string dptf:string amount:decimal seconds:integer)
        @doc "Sleeps a DPTF Token, generating its Sleeping DPOF Counterpart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Sleep patron executor target-account dptf amount seconds)
                )
                (format "Sucesfully put to Sleep {} DPTF {} on Account {} for a Duration of {} seconds." [amount dptf sta seconds])
            )
        )
    )
    (defun VST|C_Unsleep (patron:string executor:string dpof:string nonce:integer)
        @doc "Culls the Sleeping DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Unsleep patron executor dpof nonce)
                )
                (format "Succesfully unsleeped DPOF {} Nonce {} on Account {}" [dpof nonce su])
            )
        )
    )
    (defun VST|C_Merge(patron:string executor:string dpof:string nonces:[integer])
        @doc "Merges selected sleeping Tokens of an account, \
            \ releasing them if expired sleeping dpof-s exist within the selected tokens \
            \ Multiple existing Batches can be merged this way."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (sm:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Merge patron executor dpof nonces)
                )
                (format "Succesfully merged Sleeping DPOF {} Nonces {} to Account {}" [dpof nonces sm])
            )
        )
    )
    (defun VST|C_RepurposeMerge (patron:string executor:string executee:string dpof-to-repurpose:string nonces:[integer] repurpose-to:string)
        @doc "Repurposes multiple Sleeping DPOFs from <executee> to <repurpose-to>, while merging them"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeMerge patron executor executee dpof-to-repurpose nonces repurpose-to)
                )
                (format "Succesfully repurposed and merged Sleeping DPOF {} Nonces {} from {} to {}" 
                    [dpof-to-repurpose nonces srf srt]
                )
            )
        )
    )
    (defun VST|C_RepurposeSleeping (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        @doc "Repurposes a single Sleeping DPOF from <executee> to <repurpose-to>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeSleeping patron executor executee dpof-to-repurpose nonce repurpose-to)
                )
                (format "Succesfully repurposed Sleeping DPOF {} Nonce {} from {} to {}" 
                    [dpof-to-repurpose nonce srf srt]
                )
            )
        )
    )
    (defun VST|C_ToggleTransferRoleSleepingDPOF (patron:string executor:string s-dpof:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Sleeping DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleSleepingDPOF patron executor s-dpof target toggle)
                )
                (format "Succefully toggled Transfer Role for the Sleeping DPTF {}" [s-dpof])
            )
        )
    )
    ;;  [VST Hibernating]
    (defun VST|C_Hibernate (patron:string executor:string target-account:string dptf:string amount:decimal dayz:integer)
        @doc "Hibernates a DPTF Token, generating its Hibernated DPOF Counterpart"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sta:string (ref-I|OURONET::OI|UC_ShortAccount target-account))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Hibernate patron executor target-account dptf amount dayz)
                )
                (format "Sucesfully hibernated {} {} on Account {} for a Duration of {} days." [amount dptf sta dayz])
            )
        )
    )
    (defun VST|C_Awake (patron:string executor:string dpof:string nonce:integer)
        @doc "Culls the Hibernated DPOF Token, recovering its DPTF counterpart."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (sa:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-VST::C_Awake patron executor dpof nonce)
                    )
                    (output:list (at "output" ico))
                    (v1:decimal (at 0 output))
                    (v2:decimal (at 1 output))
                    (v3:decimal (at 2 output))
                )
                (ref-IGNIS::XE_CollectIgnis patron ico)
                (if (= v1 0.0)
                    (format "Awakend DPOF {} Nonce {} with no Hibernation Fee, getting the Full Amount of {} back" [dpof nonce v2])
                    (format "Awakend DPOF {} Nonce {} with a Hibernation Fee of {} Promile, relinquishing {} Tokens and getting only {} Tokens back" [dpof nonce v1 v3 v2])
                )
            )
        )
    )
    (defun VST|C_Slumber (patron:string executor:string dpof:string nonces:[integer])
        @doc "Merges selected hibernated Tokens of an account, \
            \ releasing them if expired sleeping dpof-s exist within the selected tokens \
            \ Multiple existing Batches can be merged this way."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (sm:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_Slumber patron executor dpof nonces)
                )
                (format "Succesfully merged Hibernated DPOF {} Nonces {} to Account {}" [dpof nonces sm])
            )
        )
    )
    (defun VST|C_RepurposeSlumber (patron:string executor:string executee:string dpof-to-repurpose:string nonces:[integer] repurpose-to:string)
        @doc "Repurposes multiple Hibernated DPOFs from <executee> to <repurpose-to>, while merging them"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeSlumber patron executor executee dpof-to-repurpose nonces repurpose-to)
                )
                (format "Succesfully repurposed and merged Hibernated DPOF {} Nonces {} from {} to {}" 
                    [dpof-to-repurpose nonces srf srt]
                )
            )
        )
    )
    (defun VST|C_RepurposeHibernating (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        @doc "Repurposes a single Hibernating DPOF from <executee> to <repurpose-to>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (srf:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                    (srt:string (ref-I|OURONET::OI|UC_ShortAccount repurpose-to))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_RepurposeHibernating patron executor executee dpof-to-repurpose nonce repurpose-to)
                )
                (format "Succesfully repurposed Hibernated DPOF {} Nonce {} from {} to {}" 
                    [dpof-to-repurpose nonce srf srt]
                )
            )
        )
    )
    (defun VST|C_ToggleTransferRoleHibernatingDPOF (patron:string executor:string s-dpof:string target:string toggle:bool)
        @doc "Toggles Transfer Role for a Hibernating DPOF"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-VST:module{VestingV3} VST)
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-VST::C_ToggleTransferRoleHibernatingDPOF patron executor s-dpof target toggle)
                )
                (format "Succefully toggled Transfer Role for the Hibernating DPTF {}" [s-dpof])
            )
        )
    )
    ;;  [LIQUID_Client]
    (defun LQD|C_UnwrapStoa (patron:string executor:string amount:decimal)
        @doc "Unwraps DPTF Stoa to Native Stoa"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_UnwrapStoa patron executor amount)
                )
                (format "Succesfully Unwrapped {} STOA on Account {}" [amount su])
            )
        )
    )
    (defun LQD|C_WrapStoa (patron:string executor:string amount:decimal)
        @doc "Wraps Native Stoa to DPTF Stoa"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
                    (sw:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_WrapStoa patron executor amount)
                )
                (format "Succesfully Wrapped {} STOA on Account {}" [amount sw])
            )
        )
    )
    (defun LQD|C_UnwrapUrStoa (patron:string executor:string amount:decimal)
        @doc "Unwrapper is the Ouronet Account doing the Unwrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md). \
            \ \
            \ Its register status can be verified with <LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
                    (su:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_UnwrapUrStoa patron executor amount)
                )
                (format "Succesfully Unwrapped {} URSTOA on Account {}" [amount su])
            )
        )
    )
    (defun LQD|C_WrapUrStoa (patron:string executor:string amount:decimal)
        @doc "Wrapper is the Ouronet Account doing the Wrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md). \
            \ \
            \ Its register status can be verified with <LIQUID.UR_IzOuronetAccountRegisteredForUrstoaHoldings>"
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (ref-LIQUID:module{StoaLiquidStakingV3} LIQUID)
                    (sw:string (ref-I|OURONET::OI|UC_ShortAccount executor))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-LIQUID::C_WrapUrStoa patron executor amount)
                )
                (format "Succesfully Wrapped {} URSTOA on Account {}" [amount sw])
            )
        )
    )
    ;;  [OUROBOROS_Client]
    (defun ORBR|C_Compress (executor:string ignis-amount:decimal)
        @doc "Compresses IGNIS - Ouronet Gas Token, generating OUROBOROS \
            \ Only whole IGNIS Amounts greater than or equal to 1.0 can be used for compression \
            \ Similar to Sublimation, the output amount is dependent on OUROBOROS price, set at a minimum of 1$ \
            \ Compression has 98.5% efficiency, 1.5% is lost as fees."
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV3} OUROBOROS)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ORBR::C_Compress executor ignis-amount)
                    )
                )
                (format "Succesfully compressed {} IGNIS to {} OUROBOROS" [ignis-amount (at 0 (at "output" ico))])
            )
        )
    )
    (defun ORBR|C_Sublimate (executor:string executee:string ouro-amount:decimal)
        @doc "Sublimates OUROBOROS, generating Ouronet Gas, in form of IGNIS Token \
            \ A minimum amount of 1 input OUROBOROS is required. Amount of IGNIS generated depends on OUROBOROS Price in $, \
            \ with the minimum value being set at 1$ (in case the actual value is lower than 1$ \
            \ Ignis is generated for 99% of the input Ouroboros amount, thus Sublimation has a fee of 1% \
            \ Needed for Sublimating negative Amounts"
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV3} OUROBOROS)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ORBR::C_Sublimate executor executee ouro-amount)
                    )
                )
                (format "Succesfully sublimated {} OUROBOROS to {} IGNIS" [ouro-amount (at 0 (at "output" ico))])
            )
        )
    )
    (defun ORBR|C_SublimateV2 (executor:string executee:string ouro-amount:decimal)
        @doc "Sublimates OUROBOROS, generating Ouronet Gas, in form of IGNIS Token \
            \ A minimum amount of 1 input OUROBOROS is required. Amount of IGNIS generated depends on OUROBOROS Price in $, \
            \ with the minimum value being set at 1$ (in case the actual value is lower than 1$ \
            \ Ignis is generated for 99% of the input Ouroboros amount, thus Sublimation has a fee of 1% \
            \ Can be used for Sublimation when OURO Supply is Positive, also being used in Firestarter."
        (with-capability (P|TS)
            (let
                (
                    (ref-ORBR:module{OuroborosV3} OUROBOROS)
                    (ico:object{IgnisCollectorV4.OutputCumulator}
                        (ref-ORBR::C_SublimateV2 executor executee ouro-amount)
                    )
                )
                (format "Succesfully sublimated {} OUROBOROS to {} IGNIS" [ouro-amount (at 0 (at "output" ico))])
                (at 0 (at "output" ico))
            )
        )
    )
    (defun ORBR|C_WithdrawFees (patron:string executor:string executee:string id:string)
        @doc "Withdraws collected DPTF Fees collected in standard mode \
        \ DPTF Fees collected in standard mode cumullate on the OUROBOROS Smart Account \
        \ Only the Token Owner can withdraw these fees."
        (with-capability (P|TS)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV4} IGNIS)
                    (ref-ORBR:module{OuroborosV3} OUROBOROS)
                    (ref-I|OURONET:module{OuronetInfoV3} IGNIS)
                    (st:string (ref-I|OURONET::OI|UC_ShortAccount executee))
                )
                (ref-IGNIS::XE_CollectIgnis patron
                    (ref-ORBR::C_WithdrawFees patron executor executee id)
                )
                (format "Succesfully withdrawn DPTF Fees for DPTF {} to Account {}" [id st])
            )
        )
    )

)

;; --- tables for 03_TS01-C2.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

