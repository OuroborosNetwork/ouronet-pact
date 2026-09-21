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

(create-table P|T)
(create-table P|MT)