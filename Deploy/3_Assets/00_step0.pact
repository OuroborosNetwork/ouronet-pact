;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 0
;; AQP-BOOT.C_Step0_WireImcAndGovernor
;; ===========================================================================================
;; ESTIMATED GAS ~unmeasured
;;   runs in deploy-stage02 but that block carries no gas echo; it is four P|A_Define calls plus one governor rotate, so small
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   1. Registers the inter-module-call policies for the four sovereign AQP modules, by calling
;;      `P|A_Define` on each: AQP-POOL, RPS, AQP-FVT, AQP-VCT. Until this runs, those modules
;;      cannot be reached across the module boundary -- `P|UEV_IMC` refuses.
;;   2. Rotates the governor of the AQP smart account (`AQP|SC_NAME`) to a guard that accepts
;;      ANY ONE of three authorities:
;;         - the `AQP-POOL.AQP|GOV` capability guard   (the stake path)
;;         - `FVT|RemoteAqpGov`                        (the FVT vault leg)
;;         - `VCT|RemoteAqpGov`                        (the vacate leg)
;;      That "any of" is what lets the vault legs act on the smart account without holding the
;;      pool's own governance.
;;
;; INPUT   patron -- the gas-paying konto. Nothing else; Step 0 takes no ids.
;; OUTPUT  a string of the form:
;;             "AQP-BOOT Step 0 done. aqp-sc=<ACCOUNT>. TFT+DPOF IMC + gov wired. NEXT=Step1 or client txs."
;;         The `aqp-sc=` field is the AQP smart-account name.
;;
;;         NOTHING CHAINS OUT OF STEP 0, and it is worth being explicit about why. `aqp-sc` is not
;;         a runtime-derived id -- it is a COMPILE-TIME CONSTANT, `AQP-ANK.GOV|AQP|SC_NAME`, the
;;         canonical symbolic name of the AQP sovereign smart account. It reads the same before
;;         this transaction as after, and any later step that needs it can call that function
;;         rather than parse this string.
;;
;;         So Step 0 is a pure wiring step: it changes chain STATE (policies registered, governor
;;         rotated) and publishes no new identifier. Step 1 takes a `kbn-id` -- the Bunnies
;;         collection, already on mainnet -- which does not come from here either.
;;
;;         The output string is still worth keeping as your receipt that the step ran, but the
;;         id-threading the later steps need starts at Step 1, not here.
;;
;; -------------------------------------------------------------------------------------------
;; HOW WELL IS THIS TESTED -- measured, not asserted from memory
;; -------------------------------------------------------------------------------------------
;; Step 0 executes in TEN places, including `deploy-stage02.repl` itself and nine test files, of
;; which several are gate entrypoints (Kursan/AQP-scale-*, Kursan/dsa-*, VCT-comprehensive,
;; OF-stake-smoke). It therefore runs many times on every gate run.
;;
;; No test ASSERTS its effects directly -- nothing checks "these four policies are registered" or
;; "the governor guard is exactly the any-of-three". It is exercised as a FIXTURE, not pinned as a
;; SUBJECT. That distinction was worth stating rather than glossing.
;;
;; BUT ITS EFFECTS ARE PROVEN, DIFFERENTIALLY. The four modules it registers carry 162 `P|UEV_IMC`
;; call sites between them (AQP 31, RPS 66, FVT 50, VCT 15), so every cross-module AQP path is
;; gated on exactly what Step 0 installs. Disabling the Step 0 call and re-running the AQP suite
;; (2026-09-18):
;;
;;   Step 0 DISABLED -> exit 1
;;     AQP-FVT.XI_IssueFvt -> RPS.XE_WI_FvtRewardAggregate -> RPS.P|UEV_IMC -> U|G.UEV_Any
;;     "None of the guards passed"   (02_U_G.pact:126)
;;   Step 0 RESTORED -> exit 0
;;
;; That is a differential pair, and it is stronger evidence than a direct assertion would be: the
;; whole AQP corpus is the assertion. If Step 0 did not register those policies, nothing in AQP
;; could make a cross-module call at all.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITES -- BOTH ARE MISSING FROM `Deploy/2_Init/` AND MUST RUN FIRST
;; -------------------------------------------------------------------------------------------
;; The round's init filter selected blocks whose label mentions AQP-BOOT, which caught this step
;; and nothing else. Step 0's own @doc names two prerequisites, and neither is in the plan:
;;
;;   (a) THE AQP SMART ACCOUNT MUST EXIST.
;;       Step 0 rotates its governor, so it must already be deployed. In the REPL chain:
;;         REPL/Stage_02/[2.1]_DpdcCore.repl:157
;;         (TS01-A::DALOS|A_DeploySmartAccount
;;             KC2.DPTS_NAME_0003 (keyset-ref-guard "ouronet-ns.dh_sc_aqp-keyset")
;;             KC2.KADN_NAME_0003 patron KC2.PBLC_0003)
;;       Since no part of AQP is live, this account is presumed not deployed. CONFIRM.
;;
;;   (b) TS02-C3 MUST HAVE ITS POLICY DEFINED.
;;       `TS02-C3` is the AQP Talos and is NOT in the on-chain interface snapshot -- TS02-C1,
;;       TS02-C2 and TS02-DPAD are listed, it is not -- so it is new this round. Its own
;;       `P|A_Define` is deliberately separate from Step 0 (the @doc says so) and lives at:
;;         REPL/Stage_02/[4.0]_Sovereign-Executor.repl:121
;;         (ref-P|TS02-C3::P|A_Define)
;;
;; Running Step 0 without (a) aborts on the governor rotate. Without (b), the Talos client path
;; into AQP is closed and every later step that calls `TS02-C3::AQP-POOL|C_*` fails.
;;
;; -------------------------------------------------------------------------------------------
;; SIGNING
;; -------------------------------------------------------------------------------------------
;; `C_Step0_WireImcAndGovernor` acquires `GOV|AQP_BOOT_ADMIN`, so the AQP-BOOT admin key must be
;; on the transaction. In the REPL this is `PK_AncientHodler` and the patron is `KST.ANHD`.
;; Substitute the real mainnet konto and signer -- the code below is what needs signing, not a
;; statement about which key signs it.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step0_WireImcAndGovernor PATRON_KONTO)
