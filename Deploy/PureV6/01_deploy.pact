;; -------------------------------------------------------------------------
;; TX 01/10 -- VST  (the custodial unsleep: XE_Unsleep)
;;
;; THE KEYSTONE OF POOL CUSTODY, and the module's FIRST `XE_` function ever.
;;
;; An acquisition pool that holds a sleeping batch is a SMART account, and `VST|C>UNSLEEP`
;; refuses smart executors by design -- correctly, for a user dissolving their own lock. The
;; consequence was that a pool could take custody of a sleeping position and then never release
;; it: the asset would sit there until the pool itself was dissolved. `C_Unsleep` also pays the
;; native tokens to whoever executed, which for a custodial position means paying the pool.
;;
;; `XE_Unsleep` differs in exactly two ways, and nothing else:
;;   - no Standard-account requirement, so a registered CUSTODIAN may dissolve a batch it holds
;;   - a RECIPIENT distinct from the holder, so the native tokens reach the staker
;;
;; MATURITY IS ENFORCED BY THE SAME TEST a user's own unsleep must pass
;; (`nonce-supply = culled-amount`, i.e. the batch's whole supply is past its release date). A
;; custodian therefore gains the power to exit AT ALL, never the power to exit EARLY -- which is
;; the asymmetry that makes custody acceptable to a staker rather than a risk to them.
;;
;; SHIPS FIRST, AND TRIGGERS NO CASCADE. Nothing in the tree dot-calls VST (`_dotpin.py`), so no
;; module goes stale against it; AQP-FVT reaches it by MODREF, resolved at runtime. It is first
;; only because a Stage-1 module should land before the Stage-2 modules that call it.
;;
;; AFTER THE ROUND, re-run `AQP-BOOT.C_Step0_WireImcAndGovernor` -- that is what calls
;; AQP-FVT's `P|A_Define` and registers FVT's caller guard on VST's IMP list. Without it
;; `XE_Unsleep`'s `P|UEV_IMC` refuses AQP-FVT and the release path aborts with
;; "None of the guards passed".
;;
;; ROUND V6 -- DURATION-WEIGHTED MULTIPLIERS, THE SIGNED-FLOOR FIX, AND THE RE-RATE ENGINE.
;; Deploy 01 -> 10 IN ORDER.  Ten transactions, ~1.66 MB, ~372,000 gas in size charges.
;;
;; THE PROBLEM THE OWNER POSED.  "Someone could freeze for 1 day, and get to the 2x
;; multiplicator, while a permanent freeze is also 2x in multiplication, so this is something
;; that could be gambled."  A sleeping lock earned `mx-sleeping` IN FULL from the first second,
;; so one day of commitment and twenty-five years paid the identical rate.  The ruling: the
;; multiplier becomes a CEILING, approached in proportion to the time a batch still has LEFT TO
;; RUN, and reached only at the maximum term the chain itself will accept.
;;
;;     mx(batch) = 1 + (months remaining / cap) x (ceiling - 1)
;;
;; REMAINING, NEVER ORIGINAL, and that distinction is the whole mechanism.  Weighting by the
;; duration a lock was CREATED with would let a holder sleep for the full term, wait until a
;; month before release, and stake into the full ceiling for a month of real commitment.
;; `mx-frozen` stays FLAT because a freeze is irreversible -- there is no unfreeze in the tree --
;; so it is already maximum commitment and has nothing to scale against.
;;
;; THE SCALES ARE EXACT.  `VST|C>SLEEP` caps duration at 788,400,000 seconds and
;; `VST|C>HIBERNATE` caps `dayz` at 36,500.  Divided by the 2,628,000-second month those are
;; EXACTLY 300 and EXACTLY 1200, which is why one month constant serves both curves and why
;; `months = cap` returns the ceiling exactly for any ceiling -- verified for 1.999, 2.0, 2.2
;; and 3.4.
;;
;; FOUR MODULES CHANGED; FIVE MORE SHIP BECAUSE THEY DOT-CALL ONE OF THEM.  A stale dot-caller
;; of a table-owning callee does not go quietly stale -- it aborts with "hash not blessed" -- so
;; 04 through 09 ship byte-identical to what is already live and still have to ship.
;;
;; NO NEW INTERFACE, DELIBERATELY.  Pact 5 resolves modref members against the CONCRETE module
;; at runtime; `module{Iface}` constrains only what may be ASSIGNED.  So a function needs no
;; interface declaration to be callable through a modref -- measured, and the tree already
;; relied on it.  A V2->V3 bump was built and reverted: changing `implements` on a DEPLOYED
;; module breaks every not-yet-upgraded module whose `module{AcquisitionScoresV2}` annotation it
;; must still satisfy, which across a nine-transaction round is a live window in which the whole
;; AQP family aborts.  All three touched interface regions are byte-identical to the chain.
;;
;; NOTHING TO REPAIR ON THE LIVE CHAIN.  Every current position is NATIVE, and a native leg
;; multiplies by 1.0 and never reads `mx`.  So no existing weight moves when this lands, and the
;; re-rate sweep has no work to do until somebody sleeps or freezes.
;;
;; GATE GREEN at 28,211 assertions.  The multiplier arithmetic, the signed-floor invariant and
;; the engine's write path are pinned by [6.2.17]_AQP-RERATE.repl (68 assertions).
;; -------------------------------------------------------------------------
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev6.py

(namespace "ouronet-ns")

;; ---- source: 1_SOVEREIGN/STAGE_01/2_Core/11_VST.pact (module only -- its interface is already live)
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
    (defcap VST|C>FROZEN-LINK (executor:string dptf:string)
        @event
        (compose-capability (VST|C>LINK executor dptf))
    )
    (defcap VST|C>FREEZE (executor:string freeze-output:string dptf:string amount:decimal)
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
    (defcap VST|C>RESERVATION-LINK (executor:string dptf:string)
        @event
        (compose-capability (VST|C>LINK executor dptf))
    )
    (defcap VST|C>RESERVE (executor:string dptf:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (iz-reservation:bool (ref-DPTF::UR_IzReservationOpen dptf))
            )
            (ref-DALOS::UEV_EnforceAccountType executor false)
            (ref-DPTF::UEV_Reserved dptf true)
            (enforce iz-reservation (format "Reservation is not opened for Token {}" [dptf]))
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>UNRESERVE (executor:string r-dptf:string amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (dptf:string (ref-DPTF::UR_Reservation r-dptf))
            )
            (ref-DALOS::UEV_EnforceAccountType executor true)
            (ref-DPTF::CAP_Owner dptf)
            (ref-DPTF::UEV_Reserved r-dptf true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>VESTING-LINK (executor:string dptf:string)
        @event
        (compose-capability (VST|C>LINK executor dptf))
    )
    (defcap VST|C>VEST (executor:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer)
        @event
        (let
            (
                (ref-U|VST:module{UtilityVstV2} U|VST)
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-U|VST::UEV_MilestoneWithTime offset duration milestones 788400000)
            (ref-DALOS::UEV_EnforceAccountType executor false)
            (ref-DALOS::UEV_EnforceAccountType target-account false)
            (ref-DPTF::CAP_Owner dptf)
            (ref-DPTF::UEV_Vesting dptf true)
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>CULL (executor:string dpof:string nonce:integer culled-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (enforce (> culled-amount 0.0) (format "Nonce {} cant be culled" [nonce]))
            (ref-DALOS::UEV_EnforceAccountType executor false)
            (ref-DPOF::UEV_Vesting dpof true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>SLEEPING-LINK (executor:string dptf:string)
        @event
        (compose-capability (VST|C>LINK executor dptf))
    )
    (defcap VST|C>SLEEP (executor:string target-account:string dptf:string amount:decimal duration:integer)
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
    (defcap VST|XE>UNSLEEP
        (holder:string dpof:string nonce:integer recipient:string
         nonce-supply:decimal culled-amount:decimal)
        @doc "Dissolve a MATURED sleeping batch held by a CUSTODIAN and send the native tokens to \
            \ someone else. The forward-module twin of `VST|C>UNSLEEP`, and it differs from it in \
            \ exactly two ways -- both of which are the reason it has to exist. \
            \ \
            \ 1] NO STANDARD-ACCOUNT REQUIREMENT. `VST|C>UNSLEEP` enforces \
            \    `UEV_EnforceAccountType executor false`, which refuses a SMART account. That is \
            \    right for a user unsleeping their own batch, and it is exactly what makes the \
            \    ordinary client unusable by a custodian: `AQP|SC_NAME` is a smart account, so an \
            \    acquisition pool holding a sleeping position cannot dissolve it. \
            \ \
            \ 2] A RECIPIENT DISTINCT FROM THE HOLDER. The custodian holds the batch but does not \
            \    own the value; the native tokens must land on the staker. `C_Unsleep` sends them \
            \    to the executor, which for a custodial position would strand them in the pool. \
            \ \
            \ MATURITY IS STILL ENFORCED, BY THE SAME TEST, and it is the whole safety of the \
            \ custodial design: `nonce-supply = culled-amount` says the batch's ENTIRE supply has \
            \ passed its release date. A custodian cannot dissolve a lock early any more than a \
            \ holder can -- which is what lets the acquisition pool refuse an early exit without \
            \ also being able to force one. \
            \ \
            \ The caller is gated by `P|UEV_IMC`, so only a module holding a registered \
            \ inter-module guard reaches this at all."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping dpof))
            )
            (ref-DPTF::UEV_Sleeping dptf true)
            ;;the recipient takes real value, so it must be a real, activated standard account
            (ref-DALOS::UEV_EnforceAccountExists recipient)
            (ref-DALOS::UEV_EnforceAccountType recipient false)
            (enforce
                (> nonce-supply 0.0)
                (format "{} Nonce {} is empty or retired" [dpof nonce])
            )
            (enforce
                (= nonce-supply culled-amount)
                (format "{} Nonce {} cannot be unsleeped yet" [dpof nonce])
            )
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>UNSLEEP (executor:string dpof:string nonce:integer nonce-supply:decimal culled-amount:decimal)
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                ;;
                (dptf:string (ref-DPOF::UR_Sleeping dpof))
            )
            (ref-DALOS::UEV_EnforceAccountType executor false)
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
    (defcap VST|C>MERGE (executor:string dpof:string nonces:[integer])
        @event
        (enforce (= (take 2 dpof) "Z|") "Merge requires a Sleeping DPOF")
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|X>MERGE executor dpof))
    )
    (defcap VST|C>SLUMBER (executor:string dpof:string nonces:[integer])
        @event
        (enforce (= (take 2 dpof) "H|") "Slumber requires a Hibernating DPOF")
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|X>MERGE executor dpof))
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
    (defcap VST|C>HIBERNATE (executor:string target-account:string dptf:string amount:decimal dayz:integer)
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
    (defcap VST|C>AWAKE (executor:string dpof:string nonce:integer)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DALOS::UEV_EnforceAccountType executor false)
            (ref-DPOF::UEV_Hibernation dpof true)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>REPURPOSE-FROZEN-TF (executor:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-TRUE-FUNGIBLE executor dptf-to-repurpose repurpose-from repurpose-to 1))
    )
    (defcap VST|C>REPURPOSE-RESERVED-TF (executor:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-TRUE-FUNGIBLE executor dptf-to-repurpose repurpose-from repurpose-to 2))
    )
    (defcap VST|C>REPURPOSE-VESTING-MF (executor:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE executor dpof-to-repurpose [nonce] repurpose-from repurpose-to 1))
    )
    (defcap VST|C>REPURPOSE-SLEEPING-MF (executor:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE executor dpof-to-repurpose [nonce] repurpose-from repurpose-to 2))
    )
    (defcap VST|C>REPURPOSE-HIBERNATING-MF (executor:string dpof-to-repurpose:string nonce:integer repurpose-from:string repurpose-to:string)
        @event
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE executor dpof-to-repurpose [nonce] repurpose-from repurpose-to 3))
    )
    ;;
    (defcap VST|C>REPURPOSE-MERGE (executor:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        @event
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE executor dpof-to-repurpose nonces repurpose-from repurpose-to 2))
    )
    (defcap VST|C>REPURPOSE-SLUMBER (executor:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string)
        @event
        (UEV_NoncesForMerging nonces)
        (compose-capability (VST|C>REPURPOSE-ORTO-FUNGIBLE executor dpof-to-repurpose nonces repurpose-from repurpose-to 3))
    )
    ;;
    (defcap VST|C>REPURPOSE-TRUE-FUNGIBLE (executor:string dptf-to-repurpose:string repurpose-from:string repurpose-to:string fr-tag:integer)
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
            ;;ATTRIBUTION (canon 2.2). CAP_Owner proves the AUTHORITY of the SPECIAL token's
            ;;owner -- a DERIVED account, not a parameter -- which is HANDOFF 4g's signature for
            ;;"actor unrecorded". <repurpose-from> LOOKS like the actor and is not: it is the
            ;;account being WIPED, so it is the executee. Bind the named executor to the account
            ;;the authority check actually used.
            (ref-DPTF::UEV_ExecutorIsKonto executor dptf)
            (compose-capability (P|TT))
        )
    )
    (defcap VST|C>REPURPOSE-ORTO-FUNGIBLE (executor:string dpof-to-repurpose:string nonces:[integer] repurpose-from:string repurpose-to:string vzh-tag:integer)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
            )
            (ref-DPOF::UEV_NoncesToAccount dpof-to-repurpose repurpose-from nonces)
            (compose-capability (VST|X>REPURPOSE-ORTO-FUNGIBLE executor dpof-to-repurpose repurpose-from repurpose-to vzh-tag))
        )
    )
    (defcap VST|X>REPURPOSE-ORTO-FUNGIBLE (executor:string dpof-to-repurpose:string repurpose-from:string repurpose-to:string vzh-tag:integer)
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
            ;;ATTRIBUTION (canon 2.2) -- ortofungible twin of the TF cap above. <dptf> is derived
            ;;from the DPOF by its vesting/sleeping/hibernation tag, so the account CAP_Owner
            ;;proves is never a parameter. Bind the named executor to that same account.
            (ref-DPTF::UEV_ExecutorIsKonto executor dptf)
            (compose-capability (P|TT))
        )
    )
    ;;
    ;;
    (defcap VST|C>TOGGLE-FROZEN-TF-TR (executor:string s-dptf:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-TF-TR executor s-dptf target))
    )
    (defcap VST|C>TOGGLE-RESERVED-TF-TR (executor:string s-dptf:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-TF-TR executor s-dptf target))
    )
    (defcap VST|X>TOGGLE-SPECIAL-TF-TR (executor:string s-dptf:string target:string)
        @doc "ATTRIBUTION (canon 2.2). <UEV_ParentOwnership> proved the AUTHORITY -- that the \
            \ caller owns the PARENT of this special token -- and named no actor. \
            \ <UEV_ExecutorIsParentKonto> binds the account the caller NAMED to that same parent \
            \ owner. The ownership enforce is kept, not replaced."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::UEV_ParentOwnership s-dptf)
            (ref-DPTF::UEV_ExecutorIsParentKonto executor s-dptf)
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>TOGGLE-SLEEPING-OF-TR (executor:string s-dpof:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-OF-TR executor s-dpof target))
    )
    (defcap VST|C>TOGGLE-HIBERNATING-OF-TR (executor:string s-dpof:string target:string)
        @event
        (compose-capability (VST|X>TOGGLE-SPECIAL-OF-TR executor s-dpof target))
    )
    (defcap VST|X>TOGGLE-SPECIAL-OF-TR (executor:string s-dpof:string target:string)
        @doc "Parent ownership for transfer-role toggle. Sleeping LP (Z|W|/Z|S|/Z|P|) cannot use \
            \ DPOF::UEV_ParentOwnership; gate on native LP DPTF owner instead."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;
                (fourth:string (drop 3 (take 4 s-dpof)))
            )
            ;;ATTRIBUTION (canon 2.2). The binder MIRRORS the branch above account for account:
            ;;a sleeping LP (Z|W|/Z|S|/Z|P|) is gated on the native LP DPTF's owner, everything
            ;;else on the parent DPOF's. Binding to the other side of that `if` would name an
            ;;account the authority check never proved -- which is how a decorative executor gets
            ;;written without anyone noticing.
            (if (= fourth BAR)
                (do
                    (ref-DPTF::CAP_Owner (ref-DPOF::UR_Sleeping s-dpof))
                    (ref-DPTF::UEV_ExecutorIsKonto executor (ref-DPOF::UR_Sleeping s-dpof))
                )
                (do
                    (ref-DPOF::UEV_ParentOwnership s-dpof)
                    (ref-DPOF::UEV_ExecutorIsParentKonto executor s-dpof)
                )
            )
            (compose-capability (P|TT))
        )
    )
    ;;
    (defcap VST|C>LINK (executor:string dptf:string)
        @doc "ATTRIBUTION (patron/executor canon 2.2, 2026-09-21). <CAP_Owner dptf> proved the \
            \ AUTHORITY -- that whoever called owns the token -- but named no ACTOR, the shape \
            \ HANDOFF 4g calls 'authority proven, actor unrecorded' and the third instance of \
            \ in three modules. <UEV_ExecutorIsKonto> supplies the other half: that the account \
            \ the caller NAMED is that same owner. The ownership enforce is kept, not replaced."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            (ref-DPTF::CAP_Owner dptf)
            (ref-DPTF::UEV_ExecutorIsKonto executor dptf)
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
    ;;MODULE-ONLY, NOT DECLARED IN `VestingV2`, and deliberately so: that interface is already
    ;;DEPLOYED (`Deploy/1_Pure/05_deploy.pact`) and a deployed interface cannot be changed. Both
    ;;callers are inside this module, so a declaration would buy nothing while making the repo's
    ;;interface claim a member the chain does not have -- a divergence the gate cannot see, and
    ;;the same one that cost a round earlier in this work.
    (defun URC_HibernationFeePromile:decimal (dpof:string nonce:integer)
        @doc "The awakening fee a hibernating batch still carries, in PROMILE: 800 at mint, decaying \
            \ linearly to 0 at its release date. \
            \ \
            \ EXTRACTED 2026-10-10 so there is ONE copy. The formula was written out twice -- in \
            \ `C_Awake` and in `URCi_Awake` -- which is one more than is safe for an expression \
            \ deciding how much of a holder's principal gets burned: a price reader that \
            \ disagreed with the op it prices is exactly the drift `URCi_*` exists to prevent. \
            \ \
            \ ZERO FEE IS ALSO THE MATURITY TEST -- the two are the same condition -- which is \
            \ why this is a `URC_` rather than a private expression. Nothing gates on it today; \
            \ it is here so that anything which needs to ask \"has this batch run its term?\" asks \
            \ the same expression the fee is computed from. \
            \ \
            \ Reads `mint-time` and `release-date` from element 0 of the metadata chain -- the \
            \ HIBERNATION shape. A sleeping batch writes {release-amount, release-date} and has no \
            \ `mint-time`, so this ABORTS on one rather than quietly returning 0.0, which for a \
            \ maturity gate is the right way round. Every caller is a hibernation-only path and \
            \ the capability checks the link."
        (let*
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (meta-data-chain:[object] (ref-DPOF::UR_NonceMetaData dpof nonce))
                (mint-time:time (at "mint-time" (at 0 meta-data-chain)))
                (release-time:time (at "release-date" (at 0 meta-data-chain)))
                (hibernating-period:decimal (diff-time release-time mint-time))
                (elapsed-time:decimal (diff-time (at "block-time" (chain-data)) mint-time))
            )
            (if (>= elapsed-time hibernating-period)
                0.0
                (floor (- 800.0 (* 800.0 (/ elapsed-time hibernating-period))) 4)
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
                ;;ONE COPY OF THE DECAY, in `URC_HibernationFeePromile`. It was written out here and
                ;;again in the other Awake path -- two copies of the expression that decides how
                ;;much of a holder's principal gets burned.
                (hibernating-fee-promile:decimal (URC_HibernationFeePromile dpof nonce))
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
    ;;MODULE-ONLY, NOT DECLARED IN `VestingV2` -- that interface is deployed and cannot change.
    ;;AQP-FVT reaches it by modref, which `REPL/tools/_modref.py` records as this repo's
    ;;convention for members an interface does not name.
    (defun URC_SpecialLegIssuerRestricted:bool (s-dpof:string)
        @doc "True when a special DPOF's transfer roles express the TOKEN OWNER'S intent to \
            \ restrict who may hold it -- as opposed to merely carrying this module's own \
            \ infrastructure grant. \
            \ \
            \ WHY THE DISTINCTION HAS TO EXIST. `XI_CreateSpecialOrtoFungibleLink` grants \
            \ `VST|SC_NAME` the transfer role on EVERY special token at creation, because \
            \ dissolution moves the batch to this module and `DPOF::UEV_MoveRoleCheck` would \
            \ otherwise refuse it. The side effect is that `are-transfer-roles-active` is TRUE \
            \ for every sleeping, vested and hibernating token that has ever existed -- so \
            \ \"does this token have transfer roles\" is a question with one answer and no \
            \ information in it. Used as a policy gate it would refuse everything, forever. \
            \ \
            \ WHAT IS ACTUALLY BEING ASKED is whether a HUMAN chose to restrict the token. Every \
            \ holder other than this module's own account got there through \
            \ `C_ToggleTransferRole*`, which only the token owner can call -- so any other name \
            \ present IS the owner's intent, and its absence is the absence of intent. \
            \ \
            \ IT LIVES IN VST BECAUSE VST CREATES THE EXCEPTION. A consumer cannot be expected to \
            \ know that one particular role-holder is an implementation detail of unsleeping; the \
            \ module that grants it is the one that can say so, and if that grant ever changes \
            \ this is the single place that has to follow."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (let
                (
                    (bar:string (ref-U|CT::CT_BAR))
                )
                (> (length
                       (filter
                           (lambda (a:string) (and (!= a bar) (!= a VST|SC_NAME)))
                           (ref-DPOF::UR_Verum5 s-dpof)))
                   0)
            )
        )
    )
    (defun URC_SpecialTransferRoleKonto:string (s-token:string)
        @doc "The account the transfer-role toggle caps require as <executor>, for a special \
            \ token of EITHER family. \
            \ \
            \ Exists for the reason DPOF::URC_BrandingKonto exists, and it says so itself: that \
            \ rule 'was being retyped at call sites, and got retyped WRONG' by an earlier pass of \
            \ THIS migration. The toggle rule is worse, because it BRANCHES -- a sleeping LP \
            \ (Z|W|/Z|S|/Z|P|) is gated on the native LP DPTF's owner, everything else on the \
            \ parent's -- so retyping it across fifteen call sites is fifteen chances to pick the \
            \ wrong side of an `if`. Encoded once, here, and called by the tests that must \
            \ predict it. \
            \ \
            \ NOT used by the capabilities themselves: those keep their own inline branch so the \
            \ AUTHORITY check and the ATTRIBUTION check cannot silently come to rest on \
            \ different accounts. If this reader ever disagrees with them, the cap refuses and \
            \ says so -- which is the failure anyone would want."
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                ;;BOTH ortofungible prefixes. Written first as `= "Z|"` only, which sent every
                ;;HIBERNATING token down the DPTF branch and died on
                ;;"No value found in table DPTF|PropertiesTable for key: H|MOCKA-..." -- a DPOF id
                ;;read from DPTF's table. This module's own comment at the Merge/Slumber guards
                ;;says it plainly: test (take 2 dpof-id) against ["Z|" "H|"]. Sleeping and
                ;;hibernating are two prefixes of ONE family.
                (son:bool (contains (take 2 s-token) ["Z|" "H|"]))
                (fourth:string (drop 3 (take 4 s-token)))
            )
            (if (and son (= fourth BAR))
                (ref-DPTF::UR_Konto (ref-DPOF::UR_Sleeping s-token))
                (if son
                    (ref-DPOF::URC_BrandingKonto s-token)
                    (ref-DPTF::UR_Konto (ref-DPTF::URCv_Parent s-token))
                )
            )
        )
    )

    (defun C_CreateFrozenLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>FROZEN-LINK executor dptf)
            (XI_CreateSpecialTrueFungibleLink patron dptf 1)
        )
    )
    (defun C_CreateReservationLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>RESERVATION-LINK executor dptf)
            (XI_CreateSpecialTrueFungibleLink patron dptf 2)
        )
    )
    (defun C_CreateVestingLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>VESTING-LINK executor dptf)
            (XI_CreateSpecialOrtoFungibleLink patron dptf 1)
        )
    )
    (defun C_CreateSleepingLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>SLEEPING-LINK executor dptf)
            (XI_CreateSpecialOrtoFungibleLink patron dptf 2)
        )
    )
    (defun C_CreateHibernatingLink:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dptf:string)
        (P|UEV_IMC)
        (with-capability (VST|C>SLEEPING-LINK executor dptf)
            (XI_CreateSpecialOrtoFungibleLink patron dptf 3)
        )
    )
    (defun C_Freeze:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string freeze-output:string dptf:string amount:decimal)
        (P|UEV_IMC)
        (with-capability (VST|C>FREEZE executor freeze-output dptf amount)
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
                        (if (!= executor VST|SC_NAME)
                            (ref-TFT::C_Transfer patron executor VST|SC_NAME dptf amount true)
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
        (patron:string executor:string executee:string dptf-to-repurpose:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-FROZEN-TF executor dptf-to-repurpose executee repurpose-to)
            (XI_RepurposeTrueFungible patron dptf-to-repurpose executee repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleFrozenDPTF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string s-dptf:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-FROZEN-TF-TR executor s-dptf target)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::C_ToggleTransferRole patron (ref-DPTF::UR_Konto s-dptf) target s-dptf toggle)
            )
        )
    )
    (defun C_Reserve:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dptf:string amount:decimal)
        (P|UEV_IMC)
        (with-capability (VST|C>RESERVE executor dptf amount)
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
                        (if (!= executor VST|SC_NAME)
                            (ref-TFT::C_Transfer patron executor VST|SC_NAME dptf amount true)
                            EOC
                        )
                        ;;2]VST|SC_NAME mint R|dptf
                        (ref-DPTF::C_Mint patron VST|SC_NAME r-dptf amount false)
                        ;;3]VST|SC_NAME sends R|dptf to executor
                        (ref-TFT::C_Transfer patron VST|SC_NAME executor r-dptf amount true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_Unreserve:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string r-dptf:string amount:decimal)
        (P|UEV_IMC)
        (with-capability (VST|C>UNRESERVE executor r-dptf amount)
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
                        (ref-TFT::C_Transfer patron executor VST|SC_NAME r-dptf amount true)
                        ;;2]VST|SC_NAME burns R|dptf
                        (ref-DPTF::C_Burn patron VST|SC_NAME r-dptf amount)
                        ;;3]VST|SC_NAME sends dptf back to executor
                        (ref-TFT::C_Transfer patron VST|SC_NAME executor dptf amount true)
                    ]
                    []
                )
            )
        )
    )
    (defun C_RepurposeReserved:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string dptf-to-repurpose:string repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-RESERVED-TF executor dptf-to-repurpose executee repurpose-to)
            (XI_RepurposeTrueFungible patron dptf-to-repurpose executee repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleReservedDPTF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string s-dptf:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-RESERVED-TF-TR executor s-dptf target)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                )
                (ref-DPTF::C_ToggleTransferRole patron (ref-DPTF::UR_Konto s-dptf) target s-dptf toggle)
            )
        )
    )
    (defun C_Vest:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string target-account:string dptf:string amount:decimal offset:integer duration:integer milestones:integer)
        (P|UEV_IMC)
        (with-capability (VST|C>VEST executor target-account dptf amount offset duration milestones)
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
                        (if (!= executor VST|SC_NAME)
                            (ref-TFT::C_Transfer patron executor VST|SC_NAME dptf amount true)
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
        (patron:string executor:string dpof:string nonce:integer)
        (P|UEV_IMC)
        (let
            (
                (culled-data:list (URC_CullMetaDataAmountWithObject dpof nonce))
                (culled-amount:decimal (at 0 culled-data))
            )
            (with-capability (VST|C>CULL executor dpof nonce culled-amount)
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
                                ;;1]VST|SC_NAME transfers the whole dptf back to the executor, when there is no return amount
                                (ref-TFT::C_Transfer patron VST|SC_NAME executor dptf-id nonce-supply true)
                                (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                    [
                                        ;;1]Only the ready to unvest dptf is trasnfered back to executor
                                        (ref-TFT::C_Transfer patron VST|SC_NAME executor dptf-id culled-amount true)
                                        ;;2]If return amount is non zero, it is minted as a new DPOF
                                        (ref-DPOF::C_Mint patron VST|SC_NAME dpof return-amount remint-meta-data-chain)
                                        ;;3]Together with the newly minted remainder, still vested, dppf
                                        (ref-DPOF::C_Transfer patron VST|SC_NAME executor dpof [(+ 1 nonces-used)] true)
                                    ]
                                    []
                                )
                            )
                        )
                        (ico3:object{IgnisCollectorV3.OutputCumulator}
                            (ref-IGNIS::UDC_ConcatenateOutputCumulators
                                [
                                    ;;1]Transfer <nonce> to VST|SC_NAME for Burning
                                    (ref-DPOF::C_Transfer patron executor VST|SC_NAME dpof [nonce] true)
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
        (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-VESTING-MF executor dpof-to-repurpose nonce executee repurpose-to)
            (XI_RepurposeOrtoFungible patron dpof-to-repurpose nonce executee repurpose-to)
        )
    )
    (defun C_Sleep:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string target-account:string dptf:string amount:decimal duration:integer)
        (P|UEV_IMC)
        (with-capability (VST|C>SLEEP executor target-account dptf amount duration)
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
                        (if (!= executor VST|SC_NAME)
                            (ref-TFT::C_Transfer patron executor VST|SC_NAME dptf amount true)
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
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_Unsleep:object{IgnisCollectorV3.OutputCumulator}
        (patron:string holder:string dpof:string nonce:integer recipient:string)
        @doc "Forward (AQP custodial release): dissolve a MATURED sleeping batch held by <holder> \
            \ and send the native counterpart to <recipient>. \
            \ \
            \ THE FIRST `XE_` IN THIS MODULE, and it is here because a custodial sleeping stake has \
            \ no other way out. An acquisition pool that holds a sleeping batch is a SMART account, \
            \ and `C_Unsleep` refuses smart executors by design; it also pays the native tokens to \
            \ whoever executed, which for a pool would strand them. So the pool could take custody \
            \ of a lock and then never release it -- the asset would be stuck until the pool itself \
            \ was dissolved. \
            \ \
            \ SAME THREE STEPS AS `C_Unsleep`, deliberately unchanged: the batch moves to \
            \ `VST|SC_NAME`, is burned in its entirety, and the native amount is transferred out. \
            \ Only the LAST leg differs -- it pays <recipient> rather than the holder. Burning the \
            \ whole supply is what RETIRES the nonce: `DPOF::XI_DebitNonces` sets a fully-debited \
            \ nonce's supply to -1.0 and takes it out of circulation permanently, so there is no \
            \ dangling batch afterwards and the number is never reissued. \
            \ \
            \ MATURITY IS ENFORCED IN THE CAPABILITY, by the same `nonce-supply = culled-amount` \
            \ test the user-facing client uses. A custodian gets no power to exit early; it gets \
            \ only the power to exit AT ALL. That asymmetry is the point -- it is what lets the pool \
            \ hold a position to term while still guaranteeing the staker can always get out once \
            \ the term is up. P|UEV_IMC + VST|XE>UNSLEEP."
        (P|UEV_IMC)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (culled-amount:decimal (at 0 (URC_CullMetaDataAmountWithObject dpof nonce)))
            )
            (with-capability
                (VST|XE>UNSLEEP holder dpof nonce recipient nonce-supply culled-amount)
                (let
                    (
                        (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                        (ref-TFT:module{TrueFungibleTransferV2} TFT)
                        ;;
                        (dptf-id:string (ref-DPOF::UR_Sleeping dpof))
                    )
                    (ref-IGNIS::UDC_ConcatenateOutputCumulators
                        [
                            ;;1] the custodian hands the batch to VST
                            (ref-DPOF::C_Transfer patron holder VST|SC_NAME dpof [nonce] true)
                            ;;2] burned in its entirety -- which retires the nonce to supply -1.0
                            (ref-DPOF::C_Burn patron VST|SC_NAME dpof nonce nonce-supply)
                            ;;3] and the native counterpart goes to the STAKER, not the custodian
                            (ref-TFT::C_Transfer patron VST|SC_NAME recipient dptf-id nonce-supply true)
                        ]
                        []
                    )
                )
            )
        )
    )
    (defun C_Unsleep:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dpof:string nonce:integer)
        (P|UEV_IMC)
        (let
            (
                (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                (nonce-supply:decimal (ref-DPOF::UR_NonceSupply dpof nonce))
                (culled-amount:decimal (at 0 (URC_CullMetaDataAmountWithObject dpof nonce)))
            )
            (with-capability (VST|C>UNSLEEP executor dpof nonce nonce-supply culled-amount)
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
                            (ref-DPOF::C_Transfer patron executor VST|SC_NAME dpof [nonce] true)
                            ;;2]Which is then burned in its entirety
                            (ref-DPOF::C_Burn patron VST|SC_NAME dpof nonce nonce-supply)
                            ;;3]VST|SC_NAME transfers in return the initial amount of the dpof, as the dptf counterpart
                            (ref-TFT::C_Transfer patron VST|SC_NAME executor dptf-id nonce-supply true)
                        ]
                        []
                    )
                )
            )
        ) 
    )
    (defun C_Merge:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string dpof:string nonces:[integer])
        (P|UEV_IMC)
        (with-capability (VST|C>MERGE executor dpof nonces)
            (XIv_MergeNonces patron dpof executor executor nonces 2)
        )
    )
    (defun C_RepurposeMerge:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string dpof-to-repurpose:string nonces:[integer] repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-MERGE executor dpof-to-repurpose nonces executee repurpose-to)
            (XIv_MergeNonces patron dpof-to-repurpose executee repurpose-to nonces 2)
        )
    )
    (defun C_RepurposeSleeping:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-SLEEPING-MF executor dpof-to-repurpose nonce executee repurpose-to)
            (XI_RepurposeOrtoFungible patron dpof-to-repurpose nonce executee repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleSleepingDPOF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string s-dpof:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-SLEEPING-OF-TR executor s-dpof target)
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-DPOF::C_ToggleTransferRole patron (ref-DPOF::UR_Konto s-dpof) target s-dpof toggle)
            )
        )
    )
    (defun C_Hibernate:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string target-account:string dptf:string amount:decimal dayz:integer)
        (P|UEV_IMC)
        (with-capability (VST|C>HIBERNATE executor target-account dptf amount dayz)
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
                        (if (!= executor VST|SC_NAME)
                            (ref-TFT::C_Transfer patron executor VST|SC_NAME dptf amount true)
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
        (patron:string executor:string dpof:string nonce:integer)
        @doc "Hibernated Tokens have a 80% peak awakening fee, \
            \ that goes down to zero as time elapses towards its release date.\
            \ This fee is discared (burning it), with no way of collecting it."
        (P|UEV_IMC)
        (with-capability (VST|C>AWAKE executor dpof nonce)
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
                    ;;ONE COPY OF THE DECAY, in `URC_HibernationFeePromile`. It was written out here and
                    ;;again in the other Awake path -- two copies of the expression that decides
                    ;;how much of a holder's principal gets burned.
                    (hibernating-fee-promile:decimal (URC_HibernationFeePromile dpof nonce))
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
                        (ref-DPOF::C_Transfer patron executor VST|SC_NAME dpof [nonce] true)
                        ;;2]Burn it whole
                        (ref-DPOF::C_Burn patron VST|SC_NAME dpof nonce nonce-supply)
                        ;;3]Transfer Remainder from VST|SC_NAME to <executor>
                        (ref-TFT::C_Transfer patron VST|SC_NAME executor dptf-id remainder true)
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
        (patron:string executor:string dpof:string nonces:[integer])
        (P|UEV_IMC)
        (with-capability (VST|C>SLUMBER executor dpof nonces)
            (XIv_MergeNonces patron dpof executor executor nonces 3)
        )
    )
    (defun C_RepurposeSlumber:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string dpof-to-repurpose:string nonces:[integer] repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-SLUMBER executor dpof-to-repurpose nonces executee repurpose-to)
            (XIv_MergeNonces patron dpof-to-repurpose executee repurpose-to nonces 3)
        )
    )
    (defun C_RepurposeHibernating:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string executee:string dpof-to-repurpose:string nonce:integer repurpose-to:string)
        (P|UEV_IMC)
        (with-capability (VST|C>REPURPOSE-HIBERNATING-MF executor dpof-to-repurpose nonce executee repurpose-to)
            (XI_RepurposeOrtoFungible patron dpof-to-repurpose nonce executee repurpose-to)
        )
    )
    (defun C_ToggleTransferRoleHibernatingDPOF:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string s-dpof:string target:string toggle:bool)
        (P|UEV_IMC)
        (with-capability (VST|C>TOGGLE-HIBERNATING-OF-TR executor s-dpof target)
            (let
                (
                    (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
                )
                (ref-DPOF::C_ToggleTransferRole patron (ref-DPOF::UR_Konto s-dpof) target s-dpof toggle)
            )
        )
    )
    (defun C_Constrict:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string ats:string rt:string amount:decimal dayz:integer)
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
                        (ref-TFT::C_Transfer patron executor ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt c-rbt-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (C_Hibernate patron ATS|SC_NAME executor c-rbt c-rbt-amount dayz)
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
        (patron:string executor:string ats1:string ats2:string rt:string amount:decimal dayz:integer)
        @doc "Brumates the <rt> through 2 ATS-Pairs, \
            \ outputting the <c-rbt2> as Hibernated Token to the <executor> \
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
                        (ref-TFT::C_Transfer patron executor ATS|SC_NAME rt amount true)
                    )
                    (ico2:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt1 c-rbt1-amount false)
                    )
                    (ico3:object{IgnisCollectorV3.OutputCumulator}
                        (ref-DPTF::C_Mint patron ATS|SC_NAME c-rbt2 c-rbt2-amount false)
                    )
                    (ico4:object{IgnisCollectorV3.OutputCumulator}
                        (C_Hibernate patron ATS|SC_NAME executor c-rbt2 c-rbt2-amount dayz)
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

