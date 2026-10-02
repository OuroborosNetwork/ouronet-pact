;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 23
;; KBN (module upgrade) -- the Bunny RGB Set's artwork links
;; =========================================================================================
;; Deploy this, then run the set definition. The Set is created with the real images on its
;; first and only definition -- no follow-up URI write is needed.
;;
;; ------------------------------------------------------------------------------------------
;; WHAT CHANGED -- one function, A_BunnyRGBSet
;;
;; The two artwork links were placeholders ("SmallPhoto-IPFS-Link" / "BiggrPhoto-IPFS-Link").
;; They are now the supplied Arweave transactions:
;;
;;     uri-primary   (512x512) https://arweave.net/O8Qy9Lv4BqtYcZSfjsv6IbTU-arQN8fb0S10F9q2Tn0
;;     uri-secondary (FULL)    https://arweave.net/C0PgEGQdK_PGtvnit2jZuVttup2GJtVmZ6MScvYL8Ac
;;     uri-tertiary            unset (BAR)
;;
;; Renamed to <set-image-small> / <set-image-big>, because these are ARWEAVE while the 1,100
;; individual Elements genuinely are on IPFS (KBN.UC_IpfsLink) -- the old <ipfs-link-*> names
;; said the gateway was shared, and it is not.
;;
;; ------------------------------------------------------------------------------------------
;; AND A DEFECT IN THE SAME let -- WHY THE BIG LINK WOULD NOT HAVE LANDED
;;
;; Both UDC_URI|Data calls read <ipfs-link-one>, so <ipfs-link-two> was a DEAD BINDING and
;; uri-secondary -- the full-resolution slot -- carried the SMALL image. C_Spawn sets the
;; convention for every individual Element one screen below (primary = 512x512, secondary =
;; FULL); the Set was the one nonce in the collection that broke it.
;;
;; Nothing could catch it: both links were placeholders, so the duplication produced two
;; identical strings that were equally wrong, and [5.4]_PopulateBunnies TX-03 invoked the
;; function while asserting nothing about what it stored. Had this not been found, the links
;; below would have gone in and the Set would still have shown the small image at full size.
;;
;; ------------------------------------------------------------------------------------------
;; ALSO: <(* 0.9R)> -> <(* 0.9 R)>. Pact's lexer splits at the digit->letter boundary, so the
;; two are the same expression and both give 90.0 (verified). Royalties are unchanged: 90.0
;; native, 54.0 ignis. Spaced only because it READ as a decimal literal named "0.9R".
;;
;; ------------------------------------------------------------------------------------------
;; WHY MODULE-ONLY
;;
;; KBN implements no interface at all (LIVE-MODULES.json: "interfaces": []) and declares no
;; tables, so there is nothing but the module body to ship -- no interface to be refused, no
;; create-table to re-run. `_scratch_load23.repl` asserts the no-interface premise, because the
;; day KBN gains an `implements` this file must stop being module-only or the deploy is refused.
;;
;; The live module is genuinely a different build, so this is a real upgrade and not a re-send:
;;     live   (mainnet)  5nVlXL2e0s3PFdhxzwWFmIgcl52ka49pIeIDJEjsqZs
;;     this file          73J_dJ5ulSvVVQPysdWXYvxQdtYcl4oi3pfbtfYACj4
;;
;; ------------------------------------------------------------------------------------------
;; VERIFICATION
;;
;; Gate green at 26,176 assertions. [5.4]_PopulateBunnies TX-03 <<KBN-RGB-URI>> now asserts
;; both slots hold the two DIFFERENT links in C_Spawn's order and that the tertiary stays BAR;
;; <<KBN-RGB-ROY>> pins 90.0 / 54.0. NEGATIVE-TESTED: re-pointing uri-secondary back at the
;; small link turns 2 of the 6 red, including the distinctness clause -- which is the one that
;; matters, since equality alone would pass again the day the bindings are re-shared.
;;
;; The emitted file was LOADED over an already-deployed KBN (`REPL/_scratch_loadpurev2.repl`) --
;; the only check that catches an interface refusal or a left-in create-table, both of which
;; cost round V1 a transaction. `_purev2.py --check` separately proves this body is the module
;; source byte for byte.
;;
;; `_deadbind.py --twins` is gate-fatal and MISSED this defect -- its twin rule only knew
;; "one name is the other plus a version suffix", and <ipfs-link-two> is not <ipfs-link-one>
;; plus anything. An enumerated-sibling rule was added (-one/-two, -small/-big, ...); measured
;; before widening a fatal check, it adds exactly one hit across the tree, and it is this bug.
;;
;; ------------------------------------------------------------------------------------------
;; AFTER THIS DEPLOY -- the set definition
;;
;;     (ouronet-ns.AQP-BOOT.C_Step1_CreateBunnySet PATRON_KONTO "KBN_COLLECTION_ID")
;;
;; Signed with GOV|AQP_BOOT_ADMIN; the patron is charged downstream through TS02-C2.
;; Then verify, as a /local read:
;;
;;     (ouronet-ns.DPDC-S.UR_SetNonceData "KBN_COLLECTION_ID" false 1)
;;       -> uri-primary.image   = ...O8Qy9Lv4...  (512x512)
;;          uri-secondary.image = ...C0PgEGQd...  (FULL)
;;       The two must DIFFER.
;;
;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/../4_BunniesMinter/02_KBunnies.pact (module only -- its interface is already live)
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
                (ref-DPDC:module{DpdcV2} DPDC)
                (ref-DPDC-UDC:module{DpdcUdcV2} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV2} TS02-C2)
                ;;
                ;;CORRECTED 2026-10-02: was <(* 0.9R)>. Pact's lexer splits at the
                ;;digit->letter boundary, so <0.9R> and <0.9 R> are the SAME
                ;;expression and both give 90.0 (verified in a scratch REPL). The
                ;;value was never wrong; it READ as one decimal literal named
                ;;"0.9R", which is the kind of line the next person "corrects" into
                ;;a real defect. Spaced, not changed.
                (native-royalty:decimal (* 0.9 R))
                ;;0.9 x 3 elements x common-element ignis = 54.0, i.e. 90% of what
                ;;the three individual Elements would bill -- what the description
                ;;below claims.
                (ignis-royalty:decimal (fold (*) 1.0 [0.9 3.0 IR-C]))
                (md:object{DpdcUdcV2.NonceMetaData} (ref-DPDC-UDC::UDC_NoMetaData))
                ;;SET ARTWORK. Arweave, not IPFS -- the old names said <ipfs-link-*>
                ;;while the individual Elements genuinely ARE on IPFS (UC_IpfsLink),
                ;;so a reader comparing the two would have taken the gateway to be
                ;;the same. It is not. Only the Set nonce's own artwork lives here.
                (set-image-small:string
                    "https://arweave.net/O8Qy9Lv4BqtYcZSfjsv6IbTU-arQN8fb0S10F9q2Tn0")
                (set-image-big:string
                    "https://arweave.net/C0PgEGQdK_PGtvnit2jZuVttup2GJtVmZ6MScvYL8Ac")
            )
            ;;Set Class 1
            ;;The EXECUTOR is the collection owner, READ here rather than threaded: this
            ;;populator takes only (patron kbn-id), and 08_DPDC-S binds the declared executor to
            ;;(UR_OwnerKonto id son) because the authority underneath is DPDC::CAP_Owner -- an
            ;;enforce on a DERIVED account (HANDOFF 4g, 2026-09-22).
            (ref-TS02-C2::DPNF|C_DefinePrimordialSet
                patron (ref-DPDC::UR_OwnerKonto kbn-id false) kbn-id
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
                    ;;DEFECT FIXED 2026-10-02: both of these read <ipfs-link-one>,
                    ;;so <ipfs-link-two> was a DEAD BINDING and uri-secondary -- the
                    ;;full-resolution slot -- carried the SMALL image. C_Spawn sets
                    ;;the convention for every individual Element one screen below:
                    ;;primary = (UC_IpfsLink .. true), the 512x512; secondary =
                    ;;(.. false), the FULL. The Set was the one nonce in the whole
                    ;;collection that broke it.
                    ;;
                    ;;Nothing could catch it. Both links were PLACEHOLDERS, so the
                    ;;duplication produced two identical strings that were equally
                    ;;wrong, and [5.4]_PopulateBunnies TX-03 invoked this function
                    ;;without asserting one thing about what it stored -- a test
                    ;;proving a write HAPPENED, not what was WRITTEN. Assertions
                    ;;added there in the same change.
                    (ref-DPDC-UDC::UDC_URI|Data set-image-small B B B B B B)
                    (ref-DPDC-UDC::UDC_URI|Data set-image-big B B B B B B)
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
            (ref-TS02-C2::DPNF|C_Create
                patron (DPDC.UR_Verum5 kbn-id false) kbn-id
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

