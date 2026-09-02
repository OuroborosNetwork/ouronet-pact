(interface AgeOfZalmoxis
    ;;
    ;;  [UR]
    ;;
    (defun UR_CountPrimalTrueFungibles:integer ())
    (defun UR_CountPrimalOrtoFungibles:integer ())
    (defun UR_CountATSPairs:integer ())
    (defun UR_CountTrueFungibles:integer ())
    (defun UR_CountOrtoFungibles:integer ())
    (defun UR_CountSemiFungibles:integer ())
    (defun UR_CountNonFungibles:integer ())
    ;;
    (defun UR_PrimalTrueFungible:string (position:integer))
    (defun UR_PrimalOrtoFungible:string (position:integer))
    (defun UR_AutostakePair:string (position:integer))
    (defun UR_TrueFungible:string (position:integer))
    (defun UR_OrtoFungible:string (position:integer))
    (defun UR_SemiFungible:string (position:integer))
    (defun UR_NonFungible:string (position:integer))
    ;;
    ;;  [A]
    ;;
    (defun A_InitialiseCounters ())
    (defun A_RegisterPrimalTrueFungible (id:string))
    (defun A_RegisterPrimalOrtoFungible (id:string))
    (defun A_RegisterAutostakePair (id:string))
    (defun A_RegisterTrueFungible (id:string))
    (defun A_RegisterOrtoFungible (id:string))
    (defun A_RegisterSemiFungible (id:string))
    (defun A_RegisterNonFungible (id:string))
    ;;
    ;;  [C]
    ;;
    (defun C_SetupKosonicATS (index-name:string hot-rbt:string decay:integer))
    ;;
)
(module AOZ GOV


    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    (implements AgeOfZalmoxis)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AOZ                    (keyset-ref-guard (GOV|Demiurgoi)))
    (defconst GOV|SC_AOZ                    (keyset-ref-guard AOZ|SC_KEY))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|AOZ_ADMIN)))
    (defcap GOV|AOZ_ADMIN ()
        (enforce-one
            "AOZ Admin not satisfed"
            [
                (enforce-guard GOV|MD_AOZ)
                (enforce-guard GOV|SC_AOZ)
            ]
        )
    )
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
    ;;
    (defconst AOZ|SC_KEY                    (+ (CT_Namespace) ".us-0000_aozt-keyset"))
    (defconst AOZ|SC_NAME                   "Ѻ.ÅτhGźνΣhςвiàÁĘĚДÏWÉΨTěCÃŒnæi9цéŘQí¢лΞÛIчмfÓeżÜýЯàDÖ5αȚÞVđσγ₱0ęЬÔĄsĄLлKùvåH£ΞMFУûÊyđÜqdŽŚЖsĘъsПÂÔØŹÞŮγŚΣЧ6Ïж¢чPyòлБ14ÚęŃĄåîêтηΛbΦđkûÇĂζsБúĎdŸUЛзÙÂÚJηXťćж¥zщòÁŸRĘ")
    (defconst AOZ|SC_STOA-NAME               "k:95a59029029524ebb250b2fafe6826ff88bb59c527d661cba3279d09a51d3bdf")
    (defconst AOZ|PBL                       "9G.29k17uqiwBF7mbc3rzr5gz228lxepz7a0fwrja2Bgzk1czjCLja3wg9q1ey10ftFhxIAiFBHCtvotkmKIIxFisMni8EA6esncL3lg2uLLH2u89Er9sgbeGmK0k7b63xujf1nAIf5GB583fcE6pzFak2CwhEi1dHzI0F14tvtxv4H8r1ABk5weoJ7HfCoadMm1h8MjIwjzbDKo80H25AJL8I1JiFF66Iwjcj3sFrD9xaqz1ziEEBJICF2k81pG9ABpDk2rK4ooglCK3kmC0h7yvvakjIvMpGp00jnw2Cpg1HoxjK0HoqzuKciIIczGsEzCjoB43x7lKsxkzAm7op2urv0I85Kon7uIBmg328cuKMc8driw8boAFnrdqHEFhx4sFjm8DM44FutCykKGx7GGLnoeJLaC707lot9tM51krmp6KDG8Ii318fIc1L5iuzqEwDnkro35JthzlDD1GkJaGgze3kDApAckn3uMcBypdz4LxbDGrg5K2GdiFBdFHqdpHyssrH8t694BkBtM9EB3yI3ojbnrbKrEM8fMaHAH2zl4x5gdkHnpjAeo8nz")
    (defconst AOZ|COUNTER "AOZ-AssetCount")
    ;;{3.2}  schemas
    ;;
    ;;
    ;;
    (defschema AOZ|AssetCounter
        primal-tfs:integer
        primal-ofs:integer
        atspairs:integer
        tfs:integer
        ofs:integer
        sfs:integer
        nfs:integer
    )
    (defschema AOZ|PrimalTrueFungibles
        primal-tf-id:string
    )
    (defschema AOZ|PrimalOrtoFungibles
        primal-of-id:string
    )
    (defschema AOZ|AutostakePairs
        atspair-id:string
    )
    (defschema AOZ|TrueFungibles
        tf-asset:string
    )
    (defschema AOZ|OrtoFungibles
        of-asset:string
    )
    (defschema AOZ|SemiFungibles
        sf-asset:string
    )
    (defschema AOZ|NonFungibles
        nf-asset:string
    )
    ;;{3.3}  tables
    (deftable AOZ|T|AssetCounter:{AOZ|AssetCounter})                ;;Key = FIXED
    (deftable AOZ|T|PrimalTrueFungibles:{AOZ|PrimalTrueFungibles})  ;;Key = <position>
    (deftable AOZ|T|PrimalOrtoFungibles:{AOZ|PrimalOrtoFungibles})  ;;Key = <position>
    (deftable AOZ|T|AutostakePairs:{AOZ|AutostakePairs})            ;;Key = <position>
    (deftable AOZ|T|TrueFungibles:{AOZ|TrueFungibles})              ;;Key = <position>
    (deftable AOZ|T|OrtoFungibles:{AOZ|OrtoFungibles})              ;;Key = <position>
    (deftable AOZ|T|SemiFungibles:{AOZ|SemiFungibles})              ;;Key = <position>
    (deftable AOZ|T|NonFungibles:{AOZ|NonFungibles})                ;;Key = <position>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    ;;{C2}  Simple
    ;;{C3}  Composed
    (defcap SECURE-ADMIN ()
        (compose-capability (SECURE))
        (compose-capability (GOV|AOZ_ADMIN))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()                    (let ((ref-U|CT:module{OuronetConstantsV1} U|CT)) (ref-U|CT::CT_NS_USE)))
    ;;{5.2}  Compute [UC]
    ;;
    (defun UC_Str:string (n:integer)
        (int-to-str 10 n)
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_CountPrimalTrueFungibles:integer ()
        (at "primal-tfs" (read AOZ|T|AssetCounter AOZ|COUNTER ["primal-tfs"]))
    )
    (defun UR_CountPrimalOrtoFungibles:integer ()
        (at "primal-ofs" (read AOZ|T|AssetCounter AOZ|COUNTER ["primal-ofs"]))
    )
    (defun UR_CountATSPairs:integer ()
        (at "atspairs" (read AOZ|T|AssetCounter AOZ|COUNTER ["atspairs"]))
    )
    (defun UR_CountTrueFungibles:integer ()
        (at "tfs" (read AOZ|T|AssetCounter AOZ|COUNTER ["tfs"]))
    )
    (defun UR_CountOrtoFungibles:integer ()
        (at "ofs" (read AOZ|T|AssetCounter AOZ|COUNTER ["ofs"]))
    )
    (defun UR_CountSemiFungibles:integer ()
        (at "sfs" (read AOZ|T|AssetCounter AOZ|COUNTER ["sfs"]))
    )
    (defun UR_CountNonFungibles:integer ()
        (at "nfs" (read AOZ|T|AssetCounter AOZ|COUNTER ["nfs"]))
    )
    ;;
    (defun UR_PrimalTrueFungible:string (position:integer)
        (at "primal-tf-id" (read AOZ|T|PrimalTrueFungibles (UC_Str position) ["primal-tf-id"]))
    )
    (defun UR_PrimalOrtoFungible:string (position:integer)
        (at "primal-of-id" (read AOZ|T|PrimalOrtoFungibles (UC_Str position) ["primal-of-id"]))
    )
    (defun UR_AutostakePair:string (position:integer)
        (at "atspair-id" (read AOZ|T|AutostakePairs (UC_Str position) ["atspair-id"]))
    )
    (defun UR_TrueFungible:string (position:integer)
        (at "tf-asset" (read AOZ|T|TrueFungibles (UC_Str position) ["tf-asset"]))
    )
    (defun UR_OrtoFungible:string (position:integer)
        (at "of-asset" (read AOZ|T|OrtoFungibles (UC_Str position) ["of-asset"]))
    )
    (defun UR_SemiFungible:string (position:integer)
        (at "sf-asset" (read AOZ|T|SemiFungibles (UC_Str position) ["sf-asset"]))
    )
    (defun UR_NonFungible:string (position:integer)
        (at "sf-asset" (read AOZ|T|NonFungibles (UC_Str position) ["sf-asset"]))
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;
    (defun XI_IncrementPrimalTrueFungiblesCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "primal-tfs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"primal-tfs" : (+ x 1)}
            )
        )
    )
    (defun XI_IncrementPrimalOrtoFungiblesCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "primal-ofs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"primal-ofs" : (+ x 1)}
            )
        )
    )
    (defun XI_IncrementATSPairsCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "atspairs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"atspairs" : (+ x 1)}
            )
        )
    )
    (defun XI_IncrementTrueFungiblesCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "tfs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"tfs" : (+ x 1)}
            )
        )
    )
    (defun XI_IncrementOrtoFungiblesCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "ofs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"ofs" : (+ x 1)}
            )
        )
    )
    (defun XI_IncrementSemiFungiblesCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "sfs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"sfs" : (+ x 1)}
            )
        )
    )
    (defun XI_IncrementNonFungiblesCounter ()
        (require-capability (SECURE))
        (with-read AOZ|T|AssetCounter AOZ|COUNTER
            { "nfs" := x }
            (update AOZ|T|AssetCounter AOZ|COUNTER
                {"nfs" : (+ x 1)}
            )
        )
    )
    ;;
    (defun XI_W|PrimalTrueFungible (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|PrimalTrueFungibles (UC_Str position)
            {"primal-tf-id" : id}
        )
    )
    (defun XI_W|PrimalOrtoFungible (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|PrimalOrtoFungibles (UC_Str position)
            {"primal-of-id" : id}
        )
    )
    (defun XI_W|AutostakePair (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|AutostakePairs (UC_Str position)
            {"atspair-id" : id}
        )
    )
    (defun XI_W|TrueFungible (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|TrueFungibles (UC_Str position)
            {"tf-asset" : id}
        )
    )
    (defun XI_W|OrtoFungible (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|OrtoFungibles (UC_Str position)
            {"of-asset" : id}
        )
    )
    (defun XI_W|SemiFungible (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|SemiFungibles (UC_Str position)
            {"sf-asset" : id}
        )
    )
    (defun XI_W|NonFungible (id:string position:integer)
        (require-capability (SECURE))      
        (write AOZ|T|NonFungibles (UC_Str position)
            {"nf-asset" : id}
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;;
    (defun A_InitialiseCounters ()
        (with-capability (GOV|AOZ_ADMIN)
            (insert AOZ|T|AssetCounter AOZ|COUNTER
                {"primal-tfs"   : 0
                ,"primal-ofs"   : 0
                ,"atspairs"     : 0
                ,"tfs"          : 0
                ,"ofs"          : 0
                ,"sfs"          : 0
                ,"nfs"          : 0
                }
            )
        )
    )
    (defun A_RegisterPrimalTrueFungible (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|PrimalTrueFungible id (+ (UR_CountPrimalTrueFungibles) 1))
            (XI_IncrementPrimalTrueFungiblesCounter)
        )
    )
    (defun A_RegisterPrimalOrtoFungible (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|PrimalOrtoFungible id (+ (UR_CountPrimalOrtoFungibles) 1))
            (XI_IncrementPrimalOrtoFungiblesCounter)
        )
    )
    (defun A_RegisterAutostakePair (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|AutostakePair id (+ (UR_CountATSPairs) 1))
            (XI_IncrementATSPairsCounter)
        )
    )
    (defun A_RegisterTrueFungible (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|TrueFungible id (+ (UR_CountTrueFungibles) 1))
            (XI_IncrementTrueFungiblesCounter)
        )
    )
    (defun A_RegisterOrtoFungible (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|OrtoFungible id (+ (UR_CountOrtoFungibles) 1))
            (XI_IncrementOrtoFungiblesCounter)
        )
    )
    (defun A_RegisterSemiFungible (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|SemiFungible id (+ (UR_CountSemiFungibles) 1))
            (XI_IncrementSemiFungiblesCounter)
        )
    )
    (defun A_RegisterNonFungible (id:string)
        (with-capability (SECURE-ADMIN)
            (XI_W|NonFungible id (+ (UR_CountNonFungibles) 1))
            (XI_IncrementNonFungiblesCounter)
        )
    )
    (defun C_SetupKosonicATS (index-name:string hot-rbt:string decay:integer)
        (let
            (
                (ref-TS01-C2:module{TalosStageOne_ClientTwoV1} TS01-C2)
                (patron:string AOZ|SC_NAME)
                (EsothericKosonID:string (UR_PrimalTrueFungible 2))
                (AncientKosonID:string (UR_PrimalTrueFungible 3))
            )
            (ref-TS01-C2::C_ATS|AddSecondary patron index-name EsothericKosonID false)
            (ref-TS01-C2::C_ATS|AddSecondary patron index-name AncientKosonID false)
            (ref-TS01-C2::C_ATS|AddHotRBT patron index-name hot-rbt)
            (if (!= decay 0)
                (ref-TS01-C2::C_ATS|SetHotRecoveryFee patron index-name 900.0 decay)
                true
            )
            (ref-TS01-C2::C_ATS|SwitchHotRecovery patron index-name true)
        )
    )

)

(create-table AOZ|T|AssetCounter)
(create-table AOZ|T|PrimalTrueFungibles)
(create-table AOZ|T|PrimalOrtoFungibles)
(create-table AOZ|T|AutostakePairs)
(create-table AOZ|T|TrueFungibles)
(create-table AOZ|T|OrtoFungibles)
(create-table AOZ|T|SemiFungibles)
(create-table AOZ|T|NonFungibles)