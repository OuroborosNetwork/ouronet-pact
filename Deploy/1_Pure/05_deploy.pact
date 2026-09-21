;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 5 of 22
;; This is STEP 5 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-4 must have run first, including the init steps between deploys.
;; 4 source file(s), 296,962 gas measured in the REPL gas model, 265,823 bytes
;;
;; Source files in this transaction, IN ORDER (do not reorder):
;;   1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/12_LIQUID.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/13_OUROBOROS.pact
;;   1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact
;;
;; TOTAL: 4 interface(s), 4 module(s), 11 table(s)
;; What it DEPLOYS, in load order:
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
;;   -- 1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact
;;      interface  SwapTracerV3
;;      module     SWPT
;;      table      P|T
;;      table      P|MT
;;      table      SWPT|Graph
;;      table      SWPT|PathCache
;;      table      SWPT|TopologyVersion
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

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
                    (ref-TFT::C_Transfer dptf-to-repurpose VST|SC_NAME repurpose-to amount true)
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
                        (ref-TFT::C_Transfer dptf VST|SC_NAME target free-amount true)
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
                            (ref-TFT::C_Transfer dptf freezer VST|SC_NAME amount true)
                            EOC
                        )
                        ;;2]VST|SC_NAME mints F|dptf
                        (ref-DPTF::C_Mint patron VST|SC_NAME f-dptf amount false)
                        ;;3|VST|SC_Name sends F|dptf to freeze-output
                        (ref-TFT::C_Transfer f-dptf VST|SC_NAME freeze-output amount true)
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
                            (ref-TFT::C_Transfer dptf reserver VST|SC_NAME amount true)
                            EOC
                        )
                        ;;2]VST|SC_NAME mint R|dptf
                        (ref-DPTF::C_Mint patron VST|SC_NAME r-dptf amount false)
                        ;;3]VST|SC_NAME sends R|dptf to reserver
                        (ref-TFT::C_Transfer r-dptf VST|SC_NAME reserver amount true)
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
                        (ref-TFT::C_Transfer r-dptf unreserver VST|SC_NAME amount true)
                        ;;2]VST|SC_NAME burns R|dptf
                        (ref-DPTF::C_Burn patron VST|SC_NAME r-dptf amount)
                        ;;3]VST|SC_NAME sends dptf back to unreserver
                        (ref-TFT::C_Transfer dptf VST|SC_NAME unreserver amount true)
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
                            (ref-TFT::C_Transfer dptf vester VST|SC_NAME amount true)
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
                                (ref-TFT::C_Transfer dptf-id VST|SC_NAME unvester nonce-supply true)
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                    [
                                        ;;1]Only the ready to unvest dptf is trasnfered back to unvester
                                        (ref-TFT::C_Transfer dptf-id VST|SC_NAME unvester culled-amount true)
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
                            (ref-TFT::C_Transfer dptf sleeper VST|SC_NAME amount true)
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
                            (ref-TFT::C_Transfer dptf-id VST|SC_NAME unsleeper nonce-supply true)
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
                            (ref-TFT::C_Transfer dptf hibernator VST|SC_NAME amount true)
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
                        (ref-TFT::C_Transfer dptf-id VST|SC_NAME awaker remainder true)
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
                        (ref-TFT::C_Transfer rt constricter ATS|SC_NAME amount true)
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
                        (ref-TFT::C_Transfer rt brumator ATS|SC_NAME amount true)
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
                                    (ref-TFT::C_Transfer w-stoa-id unwrapper lq-sc amount true)
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
                                    (ref-TFT::C_Transfer w-stoa-id lq-sc wrapper amount true)
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
                                    (ref-TFT::C_Transfer w-ur-stoa-id unwrapper lq-sc amount true)
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
                                    (ref-TFT::C_Transfer w-ur-stoa-id lq-sc wrapper amount true)
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
                        (ref-TFT::C_Transfer ignis-id client ORBR|SC_NAME ignis-amount true)
                        (ref-DPTF::C_Burn patron ORBR|SC_NAME ignis-id ignis-amount)
                        (ref-DPTF::C_Mint patron ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        (ref-TFT::C_Transfer ouro-id ORBR|SC_NAME client ouro-remainder-amount true)
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
                        (ref-TFT::C_Transfer ignis-id client ORBR|SC_NAME ignis-amount true)
                        ;;02]Ouroboros burns GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Burn client ORBR|SC_NAME ignis-id ignis-amount)
                        ;;03]Ouroboros mints OURO <ouro-remainder-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ouro-id ouro-remainder-amount false)
                        ;;04]Ouroboros transfers OURO <ouro-remainder-amount> to <client>
                        (ref-TFT::C_Transfer ouro-id ORBR|SC_NAME client ouro-remainder-amount true)
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
                        (ref-TFT::C_Transfer ouro-id client ORBR|SC_NAME ouro-amount true)
                        ;;02]Ouroboros burns OURO <ouro-amount>
                        (ref-DPTF::C_Burn client ORBR|SC_NAME ouro-id ouro-amount)
                        ;;03]Ouroboros mints GAS(Ignis) <ignis-amount>
                        (ref-DPTF::C_Mint client ORBR|SC_NAME ignis-id ignis-amount false)
                        ;;04]Ouroboros transfers GAS(Ignis) <ignis-amount> to <target>
                        (ref-TFT::C_Transfer ignis-id ORBR|SC_NAME target ignis-amount true)
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
                        (ref-TFT::C_Transfer ignis-id ORBR|SC_NAME target ignis-amount true)
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
                        (ref-TFT::C_Transfer id ORBR|SC_NAME target withdraw-amount true)
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

;; ===== 1_SOVEREIGN/STAGE_01/2_Core/14_SWPT.pact ====================
;(namespace "n_9d612bcfe2320d6ecbbaa99b47aab60138a2adea")
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v2   ·   dev: v3   ;; bumped by the StoicSyntax refactor — deploy v3 then set net: v3
(interface SwapTracerV3
    @doc "Exposes Tracer Functions, needed to compute Paths between Tokens existing on \
        \ Liquidity Pools. \
        \ \
        \ #21H redesign (V1 -> V2): V1 stored adjacency keyed by PRINCIPAL identity — \
        \ every swpair got filed under one Edges entry per principal it touched, at \
        \ trace time. That broke the moment a principal was removed or replaced: every \
        \ entry filed under the retired principal became permanently unreachable to \
        \ every normal read path, silently, system-wide, for every token ever pooled \
        \ against it — with no resync mechanism anywhere. It also duplicated storage \
        \ (a swpair touching 2 principals got recorded twice) and grew read cost with \
        \ every read via repeated concatenate-then-dedup over all principal buckets. \
        \ \
        \ V2 stores plain token-to-token adjacency instead — principal identity plays \
        \ no role anywhere in this module's storage, keys, or reads. Principal changes \
        \ (SWP::A_UpdatePrincipal or its future replacement-only successor) never touch \
        \ this module at all; there is nothing here that could go stale."

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
    (defschema NeighbourEdge
        token:string
        swpairs:[string]
    )
    (defschema PathCacheRow
        @doc "#34 Phase 6/7: a cached route between two tokens, keyed by <token-a>|\
            \ <token-b> in whichever direction was first registered — no \
            \ canonicalization, readers check both directions and reverse on a miss in \
            \ one of them. Stores only the route STRUCTURE, never a computed value — \
            \ every real use re-derives the current value from live reserves, so a \
            \ stale-but-structurally-valid entry can only ever point at the wrong-but- \
            \ still-real edges, which per-edge validation on every read catches and \
            \ falls back from. Same <nodes>/<edges> shape as <URC_ComputeGraphPath>'s \
            \ own return (both endpoints included in <nodes>). Declared on this \
            \ interface, not the module, since interface function signatures below \
            \ reference it and interfaces load before module schemas exist. \
            \ #65bL Phase 1 fix: added <topology-version>, the global topology-version \
            \ counter's value at the moment this entry was written — WITHOUT it, \
            \ 'first-write-wins, never overwritten' meant a cached entry could never be \
            \ refreshed even after new pools made a better route possible; a reader \
            \ now compares this against the live counter (<UR_TopologyVersion>) to tell \
            \ a genuinely-current entry from a stale one, and a stale entry can be \
            \ overwritten instead of permanently blocking any future improvement."
        nodes:[string]
        edges:[string]
        topology-version:integer
    )
    (defschema TopologyVersionRow
        @doc "#65bL Phase 1: single counter, bumped once per genuinely new token-pair \
            \ connection or genuinely new parallel pool (see <XI_UpdatePair>'s own \
            \ <did-change> logic) — never bumped on an idempotent replay (e.g. \
            \ <A_RebuildGraph> re-running over already-registered pools). A coarse \
            \ generation number, not an exact change-count: a single multi-token pool \
            \ issuance bumps it once per ordered token-pair it introduces, not once per \
            \ pool. That's fine — its only job is 'has anything changed since a given \
            \ read', not precise counting."
        version:integer
    )
    (defschema RawGraphNode
        @doc "#65bL Phase 2: one token's raw, unfiltered neighbour data — exactly what \
            \ <UR_Graph> returns for it, paired with its own name. The point of this \
            \ shape is to let a caller read a whole node universe's raw rows ONCE \
            \ (<URC_FetchRawGraph>) and reuse them across multiple best-of-K attempts \
            \ via a purely in-memory filter (<UC_MakeGraphFromRaw>) instead of each \
            \ attempt independently re-reading and rebuilding the whole graph."
        node:string
        neighbours:[object{NeighbourEdge}]
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
    (defun UC_MakeGraphFromRaw:[object{BreadthFirstSearchV2.GraphNode}]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Graph:[object{NeighbourEdge}] (token:string))
    (defun URC_TokenNeighbours:[string] (token:string))
    (defun URC_Edges:[string] (t1:string t2:string))
    (defun URC_EdgesActive:[string] (t1:string t2:string whitelist:[string]))
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string]))
    ;;#45L fix: renamed from URC_AllGraphPaths — misleading, doesn't return all
    ;;paths (one shortest BFS chain per reached node, not every simple path).
    (defun URC_ShortestChainPerNode:[[string]] (input:string output:string swpairs:[string]))
    (defun URC_MakeGraph:[object{BreadthFirstSearchV2.GraphNode}] (input:string output:string swpairs:[string]))
    ;;#65bL Phase 2: raw-fetch/pure-filter split, used by URC_ComputeAlternateRoutes/
    ;;per transaction and reuse it across every best-of-K attempt, instead of each
    ;;attempt calling URC_MakeGraph (a fresh read per node, every time).
    (defun URC_FetchRawGraph:[object{RawGraphNode}] (nodes:[string]))
    (defun URC_ShortestChainPerNodeFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    (defun URC_ComputeGraphPathFromRaw:[string]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;#65bL Phase 7: one layer deeper than Phase 2's raw-fetch/pure-filter split — a
    ;;caller making MULTIPLE Hopper queries against the SAME <swpairs> universe in one
    ;;transaction (the STOA-repricing loop: one query per distinct pool touched, each a
    ;;different source token but the same WSTOA destination) was still calling
    ;;UC_MakeGraphFromRaw (a linear-scan-per-node graph BUILD) fresh on every query,
    ;;even though that build's output is byte-identical every time for the same
    ;;<raw-graph>/<swpairs> universe (UC_MakeGraphFromRaw is input/output-independent,
    ;;same as UC_MakeGraphNodes underneath it — Phase 4's own finding). These let a
    ;;caller build the [GraphNode] graph ONCE (UC_MakeGraphFromRaw) and reuse it across
    ;;every query — only the BFS traversal itself (genuinely <input>-dependent) still
    ;;runs per query.
    (defun URC_ShortestChainPerNodeFromGraph:[[string]]
        (input:string graph:[object{BreadthFirstSearchV2.GraphNode}])
    )
    (defun URC_ComputeGraphPathFromGraph:[string]
        (input:string output:string graph:[object{BreadthFirstSearchV2.GraphNode}])
    )
    ;;#34M/M2 fix: additive — finds up to 3 edge-disjoint candidate routes instead
    ;;of just the single first-found one; see the defun's own @doc for the full
    ;;rationale.
    (defun URC_ComputeAlternateRoutes:[[string]] (input:string output:string swpairs:[string]))
    ;;#65bL Phase 4: URC_ComputeAlternateRoutes, sourcing its graph via an
    ;;multiple unrelated best-of-K searches in one transaction (the STOA-repricing
    ;;loop, one search per distinct pool) share ONE raw-graph fetch across all of them.
    (defun URC_ComputeAlternateRoutesFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
    )
    ;;#34 Phase 11 (the original #34 ask): generalizes URC_ComputeAlternateRoutes' fixed
    ;;3-attempt cap into a real parameterized search — see the defun's own @doc for the
    ;;full mechanics (early-exit, depth-cap filter, outer hard stop).
    (defun URC_ComputeAllRoutes:[[string]] (input:string output:string swpairs:[string] max-attempts:integer))
    ;;#34 Phase 7: dirty-read path-cache core functions — exists-only (structural) side.
    ;;The active-required wrapper (adds SWP::UR_CanSwap per edge) lives in SWPI instead,
    ;;same reason URC_EdgesActive's own whitelist check couldn't live here either — SWPT
    ;;deploys before SWP, can't reach it.
    (defun URC_ReadPathCache:object{PathCacheRow} (token-a:string token-b:string))
    ;;#65bL Phase 1: current global topology-version counter — one point read.
    (defun UR_TopologyVersion:integer ())
    ;;#65bL Phase 1: URC_ReadPathCache, additionally collapsing a STALE entry (its
    ;;topology-version behind the current one) to the same [BAR] miss sentinel a
    ;;genuinely-absent entry already returns — callers never need to know the
    ;;difference between "never cached" and "cached but outdated."
    (defun URC_ReadPathCacheFresh:object{PathCacheRow} (token-a:string token-b:string))
    (defun URC_EdgeConnects:bool (i-id:string o-id:string swpair:string))
    (defun URC_ValidatePathStructure:bool (nodes:[string] edges:[string]))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    (defun XI_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string]))
    ;;#34 Phase 8: forward-module entrypoint for XI_RegisterPath — mirrors XE_UpdateGraph
    ;;exactly (P|UEV_IMC gate + internal SECURE composition). Cross-module callers (SWPU)
    ;;must go through this, never grant SWPT.SECURE directly themselves — SECURE's body
    ;;is unconditionally true, so a caller-side `(with-capability (SWPT.SECURE) ...)`
    ;;would grant it to literally anyone, not just legitimate Ouronet modules (confirmed
    ;;against this exact class of issue in this codebase's own ATS audit findings).
    (defun XE_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string]))
    (defun XE_UpdateGraph (swpair:string))
    ;;{5.7}  User [A/C]

)
;;
(module SWPT GOV
    @doc "SWPT (SwapTracerV3) is the swap-graph tracer for the SWP liquidity-pool family. It \
        \ stores plain token-to-token adjacency (SWPT|Graph), a first-write path cache \
        \ (SWPT|PathCache), and a global topology-version counter, and exposes BFS-based \
        \ routing helpers (URC_ComputeGraphPath, alternate/exhaustive route discovery, \
        \ raw-graph fetch/filter variants) plus XE_/XI_ entrypoints to register paths and \
        \ update the graph. It computes multi-hop swap routes between tokens without holding \
        \ value data, so every real swap re-derives outputs from live reserves."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements SwapTracerV3)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_SWPT                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|SWPT_ADMIN)))
    (defcap GOV|SWPT_ADMIN ()                           (enforce-guard GOV|MD_SWPT))
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
    (deftable P|T:{OuronetPolicyV2.P|S})                        ;;Key = <policy-name>
    (deftable P|MT:{OuronetPolicyV2.P|MS})                      ;;Key = P|I (module-identity singleton constant)
    ;;{P4}  capabilities
    (defcap P|SWPT|CALLER ()
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
        (with-capability (GOV|SWPT_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|SWPT_ADMIN)
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
        (with-capability (GOV|SWPT_ADMIN)
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
        (with-capability (GOV|SWPT_ADMIN)
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
                (ref-P|ORBR:module{OuronetPolicyV2} OUROBOROS)
                (mg:guard (create-capability-guard (P|SWPT|CALLER)))
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
            (ref-P|ORBR::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    ;;#65bL Phase 1: singleton key for SWPT|TopologyVersion — same pattern as this
    ;;codebase's other singleton-row tables (e.g. policy's P|I).
    (defconst TOPOLOGY_VERSION_KEY                      "topology-version")
    ;;#34 Phase 11: P0.4's depth cap (7 tokens / 6 hops, "the sexy number 7") — same
    ;;value URC_ValidatePathStructure already enforces on submitted bundles, reused
    ;;here as a post-discovery filter in URC_ComputeAllRoutes (see that function's own
    ;;doc for why post-filter, not baked into U|BFS's traversal itself).
    (defconst MAX_ROUTE_NODES                           7)
    ;;#34 Phase 11: P0.2's genuine outer hard stop on max-attempts, independent of
    ;;whatever a caller requests — placeholder value, not researched/considered,
    ;;owner may override. URC_ComputeAllRoutes clamps to this regardless of the
    ;;caller's own max-attempts argument.
    (defconst MAX_ATTEMPTS_HARD_CAP                     50000)
    ;;{3.2}  schemas
    ;;
    (defschema SWPT|GraphSchema
        neighbours:[object{SwapTracerV3.NeighbourEdge}]
    )
    ;;{3.3}  tables
    (deftable SWPT|Graph:{SWPT|GraphSchema})                    ;;Key = <token>
    (deftable SWPT|PathCache:{SwapTracerV3.PathCacheRow})       ;;Key = <token-a>|<token-b> (insertion-order, reversed-lookup at read time)
    ;;#65bL Phase 1: own table per this codebase's storage-pattern rule (never
    ;;co-locate a row read for other reasons — segregated so only the path that
    ;;needs the counter pays to deserialize it).
    (deftable SWPT|TopologyVersion:{SwapTracerV3.TopologyVersionRow})  ;;Key = TOPOLOGY_VERSION_KEY (singleton)

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
    (defun UC_FindNeighbourIndex:[integer] (neighbours:[object{SwapTracerV3.NeighbourEdge}] token:string)
        @doc "Returns [idx] of the entry in <neighbours> whose token field matches \
            \ <token>, or [] if no such entry exists yet."
        (let
            (
                (l:integer (length neighbours))
            )
            (if (= l 0)
                []
                (fold
                    (lambda
                        (acc:[integer] idx:integer)
                        (if (!= acc [])
                            acc
                            (if (= (at "token" (at idx neighbours)) token) [idx] [])
                        )
                    )
                    []
                    (enumerate 0 (- l 1))
                )
            )
        )
    )
    (defun UC_ExcludeEdges:[string] (swpairs:[string] exclude:[string])
        @doc "Removes every entry of <exclude> from <swpairs> — pure list-difference. \
            \ Used to build a reduced routing universe for #34M/M2's best-of-K \
            \ alternate-route search: each retry excludes the edges of every route \
            \ already found, forcing a genuinely different one instead of \
            \ rediscovering the same route."
        (filter (lambda (s:string) (not (contains s exclude))) swpairs)
    )
    (defun UC_MakeGraphFromRaw:[object{BreadthFirstSearchV2.GraphNode}]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: pure (zero table reads) equivalent of <URC_MakeGraph> — \
            \ builds the identical active-filtered [GraphNode] shape, but derives \
            \ every node's links from an ALREADY-FETCHED <raw-graph> \
            \ (<URC_FetchRawGraph>) instead of re-reading SWPT|Graph per node, and \
            \ also skips the double-read <URC_MakeGraph> itself has (one read via \
            \ <URC_TokenNeighbours> to list neighbour tokens, another via \
            \ <URC_EdgesActive>/<URC_Edges> per neighbour to re-derive the exact \
            \ same swpairs already sitting in that first read's result) — the \
            \ per-neighbour <swpairs> field is already right there on each \
            \ <NeighbourEdge>, filtered directly, no re-read or re-derivation \
            \ needed either way. <raw-graph> must cover every node <swpairs> could \
            \ ever produce here — always true when it was fetched against a \
            \ swpairs universe that's a SUPERSET of this one (e.g. the original, \
            \ unshrunk universe a best-of-K search started from, reused unchanged \
            \ across every attempt's own shrinking exclusion universe)."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (if (= 0 (length nodes))
                []
                (fold
                    (lambda
                        (acc:[object{BreadthFirstSearchV2.GraphNode}] idx:integer)
                        (let*
                            (
                                (this-node:string (at idx nodes))
                                ;;#65bL Phase 3 investigated a binary-search replacement for
                                ;;this scan (see URC_FetchRawGraph's own doc) — measured as a
                                ;;real regression on the actual integrated call, not shipped.
                                ;;Linear filter stays, unchanged from Phase 2.
                                (raw-matches:[object{RawGraphNode}]
                                    (filter (lambda (rg:object{RawGraphNode}) (= (at "node" rg) this-node)) raw-graph)
                                )
                                (neighbours:[object{NeighbourEdge}]
                                    (if (= 0 (length raw-matches)) [] (at "neighbours" (at 0 raw-matches)))
                                )
                            )
                            (ref-U|LST::UC_AppL
                                acc
                                {
                                    "node": this-node,
                                    "links":
                                        (map (at "token")
                                            (filter
                                                (lambda (ne:object{NeighbourEdge})
                                                    (!=
                                                        (filter
                                                            (lambda (sp:string) (contains sp swpairs))
                                                            (at "swpairs" ne)
                                                        )
                                                        []
                                                    )
                                                )
                                                neighbours
                                            )
                                        )
                                }
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length nodes) 1))
                )
            )
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_Graph:[object{SwapTracerV3.NeighbourEdge}] (token:string)
        (with-default-read SWPT|Graph token
            {"neighbours" : []}
            {"neighbours" := n}
            n
        )
    )
    (defun UR_PathCacheRaw:object{SwapTracerV3.PathCacheRow} (key:string)
        @doc "#34 Phase 7: raw keyed read against SWPT|PathCache, [BAR]-sentinel default \
            \ for a missing row. Internal — callers go through <URC_ReadPathCache> for the \
            \ reversed-lookup logic, never this directly. \
            \ #65bL Phase 1: default <topology-version> is -1 — always older than any \
            \ real counter value (starts at 0, only ever increases), so a missing row \
            \ is automatically treated as stale by any freshness check, same as a \
            \ genuinely-absent entry always was structurally."
        (with-default-read SWPT|PathCache key
            {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
            {"nodes" := n, "edges" := e, "topology-version" := tv}
            {"nodes" : n, "edges" : e, "topology-version" : tv}
        )
    )
    (defun UR_TopologyVersion:integer ()
        @doc "#65bL Phase 1: current global topology-version counter — one point read, \
            \ default 0 for the pre-first-bump state."
        (with-default-read SWPT|TopologyVersion TOPOLOGY_VERSION_KEY
            {"version" : 0}
            {"version" := v}
            v
        )
    )
    (defun URC_TokenNeighbours:[string] (token:string)
        (map (at "token") (UR_Graph token))
    )
    (defun URC_Edges:[string] (t1:string t2:string)
        @doc "All swpairs directly connecting <t1> and <t2> — regardless of can-swap \
            \ state. Direct keyed lookup against <t1>'s own row; O(deg(t1)), never a \
            \ table scan."
        (let*
            (
                (neighbours:[object{SwapTracerV3.NeighbourEdge}] (UR_Graph t1))
                (idx:[integer] (UC_FindNeighbourIndex neighbours t2))
            )
            (if (= (length idx) 0)
                []
                (at "swpairs" (at (at 0 idx) neighbours))
            )
        )
    )
    (defun URC_EdgesActive:[string] (t1:string t2:string whitelist:[string])
        @doc "Same as <URC_Edges>, but the result is restricted to swpairs also \
            \ present in <whitelist> (e.g. <SWP::URC_ActiveSwpairs>) — so a disabled \
            \ parallel pool between the same token pair is never offered as an edge \
            \ candidate to <SWPI::URC_BestEdgeFiltered>. #19H fix, carried over \
            \ unchanged by the #21H storage redesign."
        (filter (lambda (swpair:string) (contains swpair whitelist)) (URC_Edges t1 t2))
    )
    (defun URCx_ShortestChainToTarget:[[string]] (input:string output:string swpairs:[string])
        @doc "#65hL: <URC_ShortestChainPerNode>, but stops doing real BFS-expansion \
            \ work once <output> is reached, via <U|BFS::UC_BFSTargeted> — see that \
            \ function's own doc for the full rationale and correctness argument \
            \ (a node's shortest chain is fixed the first time BFS visits it, so \
            \ stopping early never changes <output>'s own chain, only skips \
            \ recording chains for nodes the caller's post-filter would have \
            \ discarded anyway). Internal only, used exclusively by \
            \ <URC_ComputeGraphPath> — <URC_ShortestChainPerNode> itself is \
            \ unchanged, still available for any caller genuinely wanting chains to \
            \ every reachable node, not just one target."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}] (URC_MakeGraph input output swpairs))
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPath:[string] (input:string output:string swpairs:[string])
        @doc "Computes the path between an <input> and <output> using BFS via \
        \ <URC_ShortestChainPerNode> from a passed down list of existing <swpairs>. \
        \ #20H fix: returns the clean [BAR] sentinel — never a bare out-of-bounds \
        \ <at> crash — whenever no chain reaches <output>, including the case of a \
        \ genuinely disconnected pair once <swpairs> has been narrowed upstream \
        \ (e.g. to active-only pools, #19H). \
        \ #65hL fix: sources its chains via <URCx_ShortestChainToTarget> instead of \
        \ <URC_ShortestChainPerNode> — same post-filter-down-to-<output> logic \
        \ below, unchanged, just fed from a BFS that stops once <output> is \
        \ actually found instead of exploring the whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (shortest-chains:[[string]] (URCx_ShortestChainToTarget input output swpairs))

            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    ;;#20H fix: guard against fp coming back empty (no chain
                    ;;reached output — e.g. a genuinely disconnected pair after
                    ;;active-only filtering) instead of a bare out-of-bounds `at`.
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    (defun URC_ShortestChainPerNode:[[string]] (input:string output:string swpairs:[string])
        @doc "#45L fix: renamed from URC_AllGraphPaths — the old name claimed 'all paths' \
            \ but this runs a single BFS traversal from <input> and keeps exactly one \
            \ shortest chain per node BFS reaches, not every simple path through the \
            \ graph (that's <URC_ComputeAllRoutes>, a different function entirely, added \
            \ in #34 Phase 11). <output> is accepted for signature symmetry with its only \
            \ caller (<URC_ComputeGraphPath>, which post-filters this result down to \
            \ chains actually ending at <output>) — it plays no role in the BFS itself, \
            \ which explores every reachable node from <input> regardless of <output>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}] (URC_MakeGraph input output swpairs))
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_RouteEdges:[string] (nodes:[string] swpairs:[string])
        @doc "For a <nodes> path (as returned by <URC_ComputeGraphPath>), returns the \
            \ union of every swpair actually usable to traverse it within <swpairs>'s \
            \ universe — one <URC_EdgesActive> lookup per hop. Used to build the \
            \ exclusion set for #34M/M2's best-of-K route comparison."
        (if (or (= nodes [BAR]) (< (length nodes) 2))
            []
            (fold
                (lambda
                    (acc:[string] idx:integer)
                    (+ acc (URC_EdgesActive (at idx nodes) (at (+ idx 1) nodes) swpairs))
                )
                []
                (enumerate 0 (- (length nodes) 2))
            )
        )
    )
    (defun URC_ComputeAlternateRoutes:[[string]] (input:string output:string swpairs:[string])
        @doc "#34M/M2 fix: <URC_ComputeGraphPath> alone only ever returns the single \
            \ first-discovered route — BFS's global once-per-node visited marking \
            \ means an equally valid alternate route (e.g. a diamond A->{B,C}->D \
            \ graph) is silently lost, and nothing ever compared candidate routes by \
            \ value anyway. This finds up to 3 edge-disjoint candidate routes by \
            \ re-running <URC_ComputeGraphPath> with each previously-found route's \
            \ edges excluded from the universe, forcing genuinely different routes \
            \ rather than the same route with a different parallel pool (that choice \
            \ is already optimal per-hop via <URC_BestEdgeFiltered>/<URC_BestEdgeOf>'s \
            \ own argmax, so re-exploring it would be wasted work). \
            \ Fixed cap of 3 attempts — Pact has no dynamic-length/convergence loops, \
            \ so the count must be a number decided in advance, not a runtime \
            \ condition; measured sufficient against this codebase's actual pool \
            \ topology (see the SWP audit's adversarial REPL proof for #34M/M2). \
            \ Returns only the routes genuinely found (drops [BAR] no-route results), \
            \ so the result can have 0-3 entries; the caller picks the best by value. \
            \ #65bL Phase 4 fix: now a thin wrapper — fetches the raw graph for this \
            \ call's own node universe, then delegates to \
            \ <URC_ComputeAlternateRoutesFromRaw>. A caller who's already fetched a \
            \ raw graph covering this <swpairs> universe (e.g. the STOA-repricing \
            \ loop, sharing one fetch across many unrelated calls) should call that \
            \ function directly instead, to skip this self-fetch."
        (let*
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (full-nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
                (raw-graph:[object{RawGraphNode}] (URC_FetchRawGraph full-nodes))
            )
            (URC_ComputeAlternateRoutesFromRaw input output swpairs raw-graph)
        )
    )
    (defun URC_ComputeAlternateRoutesFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2/4 fix: <URC_ComputeAlternateRoutes>'s real logic, \
            \ parameterized on an ALREADY-FETCHED <raw-graph> instead of fetching its \
            \ own — see <URC_ComputeAlternateRoutes>'s own doc for the full best-of-3 \
            \ rationale (unchanged here) and <URCx_HopperFromRaw>'s doc for why one \
            \ fetch can safely serve many different (input,output) queries against \
            \ the same <swpairs> universe (<UC_MakeGraphNodes> is input/output- \
            \ independent by construction). An exhausted-universe guard (empty \
            \ <swpairsN>) short-circuits to [BAR] instead of calling \
            \ <URC_ComputeGraphPathFromRaw> — that function's own downstream \
            \ graph-building (M3, a separate tracked finding) crashes rather than \
            \ cleanly returning no-route on an empty list, and this is the first \
            \ caller able to legitimately produce one (a fully-excluded, single-pool \
            \ universe after route1/route2 already claimed it)."
        (let*
            (
                (route1:[string]
                    (if (= swpairs []) [BAR] (URC_ComputeGraphPathFromRaw input output swpairs raw-graph))
                )
                (swpairs2:[string]
                    (if (= route1 [BAR])
                        swpairs
                        (UC_ExcludeEdges swpairs (URC_RouteEdges route1 swpairs))
                    )
                )
                (route2:[string]
                    (if (or (= route1 [BAR]) (= swpairs2 []))
                        [BAR]
                        (URC_ComputeGraphPathFromRaw input output swpairs2 raw-graph)
                    )
                )
                (swpairs3:[string]
                    (if (= route2 [BAR])
                        swpairs2
                        (UC_ExcludeEdges swpairs2 (URC_RouteEdges route2 swpairs2))
                    )
                )
                (route3:[string]
                    (if (or (= route2 [BAR]) (= swpairs3 []))
                        [BAR]
                        (URC_ComputeGraphPathFromRaw input output swpairs3 raw-graph)
                    )
                )
            )
            (filter (lambda (r:[string]) (!= r [BAR])) [route1 route2 route3])
        )
    )
    (defun URC_ComputeAllRoutes:[[string]]
        (input:string output:string swpairs:[string] max-attempts:integer)
        @doc "#34 Phase 11 — the original #34 ask: genuine exhaustive route discovery, \
            \ not the fixed best-of-3 approximation URC_ComputeAlternateRoutes settled \
            \ for. Generalizes that function's hardcoded 3-attempt let* chain into a \
            \ real fold over up to <max-attempts> attempts, same edge-exclusion-per-\
            \ found-route mechanism (URC_RouteEdges + UC_ExcludeEdges), same \
            \ early-exit-once-empty short-circuit already proven correct in that \
            \ function. Meant to be called via off-chain dirty read only (P3 — this is \
            \ what fills a SmartSwapPathBundle's swap-route component before \
            \ submission), never on the paid execution path; the whole point of the \
            \ #34/#34M redesign is to remove exactly this kind of search from paid \
            \ transactions. \
            \ P0.2's max-attempts escalation (try 1000, then 2000, then 3000... flat \
            \ +1000 steps, no doubling) is a CALLER-side retry pattern — this function \
            \ takes a fixed <max-attempts> and does exactly that many attempts (or \
            \ fewer, via early-exit), it does not escalate itself. A caller who gets \
            \ back exactly <max-attempts> routes with no natural exhaustion should \
            \ retry with a larger <max-attempts>; fewer than requested means the \
            \ search is genuinely exhausted (every route already found). \
            \ P0.2's outer hard stop (MAX_ATTEMPTS_HARD_CAP) is enforced here \
            \ regardless of what the caller requests — a caller cannot force an \
            \ unbounded search by passing an enormous <max-attempts>. \
            \ P0.4's depth cap (MAX_ROUTE_NODES, 7 tokens / 6 hops) is enforced as a \
            \ POST-DISCOVERY filter here, not baked into <U|BFS>'s own traversal — a \
            \ deliberate, documented deviation from P0.4's stated preference \
            \ ('ideally baked into the BFS/graph-walk itself... rather than only as a \
            \ post-discovery filter, wasteful'). Reasoning: baking a depth bound into \
            \ <U|BFS> would mean modifying a SHARED lower-layer utility module with \
            \ callers beyond this one feature, a broader and riskier change than this \
            \ phase's scope justifies; the 'wasteful — pay to explore and discard' \
            \ downside the preference is guarding against does not actually apply here, \
            \ since this function is dirty-read-only (free off-chain compute, never \
            \ paid gas) — the efficiency concern the baked-in preference exists for is \
            \ moot in this function's real deployment context. An over-cap route still \
            \ has its edges excluded from the remaining search universe before the next \
            \ attempt (without this, the deterministic BFS would just rediscover the \
            \ exact same over-cap route every remaining attempt, wasting the whole \
            \ budget making zero progress) — only whether it's ADDED to the returned \
            \ results is filtered. \
            \ Reuses the already-shipped URCx_HopperForNodes/UC_BestHopper unchanged \
            \ for picking the best candidate by actual computed output value (P1.8's \
            \ requirement) — that value-computation logic lives in SWPI (16_SWPI.pact), \
            \ not here; this function only discovers node-path candidates, same \
            \ division of labor URC_ComputeAlternateRoutes already established."
        (let
            (
                (capped-attempts:integer (if (> max-attempts MAX_ATTEMPTS_HARD_CAP) MAX_ATTEMPTS_HARD_CAP max-attempts))
            )
            (if (or (= swpairs []) (<= capped-attempts 0))
                []
                (at 0
                    (fold
                        (lambda
                            (acc:list idx:integer)
                            ;;acc = [routes-found:[[string]] remaining-universe:[string] stopped:bool]
                            (if (at 2 acc)
                                acc
                                (let*
                                    (
                                        (remaining:[string] (at 1 acc))
                                        (route:[string]
                                            (if (= remaining [])
                                                [BAR]
                                                (URC_ComputeGraphPath input output remaining)
                                            )
                                        )
                                    )
                                    (if (= route [BAR])
                                        ;;Genuinely exhausted — no route findable in the
                                        ;;remaining universe. Stop; every further attempt
                                        ;;would find the identical nothing.
                                        [(at 0 acc) remaining true]
                                        (let*
                                            (
                                                (route-edges:[string] (URC_RouteEdges route remaining))
                                                (new-remaining:[string] (UC_ExcludeEdges remaining route-edges))
                                                (within-depth-cap:bool (<= (length route) MAX_ROUTE_NODES))
                                                (new-routes:[[string]]
                                                    (if within-depth-cap
                                                        (+ (at 0 acc) [route])
                                                        (at 0 acc)
                                                    )
                                                )
                                            )
                                            [new-routes new-remaining false]
                                        )
                                    )
                                )
                            )
                        )
                        [[] swpairs false]
                        (enumerate 0 (- capped-attempts 1))
                    )
                )
            )
        )
    )
    (defun URC_MakeGraph:[object{BreadthFirstSearchV2.GraphNode}] (input:string output:string swpairs:[string])
        @doc "#13C fix + #19H fix, carried over unchanged by the #21H storage redesign: \
            \ a node's links must be genuine active edges (<URC_EdgesActive> non-empty), \
            \ not just 'is this token a valid node somewhere' — a neighbor token can be \
            \ a perfectly valid node overall while the ONLY swpair directly connecting \
            \ it to THIS node is outside <swpairs> (e.g. disabled). Requiring a real \
            \ <URC_EdgesActive> match subsumes plain node-membership (a real active edge \
            \ implies both endpoints are already valid nodes) and closes both problems \
            \ with one condition. \
            \ #37M/M3 fix: <nodes> can genuinely be [] (e.g. <swpairs> is [] \
            \ before the first pool is ever issued) — previously unguarded here, \
            \ a case not named by the original finding but sharing its exact \
            \ <enumerate 0 -1> / <at 0 []> root cause, directly downstream of \
            \ <UC_MakeGraphNodes>. Short-circuits to [] instead of crashing."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (nodes:[string] (ref-U|SWP::UC_MakeGraphNodes input output swpairs))
            )
            (if (= 0 (length nodes))
                []
                (fold
                    (lambda
                        (acc:[object{BreadthFirstSearchV2.GraphNode}] idx:integer)
                        (ref-U|LST::UC_AppL
                            acc
                            {
                                "node": (at idx nodes),
                                "links":
                                    (filter
                                        (lambda (n:string) (!= (URC_EdgesActive (at idx nodes) n swpairs) []))
                                        (URC_TokenNeighbours (at idx nodes))
                                    )
                            }
                        )
                    )
                    []
                    (enumerate 0 (- (length nodes) 1))
                )
            )
        )
    )
    (defun URC_FetchRawGraph:[object{RawGraphNode}] (nodes:[string])
        @doc "#65bL Phase 2: reads each of <nodes>'s SWPT|Graph row exactly once — \
            \ the read-fetch half of the raw-fetch/pure-filter split. A caller doing \
            \ multiple best-of-K attempts over the SAME node universe calls this \
            \ ONCE, then reuses the result via <UC_MakeGraphFromRaw> for every \
            \ attempt instead of each attempt independently re-reading and \
            \ rebuilding the whole graph the way <URC_MakeGraph> does. \
            \ #65bL Phase 3 investigated: a sorted-list + binary-search lookup was \
            \ built and measured against the linear scan <UC_MakeGraphFromRaw> uses \
            \ — an isolated synthetic benchmark showed binary search winning at \
            \ 100-300 elements, but the REAL integrated measurement (this exact \
            \ function, the real P2-scale 143-node universe) showed it as a net \
            \ REGRESSION (+27,527 gas on the SWP|TX 032z2 checkpoint), isolated and \
            \ confirmed by reverting only the lookup call. Trusted the real \
            \ measurement over the synthetic one and dropped it — recorded in \
            \ ROUND-01-OWNER-FEEDBACK.md as a real, deliberately-not-shipped result, \
            \ not silently discarded."
        (map
            (lambda (n:string) {"node": n, "neighbours": (UR_Graph n)})
            nodes
        )
    )
    (defun URC_ShortestChainPerNodeFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: <URC_ShortestChainPerNode>, sourcing its graph via \
            \ <UC_MakeGraphFromRaw> (an already-fetched <raw-graph>) instead of \
            \ <URC_MakeGraph> (a fresh read per node, every call)."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}]
                    (UC_MakeGraphFromRaw input output swpairs raw-graph)
                )
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URCx_ShortestChainToTargetFromRaw:[[string]]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65hL: <URCx_ShortestChainToTarget>, sourcing its graph via an \
            \ ALREADY-FETCHED <raw-graph> instead of a fresh self-fetch — same \
            \ early-exit-on-<output> shape as <UC_BFSTargeted>, mirroring \
            \ <URC_ShortestChainPerNodeFromRaw>'s own raw-graph sourcing. Internal \
            \ only, used exclusively by <URC_ComputeGraphPathFromRaw>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (graph:[object{BreadthFirstSearchV2.GraphNode}]
                    (UC_MakeGraphFromRaw input output swpairs raw-graph)
                )
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPathFromRaw:[string]
        (input:string output:string swpairs:[string] raw-graph:[object{RawGraphNode}])
        @doc "#65bL Phase 2: <URC_ComputeGraphPath>, sourcing its graph via \
            \ <URC_ShortestChainPerNodeFromRaw> instead of \
            \ <URC_ShortestChainPerNode> — same post-filter-down-to-<output> logic, \
            \ unchanged, just fed from an already-fetched raw graph. \
            \ #65hL fix: now sources its chains via \
            \ <URCx_ShortestChainToTargetFromRaw> instead — same raw-graph sourcing, \
            \ but stops once <output> is actually found instead of exploring the \
            \ whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (shortest-chains:[[string]]
                    (URCx_ShortestChainToTargetFromRaw input output swpairs raw-graph)
                )
            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    (defun URC_ShortestChainPerNodeFromGraph:[[string]]
        (input:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7: <URC_ShortestChainPerNodeFromRaw>, sourcing an \
            \ ALREADY-BUILT <graph> (<UC_MakeGraphFromRaw>) instead of building it \
            \ fresh from <raw-graph>/<swpairs> on every call — for a caller making \
            \ MULTIPLE Hopper queries against the SAME <swpairs> universe in one \
            \ transaction (the STOA-repricing loop), who builds the graph ONCE and \
            \ reuses it across every query. Safe per the same input/output- \
            \ independence <UC_MakeGraphFromRaw>'s own doc records — one graph \
            \ built against a given <swpairs> universe is valid for EVERY query \
            \ against that same universe, not just the one it happened to be built \
            \ for. Only the BFS traversal itself (genuinely <input>-dependent) \
            \ still runs per query."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFS graph input))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URCx_ShortestChainToTargetFromGraph:[[string]]
        (input:string output:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65hL: <URCx_ShortestChainToTargetFromRaw>, sourcing an ALREADY-BUILT \
            \ <graph> instead of rebuilding it from <raw-graph>/<swpairs> — same \
            \ early-exit-on-<output> shape, mirroring \
            \ <URC_ShortestChainPerNodeFromGraph>'s own already-built-graph sourcing. \
            \ Internal only, used exclusively by <URC_ComputeGraphPathFromGraph>."
        (let
            (
                (ref-U|BFS:module{BreadthFirstSearchV2} U|BFS)
                (bfs-obj:object{BreadthFirstSearchV2.BFS} (ref-U|BFS::UC_BFSTargeted graph input output))
            )
            (at "chains" bfs-obj)
        )
    )
    (defun URC_ComputeGraphPathFromGraph:[string]
        (input:string output:string graph:[object{BreadthFirstSearchV2.GraphNode}])
        @doc "#65bL Phase 7: <URC_ComputeGraphPathFromRaw>, sourcing its graph via \
            \ <URC_ShortestChainPerNodeFromGraph> (an already-built <graph>) \
            \ instead of rebuilding it from <raw-graph>/<swpairs> on every call — \
            \ same post-filter-down-to-<output> logic, unchanged. \
            \ #65hL fix: now sources its chains via \
            \ <URCx_ShortestChainToTargetFromGraph> instead — same already-built- \
            \ graph sourcing, but stops once <output> is actually found instead of \
            \ exploring the whole reachable set first."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (shortest-chains:[[string]]
                    (URCx_ShortestChainToTargetFromGraph input output graph)
                )
            )
            (if (!= shortest-chains [[BAR]])
                (let
                    (
                        (fp:[[string]]
                            (fold
                                (lambda
                                    (acc:[[string]] idx:integer)
                                    (let
                                        (
                                            (e:[string] (at idx shortest-chains))
                                            (l:string (at 0 (take -1 e)))
                                            (check:bool (= l output))
                                        )
                                        (if (not check)
                                            (ref-U|LST::UC_RemoveItem acc e)
                                            acc
                                        )
                                    )
                                )
                                shortest-chains
                                (enumerate 0 (- (length shortest-chains) 1))
                            )
                        )
                    )
                    (if (> (length fp) 0) (at 0 fp) [BAR])
                )
                [BAR]
            )
        )
    )
    ;;#34 Phase 7: dirty-read path-cache core functions.
    (defun URC_ReadPathCache:object{SwapTracerV3.PathCacheRow} (token-a:string token-b:string)
        @doc "Reversed-lookup read: checks <token-a>|<token-b> first, then \
            \ <token-b>|<token-a> reversed (the graph is confirmed bidirectional — \
            \ XI_UpdateGraphForSwpair's symmetric i×j registration), before concluding \
            \ no cached path exists. Returns {nodes:[BAR], edges:[], topology-version:-1} \
            \ on a genuine miss in both directions — never a crash, always a clean \
            \ sentinel. No trust implied: every caller still runs \
            \ <URC_ValidatePathStructure> (or SWPI's active-required wrapper) on \
            \ whatever this returns before using it — a hit here is not itself proof of \
            \ current validity, only of prior registration. Raw registration status \
            \ only — callers wanting freshness too go through \
            \ <URC_ReadPathCacheFresh> instead (#65bL Phase 1)."
        (let*
            (
                (key-fwd:string (+ (+ token-a "|") token-b))
                (row-fwd:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-fwd))
            )
            (if (!= (at "nodes" row-fwd) [BAR])
                row-fwd
                (let*
                    (
                        (key-rev:string (+ (+ token-b "|") token-a))
                        (row-rev:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-rev))
                    )
                    (if (!= (at "nodes" row-rev) [BAR])
                        {
                            "nodes" : (reverse (at "nodes" row-rev)),
                            "edges" : (reverse (at "edges" row-rev)),
                            "topology-version" : (at "topology-version" row-rev)
                        }
                        {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
                    )
                )
            )
        )
    )
    (defun URC_ReadPathCacheFresh:object{SwapTracerV3.PathCacheRow} (token-a:string token-b:string)
        @doc "#65bL Phase 1: <URC_ReadPathCache>, additionally collapsing a STALE entry \
            \ (its <topology-version> behind the live counter) to the same [BAR] miss \
            \ sentinel a genuinely-absent entry already returns. Callers never need to \
            \ distinguish 'never cached' from 'cached but topology has moved on since' — \
            \ both mean 'don't trust this, go search live instead'."
        (let*
            (
                (row:object{SwapTracerV3.PathCacheRow} (URC_ReadPathCache token-a token-b))
                (current-version:integer (UR_TopologyVersion))
            )
            (if (< (at "topology-version" row) current-version)
                {"nodes" : [BAR], "edges" : [], "topology-version" : -1}
                row
            )
        )
    )
    (defun URC_EdgeConnects:bool (i-id:string o-id:string swpair:string)
        @doc "Structural legitimacy check for ONE claimed hop: is <swpair> a real, \
            \ registered edge that actually connects <i-id> to <o-id> — not just some \
            \ active pool that happens to exist somewhere. Prevents a submitted bundle \
            \ from containing genuinely-real-but-unrelated edges that don't actually \
            \ form a connected path."
        (contains swpair (URC_Edges i-id o-id))
    )
    (defun URC_ValidatePathStructure:bool (nodes:[string] edges:[string])
        @doc "Exists-only structural validation (P3.1): every claimed hop genuinely \
            \ connects its claimed node pair, and the whole path respects the P0.4 depth \
            \ cap (7 tokens / 6 hops) — checked here directly rather than assumed of the \
            \ off-chain search that produced it, since a malformed or adversarial bundle \
            \ could otherwise submit a structurally-valid-per-hop but far-too-long route. \
            \ [BAR] (the 'no path found' sentinel) is explicitly rejected, not treated as \
            \ a trivial 1-node path. Does NOT check can-swap — SWPI wraps this with that \
            \ additional check for the active-required (real execution) case; this \
            \ module can't reach SWP to check it directly (deploy order)."
        (if (= nodes [BAR])
            false
            (if
                ;;Pact 5's <or> is strictly binary, not variadic — 3+ conditions need
                ;;fold, per this codebase's own documented convention (same class of
                ;;gotcha as the #26M/M9 single-arg <and> bug found earlier this session).
                (fold (or) false
                    [
                        (> (length nodes) 7)
                        (> (length edges) 6)
                        (!= (length edges) (- (length nodes) 1))
                    ]
                )
                false
                ;;#20H-style guard: (enumerate 0 -1) is [0 -1], NOT empty, in Pact 5 — a
                ;;0-hop path (single-node, edges=[]) would otherwise crash on an
                ;;out-of-bounds <at>. Explicit empty-edges short-circuit avoids it.
                (if (= (length edges) 0)
                    true
                    (fold
                        (lambda
                            (acc:bool idx:integer)
                            (and acc (URC_EdgeConnects (at idx nodes) (at (+ idx 1) nodes) (at idx edges)))
                        )
                        true
                        (enumerate 0 (- (length edges) 1))
                    )
                )
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateGraph (swpair:string)
        @doc "Records <swpair> in the adjacency graph: every token in <swpair> gets \
            \ every OTHER token in <swpair> appended to its neighbour list (idempotent \
            \ — safe to call more than once for the same swpair). Called once at \
            \ issuance from both SWPI::C_Issue and the MTX-SWP defpact path."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_UpdateGraphForSwpair swpair)
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdateGraphForSwpair (swpair:string)
        (require-capability (SECURE))
        (let*
            (
                (ref-U|SWP:module{UtilitySwpV2} U|SWP)
                (tokens:[string] (ref-U|SWP::UC_TokensFromSwpairString swpair))
                (n:integer (length tokens))
            )
            (map
                (lambda (i:integer)
                    (map
                        (lambda (j:integer)
                            (if (= i j)
                                BAR
                                (XI_UpdatePair (at i tokens) (at j tokens) swpair)
                            )
                        )
                        (enumerate 0 (- n 1))
                    )
                )
                (enumerate 0 (- n 1))
            )
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_UpdatePair (from:string to:string swpair:string)
        @doc "Adds <to> as a neighbour of <from> via <swpair>, creating the neighbour \
            \ entry if this is the first connection between them, or appending \
            \ <swpair> to the existing entry's swpairs list if not already present. \
            \ #65bL Phase 1 fix: also bumps the global topology-version counter, but \
            \ ONLY when this call genuinely changes something — a new token-pair \
            \ connection, or a new parallel pool on an already-connected pair — never \
            \ on an idempotent replay of an already-registered pair+swpair (e.g. \
            \ A_RebuildGraph re-running over every existing pool). <did-change> below \
            \ is exactly the same condition the pre-existing branching already computed \
            \ implicitly; this just names it so it can also gate the version bump."
        (require-capability (SECURE))
        (let*
            (
                (existing:[object{SwapTracerV3.NeighbourEdge}] (UR_Graph from))
                (idx:[integer] (UC_FindNeighbourIndex existing to))
                (is-new-pair:bool (= (length idx) 0))
                (old-swpairs:[string]
                    (if is-new-pair
                        []
                        (at "swpairs" (at (at 0 idx) existing))
                    )
                )
                (is-new-swpair:bool (not (contains swpair old-swpairs)))
                (did-change:bool (or is-new-pair is-new-swpair))
                (new-neighbours:[object{SwapTracerV3.NeighbourEdge}]
                    (if is-new-pair
                        (+ existing [{"token": to, "swpairs": [swpair]}])
                        (let*
                            (
                                (i:integer (at 0 idx))
                                (new-swpairs:[string]
                                    (if is-new-swpair
                                        (+ old-swpairs [swpair])
                                        old-swpairs
                                    )
                                )
                            )
                            (+ (+ (take i existing) [{"token": to, "swpairs": new-swpairs}]) (drop (+ i 1) existing))
                        )
                    )
                )
            )
            (write SWPT|Graph from {"neighbours": new-neighbours})
            (if did-change (XI_BumpTopologyVersion) "no-op")
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_BumpTopologyVersion ()
        @doc "#65bL Phase 1: increments the global topology-version counter by 1. \
            \ Called only from <XI_UpdatePair> when it detects a genuine change — \
            \ never unconditionally."
        (require-capability (SECURE))
        (write SWPT|TopologyVersion TOPOLOGY_VERSION_KEY
            {"version": (+ (UR_TopologyVersion) 1)}
        )
    )
    ;;Protection: Class 2 — SECURE
    (defun XI_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string])
        @doc "#34 Phase 7: registration into SWPT|PathCache. Self-verifying (owner's \
            \ final-check catch, 2026-08-21) — checks whether a row already exists in \
            \ EITHER direction before writing, rather than trusting a caller's is-new \
            \ claim as the write authority. Structural validation is the CALLER's \
            \ responsibility (URC_ValidatePathStructure/SWPI's active-required wrapper) \
            \ — this function only handles the write-safety half, matching this \
            \ codebase's XI_* convention of writes-only, no enforce/validation here. \
            \ #65bL Phase 1 fix: was strictly first-write-wins/insert-only, meaning a \
            \ cached entry could never be refreshed even after new topology made a \
            \ better route possible — permanent staleness by construction. Now \
            \ version-checked: a genuinely absent entry still inserts; an existing \
            \ entry only gets overwritten if its own <topology-version> is behind the \
            \ current counter (topology has moved on since it was cached), otherwise \
            \ still a no-op — never a redundant write for an already-current entry."
        (require-capability (SECURE))
        (let*
            (
                (key-fwd:string (+ (+ token-a "|") token-b))
                (key-rev:string (+ (+ token-b "|") token-a))
                (row-fwd:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-fwd))
                (row-rev:object{SwapTracerV3.PathCacheRow} (UR_PathCacheRaw key-rev))
                (already-fwd:bool (!= (at "nodes" row-fwd) [BAR]))
                (already-rev:bool (!= (at "nodes" row-rev) [BAR]))
                (current-version:integer (UR_TopologyVersion))
                (new-row:object{SwapTracerV3.PathCacheRow}
                    {"nodes": nodes, "edges": edges, "topology-version": current-version}
                )
            )
            (if (and (not already-fwd) (not already-rev))
                (insert SWPT|PathCache key-fwd new-row)
                (if already-fwd
                    (if (< (at "topology-version" row-fwd) current-version)
                        (write SWPT|PathCache key-fwd new-row)
                        "already fresh, no-op"
                    )
                    (if (< (at "topology-version" row-rev) current-version)
                        (write SWPT|PathCache key-rev new-row)
                        "already fresh, no-op"
                    )
                )
            )
        )
    )
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_RegisterPath (token-a:string token-b:string nodes:[string] edges:[string])
        @doc "#34 Phase 8: forward-module entrypoint for XI_RegisterPath, mirroring \
            \ XE_UpdateGraph exactly — P|UEV_IMC gate, then internal SECURE composition. \
            \ Cross-module callers (SWPU::C_SmartSwap, once wired) go through THIS, never \
            \ a caller-side (with-capability (SWPT.SECURE) ...) directly — SECURE's own \
            \ body is unconditionally true, so a direct outside grant would hand it to \
            \ any caller at all, not just legitimate Ouronet modules (this exact class of \
            \ issue is already documented, empirically, in this codebase's own ATS audit \
            \ findings)."
        (P|UEV_IMC)
        (with-capability (SECURE)
            (XI_RegisterPath token-a token-b nodes edges)
        )
    )
    ;;{5.7}  User [A/C]

)

;; --- tables for 14_SWPT.pact (5 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)
;; (create-table SWPT|Graph)
;; (create-table SWPT|PathCache)
;; (create-table SWPT|TopologyVersion)

