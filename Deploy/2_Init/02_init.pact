;; ---------------------------------------------------------------------------
;; OURONET INIT -- file 2
;; STEP 21 of the full sequence (see Deploy/MANIFEST.md).
;; Label : TX-01 [4.1] - DPDC INIT [01]: Define IMC Policies
;; Source: REPL/Stage_02/[4.0]_Sovereign-Executor.repl:49
;;
;; SIGNERS this block used in the REPL (translate to real transaction signers):
;;   PK_AncientHodler
;;
;; !! LIKELY A SANDBOX FIXTURE, NOT A DEPLOYMENT STEP.
;; !! Matched: Fuel
;; !! These blocks create or fund test accounts so the REPL chain can run. Shipping
;; !! one to mainnet would create real accounts and move real value. REVIEW BEFORE
;; !! USING. This is a flag from a keyword match, not a judgement -- a block can be
;; !! flagged and still be required, or unflagged and still be a fixture.
;;
;; 1 form(s) below, lifted verbatim from the source.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

;; [4.0]_Sovereign-Executor.repl:67
(let
    (
        (ref-U|G:module{OuronetGuardsV2} U|G)
        (ref-TS01-C1:module{TalosStageOne_ClientOneV2} TS01-C1)
        (ref-DPDC:module{DpdcV2} DPDC)
        ;;
        (patron:string "Ѻ.éXødVțrřĄθ7ΛдUŒjeßćιiXTПЗÚĞqŸœÈэαLżØôćmч₱ęãΛě$êůáØCЗшõyĂźςÜãθΘзШË¥şEÈnxΞЗÚÏÛjDVЪжγÏŽнăъçùαìrпцДЖöŃȘâÿřh£1vĎO£κнβдłпČлÿáZiĐą8ÊHÂßĎЩmEBцÄĎвЙßÌ5Ï7ĘŘùrÑckeñëδšПχÌàî")
        (dpdc:string (ref-DPDC::GOV|DPDC|SC_NAME))
        ;;
        (ref-P|DPDC-UDC:module{OuronetPolicyV2}   DPDC-UDC)
        (ref-P|DPDC:module{OuronetPolicyV2}       DPDC)
        (ref-P|DPDC-C:module{OuronetPolicyV2}     DPDC-C)
        (ref-P|DPDC-I:module{OuronetPolicyV2}     DPDC-I)
        (ref-P|DPDC-R:module{OuronetPolicyV2}     DPDC-R)
        (ref-P|DPDC-MNG:module{OuronetPolicyV2}   DPDC-MNG)
        (ref-P|DPDC-N:module{OuronetPolicyV2}     DPDC-N)
        (ref-P|DPDC-T:module{OuronetPolicyV2}     DPDC-T)
        (ref-P|DPDC-F:module{OuronetPolicyV2}     DPDC-F)
        (ref-P|DPDC-S:module{OuronetPolicyV2}     DPDC-S)
        (ref-P|EQUITY:module{OuronetPolicyV2}     EQUITY)
        (ref-P|DEMIPAD:module{OuronetPolicyV2}    DEMIPAD)
        ;;
        (ref-P|TS02-C1:module{OuronetPolicyV2}    TS02-C1)
        (ref-P|TS02-C2:module{OuronetPolicyV2}    TS02-C2)
        (ref-P|TS02-C3:module{OuronetPolicyV2}    TS02-C3)
        (ref-P|TS02-DPAD:module{OuronetPolicyV2}  TS02-DPAD)
        (ref-P|TS02-CPAD:module{OuronetPolicyV2}  TS02-CPAD)
        ;;
        (ref-P|MTX-AQP:module{OuronetPolicyV2}    MTX-AQP)
        (ref-P|DSA:module{OuronetPolicyV2}        AQP-DSA)
        ;;

    )
    [
        ;;Main
        (ref-P|DPDC-UDC::P|A_Define)
        (ref-P|DPDC::P|A_Define)
        (ref-P|DPDC-C::P|A_Define)
        (ref-P|DPDC-I::P|A_Define)
        (ref-P|DPDC-R::P|A_Define)
        (ref-P|DPDC-MNG::P|A_Define)
        (ref-P|DPDC-N::P|A_Define)
        (ref-P|DPDC-T::P|A_Define)
        (ref-P|DPDC-F::P|A_Define)
        (ref-P|DPDC-S::P|A_Define)
        (ref-P|EQUITY::P|A_Define)
        ;;#79: DEMIPAD core module registers its caller-guard into its deps' IMC policies (DPDC-T etc.)
        ;;so C_DEMIPAD|Fuel*/Retrieve* collectable transfers pass P|UEV_IMC. Was missing -> collectable
        ;;launchpad fuel was IMC-blocked (a deploy-level gap, never caught with no launchpad test coverage).
        (ref-P|DEMIPAD::P|A_Define)
        ;;
        ;;Talos
        (ref-P|TS02-C1::P|A_Define)
        (ref-P|TS02-C2::P|A_Define)
        (ref-P|TS02-C3::P|A_Define)
        ;;Launchpad: sovereign TS02-DPAD registers into DEMIPAD/DPDC; citizen TS02-CPAD registers into the 5 sales
        (ref-P|TS02-DPAD::P|A_Define)
        (ref-P|TS02-CPAD::P|A_Define)
        ;;
        ;;MTX-AQP — registers its caller guard in AQP-FVT's IMP so the MTX|n|C_Inject defpact's XE_ calls pass P|UEV_IMC
        (ref-P|MTX-AQP::P|A_Define)
        ;;DSA — registers its caller guard in AQP-FVT's IMP so CC_OpenAgency's XE_ admit/delegation calls pass P|UEV_IMC
        (ref-P|DSA::P|A_Define)
        ;;
        ;;Set DPDC Governor
        ;;REPL-VARIANT:
        ;(acquire-module-admin ouronet-ns.DPDC)
        ;;MAIN-NET VARIANT
        ;;(acquire-module-admin n_7d40ccda457e374d8eb07b658fd38c282c545038.DPDC)
        (ref-TS01-C1::DALOS|C_RotateGovernor patron dpdc
            (ref-U|G::UEV_GuardOfAny
                [
                    (create-capability-guard (DPDC.DPDC|GOV))
                    (ref-DPDC::P|UR "DPDC-S|RemoteDpdcGov")
                    (ref-DPDC::P|UR "DPDC-F|RemoteDpdcGov")
                    (ref-DPDC::P|UR "EQUITY|RemoteDpdcGov")
                ]
            )
        )
    ]
)

