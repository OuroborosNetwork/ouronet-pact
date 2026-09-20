;; ---------------------------------------------------------------------------
;; OURONET DEPLOY -- file 22 of 22
;; This is STEP 23 of 23 in the full sequence (see Deploy/MANIFEST.md).
;; Steps 1-22 must have run first, including the init steps between deploys.
;; 1 module(s), 14,849 gas measured in the REPL gas model, 41,491 bytes
;;
;; Modules in this transaction, IN ORDER (do not reorder):
;;   2_CITIZEN/Stage_Z/03_DSP+.pact
;;
;; Paste this whole file as ONE transaction. It needs the Ouronet admin signature
;; and the `ouronet-ns` namespace, which the first line sets.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; ===== 2_CITIZEN/Stage_Z/03_DSP+.pact ==============================
(interface Dispenser




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
    (defun UC_KosonicAutostakeSplit:[decimal] (input:decimal ip:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    ;;  [URC]
    ;;
    (defun URC_DailyOURO ())
    (defun URC_DailyKOSON (iz-game-live:bool))
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    ;;  [A]
    ;;
    (defun A_OuroMinterStageOne:[decimal] ())
    (defun AA_OuroMinterStageTwo:[decimal] (fvt-ids:[string]))
    (defun A_KosonMinterStageOne ())
    (defun A_KosonMinterStageOne_1of3 ())
    (defun A_KosonMinterStageOne_2of3 ())
    (defun A_KosonMinterStageOne_3of3 ())

)
(module DSP GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements OuronetPolicyV2)
    (implements Dispenser)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DSP                                (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_DSP                                (keyset-ref-guard DSP|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|DSP_ADMIN)))
    (defcap GOV|DSP_ADMIN ()
        (enforce-one
            "DSP Dispencer Admin not satisfed"
            [
                (enforce-guard GOV|MD_DSP)
                (enforce-guard GOV|SC_DSP)
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
    ;;
    ;;  [Keys]
    (defun GOV|DSPKey ()                                (+ (CT_Namespace) ".dh_sc_dispenser-keyset"))
    (defun GOV|CSTKey ()                                (+ (CT_Namespace) ".dh_sc_custodians-keyset"))
    ;;
    ;;  [SC-Names]
    (defun GOV|DSP1|SC_NAME ()                          (at 0 ["Ѻ.hÜ5ĞÊÜεŞΓõè1Ă₳äàÄìãÓЦφLÕзЯŮμĞ₿мK6àŘуVćχδдзηφыβэÎχUHRêγBğΛ∇VŒižďЬШ£îOÜøE4ÖFSõЩЩAłκè1ččΨΦŻЖэч6Iчη₱ØćнúŒψУćÀyпãЗцÚäδÏÍtςřïçγț6γÎęôigFzÝûηы₿ÏЬüБэΞčмŃт₳ŘчjζsŠȚHъĘïЦ0"]))
    (defun GOV|CST1|SC_NAME ()                          (at 0 ["Ѻ.Щę7ãŽÓλ4ěПîЭđЮЫAďбQOχnиИДχѺNŽł6ПžιéИąĞuπЙůÞ1ęrПΔżæÍžăζàïαŮŘDzΘ€ЦBGÝŁЭЭςșúÜđŻõËŻκΩÎzŁÇÉΠмłÔÝÖθσ7₱в£μŻzéΘÚĂИüyćťξюWc2И7кςαTnÿЩE3MVTÀεPβafÖôoъBσÂбýжõÞ7ßzŁŞε0âłXâÃЛ"]))
    (defun GOV|DSP2|SC_NAME ()                          (+ "Σ" (drop 1 (GOV|DSP1|SC_NAME))))
    (defun GOV|CST2|SC_NAME ()                          (+ "Σ" (drop 1 (GOV|CST1|SC_NAME))))
    ;;
    ;;  [PBLs]
    (defun GOV|DSP|PBL ()                               (at 0 ["9G.o0n0iHmGhkch5aEqr0wcpEKpuqgGt5uvFapDLb94GwCbJvBga5H4xrFAx41CbMMH0M7AHmqFnrafceFmaHBfjsH51ggCxJmu5DMpK4jGg0rpogpD26r4yiykAIkaqDz61sHGewpxl1tly780ahKxbEB7uD8FlvA1nGppsttz3AhIhbxlhJ3BpI3Hehf5tCM6bfqF9o6ryb3bErqJwEDJmMGFC9HEeDiLKAtMgqaajzK2b0yg2sE0lJMp2K8I6sjfwnyhyL5vnycpMpeCgagdlnbMMMaA9trHLx4FxLym6KqCFAxCFwFHohfbcolG3u5wGo06M1fMBKpC64Mgm4584tH93Hpmop4tLpD7157GLo7mejJk8ryrA229K07D2hbhtanzCgdtjziBs9yqvHLq78EFEsD1fpEeD0pMhJeLEMEsqu8zf816cLErk4aDC22GnsC9774C59iaLFKkzKzh11xnAEalcpGcLf7aecGBHu5IABIGq8sEFa9Ahi5inermzrys3HcLpz2degMmAEy8hKsI83zvaCta8Ksimgn3qmv4r4jocMsIAwDeEfzE"]))
    (defun GOV|CST|PBL ()                               (at 0 ["9H.abeq3vvcwJp9gl2Kdt5xb7djJwdB35bCgkIaF3r0k38kBF6La1M6ci0ma2e5exMehsmwe1x3d6EpsIjxv95hAvc3uJweirnitcAAryxn9HaHJ1f0ya36BDfsrfaIBL4moIF3B8glb5pDBhta7pyxigEdt13ccEIKtCdyC6krMhB5iyqfEyB70zf5tjqn2xpDDzg9nA7auzzjxxtwLH80Lmdp4wAEcnqprGishhMLLefMnzDv9dFyM0n31fAcziHogCIM4kktFgydhHah7hmJurs3xCrGrs5qAEtjid0zioLHM58l8wogL2j0L9LIH21wI4lD1BlKq4445nos849CEzcm3DC9t67IH1r63pkgc9xFEGr8K6H3CCfg9aqDcApxaDuEomaKjEj6ft71gtEwbEJJmrAzfDolHrFfubcertjF2rE2wMywhv7HqIoHMCKEznMFCy2C6eyGyh1mIMeKJDDhwqIDIA5a2wvtt0HedKxmgDldafrrGdn5yDGHMexLFCrGv9aG50G82zIlE5z7cksfplf5taeiz8vlydDKmLaCcMgA7ne77hsbGHuu"]))

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
    (defcap P|DSP|CALLER ()
        true
    )
    (defcap P|DRG ()
        @doc "Dispenser Remote Governor Capability"
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
        (with-capability (GOV|DSP_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|DSP_ADMIN)
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
        (with-capability (GOV|DSP_ADMIN)
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
        (with-capability (GOV|DSP_ADMIN)
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
                (mg:guard (create-capability-guard (P|DSP|CALLER)))
            )
            (ref-P|DALOS::P|A_Add
                "DSP|RemoteDalosGov"
                (create-capability-guard (P|DRG))
            )
            (ref-P|DALOS::P|A_AddIMP mg)
        )
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    ;;
    ;; STOA Accounts
    (defconst DSP|SC_STOA-NAME                          "k:78567097b68c98bf0c86a1938e60111a3bfc0ccadb858cc7f3630bc9da9dad99")
    (defconst CST|SC_STOA-NAME                          "k:309a1052856018a954d9692560934a3b8bb6fd0f283ab6eee5fc192b61c119a7")
    ;;
    ;;  Dispenser
    (defconst DSP|SC_KEY                                (GOV|DSPKey))
    (defconst DSP1|SC_NAME                              (GOV|DSP1|SC_NAME))
    (defconst DSP2|SC_NAME                              (GOV|DSP2|SC_NAME))
    (defconst DSP|PBL                                   (GOV|DSP|PBL))
    ;;
    ;;  Custodians
    (defconst CST|SC_KEY                                (GOV|CSTKey))
    (defconst CST1|SC_NAME                              (GOV|CST1|SC_NAME))
    (defconst CST2|SC_NAME                              (GOV|CST2|SC_NAME))
    (defconst CST|PBL                                   (GOV|CST|PBL))
    (defconst GASLESS-PATRON                            (URC_Gassless))
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    (defcap DSP|GOV ()
        @doc "Governor Capability for the Dispenser Smart DALOS Account"
        true
    )
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap DSP|STAGE-ONE-MINTER ()
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (compose-capability (P|DRG))
    )
    (defcap DSP|STOICISM-MINTER (stoicism-amounts:[decimal] stoicism-targets:[string])
        @event
        (compose-capability (GOV|DSP_ADMIN))
        (let
            (
                (l1:integer (length stoicism-amounts))
                (l2:integer (length stoicism-targets))
            )
            (enforce (= l1 l2) "Length of stoicism-amounts and stoicism-targets must be the same")
        )
        (compose-capability (P|DRG))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_KosonicAutostakeSplit:[decimal] (input:decimal ip:integer)
        (let
            (
                (one:decimal 0.0625)
                (ps:decimal (floor (* one input) ip))
                (cc:decimal (* ps 2.0))
                (pp:decimal (floor (* ps 2.5) ip))
                (tt:decimal (* ps 3.0))
                (sv:decimal (floor (* ps 3.5) ip))
                (aa:decimal (- input (fold (+) 0.0 [ps cc pp tt sv])))
            )
            [ps cc pp tt sv aa]
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;
    (defun URC_Gassless ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|DALOS|SC_NAME)
        )
    )
    (defun URC_DailyOURO ()
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ouro:string (ref-DALOS::UR_OuroborosID))
                (current-ouro-supply:decimal (ref-DPTF::UR_Supply ouro))
                (op:integer (ref-DPTF::UR_Decimals ouro))
                (maximum-theorethical-supply:decimal 10000000.0)
                (speed:decimal 10000.0)
            )
            (floor (/ (- maximum-theorethical-supply current-ouro-supply) speed) op)
        )
    )
    ;;
    (defun URC_DailyKOSON (iz-game-live:bool)
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                ;;
                (PrimordialKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 1))
                (op0:integer                    (ref-DPTF::UR_Decimals PrimordialKosonID))
                ;;
                (EsothericKosonID:string        (ref-AOZ::UR_PrimalTrueFungible 2))
                (current-EK-supply:decimal      (ref-DPTF::UR_Supply EsothericKosonID))
                (op1:integer                    (ref-DPTF::UR_Decimals EsothericKosonID))
                ;;
                (AncientKosonID:string          (ref-AOZ::UR_PrimalTrueFungible 3))
                (current-AK-supply:decimal      (ref-DPTF::UR_Supply AncientKosonID))
                (op2:integer                    (ref-DPTF::UR_Decimals AncientKosonID))
                ;;
                (esoteric-mts:decimal 16180339.887498948482045868343656)
                (esoteric-speed:decimal 7000.0)
                (ancient-mts:decimal 31415926.535897932384626433832795)
                (ancient-speed:decimal 8000.0)
                ;;
                (esoteric:decimal (floor (/ (- esoteric-mts current-EK-supply) esoteric-speed) op1))
                (ancient:decimal (floor (/ (- ancient-mts current-AK-supply) ancient-speed) op2))
                (primordial:decimal
                    (if iz-game-live
                        (floor (/ (+ esoteric ancient) 5.0) op0)
                        (floor (/ esoteric 5.0) op0)
                    )
                )
            )
            (if iz-game-live
                [primordial esoteric ancient]
                [primordial esoteric]
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_StoicismMinter (stoicism-amounts:[decimal] stoicism-targets:[string])
        (with-capability (DSP|STOICISM-MINTER stoicism-amounts stoicism-targets)
            (let
                (
                    (stoicism-id:string "STOICISM-hCNmIIxczuBs")
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (dispenser:string DSP1|SC_NAME)
                    (total-stoicism-amount:decimal (fold (+) 0.0 stoicism-amounts))
                    (l1:integer (length stoicism-amounts))
                    (l2:integer (length stoicism-targets))
                    (iz-empty:bool (and (= l1 0) (= l2 0)))
                )
                (if iz-empty
                    "No stoicism to mint or distribute"
                    [
                      ;;Mints Stoicism
                      (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON stoicism-id dispenser total-stoicism-amount false)
                      ;;Moves Stoicism to Targets
                      (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON stoicism-id dispenser stoicism-targets stoicism-amounts)
                    ]
                )
            )
        )
    )
    ;;
    (defun A_OuroMinterStageOne:[decimal] ()
        @doc "Mints the Stage One Daily OURO Emission"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (op:integer (ref-DPTF::UR_Decimals ouro))
                    (daily:decimal (URC_DailyOURO))
                    ;;
                    (split:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit daily op))
                    (s1-10p:decimal (at 0 split))
                    (s1-20p:decimal (at 1 split))
                    (s1-30p:decimal (at 2 split))
                    (s1-40p:decimal (at 3 split))
                    ;;
                    (treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (validators:string CST1|SC_NAME)
                    (dispenser:string DSP1|SC_NAME)
                    ;;
                    (auryn:string (ref-DALOS::UR_AurynID))
                    (elite-auryn:string (ref-DALOS::UR_EliteAurynID))
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
                    (elite-auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken elite-auryn)))
                )
                ;;Mints whole daily on Dispencer
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON ouro dispenser daily false)
                ;;Moves 10% To Treasury and 20% to Validators
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON ouro dispenser [treasury validators] [s1-10p s1-20p])
                ;;Uses 30% to Fuel the Auryndex
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser auryndex ouro s1-30p)
                ;;Uses 40% to Coil to Auryn and then use Auryn to Fuel Elite-Auryndex
                (let
                    (
                        (c-rbt-amount:decimal (ref-ATS::URC_RBT auryndex ouro s1-40p))
                    )
                    (ref-TS01-C2::ATS|C_Coil GASLESS-PATRON dispenser auryndex ouro s1-40p)
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser elite-auryndex auryn c-rbt-amount)
                    ;; Interface contract is A_OuroMinterStageOne:[decimal] — return the split amounts
                    ;; [daily 10% 20% 30% 40%] (module defuns cannot print, so no in-body log strings).
                    [daily s1-10p s1-20p s1-30p s1-40p]
                )
            )
        )
    )
    ;;
    (defun AA_OuroMinterStageTwo:[decimal] (fvt-ids:[string])
        @doc "Mints the Stage Two Daily OURO Emission — the full six-way split that replaces Stage \
            \ One's 10/20/30/40. HEAVY (AA_): four CC_Inject legs, each of which scans the FVT's \
            \ present users, so cost scales with staker count and NOT with a constant. The doubled \
            \ prefix was not chosen — _heavy.py reported it: `DSP.A_OuroMinterStageTwo reaches \
            \ RPS.URH_FvtEnabledScoreEntityIdsForFvt`. Stage One is a flat A_ at ~135k gas; this is \
            \ structurally a different animal and is expected to cost far more. \
            \ One's 10/20/30/40 once SFTs, NFTs and stake-pools exist. \
            \ \
            \ INPUT `fvt-ids` — FOUR ids, BY POSITION. They are passed rather than hardcoded because \
            \ every AQP entity id carries the block hash of the transaction that minted it \
            \ (U|DALOS::UDC_Makeid = <name>-<first 12 of prev-block-hash>), so they cannot be known \
            \ when this module is written and cannot be recomputed afterwards. Everything this \
            \ function CAN derive it does derive — OURO, Auryn, the Auryndex, the treasury and the \
            \ dispenser all come from DALOS readers, exactly as Stage One does: \
            \   [0] CustodiansVault        — the DSA delegation vault (AQP-BOOT Step 13) \
            \   [1] CompanySharesTreasury  — shareholders (Step 8) \
            \   [2] OuroLpFarm             — Ouroboros liquidity farming (Step 8) \
            \   [3] SubsidiaryTreasury     — Demiourgos NFT staking (Step 8) \
            \ \
            \ SPLIT of the whole daily emission: 20% Custodians · 10% Treasury · 10% Shareholders · \
            \ 20% LP Farming · 20% Autostaking (Auryndex) · 20% Subsidiary. \
            \ \
            \ THE SUBSIDIARY LEG IS COILED, not injected as OURO: SubsidiaryTreasury's reward link is \
            \ AURYN (Step 12), so OURO cannot be injected into it at all. The 20% is coiled OURO→Auryn \
            \ through the Auryndex and the Auryn is injected — the same idiom Stage One already uses \
            \ to reach the Elite-Auryndex. \
            \ \
            \ GASLESS, AND THE EMISSION SITS ON THE DISPENSER -- which it could not, until Band 3. \
            \ IGNIS is waived for exactly one account: \
            \ 02_IGNIS.pact XE_CollectIgnis reads `(= patron (DALOS::GOV|DALOS|SC_NAME))` and skips collection \
            \ when true -- the owner-confirmed single hardcoded gasless payer, which is what \
            \ GASLESS-PATRON binds to. Stage One can pass it as `patron` while the tokens move from \
            \ the dispenser, because C_Mint / C_BulkTransfer / ATS|C_Fuel / ATS|C_Coil all take patron \
            \ AND a separate source account. CC_Inject does NOT: it debits the patron itself \
            \ (04_RPS.pact XI_FvtInjectCore -> C_Transfer token PATRON AQP|SC_NAME). So to inject \
            \ gaslessly the emission had to be MINTED TO the gasless patron -- the dispenser could not \
            \ hold it. Band 3 (2026-09-20) gave inject a named executor, so the roles separate the way \
            \ every other leg here already did: GASLESS-PATRON pays, `dispenser` acts. The emission is \
            \ back on the dispenser, where it belongs. \
            \ \
            \ GAS, MEASURED 2026-09-20: ~910k-970k, i.e. roughly HALF of a 2M block, against Stage \
            \ One's ~135k. Seven times the cost for one transaction. \
            \ \
            \ AND THAT IS A FLOOR, NOT A CEILING. Four of the six legs are CC_Inject, the HEAVY \
            \ enforced-fresh variant: each SCANS the FVT's present users and fixes every stale one, \
            \ so cost scales with STAKER COUNT. The measurement above comes from a fixture with a \
            \ handful of stakers. On a chain with real depth this transaction does not fit, and the \
            \ two measurements taken minutes apart already differ by 6% (911,546 in the boot suite, \
            \ 966,256 standalone) purely from chain state. \
            \ \
            \ RE-MEASURED 2026-09-20 after the patron/executor refactor converted 52 entrypoints: \
            \ 911,547 -- ONE GAS more than before it. Read that for what it is. This function's \
            \ path (C_Mint, C_BulkTransfer, CC_Inject x4, C_Coil) was already converted in Band 3; \
            \ the Band 1 work that followed touched CONFIGURATION and ADMIN entrypoints the \
            \ emission never calls. So the figure is a REGRESSION CHECK that nothing on the money \
            \ path moved -- not evidence that adding an executor is free. \
            \ \
            \ The documented spike fallback is the MTX|n|C_Inject defpact -- and until 2026-09-20 \
            \ that fallback was FICTION for this function: the defpact hardcoded `XB_FvtInject \
            \ patron patron`, so it could only run when the gas payer was also the token source, \
            \ which is precisely the shape this minter does NOT use. It now takes an `injector`, \
            \ proven by <<TX-MTX-SPONSOR>>. Plan for the daily \
            \ emission to become a SEQUENCE rather than one transaction before the Custodians vault \
            \ has depth -- not after. Pinned by <<TX-BOOT-S2GAS>> as a BAND (fits a block / is not \
            \ suspiciously cheap), because an exact pin would be noise at this variance and a \
            \ cheaper emission is a BROKEN one, not an improvement. \
            \ \
            \ RETURNS [daily custodians treasury shareholders farm autostake subsidiary-auryn]."
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-ATS:module{AutostakeV3} ATS)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    (ouro:string (ref-DALOS::UR_OuroborosID))
                    (op:integer (ref-DPTF::UR_Decimals ouro))
                    (daily:decimal (URC_DailyOURO))
                    ;;
                    (split:[decimal] (ref-U|DALOS::UC_StageTwoEmissionSplit daily op))
                    (s2-custodians:decimal (at 0 split))
                    (s2-treasury:decimal (at 1 split))
                    (s2-shareholders:decimal (at 2 split))
                    (s2-farm:decimal (at 3 split))
                    (s2-autostake:decimal (at 4 split))
                    (s2-subsidiary:decimal (at 5 split))
                    ;;
                    (treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (dispenser:string DSP1|SC_NAME)  ;;holds the emission; the EXECUTOR of every leg
                    ;;
                    (auryn:string (ref-DALOS::UR_AurynID))
                    (auryndex:string (at 0 (ref-DPTF::UR_RewardBearingToken auryn)))
                )
                (enforce (= (length fvt-ids) 4)
                    "Stage Two expects fvt-ids x4: [custodians shareholders farm subsidiary]")
                ;;1. Mint the whole daily emission on the Dispenser
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON ouro dispenser daily false)
                ;;2. 10% to the Demiourgos Treasury, as pure OURO
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON ouro dispenser [treasury] [s2-treasury])
                ;;3. 20% into the Custodians vault. Injected as OURO; the multiplet ladder pays each
                ;;   staker OURO, Auryn or Elite-Auryn according to their score quality.
                (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 0 fvt-ids) ouro s2-custodians)
                ;;4. 10% to shareholders. Its reward link IS Ouroboros, so a direct OURO inject.
                (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 1 fvt-ids) ouro s2-shareholders)
                ;;5. 20% into Ouroboros liquidity farming — OURO in, triplet rules out.
                (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 2 fvt-ids) ouro s2-farm)
                ;;6. 20% fuels the Auryndex directly
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser auryndex ouro s2-autostake)
                ;;7. 20% coiled OURO->Auryn, then injected as AURYN into the Subsidiary treasury
                (let
                    (
                        (subsidiary-auryn:decimal (ref-ATS::URC_RBT auryndex ouro s2-subsidiary))
                    )
                    (ref-TS01-C2::ATS|C_Coil GASLESS-PATRON dispenser auryndex ouro s2-subsidiary)
                    (ref-TS02-C3::AQP-FVT|CC_Inject GASLESS-PATRON dispenser (at 3 fvt-ids) auryn subsidiary-auryn)
                    [daily s2-custodians s2-treasury s2-shareholders s2-farm s2-autostake subsidiary-auryn]
                )
            )
        )
    )
    ;;
    (defun A_KosonMinterStageOne ()
        @doc "Executes the daily Koson Emission, in a single Tx"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (PrimordialKosonID:string      (ref-AOZ::UR_PrimalTrueFungible 1))
                    (EsothericKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 2))
                    (op0:integer (ref-DPTF::UR_Decimals PrimordialKosonID))
                    (op1:integer (ref-DPTF::UR_Decimals EsothericKosonID))
                    ;;
                    (daily:[decimal] (URC_DailyKOSON false))
                    (ps:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit (at 0 daily) op0))
                    (ps10:decimal (at 0 ps))
                    (ps20:decimal (at 1 ps))
                    (ps40:decimal (at 3 ps))
                    ;;
                    (standard-treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (smart-treasury:string (ref-DALOS::GOV|DHV2|SC_NAME))
                    (validators:string CST1|SC_NAME)
                    (dispenser:string DSP1|SC_NAME)
                )
                ;;Mints Primordial Koson and Esoteric Koson Amounts
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON PrimordialKosonID dispenser (at 0 daily) false)
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON EsothericKosonID dispenser (at 1 daily) false)
                ;;Moves Primordial Kosons: 10% To Standard-Treasury, 20% to Smart-Treasury, 40% to Custodians(Validators)
                ;;Leaving 30% of the Primordial Kosons to <dispenser>
                (let
                    (
                        (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                        (PlebeicStrengthID:string       (ref-AOZ::UR_AutostakePair 1))
                        (ComatiCommandID:string         (ref-AOZ::UR_AutostakePair 2))
                        (PileatiPowerID:string          (ref-AOZ::UR_AutostakePair 3))
                        (TarabostesTenacityID:string    (ref-AOZ::UR_AutostakePair 4))
                        (StrategonVigorID:string        (ref-AOZ::UR_AutostakePair 5))
                        (AsAuthorityID:string           (ref-AOZ::UR_AutostakePair 6))
                        ;;
                        (daily-primordial-left:decimal (ref-DPTF::UR_AccountSupply PrimordialKosonID dispenser))
                        (primordial-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-primordial-left op0))
                        ;;
                        (daily-esoteric:decimal (ref-DPTF::UR_AccountSupply EsothericKosonID dispenser))
                        (esoteric-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-esoteric op1))
                    )
                ;;Splits the 30% of Primordial Kosons from Dispenser into 6 parts to Fuel Autostake Pools
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     PrimordialKosonID (at 0 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       PrimordialKosonID (at 1 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        PrimordialKosonID (at 2 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  PrimordialKosonID (at 3 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      PrimordialKosonID (at 4 primordial-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         PrimordialKosonID (at 5 primordial-split-for-ats))
                ;;Splits the Esoteric Kosons using the same split, and fuels the Autostake Pools
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     EsothericKosonID (at 0 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       EsothericKosonID (at 1 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        EsothericKosonID (at 2 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  EsothericKosonID (at 3 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      EsothericKosonID (at 4 esoteric-split-for-ats))
                    (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         EsothericKosonID (at 5 esoteric-split-for-ats))
                )
            )
        )
    )
    (defun A_KosonMinterStageOne_1of3 ()
        @doc "Executes Stage One Daily Koson Emission, Part 1 of 3"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                    (ref-DALOS:module{OuronetDalosV2} DALOS)
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (PrimordialKosonID:string      (ref-AOZ::UR_PrimalTrueFungible 1))
                    (EsothericKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 2))
                    (op0:integer (ref-DPTF::UR_Decimals PrimordialKosonID))
                    ;;
                    (daily:[decimal] (URC_DailyKOSON false))
                    (ps:[decimal] (ref-U|DALOS::UC_TenTwentyThirtyFourtySplit (at 0 daily) op0))
                    (ps10:decimal (at 0 ps))
                    (ps20:decimal (at 1 ps))
                    (ps40:decimal (at 3 ps))
                    ;;
                    (standard-treasury:string (ref-DALOS::GOV|DHV1|SC_NAME))
                    (smart-treasury:string (ref-DALOS::GOV|DHV2|SC_NAME))
                    (validators:string CST1|SC_NAME)
                    (dispenser:string DSP1|SC_NAME)
                )
                ;;Mints Primordial Koson and Esoteric Koson Amounts
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON PrimordialKosonID dispenser (at 0 daily) false)
                (ref-TS01-C1::DPTF|C_Mint GASLESS-PATRON EsothericKosonID dispenser (at 1 daily) false)
                ;;Moves Primordial Kosons: 10% To Standard-Treasury, 20% to Smart-Treasury, 40% to Custodians(Validators)
                (ref-TS01-C1::DPTF|C_BulkTransfer GASLESS-PATRON PrimordialKosonID dispenser [standard-treasury validators] [ps10 ps40])
                (ref-TS01-C1::DPTF|C_Transfer GASLESS-PATRON PrimordialKosonID dispenser smart-treasury ps20 true)
                
            )
        )
    )
    (defun A_KosonMinterStageOne_2of3 ()
        @doc "Continues Stage One Daily Koson Emission, Part 2 of 3"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (PrimordialKosonID:string       (ref-AOZ::UR_PrimalTrueFungible 1))
                    (PlebeicStrengthID:string       (ref-AOZ::UR_AutostakePair 1))
                    (ComatiCommandID:string         (ref-AOZ::UR_AutostakePair 2))
                    (PileatiPowerID:string          (ref-AOZ::UR_AutostakePair 3))
                    (TarabostesTenacityID:string    (ref-AOZ::UR_AutostakePair 4))
                    (StrategonVigorID:string        (ref-AOZ::UR_AutostakePair 5))
                    (AsAuthorityID:string           (ref-AOZ::UR_AutostakePair 6))
                    ;;
                    (op0:integer (ref-DPTF::UR_Decimals PrimordialKosonID))
                    (dispenser:string DSP1|SC_NAME)
                    ;;
                    (daily-primordial-left:decimal (ref-DPTF::UR_AccountSupply PrimordialKosonID dispenser))
                    (primordial-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-primordial-left op0))
                )
                ;;Fuel the 6 ATS Pools, using Primordial Kosons
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     PrimordialKosonID (at 0 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       PrimordialKosonID (at 1 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        PrimordialKosonID (at 2 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  PrimordialKosonID (at 3 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      PrimordialKosonID (at 4 primordial-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         PrimordialKosonID (at 5 primordial-split-for-ats))
            )
        )
    )
    (defun A_KosonMinterStageOne_3of3 ()
        @doc "Finalizes Stage One Daily Koson Emission, Part 3 of 3"
        (with-capability (DSP|STAGE-ONE-MINTER)
            (let
                (
                    (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                    (ref-TS01-C2:module{TalosStageOne_ClientTwoV2} TS01-C2)
                    (ref-AOZ:module{AgeOfZalmoxis} AOZ)
                    ;;
                    (EsothericKosonID:string        (ref-AOZ::UR_PrimalTrueFungible 2))
                    (PlebeicStrengthID:string       (ref-AOZ::UR_AutostakePair 1))
                    (ComatiCommandID:string         (ref-AOZ::UR_AutostakePair 2))
                    (PileatiPowerID:string          (ref-AOZ::UR_AutostakePair 3))
                    (TarabostesTenacityID:string    (ref-AOZ::UR_AutostakePair 4))
                    (StrategonVigorID:string        (ref-AOZ::UR_AutostakePair 5))
                    (AsAuthorityID:string           (ref-AOZ::UR_AutostakePair 6))
                    ;;
                    (op1:integer (ref-DPTF::UR_Decimals EsothericKosonID))
                    (dispenser:string DSP1|SC_NAME)
                    ;;
                    (daily-esoteric:decimal (ref-DPTF::UR_AccountSupply EsothericKosonID dispenser))
                    (esoteric-split-for-ats:[decimal] (UC_KosonicAutostakeSplit daily-esoteric op1))
                )
                ;;Fuel the 6 ATS Pools, using Esoteric Kosons
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PlebeicStrengthID     EsothericKosonID (at 0 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser ComatiCommandID       EsothericKosonID (at 1 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser PileatiPowerID        EsothericKosonID (at 2 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser TarabostesTenacityID  EsothericKosonID (at 3 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser StrategonVigorID      EsothericKosonID (at 4 esoteric-split-for-ats))
                (ref-TS01-C2::ATS|C_Fuel GASLESS-PATRON dispenser AsAuthorityID         EsothericKosonID (at 5 esoteric-split-for-ats))
            )
        )
    )

)

;; --- tables for 03_DSP+.pact (2 defined) ---
;; UPGRADE MODE: this module is assumed already deployed, so its
;; tables already exist and (create-table) would ABORT the whole
;; transaction. They are listed here, commented, for reference.
;; If any of these is NEW since the last deploy, uncomment JUST it.
;; (create-table P|T)
;; (create-table P|MT)

