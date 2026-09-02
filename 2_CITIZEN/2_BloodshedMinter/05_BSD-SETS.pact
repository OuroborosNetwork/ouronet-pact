(module BLOODSHED-SETS GOV




    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_BLOODSHED-SETS         (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|BLOODSHED-SETS_ADMIN)))
    (defcap GOV|BLOODSHED-SETS_ADMIN ()     (enforce-guard GOV|MD_BLOODSHED-SETS))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()                 (let ((ref-DALOS:module{OuronetDalosV1} DALOS)) (ref-DALOS::GOV|Demiurgoi)))

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
    (defconst BAR                   (CT_Bar))
    (defconst IPFS                  Bloodshed.IPFS)
    ;;
    ;;
    (defconst R                     Bloodshed.R)            ;;Native Bloodshed Royalty
    (defconst IR-L                  Bloodshed.IR-L)         ;;Legendary Ignis Royalty
    (defconst IR-E                  Bloodshed.IR-E)         ;;Epic Ignis Royalty
    (defconst IR-R                  Bloodshed.IR-R)         ;;Rare Ignis Royalty
    (defconst IR-C                  Bloodshed.IR-C)         ;;Common Ignis Royalty
    ;;{3.2}  schemas
    ;;{3.3}  tables

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
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
    ;;
    (defun CT_Bar ()                (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_BAR)))
    ;;
    (defun UDC_AllowedNonce:object{DpdcUdcV1.DPDC|AllowedNonceForSetPosition} (lst:[integer])
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition lst)
        )
    )
    (defun UDC_AllowedClass:object{DpdcUdcV1.DPDC|AllowedClassForSetPosition} (input:integer)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_DPDC|AllowedClassForSetPosition input)
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_SetLink:string (position:integer small-or-big:bool)
        (let
            (
                (type:string (if small-or-big "512x512" "FULL"))
                (folder:string "/07_Bloodshed/5_Sets/")
                (ps:string (format "{}" [position]))
                (padded-num:string 
                    (if (< position 10)
                        (+ "0" ps)
                        ps
                    )
                )
                (image-str:string (concat [padded-num ".jpg"]))
            )
            (concat [IPFS type folder image-str])
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A01_TierOneCommonComati (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 1
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Comati" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4865 12928 144))
                    (UDC_AllowedNonce (enumerate 4866 12928 144))
                    (UDC_AllowedNonce (enumerate 4867 12928 144))
                    (UDC_AllowedNonce (enumerate 4868 12928 144))
                    (UDC_AllowedNonce (enumerate 4869 12928 144))
                    (UDC_AllowedNonce (enumerate 4870 12928 144))
                    (UDC_AllowedNonce (enumerate 4871 12928 144))
                    (UDC_AllowedNonce (enumerate 4872 12928 144))
                    (UDC_AllowedNonce (enumerate 4873 12928 144))
                    (UDC_AllowedNonce (enumerate 4874 12928 144))
                    (UDC_AllowedNonce (enumerate 4875 12928 144))
                    (UDC_AllowedNonce (enumerate 4876 12928 144))
                    (UDC_AllowedNonce (enumerate 4877 12928 144))
                    (UDC_AllowedNonce (enumerate 4878 12928 144))
                    (UDC_AllowedNonce (enumerate 4879 12928 144))
                    (UDC_AllowedNonce (enumerate 4880 12928 144))
                    (UDC_AllowedNonce (enumerate 4881 12928 144))
                    (UDC_AllowedNonce (enumerate 4882 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Comati"
                    "All Common Comati Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 1 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 1 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A02_TierOneCommonUrsoi (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 2
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Ursoi" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4883 12928 144))
                    (UDC_AllowedNonce (enumerate 4884 12928 144))
                    (UDC_AllowedNonce (enumerate 4885 12928 144))
                    (UDC_AllowedNonce (enumerate 4886 12928 144))
                    (UDC_AllowedNonce (enumerate 4887 12928 144))
                    (UDC_AllowedNonce (enumerate 4888 12928 144))
                    (UDC_AllowedNonce (enumerate 4889 12928 144))
                    (UDC_AllowedNonce (enumerate 4890 12928 144))
                    (UDC_AllowedNonce (enumerate 4891 12928 144))
                    (UDC_AllowedNonce (enumerate 4892 12928 144))
                    (UDC_AllowedNonce (enumerate 4893 12928 144))
                    (UDC_AllowedNonce (enumerate 4894 12928 144))
                    (UDC_AllowedNonce (enumerate 4895 12928 144))
                    (UDC_AllowedNonce (enumerate 4896 12928 144))
                    (UDC_AllowedNonce (enumerate 4897 12928 144))
                    (UDC_AllowedNonce (enumerate 4898 12928 144))
                    (UDC_AllowedNonce (enumerate 4899 12928 144))
                    (UDC_AllowedNonce (enumerate 4900 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Ursoi"
                    "All Common Ursoi Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 2 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 2 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A03_TierOneCommonPileati (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 3
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Pileati" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4901 12928 144))
                    (UDC_AllowedNonce (enumerate 4902 12928 144))
                    (UDC_AllowedNonce (enumerate 4903 12928 144))
                    (UDC_AllowedNonce (enumerate 4904 12928 144))
                    (UDC_AllowedNonce (enumerate 4905 12928 144))
                    (UDC_AllowedNonce (enumerate 4906 12928 144))
                    (UDC_AllowedNonce (enumerate 4907 12928 144))
                    (UDC_AllowedNonce (enumerate 4908 12928 144))
                    (UDC_AllowedNonce (enumerate 4909 12928 144))
                    (UDC_AllowedNonce (enumerate 4910 12928 144))
                    (UDC_AllowedNonce (enumerate 4911 12928 144))
                    (UDC_AllowedNonce (enumerate 4912 12928 144))
                    (UDC_AllowedNonce (enumerate 4913 12928 144))
                    (UDC_AllowedNonce (enumerate 4914 12928 144))
                    (UDC_AllowedNonce (enumerate 4915 12928 144))
                    (UDC_AllowedNonce (enumerate 4916 12928 144))
                    (UDC_AllowedNonce (enumerate 4917 12928 144))
                    (UDC_AllowedNonce (enumerate 4918 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Pileati"
                    "All Common Pileati Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 3 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 3 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A04_TierOneCommonSmardoi (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 4
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Smardoi" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4919 12928 144))
                    (UDC_AllowedNonce (enumerate 4920 12928 144))
                    (UDC_AllowedNonce (enumerate 4921 12928 144))
                    (UDC_AllowedNonce (enumerate 4922 12928 144))
                    (UDC_AllowedNonce (enumerate 4923 12928 144))
                    (UDC_AllowedNonce (enumerate 4924 12928 144))
                    (UDC_AllowedNonce (enumerate 4925 12928 144))
                    (UDC_AllowedNonce (enumerate 4926 12928 144))
                    (UDC_AllowedNonce (enumerate 4927 12928 144))
                    (UDC_AllowedNonce (enumerate 4928 12928 144))
                    (UDC_AllowedNonce (enumerate 4929 12928 144))
                    (UDC_AllowedNonce (enumerate 4930 12928 144))
                    (UDC_AllowedNonce (enumerate 4931 12928 144))
                    (UDC_AllowedNonce (enumerate 4932 12928 144))
                    (UDC_AllowedNonce (enumerate 4933 12928 144))
                    (UDC_AllowedNonce (enumerate 4934 12928 144))
                    (UDC_AllowedNonce (enumerate 4935 12928 144))
                    (UDC_AllowedNonce (enumerate 4936 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Smardoi"
                    "All Common Smardoi Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 4 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 4 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A05_TierOneCommonCarpian (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 5
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Carpian" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4937 12928 144))
                    (UDC_AllowedNonce (enumerate 4938 12928 144))
                    (UDC_AllowedNonce (enumerate 4939 12928 144))
                    (UDC_AllowedNonce (enumerate 4940 12928 144))
                    (UDC_AllowedNonce (enumerate 4941 12928 144))
                    (UDC_AllowedNonce (enumerate 4942 12928 144))
                    (UDC_AllowedNonce (enumerate 4943 12928 144))
                    (UDC_AllowedNonce (enumerate 4944 12928 144))
                    (UDC_AllowedNonce (enumerate 4945 12928 144))
                    (UDC_AllowedNonce (enumerate 4946 12928 144))
                    (UDC_AllowedNonce (enumerate 4947 12928 144))
                    (UDC_AllowedNonce (enumerate 4948 12928 144))
                    (UDC_AllowedNonce (enumerate 4949 12928 144))
                    (UDC_AllowedNonce (enumerate 4950 12928 144))
                    (UDC_AllowedNonce (enumerate 4951 12928 144))
                    (UDC_AllowedNonce (enumerate 4952 12928 144))
                    (UDC_AllowedNonce (enumerate 4953 12928 144))
                    (UDC_AllowedNonce (enumerate 4954 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Carpian"
                    "All Common Carpian Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 5 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 5 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A06_TierOneCommonTarabostes (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 6
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Tarabostes" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4955 12928 144))
                    (UDC_AllowedNonce (enumerate 4956 12928 144))
                    (UDC_AllowedNonce (enumerate 4957 12928 144))
                    (UDC_AllowedNonce (enumerate 4958 12928 144))
                    (UDC_AllowedNonce (enumerate 4959 12928 144))
                    (UDC_AllowedNonce (enumerate 4960 12928 144))
                    (UDC_AllowedNonce (enumerate 4961 12928 144))
                    (UDC_AllowedNonce (enumerate 4962 12928 144))
                    (UDC_AllowedNonce (enumerate 4963 12928 144))
                    (UDC_AllowedNonce (enumerate 4964 12928 144))
                    (UDC_AllowedNonce (enumerate 4965 12928 144))
                    (UDC_AllowedNonce (enumerate 4966 12928 144))
                    (UDC_AllowedNonce (enumerate 4967 12928 144))
                    (UDC_AllowedNonce (enumerate 4968 12928 144))
                    (UDC_AllowedNonce (enumerate 4969 12928 144))
                    (UDC_AllowedNonce (enumerate 4970 12928 144))
                    (UDC_AllowedNonce (enumerate 4971 12928 144))
                    (UDC_AllowedNonce (enumerate 4972 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Tarabostes"
                    "All Common Tarabostes Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 6 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 6 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A07_TierOneCommonCostoboc (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
            )
            ;;Set Class 7
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Costoboc" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4973 12928 144))
                    (UDC_AllowedNonce (enumerate 4974 12928 144))
                    (UDC_AllowedNonce (enumerate 4975 12928 144))
                    (UDC_AllowedNonce (enumerate 4976 12928 144))
                    (UDC_AllowedNonce (enumerate 4977 12928 144))
                    (UDC_AllowedNonce (enumerate 4978 12928 144))
                    (UDC_AllowedNonce (enumerate 4979 12928 144))
                    (UDC_AllowedNonce (enumerate 4980 12928 144))
                    (UDC_AllowedNonce (enumerate 4981 12928 144))
                    (UDC_AllowedNonce (enumerate 4982 12928 144))
                    (UDC_AllowedNonce (enumerate 4983 12928 144))
                    (UDC_AllowedNonce (enumerate 4984 12928 144))
                    (UDC_AllowedNonce (enumerate 4985 12928 144))
                    (UDC_AllowedNonce (enumerate 4986 12928 144))
                    (UDC_AllowedNonce (enumerate 4987 12928 144))
                    (UDC_AllowedNonce (enumerate 4988 12928 144))
                    (UDC_AllowedNonce (enumerate 4989 12928 144))
                    (UDC_AllowedNonce (enumerate 4990 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Common Costoboc"
                    "All Common Costoboc Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 7 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 7 false) b b b b b b)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    (defun A08_TierOneCommonBuridavensRareComati (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.9 R))
                (ir:decimal (fold (*) 1.0 [18.0 0.9 IR-C]))
                ;;
                (r2:decimal (* 0.85 R))
                (ir-r:decimal (fold (*) 1.0 [9.0 0.85 IR-R]))
                ;;
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
                ;;
                (type:object{DpdcUdcV1.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                (zd:object{DpdcUdcV1.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
            )
            ;;Set Class 8
            [(ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Common Buridavens" 1.1
                [
                    (UDC_AllowedNonce (enumerate 4991 12928 144))
                    (UDC_AllowedNonce (enumerate 4992 12928 144))
                    (UDC_AllowedNonce (enumerate 4993 12928 144))
                    (UDC_AllowedNonce (enumerate 4994 12928 144))
                    (UDC_AllowedNonce (enumerate 4995 12928 144))
                    (UDC_AllowedNonce (enumerate 4996 12928 144))
                    (UDC_AllowedNonce (enumerate 4997 12928 144))
                    (UDC_AllowedNonce (enumerate 4998 12928 144))
                    (UDC_AllowedNonce (enumerate 4999 12928 144))
                    (UDC_AllowedNonce (enumerate 5000 12928 144))
                    (UDC_AllowedNonce (enumerate 5001 12928 144))
                    (UDC_AllowedNonce (enumerate 5002 12928 144))
                    (UDC_AllowedNonce (enumerate 5003 12928 144))
                    (UDC_AllowedNonce (enumerate 5004 12928 144))
                    (UDC_AllowedNonce (enumerate 5005 12928 144))
                    (UDC_AllowedNonce (enumerate 5006 12928 144))
                    (UDC_AllowedNonce (enumerate 5007 12928 144))
                    (UDC_AllowedNonce (enumerate 5008 12928 144))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 1 Common Buridavens"
                    "All Common Buridavens Dacians in a Set. 13.5% (90% of Native Bloodshed Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 8 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 8 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 9
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Comati" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1697 4864 72))
                    (UDC_AllowedNonce (enumerate 1698 4864 72))
                    (UDC_AllowedNonce (enumerate 1699 4864 72))
                    (UDC_AllowedNonce (enumerate 1700 4864 72))
                    (UDC_AllowedNonce (enumerate 1701 4864 72))
                    (UDC_AllowedNonce (enumerate 1702 4864 72))
                    (UDC_AllowedNonce (enumerate 1703 4864 72))
                    (UDC_AllowedNonce (enumerate 1704 4864 72))
                    (UDC_AllowedNonce (enumerate 1705 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r2 ir-r
                    "Tier 1 Rare Comati"
                    "All Rare Comati Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 9 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 9 false) b b b b b b)
                    zd
                )
            )]
        )
    )
    ;;
    (defun A09a_TierOneRare (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.85 R))
                (ir:decimal (fold (*) 1.0 [9.0 0.85 IR-R]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
                ;;
                (type:object{DpdcUdcV1.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                (zd:object{DpdcUdcV1.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
            )
            ;;Set Class 10
            [(ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Ursoi" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1706 4864 72))
                    (UDC_AllowedNonce (enumerate 1707 4864 72))
                    (UDC_AllowedNonce (enumerate 1708 4864 72))
                    (UDC_AllowedNonce (enumerate 1709 4864 72))
                    (UDC_AllowedNonce (enumerate 1710 4864 72))
                    (UDC_AllowedNonce (enumerate 1711 4864 72))
                    (UDC_AllowedNonce (enumerate 1712 4864 72))
                    (UDC_AllowedNonce (enumerate 1713 4864 72))
                    (UDC_AllowedNonce (enumerate 1714 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Ursoi"
                    "All Rare Ursoi Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 10 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 10 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 11
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Pileati" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1715 4864 72))
                    (UDC_AllowedNonce (enumerate 1716 4864 72))
                    (UDC_AllowedNonce (enumerate 1717 4864 72))
                    (UDC_AllowedNonce (enumerate 1718 4864 72))
                    (UDC_AllowedNonce (enumerate 1719 4864 72))
                    (UDC_AllowedNonce (enumerate 1720 4864 72))
                    (UDC_AllowedNonce (enumerate 1721 4864 72))
                    (UDC_AllowedNonce (enumerate 1722 4864 72))
                    (UDC_AllowedNonce (enumerate 1723 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Pileati"
                    "All Rare Pileati Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 11 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 11 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 12
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Smardoi" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1724 4864 72))
                    (UDC_AllowedNonce (enumerate 1725 4864 72))
                    (UDC_AllowedNonce (enumerate 1726 4864 72))
                    (UDC_AllowedNonce (enumerate 1727 4864 72))
                    (UDC_AllowedNonce (enumerate 1728 4864 72))
                    (UDC_AllowedNonce (enumerate 1729 4864 72))
                    (UDC_AllowedNonce (enumerate 1730 4864 72))
                    (UDC_AllowedNonce (enumerate 1731 4864 72))
                    (UDC_AllowedNonce (enumerate 1732 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Smardoi"
                    "All Rare Smardoi Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 12 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 12 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 13
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Carpian" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1733 4864 72))
                    (UDC_AllowedNonce (enumerate 1734 4864 72))
                    (UDC_AllowedNonce (enumerate 1735 4864 72))
                    (UDC_AllowedNonce (enumerate 1736 4864 72))
                    (UDC_AllowedNonce (enumerate 1737 4864 72))
                    (UDC_AllowedNonce (enumerate 1738 4864 72))
                    (UDC_AllowedNonce (enumerate 1739 4864 72))
                    (UDC_AllowedNonce (enumerate 1740 4864 72))
                    (UDC_AllowedNonce (enumerate 1741 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Carpian"
                    "All Rare Carpian Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 13 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 13 false) b b b b b b)
                    zd
                )
            )]
        )
    )
    (defun A09b_TierOneRare (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.85 R))
                (ir:decimal (fold (*) 1.0 [9.0 0.85 IR-R]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
                ;;
                (type:object{DpdcUdcV1.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                (zd:object{DpdcUdcV1.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
            )
            ;;Set Class 14
            [(ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Tarabostes" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1742 4864 72))
                    (UDC_AllowedNonce (enumerate 1743 4864 72))
                    (UDC_AllowedNonce (enumerate 1744 4864 72))
                    (UDC_AllowedNonce (enumerate 1745 4864 72))
                    (UDC_AllowedNonce (enumerate 1746 4864 72))
                    (UDC_AllowedNonce (enumerate 1747 4864 72))
                    (UDC_AllowedNonce (enumerate 1748 4864 72))
                    (UDC_AllowedNonce (enumerate 1749 4864 72))
                    (UDC_AllowedNonce (enumerate 1750 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Tarabostes"
                    "All Rare Tarabostes Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 14 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 14 false) b b b b b b) 
                    zd
                )
            )
            ;;Set Class 15
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Costoboc" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1751 4864 72))
                    (UDC_AllowedNonce (enumerate 1752 4864 72))
                    (UDC_AllowedNonce (enumerate 1753 4864 72))
                    (UDC_AllowedNonce (enumerate 1754 4864 72))
                    (UDC_AllowedNonce (enumerate 1755 4864 72))
                    (UDC_AllowedNonce (enumerate 1756 4864 72))
                    (UDC_AllowedNonce (enumerate 1757 4864 72))
                    (UDC_AllowedNonce (enumerate 1758 4864 72))
                    (UDC_AllowedNonce (enumerate 1759 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Costoboc"
                    "All Rare Costoboc Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 15 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 15 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 16
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Rare Buridavens" 1.1
                [
                    (UDC_AllowedNonce (enumerate 1760 4864 72))
                    (UDC_AllowedNonce (enumerate 1761 4864 72))
                    (UDC_AllowedNonce (enumerate 1762 4864 72))
                    (UDC_AllowedNonce (enumerate 1763 4864 72))
                    (UDC_AllowedNonce (enumerate 1764 4864 72))
                    (UDC_AllowedNonce (enumerate 1765 4864 72))
                    (UDC_AllowedNonce (enumerate 1766 4864 72))
                    (UDC_AllowedNonce (enumerate 1767 4864 72))
                    (UDC_AllowedNonce (enumerate 1768 4864 72))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Rare Buridavens"
                    "All Rare Buridavens Dacians in a Set. 12.75% (85% of Native Bloodshed Royalty) Royalty and 85% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 16 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 16 false) b b b b b b)
                    zd
                )
            )]
        )
    )
    (defun A10_TierOneEpic (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.80 R))
                (ir:decimal (fold (*) 1.0 [6.0 0.80 IR-E]))
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
                ;;
                (type:object{DpdcUdcV1.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                (zd:object{DpdcUdcV1.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
            )
            ;;Set Class 17
            [(ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Comati" 1.1
                [
                    (UDC_AllowedNonce (enumerate 161 1696 48))
                    (UDC_AllowedNonce (enumerate 162 1696 48))
                    (UDC_AllowedNonce (enumerate 163 1696 48))
                    (UDC_AllowedNonce (enumerate 164 1696 48))
                    (UDC_AllowedNonce (enumerate 165 1696 48))
                    (UDC_AllowedNonce (enumerate 166 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Comati"
                    "All Epic Comati Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 17 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 17 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 18
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Ursoi" 1.1
                [
                    (UDC_AllowedNonce (enumerate 167 1696 48))
                    (UDC_AllowedNonce (enumerate 168 1696 48))
                    (UDC_AllowedNonce (enumerate 169 1696 48))
                    (UDC_AllowedNonce (enumerate 170 1696 48))
                    (UDC_AllowedNonce (enumerate 171 1696 48))
                    (UDC_AllowedNonce (enumerate 172 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Ursoi"
                    "All Epic Ursoi Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 18 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 18 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 19
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Pileati" 1.1
                [
                    (UDC_AllowedNonce (enumerate 173 1696 48))
                    (UDC_AllowedNonce (enumerate 174 1696 48))
                    (UDC_AllowedNonce (enumerate 175 1696 48))
                    (UDC_AllowedNonce (enumerate 176 1696 48))
                    (UDC_AllowedNonce (enumerate 177 1696 48))
                    (UDC_AllowedNonce (enumerate 178 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Pileati"
                    "All Epic Pileati Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 19 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 19 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 20
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Smardoi" 1.1
                [
                    (UDC_AllowedNonce (enumerate 179 1696 48))
                    (UDC_AllowedNonce (enumerate 180 1696 48))
                    (UDC_AllowedNonce (enumerate 181 1696 48))
                    (UDC_AllowedNonce (enumerate 182 1696 48))
                    (UDC_AllowedNonce (enumerate 183 1696 48))
                    (UDC_AllowedNonce (enumerate 184 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Smardoi"
                    "All Epic Smardoi Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 20 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 20 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 21
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Carpian" 1.1
                [
                    (UDC_AllowedNonce (enumerate 185 1696 48))
                    (UDC_AllowedNonce (enumerate 186 1696 48))
                    (UDC_AllowedNonce (enumerate 187 1696 48))
                    (UDC_AllowedNonce (enumerate 188 1696 48))
                    (UDC_AllowedNonce (enumerate 189 1696 48))
                    (UDC_AllowedNonce (enumerate 190 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Carpian"
                    "All Epic Carpian Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 21 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 21 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 22
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Tarabostes" 1.1
                [
                    (UDC_AllowedNonce (enumerate 191 1696 48))
                    (UDC_AllowedNonce (enumerate 192 1696 48))
                    (UDC_AllowedNonce (enumerate 193 1696 48))
                    (UDC_AllowedNonce (enumerate 194 1696 48))
                    (UDC_AllowedNonce (enumerate 195 1696 48))
                    (UDC_AllowedNonce (enumerate 196 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Tarabostes"
                    "All Epic Tarabostes Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 22 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 22 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 23
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Costoboc" 1.1
                [
                    (UDC_AllowedNonce (enumerate 197 1696 48))
                    (UDC_AllowedNonce (enumerate 198 1696 48))
                    (UDC_AllowedNonce (enumerate 199 1696 48))
                    (UDC_AllowedNonce (enumerate 200 1696 48))
                    (UDC_AllowedNonce (enumerate 201 1696 48))
                    (UDC_AllowedNonce (enumerate 202 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Costoboc"
                    "All Epic Costoboc Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 23 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 23 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 24
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 1 Epic Buridavens" 1.1
                [
                    (UDC_AllowedNonce (enumerate 203 1696 48))
                    (UDC_AllowedNonce (enumerate 204 1696 48))
                    (UDC_AllowedNonce (enumerate 205 1696 48))
                    (UDC_AllowedNonce (enumerate 206 1696 48))
                    (UDC_AllowedNonce (enumerate 207 1696 48))
                    (UDC_AllowedNonce (enumerate 208 1696 48))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r
                    ir
                    "Tier 1 Epic Buridavens"
                    "All Epic Buridavens Dacians in a Set. 12% (80% of Native Bloodshed Royalty) Royalty and 80% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 24 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 24 false) b b b b b b)
                    zd
                )
            )]
        )
    )
    (defun A11_TierTwoThreeFour (patron:string dhb:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (r:decimal (* 0.75 R))
                (ir-c:decimal (* 18 IR-C))
                (ir-r:decimal (* 9 IR-R))
                (ir-e:decimal (* 6 IR-E))
                (ir-l:decimal IR-L)
                (ir-s:decimal (fold (+) 0.0 [ir-c ir-r ir-e ir-l]))
                (ir:decimal (* 0.75 ir-s))
                ;;
                (r2:decimal (* 0.7 R))
                (ir3-c:decimal (fold (*) 1.0 [0.7 144.0 IR-C]))
                (ir3-r:decimal (fold (*) 1.0 [0.7 72.0 IR-R]))
                (ir3-e:decimal (fold (*) 1.0 [0.7 48.0 IR-E]))
                (ir3-l:decimal (fold (*) 1.0 [0.7 8.0 IR-L]))
                ;;
                (r3:decimal (* 0.65 R))
                (ir4:decimal (fold (*) 1.0 [0.65 8.0 ir-s]))
                ;;
                (md:object{DpdcUdcV1.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (b:string BAR)
                (fs:string "https://ipfs.io/ipfs/QmWjMoqfX7tunGd7krv7VrfnKPfCqZf7q9KnrzKMadXGiv/512x512.jpg")
                (fb:string "https://ipfs.io/ipfs/QmWjMoqfX7tunGd7krv7VrfnKPfCqZf7q9KnrzKMadXGiv/FULL.jpg")
                ;;
                (type:object{DpdcUdcV1.URI|Type} (ref-DPDC-UDC::UDC_URI|Type true false false false false false false))
                (zd:object{DpdcUdcV1.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
                ;;
            )
            ;;Set Class 25
            [(ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Comati" 1.3
                [(UDC_AllowedNonce (enumerate 1 160 8))]
                [(UDC_AllowedClass 1) (UDC_AllowedClass 9) (UDC_AllowedClass 17)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Comati"
                    "All Comati Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 25 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 25 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 26
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Ursoi" 1.3
                [(UDC_AllowedNonce (enumerate 2 160 8))]
                [(UDC_AllowedClass 2) (UDC_AllowedClass 10) (UDC_AllowedClass 18)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Ursoi"
                    "All Ursoi Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 26 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 26 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 27
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Pileati" 1.3
                [(UDC_AllowedNonce (enumerate 3 160 8))]
                [(UDC_AllowedClass 3) (UDC_AllowedClass 11) (UDC_AllowedClass 19)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Pileati"
                    "All Pileati Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 27 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 27 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 28
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Smardoi" 1.3
                [(UDC_AllowedNonce (enumerate 4 160 8))]
                [(UDC_AllowedClass 4) (UDC_AllowedClass 12) (UDC_AllowedClass 20)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Smardoi"
                    "All Smardoi Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 28 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 28 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 29
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Carpian" 1.3
                [(UDC_AllowedNonce (enumerate 5 160 8))]
                [(UDC_AllowedClass 5) (UDC_AllowedClass 13) (UDC_AllowedClass 21)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Carpian"
                    "All Carpian Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 29 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 29 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 30
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Tarabostes" 1.3
                [(UDC_AllowedNonce (enumerate 6 160 8))]
                [(UDC_AllowedClass 6) (UDC_AllowedClass 14) (UDC_AllowedClass 22)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Tarabostes"
                    "All Tarabostes Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 30 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 30 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 31
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Costoboc" 1.3
                [(UDC_AllowedNonce (enumerate 7 160 8))]
                [(UDC_AllowedClass 7) (UDC_AllowedClass 15) (UDC_AllowedClass 23)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Costoboc"
                    "All Costoboc Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 31 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 31 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 32
            (ref-TS02-C2::C_DPNF|DefineHybridSet
                patron dhb "Tier 2 Buridavens" 1.3
                [(UDC_AllowedNonce (enumerate 8 160 8))]
                [(UDC_AllowedClass 8) (UDC_AllowedClass 16) (UDC_AllowedClass 24)]
                (ref-DPDC-UDC::UDC_NonceData
                    r ir
                    "Tier 2 Buridavens"
                    "All Buridavens Dacians in a Set. 11.25% (75% of Native Bloodshed Royalty) Royalty and 75% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 32 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 32 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 33
            (ref-TS02-C2::C_DPNF|DefineCompositeSet
                patron dhb "Tier 3 Common" 1.6
                [(UDC_AllowedClass 1) (UDC_AllowedClass 2) (UDC_AllowedClass 3) (UDC_AllowedClass 4) (UDC_AllowedClass 5) (UDC_AllowedClass 6) (UDC_AllowedClass 7) (UDC_AllowedClass 8)]
                (ref-DPDC-UDC::UDC_NonceData
                    r2 ir3-c
                    "Tier 3 Common"
                    "All Common Dacians in a Set. 10.5% (70% of Native Bloodshed Royalty) Royalty and 70% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 33 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 33 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 34
            (ref-TS02-C2::C_DPNF|DefineCompositeSet
                patron dhb "Tier 3 Rare" 1.6
                [(UDC_AllowedClass 9) (UDC_AllowedClass 10) (UDC_AllowedClass 11) (UDC_AllowedClass 12) (UDC_AllowedClass 13) (UDC_AllowedClass 14) (UDC_AllowedClass 15) (UDC_AllowedClass 16)]
                (ref-DPDC-UDC::UDC_NonceData
                    r2 ir3-r
                    "Tier 3 Rare"
                    "All Rare Dacians in a Set. 10.5% (70% of Native Bloodshed Royalty) Royalty and 70% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 34 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 34 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 35
            (ref-TS02-C2::C_DPNF|DefineCompositeSet
                patron dhb "Tier 3 Epic" 1.6
                [(UDC_AllowedClass 17) (UDC_AllowedClass 18) (UDC_AllowedClass 19) (UDC_AllowedClass 20) (UDC_AllowedClass 21) (UDC_AllowedClass 22) (UDC_AllowedClass 23) (UDC_AllowedClass 24)]
                (ref-DPDC-UDC::UDC_NonceData
                    r2 ir3-e
                    "Tier 3 Epic"
                    "All Epic Dacians in a Set. 10.5% (70% of Native Bloodshed Royalty) Royalty and 70% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 35 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 35 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 36
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron dhb "Tier 3 Legendary" 1.6
                [
                    (UDC_AllowedNonce (enumerate 1 160 8))
                    (UDC_AllowedNonce (enumerate 2 160 8))
                    (UDC_AllowedNonce (enumerate 3 160 8))
                    (UDC_AllowedNonce (enumerate 4 160 8))
                    (UDC_AllowedNonce (enumerate 5 160 8))
                    (UDC_AllowedNonce (enumerate 6 160 8))
                    (UDC_AllowedNonce (enumerate 7 160 8))
                    (UDC_AllowedNonce (enumerate 8 160 8))
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    r2 ir3-l
                    "Tier 3 Legendary"
                    "All Legendary Dacians in a Set. 10.5% (70% of Native Bloodshed Royalty) Royalty and 70% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 36 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 36 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 37
            (ref-TS02-C2::C_DPNF|DefineCompositeSet
                patron dhb "Tier 4" 2.0
                [(UDC_AllowedClass 25) (UDC_AllowedClass 26) (UDC_AllowedClass 27) (UDC_AllowedClass 28) (UDC_AllowedClass 29) (UDC_AllowedClass 30) (UDC_AllowedClass 31) (UDC_AllowedClass 32)]
                (ref-DPDC-UDC::UDC_NonceData
                    r3 ir4
                    "Tier 4"
                    "All Unique 272 Dacians in a Set. 9.75% (65% of Native Bloodshed Royalty) Royalty and 65% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 37 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 37 false) b b b b b b)
                    zd
                )
            )
            ;;Set Class 38
            (ref-TS02-C2::C_DPNF|DefineCompositeSet
                patron dhb "Tier 4" 2.0
                [(UDC_AllowedClass 33) (UDC_AllowedClass 34) (UDC_AllowedClass 35) (UDC_AllowedClass 36)]
                (ref-DPDC-UDC::UDC_NonceData
                    r3 ir4
                    "Tier 4"
                    "All Unique 272 Dacians in a Set. 9.75% (65% of Native Bloodshed Royalty) Royalty and 65% Ignis-Royalty relative to individual Elements"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 38 true) b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data (UC_SetLink 38 false) b b b b b b)
                    zd
                )
            )
            ;;Set Fragmentation for Class 37 and 38
            (ref-TS02-C2::C_DPNF|EnableSetClassFragmentation
                patron dhb 37
                (ref-DPDC-UDC::UDC_NonceData
                    r3 (/ ir4 1000.0)
                    "Tier 4 Fragments"
                    "Bloodshed Tier 4 Fragments. 9.75% (65% of Native Bloodshed Royalty) Royalty and 1000th Ignis-Royalty relative to the Full Set"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data fs b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data fb b b b b b b)
                    zd
                )
            )
            (ref-TS02-C2::C_DPNF|EnableSetClassFragmentation
                patron dhb 38
                (ref-DPDC-UDC::UDC_NonceData
                    r3 (/ ir4 1000.0)
                    "Tier 4 Fragments"
                    "Bloodshed Tier 4 Fragments. 9.75% (65% of Native Bloodshed Royalty) Royalty and 1000th Ignis-Royalty relative to the Full Set"
                    md type
                    (ref-DPDC-UDC::UDC_URI|Data fs b b b b b b)
                    (ref-DPDC-UDC::UDC_URI|Data fb b b b b b b)
                    zd
                )
            )
            ]
        )
    )

)