;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 5 of 24
;; This is STEP 5 of 25 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-4 must have run first, including the init steps between deploys.
;; 4 source file(s), 397,481 gas measured in the REPL gas model, 310,475 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;
;; TOTAL: 4 interface(s), 4 module(s), 8 table(s)
;; What it DEPLOYS, in load order:
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
;;      interface  AutostakeUsageV2
;;      module     ATSU
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact
;;      interface  VestingV2
;;      module     VST
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact
;;      interface  StoaLiquidStakingV2
;;      module     LIQUID
;;      table      P|T
;;      table      P|MT
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;      interface  OuroborosV2
;;      module     OUROBOROS
;;      table      P|T
;;      table      P|MT
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface AutostakeUsageV2
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
    (defun URCi_UnlimitedUncoilCumulator:object{IgnisCollectorV3.OutputCumulator} (ats:string account:string))
    (defun URCi_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator} (ats:string target:string))
    (defun URCi_KickStart:object{IgnisCollectorV3.OutputCumulator} (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} (fueler:string ats:string reward-token:string amount:decimal))
    (defun URCi_Coil:object{IgnisCollectorV3.OutputCumulator} (coiler:string ats:string rt:string amount:decimal))
    (defun URCi_Curl:object{IgnisCollectorV3.OutputCumulator} (curler:string ats1:string ats2:string rt:string amount:decimal))
    (defun URCi_ColdRecovery:object{IgnisCollectorV3.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Cull:object{IgnisCollectorV3.OutputCumulator} (culler:string ats:string))
    (defun URCi_HotRecovery:object{IgnisCollectorV3.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Recover:object{IgnisCollectorV3.OutputCumulator} (recoverer:string id:string nonce:integer))
    (defun URCi_Redeem:object{IgnisCollectorV3.OutputCumulator} (redeemer:string id:string nonce:integer))
    (defun URCi_DirectRecovery:object{IgnisCollectorV3.OutputCumulator} (recoverer:string ats:string ra:decimal))
    (defun URCi_Syphon:object{IgnisCollectorV3.OutputCumulator} (syphon-target:string ats:string syphon-amounts:[decimal]))
    (defun URCi_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator} (remover:string ats:string reward-token:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun AA_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string accounts-with-ats-data:[string])
    )
    (defun A_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
    )
    ;;
    ;;  [C]
    ;;
    (defun CC_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
    )
    (defun C_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator}(ats:string target:string))
        ;;
    (defun C_KickStart:object{IgnisCollectorV3.OutputCumulator} (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal))
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (fueler:string ats:string reward-token:string amount:decimal))
    (defun C_Coil:object{IgnisCollectorV3.OutputCumulator} (patron:string coiler:string ats:string rt:string amount:decimal))
    (defun C_Curl:object{IgnisCollectorV3.OutputCumulator} (patron:string curler:string ats1:string ats2:string rt:string amount:decimal))
        ;;
    (defun C_ColdRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string ats:string ra:decimal))
    (defun C_Cull:object{IgnisCollectorV3.OutputCumulator}(culler:string ats:string))
        ;;
    (defun C_HotRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string ats:string ra:decimal))
    (defun C_Recover:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string id:string nonce:integer))
    (defun C_Redeem:object{IgnisCollectorV3.OutputCumulator} (patron:string redeemer:string id:string nonce:integer))
        ;;
    (defun C_DirectRecovery:object{IgnisCollectorV3.OutputCumulator} (patron:string recoverer:string ats:string ra:decimal))
        ;;
    (defun C_Syphon:object{IgnisCollectorV3.OutputCumulator} (syphon-target:string ats:string syphon-amounts:[decimal]))

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
    (implements AutostakeUsageV2)

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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AutostakeKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
    (defcap ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY (ats:string reward-token:string)
        @event
        (compose-capability (GOV|ATSU_ADMIN))
        (compose-capability (ATSU|C>X_REMOVE-SECONDARY ats reward-token))
    )
    (defcap ATSU|C>REMOVE-SECONDARY (ats:string reward-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::CAP_Owner ats)
            (compose-capability (ATSU|C>X_REMOVE-SECONDARY ats reward-token))
        )
    )
    (defcap ATSU|C>X_REMOVE-SECONDARY (ats:string reward-token:string)
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
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
    (defcap ATSU|C>WITHDRAW-ROYALTIES (ats:string target:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
                (royalties:[decimal] (ref-ATS::UR_RewardTokenRUR ats 3))
                (sum:decimal (fold (+) 0.0 royalties))
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (ref-ATS::CAP_Owner ats)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UEV_EnforceAccountExists acc)
            (compose-capability (ATSU|C>NORMALIZE_LEDGER ats acc))
        )
    )
    (defcap ATSU|C>NORMALIZE_LEDGER (ats:string acc:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership recoverer)
            (ref-ATS::UEV_DirectRecoveryState ats true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap ATSU|C>SYPHON (ats:string syphon-amounts:[decimal])
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
                ;;
                (unstake-obj:object{UtilityAtsV3.Awo} (ref-ATS::UR_P1-7 ats acc position))
                (cull-output:[decimal] (ref-ATS::URC_CullValue ats unstake-obj))
            )
            cull-output
        )
    )
    (defun URCi_UnlimitedUncoilCumulator:object{IgnisCollectorV3.OutputCumulator}
        (ats:string account:string)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
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
    (defun URCi_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator}
        (ats:string target:string)
        @doc "Cost preview for C_WithdrawRoyalties — a single multi-transfer of the \
            \ pool's nonzero-royalty reward-token legs to <target>, re-derived purely \
            \ via TFT URCi_MultiTransferCumulator (same nonzero-royalty filter as exec)."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
    (defun URCi_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Cost preview for C_KickStart / A_KickStart (both delegate to XI_KickStart): \
            \ one reward-token transfer per rt (mapped purely), plus cold-mint + \
            \ cold-transfer. Cost-equivalent to XI_KickStart; the [index] output is the \
            \ pre-kickstart index (the exec value reflects post-write state)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (rbt-id:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (map
                        (lambda (idx:integer)
                            (ref-TFT::URCi_Transfer (at idx rt-lst) kickstarter ATS|SC_NAME (at idx rt-amounts))
                        )
                        (enumerate 0 (- (length rt-lst) 1))
                    )
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint rbt-id ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rbt-id ATS|SC_NAME kickstarter rbt-request-amount)
                )
                (index:decimal (ref-ATS::URC_Index ats))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [index])
        )
    )
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (fueler:string ats:string reward-token:string amount:decimal)
        @doc "Cost preview for C_Fuel — a single reward-token transfer into the ATS SC."
        ;;The op's own gate, not a copy of it. Without this the quote succeeded -- returning a
        ;;cost AND the post-text "Succesfully fueled ..." -- for a pair C_Fuel refuses outright.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-001b>>.
        (UEV_FuelableIndex ats)
        (let
            (
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
            )
            (ref-TFT::URCi_Transfer reward-token fueler ATS|SC_NAME amount)
        )
    )
    (defun URCi_Coil:object{IgnisCollectorV3.OutputCumulator}
        (coiler:string ats:string rt:string amount:decimal)
        @doc "Cost preview for C_Coil (flavor-B composer). Re-derives C_Coil's \
            \ Concatenate[transfer, mint, transfer] purely — calling each sub-op's \
            \ own cost reader (TFT URCi_Transfer, DPTF URCi_Mint) instead of the write \
            \ C_ — so it totals the IGNIS cost WITHOUT performing the coil. \
            \ Cost-equivalent to C_Coil's billed cumulator (same IGNIS; output list \
            \ mirrors the exec [c-rbt-amount])."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (coil-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                )
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt coiler ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME coiler c-rbt-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
        )
    )
    (defun URCi_Curl:object{IgnisCollectorV3.OutputCumulator}
        (curler:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Cost preview for C_Curl (flavor-B composer): two chained coils across \
            \ ats1/ats2, re-derived purely via sub-op cost readers (no writes). \
            \ Cost-equivalent to C_Curl's billed cumulator; output mirrors [c-rbt2-amount]."
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (coil1-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                )
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                (coil2-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                )
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt curler ATS|SC_NAME amount)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt1 ATS|SC_NAME false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt2 ATS|SC_NAME false)
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt2 ATS|SC_NAME curler c-rbt2-amount)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [c-rbt2-amount])
        )
    )
    ;;
    (defun URCi_ColdRecovery:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::UEV_ColdRecoveryState ats true)
        )
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                )
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (if (!= usable-cold-recovery-position -1)
                        EOC
                        (URCi_UnlimitedUncoilCumulator ats recoverer)
                    )
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
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
    (defun URCi_Cull:object{IgnisCollectorV3.OutputCumulator}
        (culler:string ats:string)
        @doc "Cost preview for C_Cull: flat 2x-biggest construct + one transfer per \
            \ reward-token whose cumulative cull weight is nonzero. Cull weights are \
            \ derived purely via URC_MultiCull/URC_SingleCull (the same values the exec \
            \ XI_*Cull writers return), so this is output-exact, not just cost-equivalent."
        (let
            (
                (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                )
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
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
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] cw)
        )
    )
    ;;
    (defun URCi_HotRecovery:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (h-rbt:string (ref-ATS::UR_HotRewardBearingToken ats))
                (new-nonce:integer (+ (ref-DPOF::UR_NoncesUsed h-rbt) 1))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "ATS|C_HotRecovery" "usage")
                        ATS|SC_NAME
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_Mint h-rbt)
                )
                (ico5:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator h-rbt [new-nonce] false)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [])
        )
    )
    (defun URCi_Recover:object{IgnisCollectorV3.OutputCumulator}
        (recoverer:string id:string nonce:integer)
        @doc "Cost preview for C_Recover (flavor-B composer): DPOF nonce-transfer + \
            \ DPOF burn + cold-mint + cold-transfer, re-derived purely via sub-op cost \
            \ readers. Cost-equivalent to C_Recover."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator id [nonce] false)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_Burn id)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false)
                )
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt ATS|SC_NAME recoverer nonce-supply)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
        )
    )
    (defun URCi_Redeem:object{IgnisCollectorV3.OutputCumulator}
        (redeemer:string id:string nonce:integer)
        @doc "Cost preview for C_Redeem: DPOF nonce-transfer + DPOF burn + a \
            \ multi-transfer of the decay-earned reward-token split, plus (when a decay \
            \ fee is retained and not redirected) fee-leg burns. Re-derives the decay math \
            \ purely (same as exec); sub-op costs via URCi readers, no writes."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_MoveCumulator id [nonce] false)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::URCi_Burn id)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator rt-lst ATS|SC_NAME redeemer earned-rts)
                )
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
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
                (ico4:object{IgnisCollectorV3.OutputCumulator}
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
    (defun URCi_DirectRecovery:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-ATS:module{AutostakeV3} ATS)
            )
            (ref-ATS::UEV_DirectRecoveryState ats true)
        )
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer c-rbt recoverer ATS|SC_NAME ra)
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Burn c-rbt ATS|SC_NAME)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_MultiTransferCumulator reward-tokens ATS|SC_NAME recoverer release-amounts)
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    ;;
    (defun URCi_Syphon:object{IgnisCollectorV3.OutputCumulator}
        (syphon-target:string ats:string syphon-amounts:[decimal])
        @doc "Cost preview for C_Syphon: one transfer per reward-token whose \
            \ syphon-amount is > 0 (EOC for zero legs), mapped purely over the pool's \
            \ reward-token list. Cost-equivalent to C_Syphon."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
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
    (defun URCi_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
        @doc "Cost preview for CC_RemoveSecondary — pure re-derivation of its 3-leg concat: one \
            \ ignis|token-issue construct + two full-amount transfers (reward-token in to \
            \ remover, primal-rt out from remover), moving the combined resident+unbound+ \
            \ royalty balance at the removed reward-token position."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
    (defun XI_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Shared write path for both the owner (C_KickStart) and administrative \
            \ (A_KickStart) entrypoints (audit finding #11M / M2 fix). All bound and \
            \ authorization checks live in the composed capability chain \
            \ (ATSU|C>X_KICKSTART plus each leaf) - nothing here enforces."
        (require-capability (SECURE))
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (rbt-id:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                ;;
                (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                    (fold
                        (lambda
                            (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
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
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::C_Mint patron ATS|SC_NAME rbt-id rbt-request-amount false)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-ATS:module{AutostakeV3} ATS)
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
    (defun XI_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-IGNIS::UC_IgnisPrice "ATS|CC_RemoveSecondary" "ats-secondary")
                        ATS|SC_NAME
                        (ref-IGNIS::URC_IsVirtualGasZero)
                        []
                    )
                )
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_Transfer remover ATS|SC_NAME remover reward-token remove-sum true)
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::C_Transfer remover remover ATS|SC_NAME primal-rt remove-sum true)
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
    (defun AA_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string accounts-with-ats-data:[string])
        @doc "Administrative Variant. Fix (audit finding #1C / C2b): <accounts-with-ats-data> is now \
            \ IGNORED — XI_RemoveSecondary always re-derives the complete account list on-chain via \
            \ <ATS.URH_ExistingAutostakePairs ats> itself, so a caller-supplied list can no longer be \
            \ incomplete/stale and silently desync some accounts' stored positions. The parameter is kept \
            \ only for interface-signature compatibility (AutostakeUsageV2 is unchanged); do not rely on \
            \ its contents."
        (P|UEV_IMC)
        (with-capability (ATSU|C>ADMINISTRATIVE-REMOVE-SECONDARY ats reward-token)
            (XI_RemoveSecondary remover ats reward-token)
        )
    )
    (defun A_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Administrative variant (audit finding #11M / M2): forgoes pool ownership \
            \ for module governance (GOV|ATSU_ADMIN); resulting index is only bound by \
            \ the shared 0.1 floor, no ceiling - for legitimate ratios above 100.0."
        (P|UEV_IMC)
        (with-capability (ATSU|C>ADMINISTRATIVE-KICKSTART executor ats rt-amounts rbt-request-amount)
            (XI_KickStart patron executor ats rt-amounts rbt-request-amount)
        )
    )
    (defun CC_RemoveSecondary:object{IgnisCollectorV3.OutputCumulator}
        (remover:string ats:string reward-token:string)
        @doc "Client Variant. XI_RemoveSecondary derives the complete account list itself via \
            \ <ATS.URH_ExistingAutostakePairs ats>."
        (P|UEV_IMC)
        (with-capability (ATSU|C>REMOVE-SECONDARY ats reward-token)
            (XI_RemoveSecondary remover ats reward-token)
        )
    )
    (defun C_WithdrawRoyalties:object{IgnisCollectorV3.OutputCumulator}
        (ats:string target:string)
        @doc "Fix (audit finding #33N): C_MultiTransfer debits every leg unconditionally - a \
            \ reward-token with a zero accrued royalty (routine whenever a pool has more than \
            \ one registered RT and royalty hasn't accrued evenly across all of them) hit \
            \ DPTF's UEV_Amount (amount > 0.0) enforce and crashed the whole withdrawal. Now \
            \ filters to only the reward-token/royalty legs with a real (> 0.0) balance before \
            \ handing off to C_MultiTransfer - the RUR-reset loop below still zeroes every RT's \
            \ bucket, zero or not, so no accounting is skipped, only the doomed zero-amount leg."
        (P|UEV_IMC)
        (with-capability (ATSU|C>WITHDRAW-ROYALTIES ats target)
            (let
                (
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                    target
                    ATS|SC_NAME
                    target
                    (map (lambda (index:integer) (at index reward-tokens)) nonzero-idx)
                    (map (lambda (index:integer) (at index royalties)) nonzero-idx)
                    true
                )
            )
        )
    )
    (defun C_KickStart:object{IgnisCollectorV3.OutputCumulator}
        (patron:string kickstarter:string ats:string rt-amounts:[decimal] rbt-request-amount:decimal)
        @doc "Owner-facing variant. Fix (audit finding #11M / M2): resulting index now \
            \ bounded to [0.1, 100.0] via ATSU|C>KICKSTART / ATSU|C>X_KICKSTART."
        (P|UEV_IMC)
        (with-capability (ATSU|C>KICKSTART kickstarter ats rt-amounts rbt-request-amount)
            (XI_KickStart patron kickstarter ats rt-amounts rbt-request-amount)
        )
    )
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator}
        (fueler:string ats:string reward-token:string amount:decimal)
        @doc "Fuels an <ats> ATS-Pair, increasing it Index."
        (P|UEV_IMC)
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
            )
            (with-capability (ATSU|C>FUEL ats reward-token)
                (ref-ATS::XE_UpdateRUR ats reward-token 1 true amount)
                (ref-TFT::C_Transfer fueler fueler ATS|SC_NAME reward-token amount true)
            )
        )
    )
    (defun C_Coil:object{IgnisCollectorV3.OutputCumulator}
        (patron:string coiler:string ats:string rt:string amount:decimal)
        @doc "Autostakes an <rt> Token on <ats> ATS-Pair. \
            \ If Hibernate is on, retains the <c-rbt-amount>, which will then be hibernated \
            \ from the TALOS module, and sent as Hibernated H| Token to the <coiler>"
        (P|UEV_IMC)
        (with-capability (ATSU|C>COIL ats rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    ;;<ats>
                    (coil-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats rt amount)
                    )
                    (input-amount:decimal (at "first-input-amount" coil-data))
                    (royalty-fee:decimal (at "royalty-fee" coil-data))
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron coiler ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt c-rbt-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron ATS|SC_NAME coiler c-rbt c-rbt-amount true)
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
    (defun C_Curl:object{IgnisCollectorV3.OutputCumulator}
        (patron:string curler:string ats1:string ats2:string rt:string amount:decimal)
        @doc "Coils through 2 ATS-Pairs, outputting the <c-rbt2> to the <curler> \
            \ Both <ats1> and <ats2> must have <hibernation> off"
        (P|UEV_IMC)
        (with-capability (ATSU|C>CURL ats1 ats2 rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    ;;<ats1>
                    (coil1-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                    )
                    (input1-amount:decimal (at "first-input-amount" coil1-data))
                    (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                    (c-rbt1:string (at "rbt-id" coil1-data))
                    (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                    ;;
                    ;;<ats2>
                    (coil2-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats2 c-rbt1 c-rbt1-amount)
                    )
                    (input2-amount:decimal (at "first-input-amount" coil2-data))
                    (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                    (c-rbt2:string (at "rbt-id" coil2-data))
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron curler ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt1 c-rbt1-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt2 c-rbt2-amount false)
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron ATS|SC_NAME curler c-rbt2 c-rbt2-amount true)
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
    (defun C_ColdRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string ats:string ra:decimal)
        (P|UEV_IMC)
        (with-capability (ATSU|C>DEPLOY ats recoverer)
            (XI_DeployAccount ats recoverer)
            (let
                (
                    (ref-ATS:module{AutostakeV3} ATS)
                    (usable-cold-recovery-position:integer (ref-ATS::URC_WhichPosition ats ra recoverer))
                )
                (enforce (!= usable-cold-recovery-position 0) "Cold Recovery Unavailable! All existing Positions are used!")
                (with-capability (ATSU|C>COLD_RECOVERY recoverer ats ra usable-cold-recovery-position)
                    (let
                        (
                            (ref-U|LST:module{StringProcessorV2} U|LST)
                            (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                            (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                            (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                            (ref-TFT:module{TrueFungibleTransferV2} TFT)
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

                            (ico0:object{IgnisCollectorV3.OutputCumulator}
                                ;;10 Flat IGNIS cost for Cold Recovery
                                (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME trigger [])
                            )
                            (ico1:object{IgnisCollectorV3.OutputCumulator}
                                (ref-TFT::C_Transfer patron recoverer ATS|SC_NAME c-rbt ra true)
                            )
                            (ico2:object{IgnisCollectorV3.OutputCumulator}
                                (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                            )
                            ;;
                            (c-fr:bool (ref-ATS::UR_ColdRecoveryFeeRedirection ats))
                            (cull-time:time (ref-ATS::URC_CullColdRecoveryTime ats recoverer))
                            ;;
                            (ico3:object{IgnisCollectorV3.OutputCumulator}
                                (if (!= usable-cold-recovery-position -1)
                                    EOC
                                    (URCi_UnlimitedUncoilCumulator ats recoverer)
                                )
                            )
                            (ico4:object{IgnisCollectorV3.OutputCumulator}
                                ;;Handle the Fee Part
                                (if (= c-rbt-fee 0.0)
                                    EOC
                                    (if c-fr
                                        EOC
                                        (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                                            (fold
                                                (lambda
                                                    (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
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
                        (XIv_StoreUnstakeObject ats recoverer usable-cold-recovery-position
                            { "reward-tokens"   : positive-c-fr
                            , "cull-time"       : cull-time}
                        )
                        (XI_Normalize ats recoverer)
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico0 ico1 ico2 ico3 ico4] [])
                    )
                )
            )
        )
    )
    (defun C_Cull:object{IgnisCollectorV3.OutputCumulator}
        (culler:string ats:string)
        (P|UEV_IMC)
        (with-capability (ATSU|C>CULL culler ats)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-U|DEC:module{OuronetDecimalsV2} U|DEC)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (c0:[decimal] (XI_MultiCull ats culler))
                    (c1:[decimal] (XI_SingleCull ats culler 1))
                    (c2:[decimal] (XI_SingleCull ats culler 2))
                    (c3:[decimal] (XI_SingleCull ats culler 3))
                    (c4:[decimal] (XI_SingleCull ats culler 4))
                    (c5:[decimal] (XI_SingleCull ats culler 5))
                    (c6:[decimal] (XI_SingleCull ats culler 6))
                    (c7:[decimal] (XI_SingleCull ats culler 7))
                    (ca:[[decimal]] [c0 c1 c2 c3 c4 c5 c6 c7])
                    (cw:[decimal] (ref-U|DEC::UC_AddHybridArray ca))
                    ;;
                    (price:decimal (ref-IGNIS::UC_IgnisPrice "ATS|C_Cull" "usage"))
                    (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ATS|SC_NAME trigger [])
                    )
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL acc
                                    (if (!= (at idx cw) 0.0)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 2 false (at idx cw))
                                            (ref-TFT::C_Transfer culler ATS|SC_NAME culler (at idx rt-lst) (at idx cw) true)
                                        )
                                        EOC
                                    )
                                )
                            )
                            []
                            (enumerate 0 (- (length rt-lst) 1))
                        )
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators folded-obj [])
                    )
                )
                (XI_Normalize ats culler)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2] cw)
            )
        )
    )
    (defun C_HotRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string ats:string ra:decimal)
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
        (with-capability (ATS|C>HOT_RECOVERY recoverer ats ra)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (h-rbt:string (ref-ATS::UR_HotRewardBearingToken ats))
                (present-time:time (at "block-time" (chain-data)))
                (meta-data-obj:object{AutostakeV3.ATS|Hot} {"mint-time" : present-time})
                (new-nonce:integer (+ (ref-DPOF::UR_NoncesUsed h-rbt) 1))
                ;;
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConstructOutputCumulator 
                                (ref-IGNIS::UC_IgnisPrice "ATS|C_HotRecovery" "usage")
                                ATS|SC_NAME
                                (ref-IGNIS::URC_IsVirtualGasZero)
                                []
                            )
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron recoverer ATS|SC_NAME c-rbt ra true)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                        )
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Mint patron ATS|SC_NAME h-rbt ra [meta-data-obj])
                        )
                        (ico5:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer patron ATS|SC_NAME recoverer h-rbt [new-nonce] true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4 ico5] [])
                )
        )
        )
    )
    (defun C_Recover:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string id:string nonce:integer)
        (P|UEV_IMC)
        ;;THE CAPABILITY IS ACQUIRED BEFORE THE `let`, and that ordering is load-bearing.
        ;;FIXED 2026-09-12: it used to sit INSIDE the let body, so the eager binding group ran first
        ;;-- and for a token that is not reward-bearing `UR_RewardBearingToken` returns the BAR
        ;;sentinel, so the next binding looked up ATS pair `|` and died with
        ;;`No value found in table ouronet-ns.ATS_ATS|Pairs for key: |`. The cap's own
        ;;`(enforce iz-rbt "Invalid Hot-RBT")` -- written for exactly that input -- was never reached.
        ;;Both cap arguments are plain defun parameters, so hoisting costs nothing, and it is also the
        ;;shape StoicSyntax asks for: validation in the defcap, work in the body.
        (with-capability (ATS|C>RECOVER recoverer id nonce)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ats:string (ref-DPOF::UR_RewardBearingToken id))
                (c-rbt:string (ref-ATS::UR_ColdRewardBearingToken ats))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply id nonce))
            )
                (let
                    (
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer patron recoverer ATS|SC_NAME id [nonce] true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Burn patron ATS|SC_NAME id nonce nonce-supply)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt nonce-supply false)
                        )
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_Transfer patron ATS|SC_NAME recoverer c-rbt nonce-supply true)
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [])
                )
            )
        )
    )
    (defun C_Redeem:object{IgnisCollectorV3.OutputCumulator}
        (patron:string redeemer:string id:string nonce:integer)
        (P|UEV_IMC)
        ;;CAPABILITY BEFORE THE `let` -- same fix as C_Recover above, same cause.
        ;;FIXED 2026-09-12: it used to sit inside the let body, and the eager binding group reads
        ;;`(ats (UR_RewardBearingToken id))` then immediately `(rt-lst (UR_RewardTokenList ats))`.
        ;;For a token that is not reward-bearing `ats` is the BAR sentinel, so that second read looks
        ;;up ATS pair `|` and aborts before the cap can raise its own "Invalid Hot-RBT". Both cap
        ;;arguments are plain defun parameters, so the hoist is free.
        (with-capability (ATSU|C>REDEEM redeemer id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Transfer patron redeemer ATS|SC_NAME id [nonce] true)
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (ref-DPOF::C_Burn patron ATS|SC_NAME id nonce nonce-supply)
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-TFT::C_MultiTransfer patron ATS|SC_NAME redeemer rt-lst earned-rts true)
                        )
                        (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                            (if have-fee-rts
                                (fold
                                    (lambda
                                        (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
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
                        (ico4:object{IgnisCollectorV3.OutputCumulator}
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
    (defun C_DirectRecovery:object{IgnisCollectorV3.OutputCumulator}
        (patron:string recoverer:string ats:string ra:decimal)
        (P|UEV_IMC)
        (with-capability (ATS|C>DIRECT_RECOVERY recoverer ats ra)
            (let
                (
                    (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                        (ref-TFT::C_Transfer patron recoverer ATS|SC_NAME c-rbt ra true)
                        ;;2]Burn it
                        (ref-DPTF::C_Burn patron ATS|SC_NAME c-rbt ra)
                        ;;3]Release equivalnet RTs (minus fee)
                        (ref-TFT::C_MultiTransfer patron ATS|SC_NAME recoverer reward-tokens release-amounts true)
                    ] 
                    []
                )
            )
        )
    )
    (defun C_Syphon:object{IgnisCollectorV3.OutputCumulator}
        (syphon-target:string ats:string syphon-amounts:[decimal])
        (P|UEV_IMC)
        (with-capability (ATSU|C>SYPHON ats syphon-amounts)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))
                    (folded-obj:[object{IgnisCollectorV3.OutputCumulator}]
                        (fold
                            (lambda
                                (acc:[object{IgnisCollectorV3.OutputCumulator}] idx:integer)
                                (ref-U|LST::UC_AppL acc
                                    (if (> (at idx syphon-amounts) 0.0)
                                        (do
                                            (ref-ATS::XE_UpdateRUR ats (at idx rt-lst) 1 false (at idx syphon-amounts))
                                            (ref-TFT::C_Transfer syphon-target ATS|SC_NAME syphon-target (at idx rt-lst) (at idx syphon-amounts) true)
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

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact =====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface VestingV2
    @doc "Exposes Vesting Functions"

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
    ;;  SCHEMAS
    ;;
    (defschema VST|MetaDataSchema
        release-amount:decimal
        release-date:time
    )
    (defschema VST|HibernatingSchema
        mint-time:time
        release-date:time
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
    ;;
    ;;  [UDC]
    ;;
    (defun UDC_ComposeVestingMetaData:[object{VST|MetaDataSchema}]
        (dptf:string amount:decimal offset:integer duration:integer milestones:integer)
    )
    ;;{5.2}  Compute [UC]
    ;;
    ;;  [UC]
    ;;
    (defun UC_MergeAll:[decimal] (balances:[decimal] seconds-to-unsleep:[decimal]))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_CullMetaDataAmountWithObject:list (id:string nonce:integer))
    (defun URC_SecondsToUnlock:[decimal] (id:string nonces:[integer]))
    (defun URCi_CreateSpecialTrueFungibleLink:object{IgnisCollectorV3.OutputCumulator} (dptf:string))
    (defun URCi_CreateSpecialOrtoFungibleLink:object{IgnisCollectorV3.OutputCumulator} (dptf:string vzh-tag:integer))
    (defun URCi_CreateSpecialTrueFungibleLinkStoa:decimal ())
    (defun URCi_CreateSpecialOrtoFungibleLinkStoa:decimal ())
    (defun URCi_RepurposeTrueFungible:object{IgnisCollectorV3.OutputCumulator} (dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun URCi_RepurposeOrtoFungible:object{IgnisCollectorV3.OutputCumulator} (dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun URCi_MergeNonces:object{IgnisCollectorV3.OutputCumulator} (dpof:string target:string nonces:[integer] vzh-tag:integer))
    (defun URCi_Unvest:object{IgnisCollectorV3.OutputCumulator} (unvester:string dpof:string nonce:integer))
    (defun URCi_Awake:object{IgnisCollectorV3.OutputCumulator} (awaker:string dpof:string nonce:integer))
    (defun URCi_Constrict:object{IgnisCollectorV3.OutputCumulator} (constricter:string ats:string rt:string amount:decimal dayz:integer))
    (defun URCi_Brumate:object{IgnisCollectorV3.OutputCumulator} (brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer))
    (defun URCi_Freeze:object{IgnisCollectorV3.OutputCumulator} (freezer:string freeze-output:string dptf:string amount:decimal))
    (defun URCi_ToggleTransferRoleFrozenDPTF:object{IgnisCollectorV3.OutputCumulator} (s-dptf:string))
    (defun URCi_ToggleTransferRoleReservedDPTF:object{IgnisCollectorV3.OutputCumulator} (s-dptf:string))
    (defun URCi_ToggleTransferRoleSleepingDPOF:object{IgnisCollectorV3.OutputCumulator} (s-dpof:string))
    (defun URCi_ToggleTransferRoleHibernatingDPOF:object{IgnisCollectorV3.OutputCumulator} (s-dpof:string))
    (defun URCi_Reserve:object{IgnisCollectorV3.OutputCumulator} (reserver:string dptf:string amount:decimal))
    (defun URCi_Unreserve:object{IgnisCollectorV3.OutputCumulator} (unreserver:string r-dptf:string amount:decimal))
    (defun URCi_Vest:object{IgnisCollectorV3.OutputCumulator} (vester:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer))
    (defun URCi_Sleep:object{IgnisCollectorV3.OutputCumulator} (sleeper:string target-account:string dptf:string amount:decimal duration:integer))
    (defun URCi_Unsleep:object{IgnisCollectorV3.OutputCumulator} (unsleeper:string dpof:string nonce:integer))
    (defun URCi_Hibernate:object{IgnisCollectorV3.OutputCumulator} (hibernator:string target-account:string dptf:string amount:decimal dayz:integer))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_NoncesForMerging (nonces:[integer]))
    (defun UEV_StillHasSleeping (sleeping-dpof:string nonce:integer))
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [C]
    ;;
    (defun C_CreateFrozenLink:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf:string))
    (defun C_CreateReservationLink:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf:string))
    (defun C_CreateVestingLink:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf:string))
    (defun C_CreateSleepingLink:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf:string))
    (defun C_CreateHibernatingLink:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf:string))
        ;;
    (defun C_Freeze:object{IgnisCollectorV3.OutputCumulator} (patron:string freezer:string freeze-output:string dptf:string amount:decimal))
    (defun C_RepurposeFrozen:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun C_ToggleTransferRoleFrozenDPTF:object{IgnisCollectorV3.OutputCumulator} (patron:string s-dptf:string target:string toggle:bool))
        ;;
    (defun C_Reserve:object{IgnisCollectorV3.OutputCumulator} (patron:string reserver:string dptf:string amount:decimal))
    (defun C_Unreserve:object{IgnisCollectorV3.OutputCumulator} (patron:string unreserver:string r-dptf:string amount:decimal))
    (defun C_RepurposeReserved:object{IgnisCollectorV3.OutputCumulator} (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string))
    (defun C_ToggleTransferRoleReservedDPTF:object{IgnisCollectorV3.OutputCumulator} (patron:string s-dptf:string target:string toggle:bool))
        ;;
    (defun C_Vest:object{IgnisCollectorV3.OutputCumulator} (patron:string vester:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer))
    (defun C_Unvest:object{IgnisCollectorV3.OutputCumulator} (patron:string unvester:string dpof:string nonce:integer))
    (defun C_RepurposeVested:object{IgnisCollectorV3.OutputCumulator} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
        ;;
    (defun C_Sleep:object{IgnisCollectorV3.OutputCumulator} (patron:string sleeper:string target-account:string dptf:string amount:decimal duration:integer))
    (defun C_Unsleep:object{IgnisCollectorV3.OutputCumulator} (patron:string unsleeper:string dpof:string nonce:integer))
    (defun C_Merge:object{IgnisCollectorV3.OutputCumulator} (patron:string merger:string dpof:string nonces:[integer]))
    (defun C_RepurposeMerge:object{IgnisCollectorV3.OutputCumulator} (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string))
    (defun C_RepurposeSleeping:object{IgnisCollectorV3.OutputCumulator} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun C_ToggleTransferRoleSleepingDPOF:object{IgnisCollectorV3.OutputCumulator} (patron:string s-dpof:string target:string toggle:bool))
    ;;
    (defun C_Hibernate:object{IgnisCollectorV3.OutputCumulator} (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer))
    (defun C_Awake:object{IgnisCollectorV3.OutputCumulator} (patron:string awaker:string dpof:string nonce:integer))
    (defun C_Slumber:object{IgnisCollectorV3.OutputCumulator} (patron:string merger:string dpof:string nonces:[integer]))
    (defun C_RepurposeSlumber:object{IgnisCollectorV3.OutputCumulator} (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string))
    (defun C_RepurposeHibernating:object{IgnisCollectorV3.OutputCumulator} (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string))
    (defun C_ToggleTransferRoleHibernatingDPOF:object{IgnisCollectorV3.OutputCumulator} (patron:string s-dpof:string target:string toggle:bool))
    ;;
    (defun C_Constrict:object{IgnisCollectorV3.OutputCumulator} (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer))
    (defun C_Brumate:object{IgnisCollectorV3.OutputCumulator} (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer))

)
;;
(module VST GOV
    @doc "VST — the vesting/lockup core that mints special DPTF/DPOF derivative tokens; \
        \ implements VestingV2. It creates link tokens (frozen, reservation, vesting, \
        \ sleeping, hibernating) for a DPTF, then Freezes/Reserves/Vests/Sleeps/Hibernates \
        \ amounts into schedule-bearing DPOF nonces (release amounts and dates). \
        \ Unvest/Unsleep/Awake/Merge/Slumber/Constrict/Brumate release or combine them, \
        \ alongside repurpose and transfer-role toggles."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements VestingV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_VST                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_VST                                (keyset-ref-guard VST|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|VESTING_ADMIN)))
    (defcap GOV|VESTING_ADMIN ()
        (enforce-one
            "VESTING Admin not satisfed"
            [
                (enforce-guard GOV|MD_VST)
                (enforce-guard GOV|SC_VST)
            ]
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|VestingKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|VestingKey)
        )
    )
    (defun GOV|VST|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|VST|SC_NAME)
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
    (defcap P|VST|REMOTE-GOV ()
        true
    )
    (defcap P|VST|CALLER ()
        true
    )
    (defcap P|TT ()
        (compose-capability (VST|GOV))
        (compose-capability (P|VST|CALLER))
        (compose-capability (SECURE))
        (compose-capability (P|VST|REMOTE-GOV))
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
        (with-capability (GOV|VESTING_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|VESTING_ADMIN)
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
        (with-capability (GOV|VESTING_ADMIN)
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
        (with-capability (GOV|VESTING_ADMIN)
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
                (ref-P|ATSU:module{OuronetPolicyV2} ATSU)
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|VST|CALLER)))
            )
            (ref-P|ATS::P|A_Add
                "VST|RemoteAtsGov"
                (create-capability-guard (P|VST|REMOTE-GOV))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            (ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst VST|SC_KEY                                (GOV|VestingKey))
    (defconst VST|SC_NAME                               (GOV|VST|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst EOC                                       (CT_EmptyCumulator))
    (defconst ATS|SC_NAME
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|ATS|SC_NAME)
        )
    )
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap VST|GOV ()
        @doc "Governor Capability for the Vesting Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap VST|C>FROZEN-LINK (dptf:string)
        @event
        (compose-capability (VST|C>LINK dptf))
    )
    (defcap VST|C>FREEZE (freezer:string freeze-output:string dptf:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DALOS::UEV_EnforceAccountType freeze-output false)
            (ref-DPTF::UEV_Frozen dptf true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>RESERVATION-LINK (dptf:string)
        @event
        (compose-capability (VST|C>LINK dptf))
    )
    (defcap VST|C>RESERVE (reserver:string dptf:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (iz-reservation:bool (ref-DPTF::UR_IzReservationOpen dptf))
            )
            (ref-DALOS::UEV_EnforceAccountType reserver false)
            (ref-DPTF::UEV_Reserved dptf true)
            (enforce iz-reservation (format "Reservation is not opened for Token {}" [dptf]))
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>UNRESERVE (unreserver:string r-dptf:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dptf:string (ref-DPTF::UR_Reservation r-dptf))
            )
            (ref-DALOS::UEV_EnforceAccountType unreserver true)
            (ref-DPTF::CAP_Owner dptf)
            (ref-DPTF::UEV_Reserved r-dptf true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>VESTING-LINK (dptf:string)
        @event
        (compose-capability (VST|C>LINK dptf))
    )
    (defcap VST|C>VEST (vester:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer)
        @event
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|VST::UEV_MilestoneWithTime offset duration milestones 788400000)
            (ref-DALOS::UEV_EnforceAccountType vester false)
            (ref-DALOS::UEV_EnforceAccountType target-account false)
            (ref-DPTF::CAP_Owner dptf)
            (ref-DPTF::UEV_Vesting dptf true)
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>CULL (unvester:string dpof:string nonce:integer culled-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (enforce (> culled-amount 0.0) (format "Nonce {} cant be culled" [nonce]))
            (ref-DALOS::UEV_EnforceAccountType unvester false)
            (ref-DPOF::UEV_Vesting dpof true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>SLEEPING-LINK (dptf:string)
        @event
        (compose-capability (VST|C>LINK dptf))
    )
    (defcap VST|C>SLEEP (sleeper:string target-account:string dptf:string amount:decimal duration:integer)
        @event
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;Limit <Sleep> to 25 Years
            (ref-U|VST::UEV_MilestoneWithTime 0 duration 1 788400000)
            (ref-DALOS::UEV_EnforceAccountType target-account false)
            (ref-DPTF::UEV_Sleeping dptf true)
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>UNSLEEP (unsleeper:string dpof:string nonce:integer nonce-supply:decimal culled-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping dpof))
            )
            (ref-DALOS::UEV_EnforceAccountType unsleeper false)
            (ref-DPTF::UEV_Sleeping dptf true)
            (enforce 
                (= nonce-supply culled-amount) 
                (format "{} Nonce {} cannot be unsleeped yet" [dpof nonce])
            )
            (compose-capability (P|TT))
        )
    )
    ;;THE DPOF-KIND GUARDS BELOW, added 2026-09-12, close a defect that minted an unreadable nonce.
    ;;
    ;;Both of these clients funnel into XIv_MergeNonces, which picks the metadata shape from its
    ;;<vzh-tag>: tag 2 writes SLEEPING metadata ({release-amount, release-date}), tag 3 writes
    ;;HIBERNATING metadata ({mint-time, release-date}). C_Merge passes 2; C_Slumber passes 3. That
    ;;branching is correct and is NOT what was wrong.
    ;;
    ;;What was wrong: neither cap checked WHAT KIND OF TOKEN <dpof> is -- they compose VST|X>MERGE,
    ;;which only validates the merger's account. So the metadata shape was decided by WHICH CLIENT
    ;;the caller picked rather than by what the token IS. Point C_Slumber at a SLEEPING (Z|) token
    ;;and it stamps hibernation metadata onto it; VST|MetaDataSchema is the sleeping shape, so
    ;;C_Unsleep then dies on a RUNTIME TYPECHECK before reaching any enforce, and the nonce is
    ;;permanently un-unsleepable while still in circulation. That is how Z|MOCKA nonce 3 was created
    ;;(modules/VST.repl <<VST-G7>>).
    ;;
    ;;Prefix discrimination is the established idiom for this -- 02_SCORE.pact:2522/:2526 already
    ;;test (take 2 dpof-id) against ["Z|" "H|"].
    ;;
    ;;DELIBERATELY NOT ADDED to VST|C>REPURPOSE-MERGE / VST|C>REPURPOSE-SLUMBER, and the reason
    ;;matters: RepurposeSlumber is the ONLY remaining exit for a nonce that was already minted wrong.
    ;;Guarding it on kind would strand exactly the holders this fix exists to protect. These two caps
    ;;stop NEW bad rows; the repurpose path stays open for the ones that exist.
    (defcap VST|C>MERGE (merger:string dpof:string nonces:[integer])
        @event
        (enforce (= (take 2 dpof) "Z|") "Merge requires a Sleeping DPOF")
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|X>MERGE merger dpof))
    )
    (defcap VST|C>SLUMBER (merger:string dpof:string nonces:[integer])
        @event
        (enforce (= (take 2 dpof) "H|") "Slumber requires a Hibernating DPOF")
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|X>MERGE merger dpof))
    )
    (defcap VST|X>MERGE (merger:string dpof:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership merger)
            (ref-DALOS::UEV_EnforceAccountType merger false)
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>HIBERNATE (hibernator:string target-account:string dptf:string amount:decimal dayz:integer)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DALOS::UEV_EnforceAccountType target-account false)
            (ref-DPTF::UEV_Hibernation dptf true)
            (enforce
                (and (>= dayz 1) (<= dayz 36500))
                "Between 1 Day and 100 years is allowed for Hibernation"
            )
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>AWAKE (awaker:string dpof:string nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DALOS::UEV_EnforceAccountType awaker false)
            (ref-DPOF::UEV_Hibernation dpof true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>REPURPOSE-FROZEN-TF (dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-TRUE-FUNGIBLE dptf-to-repurpose repurpose-from repurpose-to 1))
    )
    (defcap VST|C>REPURPOSE-RESERVED-TF (dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-TRUE-FUNGIBLE dptf-to-repurpose repurpose-from repurpose-to 2))
    )
    (defcap VST|C>REPURPOSE-VESTING-MF (dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE dpof-to-repurpose [nonce] repurpose-from repurpose-to 1))
    )
    (defcap VST|C>REPURPOSE-SLEEPING-MF (dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE dpof-to-repurpose [nonce] repurpose-from repurpose-to 2))
    )
    (defcap VST|C>REPURPOSE-HIBERNATING-MF (dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE dpof-to-repurpose [nonce] repurpose-from repurpose-to 3))
    )
    ;;
    (defcap VST|C>REPURPOSE-MERGE (dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        @event
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE dpof-to-repurpose nonces repurpose-from repurpose-to 2))
    )
    (defcap VST|C>REPURPOSE-SLUMBER (dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        @event
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE dpof-to-repurpose nonces repurpose-from repurpose-to 3))
    )
    ;;
    (defcap VST|C>REPURPOSE-TRUE-FUNGIBLE (dptf-to-repurpose:string repurpose-from:string repurpose-to:string fr-tag:integer)
        ;;UNREACHABLE BY CONSTRUCTION: both compose sites pass a LITERAL (1 and 2) and no Talos
        ;;wrapper exposes <fr-tag> to a client, so no input can trip this. Fail-closed backstop,
        ;;not a live guard - it cannot be pinned by a negative test. DPTF|C>UPDATE-SPECIAL carries
        ;;the IDENTICAL check and message downstream, unreachable for the same reason.
        (enforce (contains fr-tag [1 2]) "Invalid Frozen|Reserve Tag")
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dptf:string
                    (cond
                        ((= fr-tag 1) (ref-DPTF::UR_Frozen dptf-to-repurpose))
                        ((= fr-tag 2) (ref-DPTF::UR_Reservation dptf-to-repurpose))
                        BAR
                    )
                )
            )
            (ref-DALOS::UEV_SenderWithReceiver repurpose-from repurpose-to)
            (ref-DALOS::UEV_EnforceAccountType repurpose-to false)
            (ref-DPTF::CAP_Owner dptf)
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>REPURPOSE-ORTO-FUNGIBLE (dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string vzh-tag:integer)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::UEV_NoncesToAccount dpof-to-repurpose repurpose-from nonces)
            (compose-capability (VST|X>REPURPOSE-ORTO-FUNGIBLE dpof-to-repurpose repurpose-from repurpose-to vzh-tag))
        )
    )
    (defcap VST|X>REPURPOSE-ORTO-FUNGIBLE (dpof-to-repurpose:string repurpose-from:string repurpose-to:string vzh-tag:integer)
        (enforce (contains vzh-tag [1 2 3]) "Invalid Vesting|Sleeping|Hibernation Tag")
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (dptf:string
                    (cond
                        ((= vzh-tag 1) (ref-DPOF::UR_Vesting dpof-to-repurpose))
                        ((= vzh-tag 2) (ref-DPOF::UR_Sleeping dpof-to-repurpose))
                        ((= vzh-tag 3) (ref-DPOF::UR_Hibernation dpof-to-repurpose))
                        BAR
                    )
                )
            )
            (ref-DALOS::UEV_SenderWithReceiver repurpose-from repurpose-to)
            (ref-DALOS::UEV_EnforceAccountType repurpose-to false)
            (ref-DPTF::CAP_Owner dptf)
            (compose-capability (P|TT))
        )
    )
    ;;
    ;;
    (defcap VST|C>TOGGLE-FROZEN-TF-TR (s-dptf:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-TF-TR s-dptf target))
    )
    (defcap VST|C>TOGGLE-RESERVED-TF-TR (s-dptf:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-TF-TR s-dptf target))
    )
    (defcap VST|X>TOGGLE-SPECIAL-TF-TR (s-dptf:string target:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UEV_ParentOwnership s-dptf)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>TOGGLE-SLEEPING-OF-TR (s-dpof:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-OF-TR s-dpof target))
    )
    (defcap VST|C>TOGGLE-HIBERNATING-OF-TR (s-dpof:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-OF-TR s-dpof target))
    )
    (defcap VST|X>TOGGLE-SPECIAL-OF-TR (s-dpof:string target:string)
        @doc "Parent ownership for transfer-role toggle. Sleeping LP (Z|W|/Z|S|/Z|P|) cannot use \
            \ DPOF::UEV_ParentOwnership; gate on native LP DPTF owner instead."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fourth:string (drop 3 (take 4 s-dpof)))
            )
            (if (= fourth BAR)
                (ref-DPTF::CAP_Owner (ref-DPOF::UR_Sleeping s-dpof))
                (ref-DPOF::UEV_ParentOwnership s-dpof)
            )
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>LINK (dptf:string)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::CAP_Owner dptf)
        )
        (compose-capability (P|TT))
    )
    ;;
    (defcap ATSU|C>CONSTRICT (ats:string coil-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (h:bool (ref-ATS::UR_Hibernate ats))
            )
            (ref-ATS::UEV_RewardTokenExistance ats coil-token true)
            ;;"turned of" -> "turned off": a misspelling, corrected alongside its Brumate sibling above.
            (enforce h (format "Cannot Constrict when {} has Hibernation turned off" [ats]))
            (compose-capability (P|TT))
        )
    )
    (defcap ATSU|C>BRUMATE (ats1:string ats2:string curl-token:string)
        @event
        (let
            (
                (ref-ATS:module{AutostakeV3} ATS)
                (h1:bool (ref-ATS::UR_Hibernate ats1))
                (h2:bool (ref-ATS::UR_Hibernate ats2))
            )
            (ref-ATS::UEV_RewardTokenExistance ats1 curl-token true)
            ;;MESSAGE CONSTRUCTION FIXED 2026-09-12 (owner-authorised class): this was a BARE string
            ;;containing two `{}` placeholders and no `format`, so a caller saw the braces verbatim
            ;;instead of the two pair ids. Only variant of that shape in the codebase; the detector
            ;;`_conformance.py --rule enforce-msg-bare-template` now keeps it at 0. The "andfor"
            ;;run-together is corrected with it.
            (enforce (and (not h1) h2)
                (format "Brumate requires hibernation for {} set to off and for {} set to ON"
                    [ats1 ats2]))
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_EmptyOutputCumulatorV2)
        )
    )
    ;;
    (defun UDC_ComposeVestingMetaData:[object{VestingV2.VST|MetaDataSchema}]
        (dptf:string amount:decimal offset:integer duration:integer milestones:integer)
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (amount-lst:[decimal] (ref-U|VST::UCv_SplitBalanceForVesting (ref-DPTF::UR_Decimals dptf) amount milestones))
                (date-lst:[time] (ref-U|VST::UC_MakeVestingDateList offset duration milestones))
                (meta-data-chain:[object{VestingV2.VST|MetaDataSchema}] (zip (lambda (x:decimal y:time) { "release-amount": x, "release-date": y }) amount-lst date-lst))
            )
            (ref-DPTF::UEV_Amount dptf amount)
            meta-data-chain
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_MergeAll:[decimal] (balances:[decimal] seconds-to-unsleep:[decimal])
        @doc "Combines an equal length <balances> list representing Sleeping DPOF Account Balances \
            \ with a <seconds-to-unsleep> list to create an output decimal list with 3 decimals: \
            \ 1] 1st decimal, representing the amount of DPTF token that can be awakend \
            \ 2] 2nd decimal, representing the amount of Sleeping DPOF that must still exist in a sleeping state \
            \ 3] 3rd decimal, representing the mean computed weigthed average time in seconds until the the sleeping part must still remain asleep"
        (let
            (
                (sum:decimal (fold (+) 0.0 balances))
                (wake-numerator-denominator:[decimal]
                    (fold
                        (lambda
                            (acc:[decimal] idx:integer)
                            (let
                                (
                                    (wake:decimal (at 0 acc))
                                    (numerator:decimal (at 1 acc))
                                    (denominator:decimal (at 2 acc))
                                    (balance:decimal (at idx balances))
                                    (stu:decimal (at idx seconds-to-unsleep))
                                    (new-wake:decimal
                                        (if (<= stu 0.0)
                                            (+ wake balance)
                                            wake
                                        )
                                    )
                                    (new-numerator:decimal
                                        (if (> stu 0.0)
                                            (floor (+ numerator (* balance stu)) 24)
                                            numerator
                                        )
                                    )
                                    (new-denominator:decimal
                                        (if (>= stu 0.0)
                                            (+ denominator balance)
                                            denominator
                                        )
                                    )
                                )
                                [new-wake new-numerator new-denominator]
                            )
                        )
                        [0.0 0.0 0.0]
                        (enumerate 0 (- (length balances) 1))
                    )
                )
            )
            [
                (at 0 wake-numerator-denominator)
                (- sum (at 0 wake-numerator-denominator))
                (if (!= (at 2 wake-numerator-denominator) 0.0)
                    (floor (/ (at 1 wake-numerator-denominator) (at 2 wake-numerator-denominator)) 0)
                    0.0
                )

            ]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_CullMetaDataAmountWithObject:list (id:string nonce:integer)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (meta-data-chain:[object{VestingV2.VST|MetaDataSchema}] 
                    (ref-DPOF::UR_NonceMetaData id nonce)
                )
            )
            (fold
                (lambda
                    (acc:list item:object{VestingV2.VST|MetaDataSchema})
                    (let
                        (
                            (balance:decimal (at "release-amount" item))
                            (date:time (at "release-date" item))
                            (present-time:time (at "block-time" (chain-data)))
                            (t:decimal (diff-time present-time date))
                            (current-acc-amount:decimal (at 0 acc))
                            (current-acc-obj:list (at 1 acc))
                            (amount
                                (if (>= t 0.0)
                                    (+ current-acc-amount balance)
                                    current-acc-amount
                                )
                            )
                            (md-obj
                                (if (< t 0.0)
                                    (ref-U|LST::UC_AppL current-acc-obj item)
                                    current-acc-obj
                                )
                            )
                        )
                        [amount md-obj]
                    )
                )
                [0.0 []]
                meta-data-chain
            )
        )
    )
    (defun URC_SecondsToUnlock:[decimal] (id:string nonces:[integer])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (meta-data-array (ref-DPOF::UR_NoncesMetaDatas id nonces))
                (present-time:time (at "block-time" (chain-data)))
            )
            (fold
                (lambda
                    (acc:[decimal] idx:integer)
                    (ref-U|LST::UC_AppL
                        acc
                        (diff-time 
                            (at "release-date" (at 0 (take -1 (at idx meta-data-array)))) 
                            present-time
                        )
                    )
                )
                []
                (enumerate 0 (- (length meta-data-array) 1))
            )
        )
    )
    ;;
    (defun URCi_CreateSpecialTrueFungibleLink:object{IgnisCollectorV3.OutputCumulator}
        (dptf:string)
        @doc "Cost preview for C_CreateFrozenLink/C_CreateReservationLink (shared \
            \ XI_CreateSpecialTrueFungibleLink): issue the special wrapper (gas rail, empty \
            \ write-product output as the block-hash id is exec-only) + update-special on \
            \ <dptf> + the unconditional transfer-role toggle on the VST-owned wrapper \
            \ (the vst-link-role-toggle-tf leg on VST|SC_NAME == DPTF::URCi_ToggleTransferRole). \
            \ Cost is fr-tag independent (both tags issue 1 token + toggle)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;1]The link's own DETERRENCE, its own leg. Read from the single source the exec
                    ;;  also reads, and kept SEPARATE from the issue leg below so the preview has the
                    ;;  same leg COUNT as the exec -- UDC_PrimeIgnisCumulator discounts and
                    ;;  quarter-splits per leg, so folding two charges into one leg can round differently.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URCi_CreateSpecialTrueFungibleLinkDeterrence)
                        VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ;;2]Issue the special DPTF wrapper IN FULL (gas rail only; STOA collected separately).
                    ;;  Mirrors XB_IssueFree's own cumulator, which is exactly URCi_IssueGas over 1 token.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-DPTF::URCi_IssueGas 1)
                        VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ;;3]Link <dptf> <-> special wrapper
                    (ref-DPTF::URCi_UpdateSpecialTrueFungible dptf)
                    ;;4]Toggle transfer-role on the VST-owned special wrapper.
                    ;;  FIXED 2026-09-14: this modelled a hand-made 4.0 "leg cumulator" while the exec
                    ;;  pays the real DPTF|C_ToggleTransferRole, which is 59.0 -- the single largest
                    ;;  term in the old 55.0 under-quote.
                    (URCi_CreateSpecialTrueFungibleLinkToggle)
                ]
                []
            )
        )
    )
    (defun URCi_CreateSpecialTrueFungibleLinkStoa:decimal ()
        @doc "STOA leg of C_CreateFrozenLink / C_CreateReservationLink. Read-only twin of the \
            \ <stoa-costs> that XI_CreateSpecialTrueFungibleLink hands to XE_CollectStoa, so the \
            \ INFO_ preview and the charge are sourced from one place and cannot drift."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UR_UsagePrice "dptf")
        )
    )
    (defun URCi_CreateSpecialOrtoFungibleLinkStoa:decimal ()
        @doc "STOA leg of C_CreateVestingLink / C_CreateSleepingLink / C_CreateHibernatingLink. \
            \ Read-only twin of the <stoa-costs> that XI_CreateSpecialOrtoFungibleLink hands to \
            \ XE_CollectStoa. Note the key is \"dpmf\", not \"dpof\" -- the usage-price table \
            \ still carries the pre-rename name."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::UR_UsagePrice "dpmf")
        )
    )
    (defun URCi_CreateSpecialTrueFungibleLinkDeterrence:decimal ()
        @doc "The link's own DETERRENCE leg for C_CreateFrozenLink / C_CreateReservationLink. \
            \ SINGLE SOURCE (2026-09-14): read by BOTH URCi_CreateSpecialTrueFungibleLink and \
            \ XI_CreateSpecialTrueFungibleLink, so the quote and the charge cannot drift. Creating a \
            \ special link is priced as a small deterrence PLUS the full cost of the token it issues; \
            \ the exec used to charge only the issue, which is the half this reader restores."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UC_IgnisPrice "VST|C_CreateFrozenLink" "vst-link")
        )
    )
    (defun URCi_CreateSpecialOrtoFungibleLinkDeterrence:decimal ()
        @doc "The link's own DETERRENCE leg for C_CreateVestingLink / C_CreateSleepingLink / \
            \ C_CreateHibernatingLink. Single source for the preview and the exec, as its \
            \ true-fungible twin above."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UC_IgnisPrice "VST|C_CreateVestingLink" "vst-link")
        )
    )
    (defun URCi_CreateSpecialTrueFungibleLinkToggle:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "The transfer-role toggle leg that XI_CreateSpecialTrueFungibleLink pays on the \
            \ wrapper it just issued. The wrapper id is derived from the block hash, so the preview \
            \ cannot name it and cannot call DPTF::URCi_ToggleTransferRole (which reads the token's \
            \ konto row). Both halves are known without the id: the price is flat per op, and the \
            \ konto is VST|SC_NAME because VST is the issuer. Same IGNIS price row DPTF reads, so \
            \ this is a restatement of the exec leg, not a second price."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPTF|C_ToggleTransferRole" "usage")
                VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_CreateSpecialOrtoFungibleLinkToggle:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "The transfer-role toggle leg that XI_CreateSpecialOrtoFungibleLink pays on the \
            \ Vesting/Sleeping wrapper it just issued (Hibernating wrappers are transfer-free and \
            \ skip this leg). Ortofungible twin of the reader above -- same reasoning, DPOF price row."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (ref-IGNIS::UC_IgnisPrice "DPOF|C_ToggleTransferRole" "usage")
                VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        )
    )
    (defun URCi_CreateSpecialOrtoFungibleLink:object{IgnisCollectorV3.OutputCumulator}
        (dptf:string vzh-tag:integer)
        @doc "Cost preview for C_CreateVestingLink(1)/C_CreateSleepingLink(2)/ \
            \ C_CreateHibernatingLink(3) (shared XI_CreateSpecialOrtoFungibleLink): issue the \
            \ special DPOF wrapper (gas rail, empty write-product output) + update-special on \
            \ <dptf> + the transfer-role toggle (only for Vesting/Sleeping; Hibernating is \
            \ transfer-free -> EOC)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;1]The link's own DETERRENCE, its own leg -- see the true-fungible twin above for
                    ;;  why it is not folded into the issue leg.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URCi_CreateSpecialOrtoFungibleLinkDeterrence)
                        VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ;;2]Issue the special DPOF wrapper IN FULL (gas rail only; STOA collected separately)
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (ref-DPOF::URCi_IssueGas 1)
                        VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ;;3]Link <dptf> <-> special wrapper
                    (ref-DPOF::URCi_UpdateSpecialOrtoFungible dptf)
                    ;;4]Toggle transfer-role only for Vesting/Sleeping wrappers; Hibernating is
                    ;;  transfer-free -> EOC. FIXED 2026-09-14 for the same reason as the TF twin: this
                    ;;  modelled a hand-made 5.0 leg where the exec pays the real 54.0 toggle.
                    (if (or (= vzh-tag 1) (= vzh-tag 2))
                        (URCi_CreateSpecialOrtoFungibleLinkToggle)
                        EOC
                    )
                ]
                []
            )
        )
    )
    ;;  [Frozen Token Actions]
    (defun URCi_Freeze:object{IgnisCollectorV3.OutputCumulator}
        (freezer:string freeze-output:string dptf:string amount:decimal)
        @doc "Cost preview for C_Freeze: (conditional) freezer->VST transfer + mint of \
            \ the frozen wrapper + VST->freeze-output transfer, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (f-dptf:string (ref-DPTF::UR_Frozen dptf))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (!= freezer VST|SC_NAME)
                        (ref-TFT::URCi_Transfer dptf freezer VST|SC_NAME amount)
                        EOC
                    )
                    (ref-DPTF::URCi_Mint f-dptf VST|SC_NAME false)
                    (ref-TFT::URCi_Transfer f-dptf VST|SC_NAME freeze-output amount)
                ]
                []
            )
        )
    )
    (defun URCi_RepurposeTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @doc "Cost preview for C_RepurposeFrozen/C_RepurposeReserved (shared \
            \ XI_RepurposeTrueFungible): freeze <repurpose-from> + wipe + unfreeze + re-mint on \
            \ VST + transfer the wiped supply to <repurpose-to>, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (amount:decimal (ref-DPTF::UR_AccountSupply dptf-to-repurpose repurpose-from))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPTF::URCi_ToggleFreezeAccount dptf-to-repurpose)
                    (ref-DPTF::URCi_Wipe dptf-to-repurpose)
                    (ref-DPTF::URCi_ToggleFreezeAccount dptf-to-repurpose)
                    (ref-DPTF::URCi_Mint dptf-to-repurpose VST|SC_NAME false)
                    (ref-TFT::URCi_Transfer dptf-to-repurpose VST|SC_NAME repurpose-to amount)
                ]
                []
            )
        )
    )
    (defun URCi_ToggleTransferRoleFrozenDPTF:object{IgnisCollectorV3.OutputCumulator}
        (s-dptf:string)
        @doc "Cost preview for C_ToggleTransferRoleFrozenDPTF (single DPTF transfer-role toggle)."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::URCi_ToggleTransferRole s-dptf)
        )
    )
    ;;  [Reserve Token Actions]
    (defun URCi_Reserve:object{IgnisCollectorV3.OutputCumulator}
        (reserver:string dptf:string amount:decimal)
        @doc "Cost preview for C_Reserve: (conditional) reserver->VST transfer + mint of \
            \ the reserved wrapper + VST->reserver transfer, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (r-dptf:string (ref-DPTF::UR_Reservation dptf))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (if (!= reserver VST|SC_NAME)
                        (ref-TFT::URCi_Transfer dptf reserver VST|SC_NAME amount)
                        EOC
                    )
                    (ref-DPTF::URCi_Mint r-dptf VST|SC_NAME false)
                    (ref-TFT::URCi_Transfer r-dptf VST|SC_NAME reserver amount)
                ]
                []
            )
        )
    )
    (defun URCi_Unreserve:object{IgnisCollectorV3.OutputCumulator}
        (unreserver:string r-dptf:string amount:decimal)
        @doc "Cost preview for C_Unreserve: unreserver->VST transfer of the reserved \
            \ wrapper + burn + VST->unreserver transfer of the underlying, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (dptf:string (ref-DPTF::UR_Reservation r-dptf))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer r-dptf unreserver VST|SC_NAME amount)
                    (ref-DPTF::URCi_Burn r-dptf VST|SC_NAME)
                    (ref-TFT::URCi_Transfer dptf VST|SC_NAME unreserver amount)
                ]
                []
            )
        )
    )
    (defun URCi_ToggleTransferRoleReservedDPTF:object{IgnisCollectorV3.OutputCumulator}
        (s-dptf:string)
        @doc "Cost preview for C_ToggleTransferRoleReservedDPTF (single DPTF transfer-role toggle)."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::URCi_ToggleTransferRole s-dptf)
        )
    )
    ;;  [Vesting Token Actions]
    (defun URCi_Vest:object{IgnisCollectorV3.OutputCumulator}
        (vester:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer)
        @doc "Cost preview for C_Vest: DPOF mint of the vested token + (conditional) \
            \ vester->VST DPTF transfer + DPOF transfer of the vested nonce to target. \
            \ Re-derived purely; offset/duration/milestones affect only meta, not cost."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (dpof-id:string (ref-DPTF::UR_Vesting dptf))
                (nonce:integer (+ (ref-DPOF::UR_NoncesUsed dpof-id) 1))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_Mint dpof-id)
                    (if (!= vester VST|SC_NAME)
                        (ref-TFT::URCi_Transfer dptf vester VST|SC_NAME amount)
                        EOC
                    )
                    (ref-DPOF::URCi_MoveCumulator dpof-id [nonce] false)
                ]
                []
            )
        )
    )
    (defun URCi_Unvest:object{IgnisCollectorV3.OutputCumulator}
        (unvester:string dpof:string nonce:integer)
        @doc "Cost preview for C_Unvest: the per-object IGNIS cull price (obj-count * smallest \
            \ / 5) + the release leg (whole-nonce transfer when nothing stays vested, else \
            \ ready-amount transfer + re-mint of the still-vested remainder + its nonce \
            \ transfer) + the burn leg (nonce transfer to VST + burn). Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (culled-data:list (URC_CullMetaDataAmountWithObject dpof nonce))
                (culled-amount:decimal (at 0 culled-data))
                (remint-meta-data-chain:list (at 1 culled-data))
                ;;
                (dptf-id:string (ref-DPOF::UR_Vesting dpof))
                (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (return-amount:decimal (- nonce-supply culled-amount))
                ;;
                (obj-l:decimal (dec (length remint-meta-data-chain)))
                (smallest:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                (price:decimal (/ (* obj-l smallest) 5.0))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConstructOutputCumulator price VST|SC_NAME trigger []))
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (if (= return-amount 0.0)
                        (ref-TFT::URCi_Transfer dptf-id VST|SC_NAME unvester nonce-supply)
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [
                                (ref-TFT::URCi_Transfer dptf-id VST|SC_NAME unvester culled-amount)
                                (ref-DPOF::URCi_Mint dpof)
                                (ref-DPOF::URCi_MoveCumulator dpof [(+ 1 nonces-used)] false)
                            ]
                            []
                        )
                    )
                )
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            (ref-DPOF::URCi_MoveCumulator dpof [nonce] false)
                            (ref-DPOF::URCi_Burn dpof)
                        ]
                        []
                    )
                )
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
        )
    )
    (defun URCi_RepurposeOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @doc "Cost preview for C_RepurposeVested/C_RepurposeSleeping/C_RepurposeHibernating \
            \ (shared XI_RepurposeOrtoFungible): freeze <repurpose-from> + wipe the <nonce> + \
            \ unfreeze + re-mint on VST + transfer the new nonce to <repurpose-to>, purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof-to-repurpose))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_ToggleFreezeAccount dpof-to-repurpose)
                    (ref-DPOF::URCi_WipeCumulator dpof-to-repurpose
                        (ref-DPOF::UDC_RemovableNonces [nonce]
                            (ref-DPOF::UR_NoncesSupplies dpof-to-repurpose [nonce])))
                    (ref-DPOF::URCi_ToggleFreezeAccount dpof-to-repurpose)
                    (ref-DPOF::URCi_Mint dpof-to-repurpose)
                    (ref-DPOF::URCi_MoveCumulator dpof-to-repurpose [(+ 1 nonces-used)] false)
                ]
                []
            )
        )
    )
    ;;  [Sleeping Token Actions]
    (defun URCi_Sleep:object{IgnisCollectorV3.OutputCumulator}
        (sleeper:string target-account:string dptf:string amount:decimal duration:integer)
        @doc "Cost preview for C_Sleep: DPOF mint of the sleeping token + (conditional) \
            \ sleeper->VST DPTF transfer + DPOF nonce transfer to target. Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (dpof-id:string (ref-DPTF::UR_Sleeping dptf))
                (nonce:integer (+ (ref-DPOF::UR_NoncesUsed dpof-id) 1))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_Mint dpof-id)
                    (if (!= sleeper VST|SC_NAME)
                        (ref-TFT::URCi_Transfer dptf sleeper VST|SC_NAME amount)
                        EOC
                    )
                    (ref-DPOF::URCi_MoveCumulator dpof-id [nonce] false)
                ]
                []
            )
        )
    )
    (defun URCi_Unsleep:object{IgnisCollectorV3.OutputCumulator}
        (unsleeper:string dpof:string nonce:integer)
        @doc "Cost preview for C_Unsleep: unsleeper->VST DPOF nonce transfer + DPOF burn \
            \ + VST->unsleeper DPTF transfer of the released underlying. Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (dptf-id:string (ref-DPOF::UR_Sleeping dpof))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_MoveCumulator dpof [nonce] false)
                    (ref-DPOF::URCi_Burn dpof)
                    (ref-TFT::URCi_Transfer dptf-id VST|SC_NAME unsleeper nonce-supply)
                ]
                []
            )
        )
    )
    (defun URCi_MergeNonces:object{IgnisCollectorV3.OutputCumulator}
        (dpof:string target:string nonces:[integer] vzh-tag:integer)
        @doc "Cost preview for C_Merge/C_RepurposeMerge (vzh-tag 2) and C_Slumber/ \
            \ C_RepurposeSlumber (vzh-tag 3), shared XIv_MergeNonces: the per-nonce IGNIS merge \
            \ price (count * biggest) + destroy the input nonces (freeze/wipe/unfreeze) + \
            \ (conditional) release the free DPTF amount + (conditional) re-mint the still-locked \
            \ remainder as a new nonce and transfer it. Output == compute-merge-all, purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (dptf:string
                    (if (= vzh-tag 2)
                        (ref-DPOF::UR_Sleeping dpof)
                        (ref-DPOF::UR_Hibernation dpof)
                    )
                )
                (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof))
                (nonces-supplies:[decimal] (ref-DPOF::UR_NoncesSupplies dpof nonces))
                (how-many:decimal (dec (length nonces)))
                (biggest:decimal (ref-IGNIS::UC_IgnisLeg "tier-biggest"))
                (price:decimal (* how-many biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                ;;
                (stu:[decimal] (URC_SecondsToUnlock dpof nonces))
                (compute-merge-all:[decimal] (UC_MergeAll nonces-supplies stu))
                (free-amount:decimal (at 0 compute-merge-all))
                (locked-amount:decimal (at 1 compute-merge-all))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-IGNIS::UDC_ConstructOutputCumulator price VST|SC_NAME trigger [])
                    (ref-DPOF::URCi_ToggleFreezeAccount dpof)
                    (ref-DPOF::URCi_WipeCumulator dpof
                        (ref-DPOF::UDC_RemovableNonces nonces nonces-supplies))
                    (ref-DPOF::URCi_ToggleFreezeAccount dpof)
                    (if (!= free-amount 0.0)
                        (ref-TFT::URCi_Transfer dptf VST|SC_NAME target free-amount)
                        EOC
                    )
                    (if (!= locked-amount 0.0)
                        (ref-IGNIS::UDC_ConcatenateOutputCumulators
                            [
                                (ref-DPOF::URCi_Mint dpof)
                                (ref-DPOF::URCi_MoveCumulator dpof [(+ 1 nonces-used)] false)
                            ]
                            []
                        )
                        EOC
                    )
                ]
                compute-merge-all
            )
        )
    )
    (defun URCi_ToggleTransferRoleSleepingDPOF:object{IgnisCollectorV3.OutputCumulator}
        (s-dpof:string)
        @doc "Cost preview for C_ToggleTransferRoleSleepingDPOF (single DPOF transfer-role toggle)."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::URCi_ToggleTransferRole s-dpof)
        )
    )
    ;;
    (defun URCi_Hibernate:object{IgnisCollectorV3.OutputCumulator}
        (hibernator:string target-account:string dptf:string amount:decimal dayz:integer)
        @doc "Cost preview for C_Hibernate: DPOF mint of the hibernating token + \
            \ (conditional) hibernator->VST DPTF transfer + DPOF nonce transfer to target. \
            \ Re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (dpof-id:string (ref-DPTF::UR_Hibernation dptf))
                (nonce:integer (+ (ref-DPOF::UR_NoncesUsed dpof-id) 1))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_Mint dpof-id)
                    (if (!= hibernator VST|SC_NAME)
                        (ref-TFT::URCi_Transfer dptf hibernator VST|SC_NAME amount)
                        EOC
                    )
                    (ref-DPOF::URCi_MoveCumulator dpof-id [nonce] false)
                ]
                []
            )
        )
    )
    (defun URCi_Awake:object{IgnisCollectorV3.OutputCumulator}
        (awaker:string dpof:string nonce:integer)
        @doc "Cost preview for C_Awake: nonce transfer to VST + whole-nonce burn + remainder \
            \ DPTF transfer back to <awaker> + (conditional) burn of the time-decayed \
            \ hibernating fee. Output == [fee-promile remainder fee], re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (dptf-id:string (ref-DPOF::UR_Hibernation dpof))
                (precision:integer (ref-DPOF::UR_Decimals dpof))
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
                ;;
                (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                (release-time:time (at "release-date" (at 0 meta-data-chain)))
                (hibernating-period:decimal (diff-time release-time mint-time))
                ;;
                (present-time:time (at "block-time" (chain-data)))
                (elapsed-time:decimal (diff-time present-time mint-time))
                ;;
                (hibernating-fee-promile:decimal
                    (if (>= elapsed-time hibernating-period)
                        0.0
                        (floor (- 800.0 (* 800.0 (/ elapsed-time hibernating-period))) 4)
                    )
                )
                (remainder:decimal
                    (if (= hibernating-fee-promile 0.0)
                        nonce-supply
                        (at 0 (ref-U|ATS::UC_PromilleSplit hibernating-fee-promile nonce-supply precision))
                    )
                )
                (hibernating-fee:decimal (- nonce-supply remainder))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPOF::URCi_MoveCumulator dpof [nonce] false)
                    (ref-DPOF::URCi_Burn dpof)
                    (ref-TFT::URCi_Transfer dptf-id VST|SC_NAME awaker remainder)
                    (if (!= hibernating-fee 0.0)
                        (ref-DPTF::URCi_Burn dptf-id VST|SC_NAME)
                        EOC
                    )
                ]
                [hibernating-fee-promile remainder hibernating-fee]
            )
        )
    )
    (defun URCi_ToggleTransferRoleHibernatingDPOF:object{IgnisCollectorV3.OutputCumulator}
        (s-dpof:string)
        @doc "Cost preview for C_ToggleTransferRoleHibernatingDPOF (single DPOF transfer-role toggle)."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::URCi_ToggleTransferRole s-dpof)
        )
    )
    ;;
    (defun URCi_Constrict:object{IgnisCollectorV3.OutputCumulator}
        (constricter:string ats:string rt:string amount:decimal dayz:integer)
        @doc "Cost preview for C_Constrict: <rt> transfer into the ATS SC + rbt mint + \
            \ Hibernate of the rbt to <constricter>. Output == [c-rbt-amount], purely \
            \ (the XE_UpdateRUR aggregate side-writes carry no cumulator cost)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (coil-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats rt amount dayz))
                (c-rbt:string (at "rbt-id" coil-data))
                (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt constricter ATS|SC_NAME amount))
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt ATS|SC_NAME false))
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (URCi_Hibernate ATS|SC_NAME constricter c-rbt c-rbt-amount dayz))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [c-rbt-amount])
        )
    )
    (defun URCi_Brumate:object{IgnisCollectorV3.OutputCumulator}
        (brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        @doc "Cost preview for C_Brumate: <rt> transfer into the ATS SC + c-rbt1 mint (ats1) + \
            \ c-rbt2 mint (ats2) + Hibernate of c-rbt2 to <brumator>. Output == [c-rbt2-amount], \
            \ purely (the XE_UpdateRUR aggregate side-writes carry no cumulator cost)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-ATS:module{AutostakeV3} ATS)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (coil1-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount))
                (c-rbt1:string (at "rbt-id" coil1-data))
                (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                ;;
                (coil2-data:object{AutostakeV3.CoilData}
                    (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats2 c-rbt1 c-rbt1-amount dayz))
                (c-rbt2:string (at "rbt-id" coil2-data))
                (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                ;;
                (ico1:object{IgnisCollectorV3.OutputCumulator}
                    (ref-TFT::URCi_Transfer rt brumator ATS|SC_NAME amount))
                (ico2:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt1 ATS|SC_NAME false))
                (ico3:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::URCi_Mint c-rbt2 ATS|SC_NAME false))
                (ico4:object{IgnisCollectorV3.OutputCumulator}
                    (URCi_Hibernate ATS|SC_NAME brumator c-rbt2 c-rbt2-amount dayz))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3 ico4] [c-rbt2-amount])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_NoncesForMerging (nonces:[integer])
        (let
            (
                (l:integer (length nonces))
            )
            (enforce (>= l 2) "Merging requires at least 2 nonces")
        )
    )
    (defun UEV_StillHasSleeping (sleeping-dpof:string nonce:integer)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData sleeping-dpof nonce))
                (release-date:time (at "release-date" (at 0 meta-data-chain)))
                (present-time:time (at "block-time" (chain-data)))
                (dt:decimal (diff-time release-date present-time))
            )
            (enforce (> dt 0.0) (format "Nonce {} of Sleeping DPOF {} must be dormant for operation" [nonce sleeping-dpof]))
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 2 — SECURE
    (defun XI_CreateSpecialTrueFungibleLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string fr-tag:integer)
        (require-capability (SECURE))
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (dptf-owner:string (ref-DPTF::UR_Konto dptf))
                (dptf-name:string (ref-DPTF::UR_Name dptf))
                (dptf-ticker:string (ref-DPTF::UR_Ticker dptf))
                (dptf-decimals:integer (ref-DPTF::UR_Decimals dptf))
                (special-tf-id:[string]
                    (cond
                        ((= fr-tag 1) (ref-U|VST::UC_FrozenID dptf-name dptf-ticker))
                        ((= fr-tag 2) (ref-U|VST::UC_ReservedID dptf-name dptf-ticker))
                        [BAR]
                    )
                )
                (special-tf-name:string (at 0 special-tf-id))
                (special-tf-ticker:string (at 1 special-tf-id))
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPTF::XB_IssueFree
                        VST|SC_NAME
                        [special-tf-name]
                        [special-tf-ticker]
                        [dptf-decimals]
                        ;;
                        [false] ;;<can-upgrade>
                        [false] ;;<can-change-owner>
                        [true]  ;;<can-add-special-role>
                        ;;
                        [true]  ;;<can-freeze>
                        [true]  ;;<can-wipe>
                        [false] ;;<can-pause>
                        [true]  ;;<iz-special>
                    )
                )
                (special-dptf:string (at 0 (at "output" ico0)))
                (stoa-costs:decimal (ref-DALOS::UR_UsagePrice "dptf"))
            )
            ;;Create DPTF Account
            (ref-DPTF::XBv_DeployAccount dptf VST|SC_NAME)
            (ref-IGNIS::XE_CollectStoa patron stoa-costs)
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ;;MISSING DETERRENCE FIXED (2026-09-14). Creating a special link is priced as a
                    ;;small DETERRENCE plus paying IN FULL for the token it issues. This concat carried
                    ;;only the issue, so the deterrence half was designed in and never collected -- a
                    ;;revenue bug, not a quoting one, and the reason the preview read 118.72 HIGHER
                    ;;than the charge. Read from the same single source the preview reads.
                    ;;Measured by modules/VST.repl <<VST-I1>> and modules/SWP.repl <<SWP-I8>>/<<SWP-I9>>.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URCi_CreateSpecialTrueFungibleLinkDeterrence)
                        VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ico0 
                    (ref-DPTF::XE_UpdateSpecialTrueFungible dptf special-dptf fr-tag)
                    ;;Required Roles are on by default for VST|SC_NAME and dont need to be set except for the active transfer role
                    ;;Which technically isnt needed, but when set, makes the issued special token transfer restricted.
                    ;;Frozen and Reserved Tokens are transfer restricted
                    (ref-DPTF::C_ToggleTransferRole patron (ref-DPTF::UR_Konto special-dptf) VST|SC_NAME special-dptf true)
                ] 
                [special-dptf]
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_CreateSpecialOrtoFungibleLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string vzh-tag:integer)
        (require-capability (SECURE))
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (dptf-name:string (ref-DPTF::UR_Name dptf))
                (dptf-ticker:string (ref-DPTF::UR_Ticker dptf))
                (dptf-decimals:integer (ref-DPTF::UR_Decimals dptf))
                (special-of-id:[string]
                    (cond
                        ((= vzh-tag 1) (ref-U|VST::UC_VestingID dptf-name dptf-ticker))
                        ((= vzh-tag 2) (ref-U|VST::UC_SleepingID dptf-name dptf-ticker))
                        ((= vzh-tag 3) (ref-U|VST::UC_HibernationID dptf-name dptf-ticker))
                        [BAR]
                    )
                )
                (special-of-name:string (at 0 special-of-id))
                (special-of-ticker:string (at 1 special-of-id))
                (ico0:object{IgnisCollectorV3.OutputCumulator}
                    (ref-DPOF::XB_IssueFree
                        VST|SC_NAME
                        ;;
                        [special-of-name]
                        [special-of-ticker]
                        [dptf-decimals]
                        ;;
                        [false] ;;<can-upgrade>
                        [false] ;;<can-change-owner>
                        [true]  ;;<can-add-special-role>
                        [false] ;;<can-transfer-nft-create-role>
                        ;;
                        [true]  ;;<can-freeze>
                        [true]  ;;<can-wipe>
                        [false] ;;<can-pause>
                        ;;
                        [true]  ;;<iz-special>
                    )
                )
                (special-dpof:string (at 0 (at "output" ico0)))
                (stoa-costs:decimal (ref-DALOS::UR_UsagePrice "dpmf"))
            )
            ;;Create DPTF Account 
            (ref-DPTF::XBv_DeployAccount dptf VST|SC_NAME)
            (ref-IGNIS::XE_CollectStoa patron stoa-costs)
            (ref-IGNIS::UDC_ConcatenateOutputCumulators 
                [
                    ;;MISSING DETERRENCE FIXED (2026-09-14) -- see the true-fungible twin above.
                    (ref-IGNIS::UDC_ConstructOutputCumulator
                        (URCi_CreateSpecialOrtoFungibleLinkDeterrence)
                        VST|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
                    ico0 
                    (ref-DPOF::XE_UpdateSpecialOrtoFungible dptf special-dpof vzh-tag)
                    ;;Required Roles are on by default for VST|SC_NAME and dont need to be set except for the active transfer role
                    ;;Which technically isnt needed, but when set, makes the issued special token transfer restricted.
                    ;;Vested Tokens and Sleeping Tokens are transfer restricted, Hibernated Tokens are not
                    (if (or (= vzh-tag 1)(= vzh-tag 2))
                        (ref-DPOF::C_ToggleTransferRole patron (ref-DPOF::UR_Konto special-dpof) VST|SC_NAME special-dpof true)
                        EOC
                    )
                ]
                [special-dpof]
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RepurposeTrueFungible:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (amount:decimal (ref-DPTF::UR_AccountSupply dptf-to-repurpose repurpose-from))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;1]Freeze <repurpose-from> for <dptf-to-repurpose>
                    (ref-DPTF::C_ToggleFreezeAccount patron (ref-DPTF::UR_Konto dptf-to-repurpose) repurpose-from dptf-to-repurpose true)
                    ;;2]Wipe <dptf-to-repurpose> on <repurpose-from>
                    (ref-DPTF::C_Wipe patron (ref-DPTF::UR_Konto dptf-to-repurpose) repurpose-from dptf-to-repurpose)
                    ;;3]Unfreeze <repurpose-from>
                    (ref-DPTF::C_ToggleFreezeAccount patron (ref-DPTF::UR_Konto dptf-to-repurpose) repurpose-from dptf-to-repurpose false)
                    ;;4]Mint <dptf-to-repurpose> anew
                    (ref-DPTF::C_Mint patron VST|SC_NAME dptf-to-repurpose amount false)
                    ;;5]Transfer it to <repurpose-to>
                    (ref-TFT::C_Transfer patron VST|SC_NAME repurpose-to dptf-to-repurpose amount true)
                ]
                []
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RepurposeOrtoFungible:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (require-capability (SECURE))
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof-to-repurpose))
                (amount:decimal (ref-DPOF::UR_NonceSupply dpof-to-repurpose nonce))
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof-to-repurpose nonce))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;1]Freeze <repurpose-from> for <dpof-to-repurpose>
                    (ref-DPOF::C_ToggleFreezeAccount patron (ref-DPOF::UR_Konto dpof-to-repurpose) repurpose-from dpof-to-repurpose true)
                    ;;2]WipePartial <dpof-to-repurpose> on <repurpose-from>
                    (ref-DPOF::C_WipeClean patron (ref-DPOF::UR_Konto dpof-to-repurpose) repurpose-from dpof-to-repurpose [nonce])
                    ;;3]Unfreeze <repurpose-from>
                    (ref-DPOF::C_ToggleFreezeAccount patron (ref-DPOF::UR_Konto dpof-to-repurpose) repurpose-from dpof-to-repurpose false)
                    ;;4]Mint <dptf-to-repurpose> anew
                    (ref-DPOF::C_Mint patron VST|SC_NAME dpof-to-repurpose amount meta-data-chain)
                    ;;5]Transfer it to <repurpose-to>
                    (ref-DPOF::C_Transfer patron VST|SC_NAME repurpose-to dpof-to-repurpose [(+ 1 nonces-used)] true)
                ]
                []
            )
        )
    )
    ;;Enforce: 4 call sites (C_Merge, C_Slumber, C_RepurposeMerge, C_RepurposeSlumber) -- relocating the
    ;;          <vzh-tag> domain check duplicates it 4x, which is strictly more code.
    ;;          UNREACHABLE TODAY: all four sites pass a LITERAL (2 or 3) and no Talos wrapper
    ;;          exposes <vzh-tag> to a client, so no input can currently trip this. It is
    ;;          defence-in-depth for a future caller passing a variable -- NOT a live guard, and
    ;;          it cannot be pinned by a negative test. Read the `v` as "an enforcement lives
    ;;          here", not as "validation runs here".
    ;;Protection: Class 2 — SECURE
    (defun XIv_MergeNonces:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof:string merger:string target:string nonces:[integer] vzh-tag:integer)
        @doc "<vzh-tag> = 2; Sleeping Tokens \
            \ <vzh-tag> = 3: Hibernating Tokens "
        (enforce (contains vzh-tag [2 3]) "Only Sleeping and Hibernating Tokens can be merged")
        (require-capability (SECURE))
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (dptf:string 
                    (if (= vzh-tag 2)
                        (ref-DPOF::UR_Sleeping dpof)
                        (ref-DPOF::UR_Hibernation dpof)
                    )
                )
                (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof))
                (nonces-supplies:[decimal] (ref-DPOF::UR_NoncesSupplies dpof nonces))
                (sum:decimal (fold (+) 0.0 nonces-supplies))
                (how-many:decimal (dec (length nonces)))
                (biggest:decimal (ref-IGNIS::UC_IgnisLeg "tier-biggest"))
                (price:decimal (* how-many biggest))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                ;;
                (stu:[decimal] (URC_SecondsToUnlock dpof nonces))
                (compute-merge-all:[decimal] (UC_MergeAll nonces-supplies stu))
                ;;
                (free-amount:decimal (at 0 compute-merge-all))
                (locked-amount:decimal (at 1 compute-merge-all))
                (weigthed-locked-amount-in-seconds:integer (floor (at 2 compute-merge-all)))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    ;;A]5xNumber of Nonces in IGNIS for Merging
                    (ref-IGNIS::UDC_ConstructOutputCumulator price VST|SC_NAME trigger [])
                    ;;
                    ;;B]Destroy input Nonces through Wiping
                    ;;1]Freeze <merger> for <dpof>
                    (ref-DPOF::C_ToggleFreezeAccount patron (ref-DPOF::UR_Konto dpof) merger dpof true)
                    ;;2]WipePartial <dpof> on <merger>
                    (ref-DPOF::C_WipeClean patron (ref-DPOF::UR_Konto dpof) merger dpof nonces)
                    ;;3]Unfreeze <merger>
                    (ref-DPOF::C_ToggleFreezeAccount patron (ref-DPOF::UR_Konto dpof) merger dpof false)
                    ;;
                    ;;C]Release DPTF if <free-amount> is non zero
                    (if (!= free-amount 0.0)
                        (ref-TFT::C_Transfer patron VST|SC_NAME target dptf free-amount true)
                        EOC
                    )
                    ;;
                    ;;D]Release a new Orto-Fungible if <locked-amount> is non zero
                    (if (!= locked-amount 0.0)
                        (let
                            (
                                (release-date:time (at 0 (ref-U|VST::UC_MakeVestingDateList 0 weigthed-locked-amount-in-seconds 1)))
                            )
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-DPOF::C_Mint patron VST|SC_NAME dpof locked-amount (if (= vzh-tag 2)
                                            [
                                                ;;Sleeping Meta-Data
                                                {"release-amount"   : locked-amount
                                                ,"release-date"     : release-date}
                                            ]
                                            [
                                                ;;Hibernating Meta-Data
                                                {"mint-time"        : (at "block-time" (chain-data))
                                                ,"release-date"     : release-date}
                                            ]
                                        )
                                    )
                                    (ref-DPOF::C_Transfer patron VST|SC_NAME target dpof [(+ 1 nonces-used)] true)
                                ]
                                []
                            )
                        )
                        EOC
                    )
                ]
                compute-merge-all
            )
        )
    )
    ;;{5.7}  User [A/C]
    (defun C_CreateFrozenLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>FROZEN-LINK dptf)
            (XI_CreateSpecialTrueFungibleLink patron dptf 1)
        )
    )
    (defun C_CreateReservationLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>RESERVATION-LINK dptf)
            (XI_CreateSpecialTrueFungibleLink patron dptf 2)
        )
    )
    (defun C_CreateVestingLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>VESTING-LINK dptf)
            (XI_CreateSpecialOrtoFungibleLink patron dptf 1)
        )
    )
    (defun C_CreateSleepingLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>SLEEPING-LINK dptf)
            (XI_CreateSpecialOrtoFungibleLink patron dptf 2)
        )
    )
    (defun C_CreateHibernatingLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>SLEEPING-LINK dptf)
            (XI_CreateSpecialOrtoFungibleLink patron dptf 3)
        )
    )
    (defun C_Freeze:object{IgnisCollectorV3.OutputCumulator}
        (patron:string freezer:string freeze-output:string dptf:string amount:decimal)
        (P|UEV_IMC)
        (with-capability (VST|C>FREEZE freezer freeze-output dptf amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (f-dptf:string (ref-DPTF::UR_Frozen dptf))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]Freezer sends dptf to VST|SC_NAME, if its not already there
                        (if (!= freezer VST|SC_NAME)
                            (ref-TFT::C_Transfer patron freezer VST|SC_NAME dptf amount true)
                            EOC
                        )
                        ;;2]VST|SC_NAME mints F|dptf
                        (ref-DPTF::C_Mint patron VST|SC_NAME f-dptf amount false)
                        ;;3|VST|SC_Name sends F|dptf to freeze-output
                        (ref-TFT::C_Transfer patron VST|SC_NAME freeze-output f-dptf amount true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_RepurposeFrozen:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-FROZEN-TF dptf-to-repurpose repurpose-from repurpose-to)
            (XI_RepurposeTrueFungible patron dptf-to-repurpose repurpose-from repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleFrozenDPTF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string s-dptf:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-FROZEN-TF-TR s-dptf target)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::C_ToggleTransferRole patron (ref-DPTF::UR_Konto s-dptf) target s-dptf toggle)
            )
        )
    )
    (defun C_Reserve:object{IgnisCollectorV3.OutputCumulator}
        (patron:string reserver:string dptf:string amount:decimal)
        (P|UEV_IMC)
        (with-capability (VST|C>RESERVE reserver dptf amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (r-dptf:string (ref-DPTF::UR_Reservation dptf))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]Reserver sends dptf to VST|SC_NAME if its not already tehre
                        (if (!= reserver VST|SC_NAME)
                            (ref-TFT::C_Transfer patron reserver VST|SC_NAME dptf amount true)
                            EOC
                        )
                        ;;2]VST|SC_NAME mint R|dptf
                        (ref-DPTF::C_Mint patron VST|SC_NAME r-dptf amount false)
                        ;;3]VST|SC_NAME sends R|dptf to reserver
                        (ref-TFT::C_Transfer patron VST|SC_NAME reserver r-dptf amount true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_Unreserve:object{IgnisCollectorV3.OutputCumulator}
        (patron:string unreserver:string r-dptf:string amount:decimal)
        (P|UEV_IMC)
        (with-capability (VST|C>UNRESERVE unreserver r-dptf amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (dptf:string (ref-DPTF::UR_Reservation r-dptf))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]Unreserver sends R|dptf to VST|SC_NAME
                        (ref-TFT::C_Transfer patron unreserver VST|SC_NAME r-dptf amount true)
                        ;;2]VST|SC_NAME burns R|dptf
                        (ref-DPTF::C_Burn patron VST|SC_NAME r-dptf amount)
                        ;;3]VST|SC_NAME sends dptf back to unreserver
                        (ref-TFT::C_Transfer patron VST|SC_NAME unreserver dptf amount true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_RepurposeReserved:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-RESERVED-TF dptf-to-repurpose repurpose-from repurpose-to)
            (XI_RepurposeTrueFungible patron dptf-to-repurpose repurpose-from repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleReservedDPTF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string s-dptf:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-RESERVED-TF-TR s-dptf target)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::C_ToggleTransferRole patron (ref-DPTF::UR_Konto s-dptf) target s-dptf toggle)
            )
        )
    )
    (defun C_Vest:object{IgnisCollectorV3.OutputCumulator}
        (patron:string vester:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer)
        (P|UEV_IMC)
        (with-capability (VST|C>VEST vester target-account dptf amount offset duration milestones)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (dpof-id:string (ref-DPTF::UR_Vesting dptf))
                    (meta-data-chain:[object{VestingV2.VST|MetaDataSchema}] 
                        (UDC_ComposeVestingMetaData dptf amount offset duration milestones)
                    )
                    (nonce:integer (+ (ref-DPOF::UR_NoncesUsed dpof-id) 1))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]VST|SC_NAME mints the DPOF Vested Token
                        (ref-DPOF::C_Mint patron VST|SC_NAME dpof-id amount meta-data-chain)
                        ;;2]Vester transfers the DPTF Token to the VST|SC_NAME if its not already there
                        (if (!= vester VST|SC_NAME)
                            (ref-TFT::C_Transfer patron vester VST|SC_NAME dptf amount true)
                            EOC
                        )
                        ;;3]VST|SC_NAME transfers the DPOF Vested Token to target-account
                        (ref-DPOF::C_Transfer patron VST|SC_NAME target-account dpof-id [nonce] true)
                    ]
                    [nonce]
                )
            )
        )
    )
    (defun C_Unvest:object{IgnisCollectorV3.OutputCumulator}
        (patron:string unvester:string dpof:string nonce:integer)
        (P|UEV_IMC)
        (let
            (
                (culled-data:list (URC_CullMetaDataAmountWithObject dpof nonce))
                (culled-amount:decimal (at 0 culled-data))
            )
            (with-capability (VST|C>CULL unvester dpof nonce culled-amount)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        ;;
                        (dptf-id:string (ref-DPOF::UR_Vesting dpof))
                        (nonces-used:integer (ref-DPOF::UR_NoncesUsed dpof))
                        (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                        (remint-meta-data-chain:[object{VestingV2.VST|MetaDataSchema}] (at 1 culled-data))
                        ;;
                        (obj-l:decimal (dec (length remint-meta-data-chain)))
                        (smallest:decimal (ref-IGNIS::UC_IgnisLeg "tier-smallest"))
                        ;;
                        (price:decimal (/ (* obj-l smallest) 5.0))
                        (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
                        (return-amount:decimal (- nonce-supply culled-amount))
                        ;;
                        (ico1:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConstructOutputCumulator price VST|SC_NAME trigger [])
                        )
                        (ico2:object{IgnisCollectorV3.OutputCumulator}
                            (if (= return-amount 0.0)
                                ;;1]VST|SC_NAME transfers the whole dptf back to the unvester, when there is no return amount
                                (ref-TFT::C_Transfer patron VST|SC_NAME unvester dptf-id nonce-supply true)
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                    [
                                        ;;1]Only the ready to unvest dptf is trasnfered back to unvester
                                        (ref-TFT::C_Transfer patron VST|SC_NAME unvester dptf-id culled-amount true)
                                        ;;2]If return amount is non zero, it is minted as a new DPOF
                                        (ref-DPOF::C_Mint patron VST|SC_NAME dpof return-amount remint-meta-data-chain)
                                        ;;3]Together with the newly minted remainder, still vested, dppf
                                        (ref-DPOF::C_Transfer patron VST|SC_NAME unvester dpof [(+ 1 nonces-used)] true)
                                    ]
                                    []
                                )
                            )
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    ;;1]Transfer <nonce> to VST|SC_NAME for Burning
                                    (ref-DPOF::C_Transfer patron unvester VST|SC_NAME dpof [nonce] true)
                                    ;;2]Burn it
                                    (ref-DPOF::C_Burn patron VST|SC_NAME dpof nonce nonce-supply)
                                ]
                                []
                            )
                        )
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators [ico1 ico2 ico3] [])
                )
            )
        )
    )
    (defun C_RepurposeVested:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-VESTING-MF dpof-to-repurpose nonce repurpose-from repurpose-to)
            (XI_RepurposeOrtoFungible patron dpof-to-repurpose nonce repurpose-from repurpose-to)
        )
    )
    (defun C_Sleep:object{IgnisCollectorV3.OutputCumulator}
        (patron:string sleeper:string target-account:string dptf:string amount:decimal duration:integer)
        (P|UEV_IMC)
        (with-capability (VST|C>SLEEP sleeper target-account dptf amount duration)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (dpof-id:string (ref-DPTF::UR_Sleeping dptf))
                    (meta-data-chain:[object{VestingV2.VST|MetaDataSchema}] 
                        (UDC_ComposeVestingMetaData dptf amount 0 duration 1)
                    )
                    (nonce:integer (+ (ref-DPOF::UR_NoncesUsed dpof-id) 1))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]VST|SC_NAME mints the DPOF Sleeping Token
                        (ref-DPOF::C_Mint patron VST|SC_NAME dpof-id amount meta-data-chain)
                        ;;2]Sleeper transfers the DPTF Token to the VST|SC_NAME if its not already there
                        (if (!= sleeper VST|SC_NAME)
                            (ref-TFT::C_Transfer patron sleeper VST|SC_NAME dptf amount true)
                            EOC
                        )
                        ;;3]VST|SC_NAME transfers the DPOF Sleeping Token to target-account
                        (ref-DPOF::C_Transfer patron VST|SC_NAME target-account dpof-id [nonce] true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_Unsleep:object{IgnisCollectorV3.OutputCumulator}
        (patron:string unsleeper:string dpof:string nonce:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (culled-amount:decimal (at 0 (URC_CullMetaDataAmountWithObject dpof nonce)))
            )
            (with-capability (VST|C>UNSLEEP unsleeper dpof nonce nonce-supply culled-amount)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        ;;
                        (dptf-id:string (ref-DPOF::UR_Sleeping dpof))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            ;;1]Unsleeper transfers the initial dpof to the VST|SC_NAME
                            (ref-DPOF::C_Transfer patron unsleeper VST|SC_NAME dpof [nonce] true)
                            ;;2]Which is then burned in its entirety
                            (ref-DPOF::C_Burn patron VST|SC_NAME dpof nonce nonce-supply)
                            ;;3]VST|SC_NAME transfers in return the initial amount of the dpof, as the dptf counterpart
                            (ref-TFT::C_Transfer patron VST|SC_NAME unsleeper dptf-id nonce-supply true)
                        ]
                        []
                    )
                )
            )
        ) 
    )
    (defun C_Merge:object{IgnisCollectorV3.OutputCumulator}
        (patron:string merger:string dpof:string nonces:[integer])
        (P|UEV_IMC)
        (with-capability (VST|C>MERGE merger dpof nonces)
            (XIv_MergeNonces patron dpof merger merger nonces 2)
        )
    )
    (defun C_RepurposeMerge:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-MERGE dpof-to-repurpose nonces repurpose-from repurpose-to)
            (XIv_MergeNonces patron dpof-to-repurpose repurpose-from repurpose-to nonces 2)
        )
    )
    (defun C_RepurposeSleeping:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-SLEEPING-MF dpof-to-repurpose nonce repurpose-from repurpose-to)
            (XI_RepurposeOrtoFungible patron dpof-to-repurpose nonce repurpose-from repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleSleepingDPOF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string s-dpof:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-SLEEPING-OF-TR s-dpof target)
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-DPOF::C_ToggleTransferRole patron (ref-DPOF::UR_Konto s-dpof) target s-dpof toggle)
            )
        )
    )
    (defun C_Hibernate:object{IgnisCollectorV3.OutputCumulator}
        (patron:string hibernator:string target-account:string dptf:string amount:decimal dayz:integer)
        (P|UEV_IMC)
        (with-capability (VST|C>HIBERNATE hibernator target-account dptf amount dayz)
            (let
                (
                    (ref-U|VST:module{UtilityVstV2} U|VST)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (dpof-id:string (ref-DPTF::UR_Hibernation dptf))
                    (duration:integer (* dayz 86400))
                    (meta-data-chain:[object{VestingV2.VST|HibernatingSchema}]
                        [
                            {"mint-time"    : (at "block-time" (chain-data))
                            ,"release-date" : (at 0 (ref-U|VST::UC_MakeVestingDateList 0 duration 1))}
                        ]
                    )
                    (nonce:integer (+ (ref-DPOF::UR_NoncesUsed dpof-id) 1))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]VST|SC_NAME mints the DPOF Hibernating Token
                        (ref-DPOF::C_Mint patron VST|SC_NAME dpof-id amount meta-data-chain)
                        ;;2]Sleeper transfers the DPTF Token to the VST|SC_NAME if its not already there
                        (if (!= hibernator VST|SC_NAME)
                            (ref-TFT::C_Transfer patron hibernator VST|SC_NAME dptf amount true)
                            EOC
                        )
                        ;;3]VST|SC_NAME transfers the DPOF Sleeping Token to target-account
                        (ref-DPOF::C_Transfer patron VST|SC_NAME target-account dpof-id [nonce] true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_Awake:object{IgnisCollectorV3.OutputCumulator}
        (patron:string awaker:string dpof:string nonce:integer)
        @doc "Hibernated Tokens have a 80% peak awakening fee, \
            \ that goes down to zero as time elapses towards its release date.\
            \ This fee is discared (burning it), with no way of collecting it."
        (P|UEV_IMC)
        (with-capability (VST|C>AWAKE awaker dpof nonce)
            (let
                (
                    (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    ;;
                    (dptf-id:string (ref-DPOF::UR_Hibernation dpof))
                    (precision:integer (ref-DPOF::UR_Decimals dpof))
                    (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                    (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
                    ;;
                    (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                    (release-time:time (at "release-date" (at 0 meta-data-chain)))
                    (hibernating-period:decimal (diff-time release-time mint-time))
                    ;;
                    (present-time:time (at "block-time" (chain-data)))
                    (elapsed-time:decimal (diff-time present-time mint-time))
                    ;;
                    (hibernating-fee-promile:decimal
                        (if (>= elapsed-time hibernating-period)
                            0.0
                            (floor (- 800.0 (* 800.0 (/ elapsed-time hibernating-period))) 4)
                        )
                    )
                    (remainder:decimal 
                        (if (= hibernating-fee-promile 0.0)
                            nonce-supply
                            (at 0 (ref-U|ATS::UC_PromilleSplit hibernating-fee-promile nonce-supply precision))
                        )
                    )
                    (hibernating-fee:decimal (- nonce-supply remainder))
                )
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;1]Transfer Nonce to VST|SC_NAME
                        (ref-DPOF::C_Transfer patron awaker VST|SC_NAME dpof [nonce] true)
                        ;;2]Burn it whole
                        (ref-DPOF::C_Burn patron VST|SC_NAME dpof nonce nonce-supply)
                        ;;3]Transfer Remainder from VST|SC_NAME to <awaker>
                        (ref-TFT::C_Transfer patron VST|SC_NAME awaker dptf-id remainder true)
                        ;;4]Burn <hibernating-fee> if its greater than 0.0 on VST|SC_NAME
                        (if (!= hibernating-fee 0.0)
                            (ref-DPTF::C_Burn patron VST|SC_NAME dptf-id hibernating-fee)
                            EOC
                        )
                    ]
                    [hibernating-fee-promile remainder hibernating-fee]
                )
            )
        )
    )
    (defun C_Slumber:object{IgnisCollectorV3.OutputCumulator}
        (patron:string merger:string dpof:string nonces:[integer])
        (P|UEV_IMC)
        (with-capability (VST|C>SLUMBER merger dpof nonces)
            (XIv_MergeNonces patron dpof merger merger nonces 3)
        )
    )
    (defun C_RepurposeSlumber:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-SLUMBER dpof-to-repurpose nonces repurpose-from repurpose-to)
            (XIv_MergeNonces patron dpof-to-repurpose repurpose-from repurpose-to nonces 3)
        )
    )
    (defun C_RepurposeHibernating:object{IgnisCollectorV3.OutputCumulator}
        (patron:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-HIBERNATING-MF dpof-to-repurpose nonce repurpose-from repurpose-to)
            (XI_RepurposeOrtoFungible patron dpof-to-repurpose nonce repurpose-from repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleHibernatingDPOF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string s-dpof:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-HIBERNATING-OF-TR s-dpof target)
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-DPOF::C_ToggleTransferRole patron (ref-DPOF::UR_Konto s-dpof) target s-dpof toggle)
            )
        )
    )
    (defun C_Constrict:object{IgnisCollectorV3.OutputCumulator}
        (patron:string constricter:string ats:string rt:string amount:decimal dayz:integer)
            @doc "Constricts the <rt> Token, autostaking it in the ATS-Pair <ats>, generating Hibernated Token \
            \ Only works when <ats> has <hibernate> on"
        (P|UEV_IMC)
        (with-capability (ATSU|C>CONSTRICT ats rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    ;;<ats>
                    (coil-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats rt amount dayz)
                    )
                    (input-amount:decimal (at "first-input-amount" coil-data))
                    (royalty-fee:decimal (at "royalty-fee" coil-data))
                    (c-rbt:string (at "rbt-id" coil-data))
                    (c-rbt-amount:decimal (at "rbt-amount" coil-data))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron constricter ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt c-rbt-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (C_Hibernate patron ATS|SC_NAME constricter c-rbt c-rbt-amount dayz)
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
    (defun C_Brumate:object{IgnisCollectorV3.OutputCumulator}
        (patron:string brumator:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        @doc "Brumates the <rt> through 2 ATS-Pairs, \
            \ outputting the <c-rbt2> as Hibernated Token to the <brumator> \
            \ <ats1> must have <hibernation> off, and <ats2> may on for brumation to work"
        (P|UEV_IMC)
        (with-capability (ATSU|C>BRUMATE ats1 ats2 rt)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TFT:module{TrueFungibleTransferV2} TFT)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    ;;
                    ;;<ats1>
                    (coil1-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmounts ats1 rt amount)
                    )
                    (input1-amount:decimal (at "first-input-amount" coil1-data))
                    (royalty1-fee:decimal (at "royalty-fee" coil1-data))
                    (c-rbt1:string (at "rbt-id" coil1-data))
                    (c-rbt1-amount:decimal (at "rbt-amount" coil1-data))
                    ;;
                    ;;<ats2>
                    (coil2-data:object{AutostakeV3.CoilData} 
                        (ref-ATS::URC_RewardBearingTokenAmountsWithHibernation ats2 c-rbt1 c-rbt1-amount dayz)
                    )
                    (input2-amount:decimal (at "first-input-amount" coil2-data))
                    (royalty2-fee:decimal (at "royalty-fee" coil2-data))
                    (c-rbt2:string (at "rbt-id" coil2-data))
                    (c-rbt2-amount:decimal (at "rbt-amount" coil2-data))
                    ;;
                    (ico1:object{IgnisCollectorV3.OutputCumulator}
                        (ref-TFT::C_Transfer patron brumator ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt1 c-rbt1-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt2 c-rbt2-amount false)
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        (C_Hibernate patron ATS|SC_NAME brumator c-rbt2 c-rbt2-amount dayz)
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

)

;; --- tables for 11_VST.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact ==================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v1   ·   dev: v2   ;; bumped by the StoicSyntax refactor — deploy v2 then set net: v2
(interface StoaLiquidStakingV2
    @doc "Exposes the functions needed for Stoa Liquid Staking, Wrap and Unwrap STOA \
        \ as well as their URSTOA Counterparts"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    (defun GOV|LIQUID|SC_STOA-NAME ())
    (defun GOV|LIQUID|GUARD ())

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
    ;;  [UR]
    ;;
    (defun UR_IzOuronetAccountRegisteredForUrstoaHoldings:bool (ouronet-account:string))
    (defun URCi_UnwrapStoa:object{IgnisCollectorV3.OutputCumulator} (unwrapper:string amount:decimal))
    (defun URCi_WrapStoa:object{IgnisCollectorV3.OutputCumulator} (wrapper:string amount:decimal))
    (defun URCi_UnwrapUrStoa:object{IgnisCollectorV3.OutputCumulator} (unwrapper:string amount:decimal))
    (defun URCi_WrapUrStoa:object{IgnisCollectorV3.OutputCumulator} (wrapper:string amount:decimal))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    ;;  [UEV]
    ;;
    (defun UEV_IzLiquidStakingLive ())
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string))
    ;;
    ;;  [C]
    ;;
    (defun C_UnwrapStoa:object{IgnisCollectorV3.OutputCumulator} (patron:string unwrapper:string amount:decimal))
    (defun C_WrapStoa:object{IgnisCollectorV3.OutputCumulator} (patron:string wrapper:string amount:decimal))
    ;;
    ;;#13H fix: C_RegisterOuronetAccountForUrstoaHoldings removed (2026-08-27) - it took a
    ;;caller-supplied <guard> for an arbitrary <ouronet-account> with no ownership check
    ;;(account-hijacking risk). Account creation for wrapping/unwrapping UrStoa is instead
    ;;handled by UI-constructed Pact code using the real signer's own (read-keyset "ks"), the
    ;;same established pattern already used for native Stoa unwrap - see
    ;;OuronetInformational/memories/2026-08-27-urstoa-account-creation-is-ui-constructed.md.
    (defun C_UnwrapUrStoa:object{IgnisCollectorV3.OutputCumulator} (patron:string unwrapper:string amount:decimal))
    (defun C_WrapUrStoa:object{IgnisCollectorV3.OutputCumulator} (patron:string wrapper:string amount:decimal))

)
;;
(module LIQUID GOV
    @doc "LIQUID — the Stoa liquid-staking core, implementing StoaLiquidStakingV2. It wraps \
        \ and unwraps native STOA into liquid-staking tokens and their URSTOA counterparts \
        \ (C_WrapStoa/C_UnwrapStoa and C_WrapUrStoa/C_UnwrapUrStoa, with matching URCi cost \
        \ readers), gated by a liquid-staking-live check, plus an A_MigrateLiquidFunds admin \
        \ migration path."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements StoaLiquidStakingV2)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_LIQUID                             (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_LIQUID                             (keyset-ref-guard LIQUID|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|LIQUID_ADMIN)))
    (defcap GOV|LIQUID_ADMIN ()
        (enforce-one
            "LIQUID Admin not satisfed"
            [
                (enforce-guard GOV|MD_LIQUID)
                (enforce-guard GOV|SC_LIQUID)
            ]
        )
    )
    (defcap GOV|MIGRATE (migration-target-stoa-account:string)
        @event
        (compose-capability (GOV|LIQUID_ADMIN))
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (target-balance:decimal (ref-coin::get-balance migration-target-stoa-account))
                (gap:bool (ref-DALOS::UR_GAP))
            )
            ;;WORDING CORRECTED 2026-09-12 (owner-authorised message-repair class): this said
            ;;"offline" while enforcing `gap`, i.e. the exact opposite of its own condition. Five
            ;;sites elsewhere -- TS01-C2:197, C3:158, C4:145, TS01-P:111, TS02-CPAD:110 -- use
            ;;"online" to mean the pause is ON, which is the convention followed here. The same line
            ;;also wrapped its message in a one-argument `(format …)`, so the sentence never reached
            ;;a caller at all; that is fixed too, and pinned by modules/LIQUID.repl <<LQD-03pre>>.
            (enforce gap "Migration can only be executed when Global Administrative Pause is online")
            (enforce (= target-balance 0.0) "Migration can only be executed to an empty stoa account")
            (compose-capability (LIQUID|NATIVE-AUTOMATIC))
        )
    )
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|LiquidKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|LiquidKey)
        )
    )
    (defun GOV|LIQUID|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|LIQUID|SC_NAME)
        )
    )
    (defun GOV|LIQUID|SC_STOA-NAME () (create-principal (GOV|LIQUID|GUARD)))
    (defun GOV|LIQUID|GUARD ()                          (create-capability-guard (LIQUID|NATIVE-AUTOMATIC)))

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
    (defcap P|LQD|CALLER ()
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
        (with-capability (GOV|LIQUID_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|LIQUID_ADMIN)
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
        (with-capability (GOV|LIQUID_ADMIN)
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
        (with-capability (GOV|LIQUID_ADMIN)
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
                (ref-P|IGNIS:module{OuronetPolicyV2} IGNIS)
                (mg:guard (create-capability-guard (P|LQD|CALLER)))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
            (ref-P|BRD::P|A_AddIMP mg)
            (ref-P|DPTF::P|A_AddIMP mg)
            ;(ref-P|DPOF::P|A_AddIMP mg)
            (ref-P|ATS::P|A_AddIMP mg)
            (ref-P|TFT::P|A_AddIMP mg)
            (ref-P|ATSU::P|A_AddIMP mg)
            (ref-P|VST::P|A_AddIMP mg)
            (ref-P|IGNIS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    (defconst LIQUID|SC_KEY                             (GOV|LiquidKey))
    (defconst LIQUID|SC_NAME                            (GOV|LIQUID|SC_NAME))
    (defconst LIQUID|SC_STOA-NAME                       (GOV|LIQUID|SC_STOA-NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst LIQUID|INFO                               (CT_Info))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap LIQUID|GOV ()
        @doc "Governor Capability for the Liquid Smart DALOS Account"
        true
    )
    (defcap LIQUID|NATIVE-AUTOMATIC ()
        @doc "Autonomic management of <stoa-konto> of LIQUID Smart Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap LIQUID|C>WRAP (account:string)
        @doc "Capability needed to wrap STOA to Ouronet Wrapped Stoa"
        @event
        (compose-capability (LIQUID|C>X_WRAPPER account))
    )
    (defcap LIQUID|C>UNWRAP (account:string)
        @doc "Capability needed to unwrap STOA to Ouronet Wrapped Stoa"
        @event
        (compose-capability (LIQUID|CONVERTER))
        (compose-capability (LIQUID|NATIVE-AUTOMATIC))
    )
    (defcap LIQUID|C>UR-WRAP (account:string)
        @doc "Capability needed to wrap URSTOA to Ouronet Wrapped UrStoa"
        @event
        (compose-capability (LIQUID|C>X_WRAPPER account))
    )
    (defcap LIQUID|C>UR-UNWRAP (account:string)
        @doc "Capability needed to unwrap URSTOA to Ouronet Wrapped UrStoa"
        @event
        (compose-capability (LIQUID|CONVERTER))
        (compose-capability (LIQUID|NATIVE-AUTOMATIC))
    )
    (defcap LIQUID|CONVERTER ()
        (UEV_IzLiquidStakingLive)
        (compose-capability (LIQUID|CALLER))
    )
    (defcap LIQUID|CALLER ()
        (compose-capability (LIQUID|GOV))
        (compose-capability (P|LQD|CALLER))
    )
    (defcap LIQUID|C>X_WRAPPER (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::CAP_EnforceAccountOwnership account)
            (compose-capability (LIQUID|CONVERTER))
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
    (defun CT_Info ()                                   (at 0 ["LiquidInformation"]))
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun UR_IzOuronetAccountRegisteredForUrstoaHoldings:bool (ouronet-account:string)
        (let
            (
                (ref-ur-coin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa ouronet-account))
                (trial (try false (ref-ur-coin::UR_UR|Details stoa-patron)))
            )
            (if (= (typeof trial) "bool") false true)
        )
    )
    (defun URCi_UnwrapStoa:object{IgnisCollectorV3.OutputCumulator}
        (unwrapper:string amount:decimal)
        @doc "Cost preview for C_UnwrapStoa: unwrapper->LIQUID wrapped-STOA transfer + burn, \
            \ re-derived purely (the STOA fuel payout is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer w-stoa-id unwrapper lq-sc amount)
                    (ref-DPTF::URCi_Burn w-stoa-id lq-sc)
                ]
                []
            )
        )
    )
    (defun URCi_WrapStoa:object{IgnisCollectorV3.OutputCumulator}
        (wrapper:string amount:decimal)
        @doc "Cost preview for C_WrapStoa: mint wrapped-STOA on LIQUID + LIQUID->wrapper \
            \ transfer, re-derived purely (the STOA fuel intake is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPTF::URCi_Mint w-stoa-id lq-sc false)
                    (ref-TFT::URCi_Transfer w-stoa-id lq-sc wrapper amount)
                ]
                []
            )
        )
    )
    (defun URCi_UnwrapUrStoa:object{IgnisCollectorV3.OutputCumulator}
        (unwrapper:string amount:decimal)
        @doc "Cost preview for C_UnwrapUrStoa: unwrapper->LIQUID Ur-STOA transfer + burn, \
            \ re-derived purely (the Ur-STOA transmit payout is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-TFT::URCi_Transfer w-ur-stoa-id unwrapper lq-sc amount)
                    (ref-DPTF::URCi_Burn w-ur-stoa-id lq-sc)
                ]
                []
            )
        )
    )
    (defun URCi_WrapUrStoa:object{IgnisCollectorV3.OutputCumulator}
        (wrapper:string amount:decimal)
        @doc "Cost preview for C_WrapUrStoa: mint Ur-STOA on LIQUID + LIQUID->wrapper transfer, \
            \ re-derived purely (the Ur-STOA intake is a separate side effect)."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                [
                    (ref-DPTF::URCi_Mint w-ur-stoa-id lq-sc false)
                    (ref-TFT::URCi_Transfer w-ur-stoa-id lq-sc wrapper amount)
                ]
                []
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    (defun UEV_IzLiquidStakingLive ()
        @doc "Enforces Liquid Staking is live with an existing Autostake Pair"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (w-stoa:string (ref-DALOS::UR_WrappedStoaID))
                (l-stoa:string (ref-DALOS::UR_SilverStoaID))
            )
            (enforce (!= w-stoa BAR) "Wrapped-Stoa is not set")
            (enforce (!= l-stoa BAR) "Liquid-Stoa is not set")
            (let
                (
                    (w-stoa-as-rt:[string] (ref-DPTF::UR_RewardToken w-stoa))
                    (l-stoa-as-rbt:[string] (ref-DPTF::UR_RewardBearingToken l-stoa))
                )
                (enforce (= (length w-stoa-as-rt) 1) "Wrapped-Stoa cannot ever be part of another ATS-Pair")
                (enforce (= (length l-stoa-as-rbt) 1) "Liquid-Stoa cannot ever be part of another ATS-Pair")
                (enforce (= (at 0 w-stoa-as-rt) (at 0 l-stoa-as-rbt)) "Wrapped and Liquid Stoa are not part of the same ASTS Pair")
            )
        )
    )
    (defun UEV_Amount (amount:decimal)
        @doc "Enforces amount to coin (Stoa) Precision, which uses 12 decimal"
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (stoa-prec:integer (ref-U|CT::CT_STOA_PRECISION))
            )
            (enforce
                (= (floor amount stoa-prec) amount)
                (format "{} is not conform with STOA prec." [amount])
            )
        )
    )
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_MigrateLiquidFunds:decimal (migration-target-stoa-account:string)
        (P|UEV_IMC)
        (with-capability (GOV|MIGRATE migration-target-stoa-account)
            (let
                (
                    (ref-coin:module{stoa-ns.fungible-v1} coin)    
                    ;;XB_MoveDalosFuel lives in IGNIS, not DALOS — it was called through the
                    ;;DALOS ref, which DOES NOT have that member, so this admin migration path
                    ;;died on every call (modref members resolve at runtime, so it still loaded).
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    (lq-stoa:string LIQUID|SC_STOA-NAME)
                    (present-stoa-balance:decimal (ref-coin::get-balance lq-stoa))
                )
                (install-capability (ref-coin::TRANSFER lq-stoa migration-target-stoa-account present-stoa-balance))
                (ref-IGNIS::XB_MoveDalosFuel lq-stoa migration-target-stoa-account present-stoa-balance)
                present-stoa-balance
            )
        )
    )
    (defun C_UnwrapStoa:object{IgnisCollectorV3.OutputCumulator}
        (patron:string unwrapper:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa unwrapper))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (with-capability (LIQUID|C>UNWRAP unwrapper)
                (let
                    (
                        (output:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-TFT::C_Transfer patron unwrapper lq-sc w-stoa-id amount true)
                                    (ref-DPTF::C_Burn patron lq-sc w-stoa-id amount)
                                ]
                                []
                            )
                            
                        )
                    )
                    ;;(install-capability (ref-coin::TRANSFER lq-stoa stoa-patron amount))
                    ;;Capability is added instead in the JavaCode
                    (ref-IGNIS::XB_MoveDalosFuel lq-stoa stoa-patron amount)
                    output
                )
            )
        )
    )
    (defun C_WrapStoa:object{IgnisCollectorV3.OutputCumulator}
        (patron:string wrapper:string amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa wrapper))
                (w-stoa-id:string (ref-DALOS::UR_WrappedStoaID))
            )
            (with-capability (LIQUID|C>WRAP wrapper)
                (let
                    (
                        (output:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-DPTF::C_Mint patron lq-sc w-stoa-id amount false)
                                    (ref-TFT::C_Transfer patron lq-sc wrapper w-stoa-id amount true)
                                ]
                                []
                            )
                        )
                    )
                    (ref-IGNIS::XB_MoveDalosFuel stoa-patron lq-stoa amount)
                    output
                )
            )
        )
    )
    (defun C_UnwrapUrStoa:object{IgnisCollectorV3.OutputCumulator}
        (patron:string unwrapper:string amount:decimal)
        @doc "Unwrapper is the Ouronet Account doing the Unwrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md)."
        (P|UEV_IMC)
        (let
            (
                (ref-ur-coin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa unwrapper))
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (with-capability (LIQUID|C>UR-UNWRAP unwrapper)
                (let
                    (
                        (output:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-TFT::C_Transfer patron unwrapper lq-sc w-ur-stoa-id amount true)
                                    (ref-DPTF::C_Burn patron lq-sc w-ur-stoa-id amount)
                                ]
                                []
                            )
                            
                        )
                    )
                    ;;(install-capability (ref-ur-coin::UR|TRANSFER lq-stoa stoa-patron amount))
                    ;;Capability is added instead in the JavaCode - NOT NEEDED because TRANSMIT is used.
                    (ref-ur-coin::C_UR|Transmit lq-stoa stoa-patron amount)
                    output
                )
            )
        )
    )
    (defun C_WrapUrStoa:object{IgnisCollectorV3.OutputCumulator}
        (patron:string wrapper:string amount:decimal)
        @doc "Wrapper is the Ouronet Account doing the Wrapping. \
            \ Its attached Stoa address k:xxx must be registered in the UrStoa Account Table for this to work. \
            \ If its not registered there yet, the UI constructs a bespoke tx that creates the \
            \ account with the real signer's own (read-keyset \"ks\") immediately before this \
            \ call, the same pattern already used for native Stoa unwrap - there is no \
            \ standalone Pact function for this (see #13H, ROUND-02-FIXES.md)."
        (P|UEV_IMC)
        (let
            (
                (ref-ur-coin:module{stoa-ns.ur-stoic-fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (lq-sc:string LIQUID|SC_NAME)
                (lq-stoa:string LIQUID|SC_STOA-NAME)
                (stoa-patron:string (ref-DALOS::UR_AccountStoa wrapper))
                (w-ur-stoa-id:string (ref-DALOS::UR_UrStoaID))
            )
            (with-capability (LIQUID|C>UR-WRAP wrapper)
                (let
                    (
                        (output:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    (ref-DPTF::C_Mint patron lq-sc w-ur-stoa-id amount false)
                                    (ref-TFT::C_Transfer patron lq-sc wrapper w-ur-stoa-id amount true)
                                ]
                                []
                            )
                        )
                    )
                    (ref-ur-coin::C_UR|Transfer stoa-patron lq-stoa amount)
                    output
                )
            )
        )
    )

)

;; --- tables for 12_LIQUID.pact (2 defined) ---
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
(interface OuroborosV2
    @doc "Exposes Functions related to the OUROBOROS Module"

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;{G2}  schemas
    ;;{G3}  tables  ⟨cannot exist in an interface⟩
    ;;{G4}  capabilities
    ;;{G5}  functions
    ;;
    (defun GOV|ORBR|SC_STOA-NAME ())
    (defun GOV|ORBR|GUARD ())

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
    ;;
    (defun URC_ProjectedStoaLiquindex:[decimal] ())
    (defun URCv_Compress:[decimal] (ignis-amount:decimal))
    (defun URCv_Sublimate:decimal (ouro-amount:decimal))
    (defun URCi_Compress:object{IgnisCollectorV3.OutputCumulator} (client:string ignis-amount:decimal))
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} ())
    (defun URCi_Sublimate:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    (defun URCi_SublimateV2:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    (defun URCi_WithdrawFees:object{IgnisCollectorV3.OutputCumulator} (id:string target:string))
    ;;{5.4}  Validate [UEV/CAP]
    ;;
    (defun UEV_Exchange ())
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XB_Compress:object{IgnisCollectorV3.OutputCumulator} (patron:string client:string ignis-amount:decimal))
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun C_Compress:object{IgnisCollectorV3.OutputCumulator} (client:string ignis-amount:decimal))
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (patron:string ))
    (defun C_Sublimate:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    ;;#23H fix: C_SublimateV2 was already live/actively-used (TS01-C2's ORBR|C_SublimateV2,
    ;;TS01-C3's Firestarter path) but missing from its own interface. Cheaper alternative to
    ;;C_Sublimate (freeze+C_WipeSlim+unfreeze instead of transfer+burn) - added here, no
    ;;behavioral change, the module already implements this exact signature.
    (defun C_SublimateV2:object{IgnisCollectorV3.OutputCumulator} (client:string target:string ouro-amount:decimal))
    (defun C_WithdrawFees:object{IgnisCollectorV3.OutputCumulator} (id:string target:string))

)
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
    (implements OuroborosV2)

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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|OuroborosKey ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|OuroborosKey)
        )
    )
    (defun GOV|ORBR|SC_NAME ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
        @doc "Autonomic management of <stoa-konto> of OUROBOROS Smart Account"
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
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
        @event
        (compose-capability (IGNIS|XB>CONVERT client))
    )
    (defcap IGNIS|XB>CONVERT (client:string)
        (UEV_Exchange)
        (compose-capability (ORBR|GOV))
        (compose-capability (P|ORBR|CALLER))
    )
    (defcap OUROBOROS|C>WITHDRAW (id:string target:string)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DALOS::UEV_EnforceAccountType target false)
            (ref-DPTF::CAP_Owner id)
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
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATS:module{AutostakeV3} ATS)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
    (defun URCi_Compress:object{IgnisCollectorV3.OutputCumulator}
        (client:string ignis-amount:decimal)
        @doc "Cost preview for C_Compress (and cost-identical XB_Compress): client->ORBR IGNIS \
            \ transfer + IGNIS burn + OURO mint + ORBR->client OURO transfer. Output == \
            \ [ouro-remainder-amount], re-derived purely."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
    (defun URCi_Fuel:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "Cost preview for C_Fuel: when wrapped-STOA exists and the ORBR STOA balance is \
            \ positive, the wrap + ATSU fuel legs; otherwise EOC (no-op). Re-derived purely."
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATSU:module{AutostakeUsageV2} ATSU)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
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
    (defun URCi_Sublimate:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        @doc "Cost preview for C_Sublimate: client->ORBR OURO transfer + OURO burn + IGNIS mint \
            \ + ORBR->target IGNIS transfer. Output == [ignis-amount], re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
    (defun URCi_SublimateV2:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        @doc "Cost preview for C_SublimateV2: (conditional) freeze client + wipe-slim the OURO \
            \ + unfreeze + IGNIS mint + ORBR->target IGNIS transfer. Output == [ignis-amount], \
            \ re-derived purely."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
    (defun URCi_WithdrawFees:object{IgnisCollectorV3.OutputCumulator}
        (id:string target:string)
        @doc "Cost preview for C_WithdrawFees: the base token-issue IGNIS price + the ORBR-> \
            \ target transfer of the accrued fee supply, re-derived purely."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (gas-id:string (ref-DALOS::UR_IgnisID))
            )
            (enforce (!= ouro-id BAR) "Ouroboros is not set")
            (enforce (!= gas-id BAR) "Ignis is not set")
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
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
    (defun XB_Compress:object{IgnisCollectorV3.OutputCumulator}
        (patron:string client:string ignis-amount:decimal)
        @doc "SC-account-tolerant IGNIS→OURO compress for INTERNAL module callers (registered OUROBOROS IMC). Same \
            \ conversion + fee as C_Compress (98.5% efficiency), but authorized by IGNIS|XB>COMPRESS which OMITS the \
            \ standard-account restriction — so a SMART account (e.g. AQP|SC_NAME custody) may normalize an IGNIS \
            \ royalty leg to OURO before disposal. P|UEV_IMC gates the caller module. The <client>'s IGNIS→ORBR \
            \ transfer is authorized by whatever cap the caller holds for <client> (e.g. P|FVT|REMOTE-GOV)."
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
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
    (defun C_Compress:object{IgnisCollectorV3.OutputCumulator}
        (client:string ignis-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ignis-to-ouro:[decimal] (URCv_Compress ignis-amount))
                (ouro-remainder-amount:decimal (at 0 ignis-to-ouro))
                ;;#61L fix: removed the dead `total-ouro` binding (bound, never referenced
                ;;anywhere in the function body - only `ouro-remainder-amount`, the first
                ;;element, is actually minted/transferred). No functional change.
            )
            (with-capability (IGNIS|C>COMPRESS client)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends GAS(Ignis) <ignis-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer client client ORBR|SC_NAME ignis-id ignis-amount true)
                        ;;02]Ouroboros burns GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Burn client ORBR|SC_NAME ignis-id ignis-amount)
                        ;;03]Ouroboros mints OURO <ouro-remainder-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        ;;04]Ouroboros transfers OURO <ouro-remainder-amount> to <client>
                        (ref-TFT::C_Transfer client ORBR|SC_NAME client ouro-id ouro-remainder-amount true)
                    ]
                    [ouro-remainder-amount]
                )
            )
        )
    )
    (defun C_Fuel:object{IgnisCollectorV3.OutputCumulator} (patron:string )
        (P|UEV_IMC)
        (let
            (
                (ref-coin:module{stoa-ns.fungible-v1} coin)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-ATSU:module{AutostakeUsageV2} ATSU)
                (ref-LIQUID:module{StoaLiquidStakingV2} LIQUID)
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
                                    (ref-ATSU::C_Fuel orb-sc liquid-idx w-stoa present-stoa-balance)
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
    (defun C_Sublimate:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
            )
            (with-capability (IGNIS|C>SUBLIMATE client target)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Client sends OURO <ouro-amount> to the Ouroboros Smart Ouronet Account
                        (ref-TFT::C_Transfer client client ORBR|SC_NAME ouro-id ouro-amount true)
                        ;;02]Ouroboros burns OURO <ouro-amount>
                        (ref-DPTF::C_Burn client ORBR|SC_NAME ouro-id ouro-amount)
                        ;;03]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;04]Ouroboros transfers GAS(Ignis) <ignis-amount> to <target>
                        (ref-TFT::C_Transfer client ORBR|SC_NAME target ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_SublimateV2:object{IgnisCollectorV3.OutputCumulator}
        (client:string target:string ouro-amount:decimal)
        (P|UEV_IMC)
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                ;;
                (ignis-id:string (ref-DALOS::UR_IgnisID))
                (ouro-id:string (ref-DALOS::UR_OuroborosID))
                (ouro-precision:integer (ref-DPTF::UR_Decimals ouro-id))
                ;;
                (ouro-split:[decimal] (ref-U|ATS::UC_PromilleSplit 10.0 ouro-amount ouro-precision))
                (ouro-remainder-amount:decimal (at 0 ouro-split))
                (ignis-amount:decimal (URCv_Sublimate ouro-remainder-amount))
                (frozen-state:bool (ref-DPTF::UR_AccountFrozenState ouro-id client))
            )
            (with-capability (IGNIS|C>SUBLIMATE client target)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;01]Freeze Client Account for Ouro if not already frozen
                        (if (not frozen-state)
                            (ref-DPTF::C_ToggleFreezeAccount client (ref-DPTF::UR_Konto ouro-id) client ouro-id true)
                            EOC
                        )
                        ;;02]Partialy wipe the required OURO
                        (ref-DPTF::C_WipeSlim client (ref-DPTF::UR_Konto ouro-id) client ouro-id ouro-amount)
                        ;;03]Unfreeze Client Account
                        (ref-DPTF::C_ToggleFreezeAccount client (ref-DPTF::UR_Konto ouro-id) client ouro-id false)
                        ;;04]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;05]Ouroboros transfers GAS(Ignis) <ignis-amount> to <target>
                        (ref-TFT::C_Transfer client ORBR|SC_NAME target ignis-id ignis-amount true)
                    ]
                    [ignis-amount]
                )
            )
        )
    )
    (defun C_WithdrawFees:object{IgnisCollectorV3.OutputCumulator}
        (id:string target:string)
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-TFT:module{TrueFungibleTransferV2} TFT)
                (withdraw-amount:decimal (ref-DPTF::UR_AccountSupply id ORBR|SC_NAME))
                (price:decimal (ref-IGNIS::UC_IgnisDeter "fee-withdraw"))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (enforce (> withdraw-amount 0.0) (format "There are no {} fees to be withdrawn from {}" [id ORBR|SC_NAME]))
            (with-capability (OUROBOROS|C>WITHDRAW id target)
                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                    [
                        ;;00]Compose base withdraw IGNIS Price
                        (ref-IGNIS::UDC_ConstructOutputCumulator price ORBR|SC_NAME trigger [])
                        ;;01]Patron withdraws Fees from Ouroboros Smart DALOS Account to a target Normal Ouronet Account
                        (ref-TFT::C_Transfer target ORBR|SC_NAME target id withdraw-amount true)
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

