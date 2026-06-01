;; AQP-BOOT — live-chain AQP provisioning helpers.
;; Purpose: one-shot bootstrap writers for score/anchor/pool/fvt infra.
;;
(interface AcquisitionPoolBootV1
    (defun GOV|Demiurgoi ())
    ;;
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
    )
    (defun C_Step4_CreateCoreScores:string
        (patron:string owner-konto:string)
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string class1-asset-ids:[string] ouro-lp-asset-id:string class1-pool-ids:[string] ouro-lp-pool-id:string class1-score-ids:[string] ouro-triplet-score-ids:[string])
    )
)

(module AQP-BOOT GOV
    ;;
    (implements AcquisitionPoolBootV1)
    ;;
    ;;<========>
    ;;GOVERNANCE
    ;;{G1}
    (defconst GOV|MD_AQP-BOOT               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}
    (defcap GOV ()                          (compose-capability (GOV|AQP_BOOT_ADMIN)))
    (defcap GOV|AQP_BOOT_ADMIN ()           (enforce-guard GOV|MD_AQP-BOOT))
    ;;{G3}
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))
    ;;
    ;;<======================>
    ;;SCHEMAS-TABLES-CONSTANTS
    (defconst BOOT|SCORE_SILVER:string      "SilverSnakePower")
    (defconst BOOT|SCORE_BRONZE:string      "BronzeSnakePower")
    (defconst BOOT|SCORE_GOLDEN:string      "GoldenSnakePower")
    (defconst BOOT|PRECISION:integer        6)
    (defconst BOOT|MX_FROZEN:decimal        2.0)
    (defconst BOOT|MX_SLEEPING:decimal      2.0)
    ;;
    ;;<=======>
    ;;FUNCTIONS
    ;;
    ;;Step 1 - Create the Bunny Set Definition
    ;;Step 2 - Craete the BronzeSnakePower, SilverSnakePower and GoldenSnakePower Anchor-Class Definitions
    ;;Step 3 - Create the UnityBooster, StoaBooster and VestaBooster Anchor-Class Definitions
    ;;Step 4 - Create the TheCodingDivision, Bloodshed, DemiourgosShareholder and DemiourgosSnakes Score Definitions
    ;;Step 5 - Create the SubsidiaryCodingDivision, SubsidiaryWonderCoach, SubsidiaryBloodshed, SubsidiaryNosferatu and SubsidiaryBunnies Score Definitions
    ;;Step 6 - Create the Ouro LP Triplet Score Definition
    ;;Step 7 - Create class-1 DH pools + class-0 OURO LP pool and assign Step4/5/6 scores
    (defun C_Step1_CreateBunnySet:string
        (patron:string kbn-id:string)
        @doc "Step 1 — Create Bunny set definition on KBN."
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (KBN.A_BunnyRGBSet patron kbn-id)
            (format "AQP-BOOT Step 1 done. anchor-ids=[], boost-class-ids=[], score-ids=[] (kbn-id={})." [kbn-id])
        )
    )
    (defun C_Step2_CreateSnakePowerAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 2 — Create Bronze/Silver/Golden SnakePower Anchor-Class definitions via SnakeTokenRain anchors."
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    ;;
                    (bronze-boost-class-id:string (ref-U|DALOS::UDC_Makeid "BronzeSnakePower"))
                    (silver-boost-class-id:string (ref-U|DALOS::UDC_Makeid "SilverSnakePower"))
                    (golden-boost-class-id:string (ref-U|DALOS::UDC_Makeid "GoldenSnakePower"))
                    ;;
                    (anchor-ouroboros-rain-id:string (ref-U|DALOS::UDC_Makeid "OuroborosRain"))
                    (anchor-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "AurynRain"))
                    (anchor-elite-auryn-rain-id:string (ref-U|DALOS::UDC_Makeid "EliteAurynRain"))
                    (anchor-legendary-snake-token-rain-id:string (ref-U|DALOS::UDC_Makeid "LegendarySnakeTokenRain"))
                )
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "OuroborosRain" kbn-id true "BronzeSnakePower" 3 50.0 "Background" "Ouroboros Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "AurynRain" kbn-id true "SilverSnakePower" 3 100.0 "Background" "Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "EliteAurynRain" kbn-id true "GoldenSnakePower" 3 200.0 "Background" "Elite-Auryn Rain")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendarySnakeTokenRain" kbn-id false golden-boost-class-id 3 400.0 "Rarity" "Legendary")
                (format "AQP-BOOT Step 2 done. anchor-ids=[{} {} {} {}], boost-class-ids=[{} {} {}], score-ids=[]"
                    [
                        anchor-ouroboros-rain-id anchor-auryn-rain-id anchor-elite-auryn-rain-id anchor-legendary-snake-token-rain-id
                        bronze-boost-class-id silver-boost-class-id golden-boost-class-id
                    ]
                )
            )
        )
    )
    (defun C_Step3_CreateBoosterAnchorClasses:string
        (patron:string kbn-id:string)
        @doc "Step 3 — Create UnityBooster, StoaBooster and VestaBooster Anchor-Class definitions."
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
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
                )
                ;; Unity
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "Elk0nite" kbn-id true "UnityBooster" 3 100.0 "Eyes" "Elk0nite Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "Osmiridium" kbn-id false unity-boost-class-id 3 300.0 "Eyes" "Osmiridium Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "Titanium" kbn-id false unity-boost-class-id 3 900.0 "Eyes" "Titaniumgold Unity Glasses")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendaryUnityBooster" kbn-id false unity-boost-class-id 3 1000.0 "Rarity" "Legendary")
                ;; Stoa
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "VegoldEyes" kbn-id true "StoaBooster" 3 1000.0 "Eyes" "vEGLD Focus")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendaryStoaBooster" kbn-id false stoa-boost-class-id 3 3500.0 "Rarity" "Legendary")
                ;; Vesta
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "RedEyes" kbn-id true "VestaBooster" 3 250.0 "Eyes" "Red")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "GreenEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Green")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "BlueEyes" kbn-id false vesta-boost-class-id 3 250.0 "Eyes" "Blue")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleAnchor patron "LegendaryVestaBooster" kbn-id false vesta-boost-class-id 3 3500.0 "Rarity" "Legendary")
                (ref-TS02-C3::AQP-ANK|C_IssueNonFungibleSetAnchor patron "RGBEyes" kbn-id false vesta-boost-class-id 3 1000.0 1)
                (format "AQP-BOOT Step 3 done. anchor-ids=[{} {} {} {} {} {} {} {} {} {} {}], boost-class-ids=[{} {} {}], score-ids=[]"
                    [
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
        @doc "Step 4 — Create TheCodingDivision, Bloodshed, DemiourgosShareholder and DemiourgosSnakes score definitions."
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "TheCodingDivision" 3 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "Bloodshed" 6 0)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosShareholder" 6 true)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "DemiourgosSnakes" 6 false)
                (format "AQP-BOOT Step 4 done. anchor-ids=[], boost-class-ids=[], score-ids=[{} {} {} {}]"
                    [
                        (ref-U|DALOS::UDC_Makeid "TheCodingDivision")
                        (ref-U|DALOS::UDC_Makeid "Bloodshed")
                        (ref-U|DALOS::UDC_Makeid "DemiourgosShareholder")
                        (ref-U|DALOS::UDC_Makeid "DemiourgosSnakes")
                    ]
                )
            )
        )
    )
    (defun C_Step5_CreateSubsidiaryScores:string
        (patron:string owner-konto:string)
        @doc "Step 5 — Create subsidiary score definitions: CodingDivision, WonderCoach, Bloodshed, Nosferatu, Bunnies."
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                )
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryCodingDivision" 6 false)
                (ref-TS02-C3::AQP-SCR|C_IssueSemiFungibleScore patron owner-konto "SubsidiaryWonderCoach" 6 false)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBloodshed" 6 1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryNosferatu" 6 1)
                (ref-TS02-C3::AQP-SCR|C_IssueNonFungibleScore patron owner-konto "SubsidiaryBunnies" 6 1)
                (format "AQP-BOOT Step 5 done. anchor-ids=[], boost-class-ids=[], score-ids=[{} {} {} {} {}]"
                    [
                        (ref-U|DALOS::UDC_Makeid "SubsidiaryCodingDivision")
                        (ref-U|DALOS::UDC_Makeid "SubsidiaryWonderCoach")
                        (ref-U|DALOS::UDC_Makeid "SubsidiaryBloodshed")
                        (ref-U|DALOS::UDC_Makeid "SubsidiaryNosferatu")
                        (ref-U|DALOS::UDC_Makeid "SubsidiaryBunnies")
                    ]
                )
            )
        )
    )
    (defun C_Step6_CreateOuroLpTriplet:string
        (patron:string owner-konto:string lp-denominator:string boost-class-ids:[string])
        @doc "Step 6 — Create OURO LP triplet scores (Silver/Bronze/Golden) and links. \
            \ boost-class-ids must be [silver-boost-class-id bronze-boost-class-id golden-boost-class-id] \
            \ from previously executed anchor-class steps."
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-U|DALOS:module{UtilityDalosV1} U|DALOS)
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    ;;
                    (silver-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_SILVER))
                    (bronze-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_BRONZE))
                    (golden-id:string (ref-U|DALOS::UDC_Makeid BOOT|SCORE_GOLDEN))
                    ;;
                    (silver-boost-class-id:string (at 0 boost-class-ids))
                    (bronze-boost-class-id:string (at 1 boost-class-ids))
                    (golden-boost-class-id:string (at 2 boost-class-ids))
                )
                (enforce (= (length boost-class-ids) 3) "Step 6 expects boost-class-ids=[silver bronze golden].")
                ;; [1..2] Silver
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_SILVER BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron silver-id silver-boost-class-id)
                ;; [3..5] Bronze
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_BRONZE BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron bronze-id bronze-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron bronze-id silver-id)
                ;; [6..8] Golden
                (ref-TS02-C3::AQP-SCR|C_IssueLiquidityScore
                    patron owner-konto BOOT|SCORE_GOLDEN BOOT|PRECISION lp-denominator BOOT|MX_FROZEN BOOT|MX_SLEEPING
                )
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostClassLink patron golden-id golden-boost-class-id)
                (ref-TS02-C3::AQP-SCR|C_CreateScoreBoostLink patron golden-id silver-id)
                ;;
                (format "AQP-BOOT Step 6 done. anchor-ids=[], boost-class-ids=[{} {} {}], score-ids=[{} {} {}], boost-links=[{}->{} {}->{}]"
                    [
                        silver-boost-class-id bronze-boost-class-id golden-boost-class-id
                        silver-id bronze-id golden-id
                        bronze-id silver-id golden-id silver-id
                    ]
                )
            )
        )
    )
    (defun C_Step7_CreatePoolsAndScores:string
        (patron:string class1-asset-ids:[string] ouro-lp-asset-id:string class1-pool-ids:[string] ouro-lp-pool-id:string class1-score-ids:[string] ouro-triplet-score-ids:[string])
        @doc "Step 7 — Issue six class-1 DH pools plus one class-0 OURO LP pool and assign existing scores. \
            \ Inputs are explicit ids so this function can run in a separate transaction from prior steps. \
            \ class1-asset-ids order=[DHCodingDivision DHBloodshed DHCompany DHWonderCoach DHNosferatu DHBunnies]. \
            \ class1-pool-ids order matches assets. class1-score-ids order=[TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu SubsidiaryBunnies]. \
            \ ouro-triplet-score-ids order=[Silver Bronze Golden]. This step does not create FVT links."
        ;;Input list usage (index map)
        ;; class1-asset-ids[0..5]:
        ;;   0 DHCodingDivision asset-id (class-1 DPTF)
        ;;   1 DHBloodshed asset-id (class-1 DPTF)
        ;;   2 DHCompany asset-id (class-1 DPTF)
        ;;   3 DHWonderCoach asset-id (class-1 DPTF)
        ;;   4 DHNosferatu asset-id (class-1 DPTF)
        ;;   5 DHBunnies asset-id (class-1 DPTF)
        ;; class1-pool-ids[0..5] must be the ids for:
        ;;   [DHCodingDivision DHBloodshed DHCompany DHWonderCoach DHNosferatu DHBunnies]
        ;; class1-score-ids[0..8] must be:
        ;;   [TheCodingDivision SubsidiaryCodingDivision Bloodshed SubsidiaryBloodshed DemiourgosShareholder DemiourgosSnakes SubsidiaryWonderCoach SubsidiaryNosferatu SubsidiaryBunnies]
        ;; ouro-triplet-score-ids[0..2] must be:
        ;;   [SilverSnakePower BronzeSnakePower GoldenSnakePower]
        ;;
        ;;REPL-style example (replace with real chain ids):
        ;; (C_Step7_CreatePoolsAndScores
        ;;   "k:patron"
        ;;   ["DPTF-CODING-ID" "DPTF-BLOODSHED-ID" "DPTF-COMPANY-ID" "DPTF-WONDERCOACH-ID" "DPTF-NOSFERATU-ID" "DPTF-BUNNIES-ID"]
        ;;   "W|SSTOA-OURO-WSTOA|LP-98c486052a51"
        ;;   [(U|DALOS.UDC_Makeid "DHCodingDivision") (U|DALOS.UDC_Makeid "DHBloodshed") (U|DALOS.UDC_Makeid "DHCompany") (U|DALOS.UDC_Makeid "DHWonderCoach") (U|DALOS.UDC_Makeid "DHNosferatu") (U|DALOS.UDC_Makeid "DHBunnies")]
        ;;   (U|DALOS.UDC_Makeid "DHOuroLp")
        ;;   [(U|DALOS.UDC_Makeid "TheCodingDivision") (U|DALOS.UDC_Makeid "SubsidiaryCodingDivision") (U|DALOS.UDC_Makeid "Bloodshed") (U|DALOS.UDC_Makeid "SubsidiaryBloodshed") (U|DALOS.UDC_Makeid "DemiourgosShareholder") (U|DALOS.UDC_Makeid "DemiourgosSnakes") (U|DALOS.UDC_Makeid "SubsidiaryWonderCoach") (U|DALOS.UDC_Makeid "SubsidiaryNosferatu") (U|DALOS.UDC_Makeid "SubsidiaryBunnies")]
        ;;   [(U|DALOS.UDC_Makeid "SilverSnakePower") (U|DALOS.UDC_Makeid "BronzeSnakePower") (U|DALOS.UDC_Makeid "GoldenSnakePower")]
        ;; )
        (with-capability (GOV|AQP_BOOT_ADMIN)
            (let
                (
                    (ref-TS02-C3:module{TalosStageTwo_ClientThreeV1} TS02-C3)
                    ;;
                    (asset-coding:string (at 0 class1-asset-ids))
                    (asset-bloodshed:string (at 1 class1-asset-ids))
                    (asset-company:string (at 2 class1-asset-ids))
                    (asset-wondercoach:string (at 3 class1-asset-ids))
                    (asset-nosferatu:string (at 4 class1-asset-ids))
                    (asset-bunnies:string (at 5 class1-asset-ids))
                    ;;
                    (pool-coding:string (at 0 class1-pool-ids))
                    (pool-bloodshed:string (at 1 class1-pool-ids))
                    (pool-company:string (at 2 class1-pool-ids))
                    (pool-wondercoach:string (at 3 class1-pool-ids))
                    (pool-nosferatu:string (at 4 class1-pool-ids))
                    (pool-bunnies:string (at 5 class1-pool-ids))
                    (pool-ouro-lp:string ouro-lp-pool-id)
                    ;;
                    (score-coding:string (at 0 class1-score-ids))
                    (score-sub-coding:string (at 1 class1-score-ids))
                    (score-bloodshed:string (at 2 class1-score-ids))
                    (score-sub-bloodshed:string (at 3 class1-score-ids))
                    (score-company-share:string (at 4 class1-score-ids))
                    (score-company-snakes:string (at 5 class1-score-ids))
                    (score-sub-wondercoach:string (at 6 class1-score-ids))
                    (score-sub-nosferatu:string (at 7 class1-score-ids))
                    (score-sub-bunnies:string (at 8 class1-score-ids))
                    (score-silver:string (at 0 ouro-triplet-score-ids))
                    (score-bronze:string (at 1 ouro-triplet-score-ids))
                    (score-golden:string (at 2 ouro-triplet-score-ids))
                )
                (enforce (= (length class1-asset-ids) 6) "Step 7 expects class1-asset-ids=[coding bloodshed company wondercoach nosferatu bunnies].")
                (enforce (= (length class1-pool-ids) 6) "Step 7 expects class1-pool-ids=[pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies].")
                (enforce (= (length class1-score-ids) 9) "Step 7 expects class1-score-ids=[coding sub-coding bloodshed sub-bloodshed company-share company-snakes sub-wondercoach sub-nosferatu sub-bunnies].")
                (enforce (= (length ouro-triplet-score-ids) 3) "Step 7 expects ouro-triplet-score-ids=[silver bronze golden].")
                ;;
                ;; [1] DHCodingDivision
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHCodingDivision" asset-coding 1)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding score-coding)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-coding score-sub-coding)
                ;; [2] DHBloodshed
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHBloodshed" asset-bloodshed 1)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed score-bloodshed)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bloodshed score-sub-bloodshed)
                ;; [3] DHCompany
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHCompany" asset-company 1)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company score-company-share)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-company score-company-snakes)
                ;; [4] DHWonderCoach
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHWonderCoach" asset-wondercoach 1)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-wondercoach score-sub-wondercoach)
                ;; [5] DHNosferatu
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHNosferatu" asset-nosferatu 1)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-nosferatu score-sub-nosferatu)
                ;; [6] DHBunnies
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHBunnies" asset-bunnies 1)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-bunnies score-sub-bunnies)
                ;; [7] class-0 OURO LP pool + triplet from Step 6
                (ref-TS02-C3::AQP-POOL|C_Issue patron "DHOuroLp" ouro-lp-asset-id 0)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp score-silver)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp score-bronze)
                (ref-TS02-C3::AQP-POOL|C_AddScore patron pool-ouro-lp score-golden)
                ;;
                (format "AQP-BOOT Step 7 done. pool-ids=[{} {} {} {} {} {} {}], class1-asset-ids=[{} {} {} {} {} {}], ouro-lp-asset-id={}, score-slot-assignments=12, fvt-links=pending."
                    [
                        pool-coding pool-bloodshed pool-company pool-wondercoach pool-nosferatu pool-bunnies pool-ouro-lp
                        asset-coding asset-bloodshed asset-company asset-wondercoach asset-nosferatu asset-bunnies
                        ouro-lp-asset-id
                    ]
                )
            )
        )
    )
)
