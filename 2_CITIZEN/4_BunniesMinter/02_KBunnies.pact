(module KBN GOV






    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    ;;
    (defconst GOV|MD_KBN                                (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    ;;
    (defcap GOV ()                                      (compose-capability (GOV|DPL_NFT_ADMIN)))
    (defcap GOV|DPL_NFT_ADMIN ()                        (enforce-guard GOV|MD_KBN))
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
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;{P4}  capabilities
    ;;{P5}  functions

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst B                                         (CT_Bar))
    ;;
    (defconst R                                         100.0)  ;;Native Bunny Royalty
    (defconst IR-L                                      1600.0) ;;Legendary Ignis Royalty
    (defconst IR-C                                      20.0)   ;;Common Ignis Royalty
    ;;
    (defconst T true)
    (defconst F false)
    ;;
    (defconst D-L "Golden Bunnies, the most precious Bunnies in the whole of Existance, makes the dreams come true for their Owners")
    (defconst D-C "Born on MultiversX, fled to Ouronet, ready for Unity, primed for Cryptoplasm, the Bunny Collection is here to make your dreams come true.")
    ;;
    (defconst TYPE
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_URI|Type T F F F F F F)
        )
    )
    (defconst ZD
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
            )
            (ref-DPDC-UDC::UDC_ZeroURI|Data)
        )
    )
    ;;{3.2}  schemas
    ;;
    ;;
    (defschema BunnyMetaData
        Rarity:string
        Background:string
        Clothes:string
        Ear:string
        Eyes:string
        Hats:string
        Mouth:string
    )
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
    (defun CT_Namespace ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_MetaData:object{BunnyMetaData} (a:[string])
        {"Rarity"       : (at 0 a)
        ,"Background"   : (at 1 a)
        ,"Clothes"      : (at 2 a)
        ,"Ear"          : (at 3 a)
        ,"Eyes"         : (at 4 a)
        ,"Hats"         : (at 5 a)
        ,"Mouth"        : (at 6 a)
        }
    )
    ;;{5.2}  Compute [UC]
    (defun UC_IpfsLink:string (starting-position:integer idx:integer small-or-big:bool)
        (let
            (
                (ipfs:string "https://ipfs.io/ipfs/QmYjHPWPxCeHGu9vgYUbzjmWo34A2z3CNuYmU6MEzgUSzP/")
                (type:string (if small-or-big "512x512" "FULL"))
                (folder:string "/06_DemiBunnies/")
                (number:integer (+ starting-position idx))
                (num-str:string (format "{}" [number]))
                (padded-num:string
                    (if (< number 1000)
                        (if (< number 100)
                            (if (< number 10)
                                (+ "000" num-str)
                                (+ "00" num-str)
                            )
                            (+ "0" num-str)
                        )
                        num-str
                    )
                )
                (jpg:string ".jpg")
            )
            (concat [ipfs type folder padded-num jpg])
        )
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;{5.7}  User [A/C]
    ;;
    (defun A_Step01 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 1 70 mdm)
    )
    (defun A_Step02 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 71 70 mdm)
    )
    (defun A_Step03 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 141 70 mdm)
    )
    (defun A_Step04 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 211 70 mdm)
    )
    (defun A_Step05 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 281 70 mdm)
    )
    (defun A_Step06 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 351 70 mdm)
    )
    (defun A_Step07 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 421 70 mdm)
    )
    (defun A_Step08 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 491 70 mdm)
    )
    (defun A_Step09 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 561 70 mdm)
    )
    (defun A_Step10 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 631 70 mdm)
    )
    (defun A_Step11 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 701 70 mdm)
    )
    (defun A_Step12 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 771 70 mdm)
    )
    (defun A_Step13 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 841 70 mdm)
    )
    (defun A_Step14 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 911 70 mdm)
    )
    (defun A_Step15 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 981 70 mdm)
    )
    (defun A_Step16 (patron:string kbn-id:string mdm:[[string]])
        (C_Spawn patron kbn-id 1051 70 mdm)
    )
    ;;
    (defun A_BunnyRGBSet (patron:string kbn-id:string)
        (let
            (
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)
                ;;
                (native-royalty:decimal (* 0.9R))
                (ignis-royalty:decimal (fold (*) 1.0 [0.9 3.0 IR-C]))
                (md:object{DpdcUdcV2.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                (ipfs-link-one:string "SmallPhoto-IPFS-Link")
                (ipfs-link-two:string "BiggrPhoto-IPFS-Link")
            )
            ;;Set Class 1
            (ref-TS02-C2::C_DPNF|DefinePrimordialSet
                patron kbn-id
                "Bunny RGB Set"
                1.0
                [
                    (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition [26 56 81 110 132 138 148 197 231 242 293 315 318 404 416 490 529 656 676 680 688 693 711 725 799 808 812 823 867 887 926 927 950 965 970 998 1031 1034 1094 1108])
                    (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition [29 84 113 120 152 169 193 245 262 296 338 346 357 359 366 380 389 410 426 459 499 513 542 586 607 642 647 653 704 721 724 766 810 813 855 861 912 931 933 1008])
                    (ref-DPDC-UDC::UDC_DPDC|AllowedNonceForSetPosition [9 55 74 111 140 151 157 246 276 300 327 341 376 425 431 435 464 517 530 596 603 630 648 662 671 684 699 731 768 803 830 884 897 907 918 935 996 1014 1032 1096])
                ]
                (ref-DPDC-UDC::UDC_NonceData
                    native-royalty
                    ignis-royalty
                    "Bunny RGB Set"
                    "Red, Green and Blue eyed Bunnies in a Set. 9.0% (90% of Native Bunny Royalty) Royalty and 90% Ignis-Royalty relative to individual Elements"
                    md
                    (ref-DPDC-UDC::UDC_URI|Type true false false false false false false)
                    (ref-DPDC-UDC::UDC_URI|Data ipfs-link-one B B B B B B)
                    (ref-DPDC-UDC::UDC_URI|Data ipfs-link-one B B B B B B)
                    (ref-DPDC-UDC::UDC_ZeroURI|Data)
                )
            )
        )
    )
    ;;
    (defun C_Spawn (patron:string kbn-id:string starting-position:integer number-of-positions:integer mdm:[[string]])
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)
                ;;
                (l:integer (length mdm))
                (legendary:[integer] [25 175 274 388 407 873 880 954 1033 1095])
                (iz-legendary ())
            )
            (enforce (= l number-of-positions) "Invalid Number of Positions")
            (ref-TS02-C2::C_DPNF|Create
                patron kbn-id
                (fold
                    (lambda
                        (acc:[object{DpdcUdcV2.DPDC|NonceData}] idx:integer)
                        (let
                            (
                                (element-number:integer (+ starting-position idx))
                                (iz-legendary:bool (contains element-number legendary))
                                (rarity:string (if iz-legendary "Legendary" "Common"))
                                (ignis-royalty:decimal (if iz-legendary IR-L IR-C))
                                (element-name:string (format "{} Bunny #{}" [rarity element-number]))
                                (description:string (if iz-legendary D-L D-C))
                            )
                            (ref-U|LST::UC_AppL acc
                                (ref-DPDC-UDC::UDC_NonceData
                                    R
                                    ignis-royalty
                                    element-name
                                    description
                                    (ref-DPDC-UDC::UDC_MetaData (UDC_MetaData (at idx mdm)))
                                    TYPE
                                    (ref-DPDC-UDC::UDC_URI|Data (UC_IpfsLink starting-position idx true) B B B B B B)
                                    (ref-DPDC-UDC::UDC_URI|Data (UC_IpfsLink starting-position idx false) B B B B B B)
                                    ZD
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 (- (length mdm) 1))
                )
            )
        )
    )

)