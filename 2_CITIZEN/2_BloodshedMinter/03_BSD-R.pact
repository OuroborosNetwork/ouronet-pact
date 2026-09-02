(module BLOODSHED-R GOV

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_BLOODSHED-R            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                          (compose-capability (GOV|BLOODSHED-R_ADMIN)))
    (defcap GOV|BLOODSHED-R_ADMIN ()        (enforce-guard GOV|MD_BLOODSHED-R))
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
    (defconst LEGENDARY             Bloodshed.LEGENDARY)    ;;Legendary BS Score
    (defconst EPIC                  Bloodshed.EPIC)         ;;Epic BS Score
    (defconst RARE                  Bloodshed.RARE)         ;;Rare BS Score
    (defconst COMMON                Bloodshed.COMMON)       ;;Common BS Score
    ;;
    (defconst LEGENDARY-S           Bloodshed.LEGENDARY-S)  ;;Legendary Supply
    (defconst EPIC-S                Bloodshed.EPIC-S)       ;;Epic Supply
    (defconst RARE-S                Bloodshed.RARE-S)       ;:Rare Supply
    (defconst COMMON-S              Bloodshed.COMMON-S)     ;;Common Supply
    ;;
    (defconst R                     Bloodshed.R)            ;;Native Bloodshed Royalty
    (defconst IR-L                  Bloodshed.IR-L)         ;;Legendary Ignis Royalty
    (defconst IR-E                  Bloodshed.IR-E)         ;;Epic Ignis Royalty
    (defconst IR-R                  Bloodshed.IR-R)         ;;Rare Ignis Royalty
    (defconst IR-C                  Bloodshed.IR-C)         ;;Common Ignis Royalty
    ;;
    (defconst BS-PREC               Bloodshed.BS-PREC)      ;;Score Precision
    ;;
    (defconst NAME                  Bloodshed.NAME)         ;;Collection Name
    (defconst DS                    Bloodshed.DS)           ;;Colelction Description
    ;;
    ;;Rarity
    (defconst R1                    Bloodshed.R1)
    (defconst R2                    Bloodshed.R2)
    (defconst R3                    Bloodshed.R3)
    (defconst R4                    Bloodshed.R4)
    ;;Dacian
    (defconst D1                    Bloodshed.D1)
    (defconst D2                    Bloodshed.D2)
    (defconst D3                    Bloodshed.D3)
    (defconst D4                    Bloodshed.D4)
    (defconst D5                    Bloodshed.D5)
    (defconst D6                    Bloodshed.D6)
    (defconst D7                    Bloodshed.D7)
    (defconst D8                    Bloodshed.D8)
    ;;Potency
    (defconst P1                    Bloodshed.P1)
    (defconst P2                    Bloodshed.P2)
    (defconst P3                    Bloodshed.P3)
    ;;Bloodshed
    (defconst B0                    Bloodshed.B0)
    (defconst B1                    Bloodshed.B1)
    (defconst B2                    Bloodshed.B2)
    (defconst B3                    Bloodshed.B3)
    (defconst B4                    Bloodshed.B4)
    (defconst B5                    Bloodshed.B5)
    ;;Backgrounds
    (defconst CC1                   Bloodshed.CC1)
    (defconst CC2                   Bloodshed.CC2)
    (defconst CC3                   Bloodshed.CC3)
    (defconst CC4                   Bloodshed.CC4)
    (defconst CC5                   Bloodshed.CC5)
    (defconst CC6                   Bloodshed.CC6)
    (defconst RR1                   Bloodshed.RR1)
    (defconst RR2                   Bloodshed.RR2)
    (defconst RR3                   Bloodshed.RR3)
    (defconst EP1                   Bloodshed.EP1)
    (defconst EP2                   Bloodshed.EP2)
    (defconst LG1                   Bloodshed.LG1)
    (defconst LG2                   Bloodshed.LG2)
    (defconst LG3                   Bloodshed.LG3)
    (defconst LG4                   Bloodshed.LG4)
    (defconst LG5                   Bloodshed.LG5)
    (defconst LG6                   Bloodshed.LG6)
    (defconst LG7                   Bloodshed.LG7)
    (defconst LG8                   Bloodshed.LG8)
    ;;MainProtection
    (defconst MP1                   Bloodshed.MP1)
    (defconst MP2                   Bloodshed.MP2)
    ;;SecondaryProtection
    (defconst SP1                   Bloodshed.SP1)
    (defconst SP2                   Bloodshed.SP2)
    ;;MainHand
    (defconst MH1                   Bloodshed.MH1)
    (defconst MH2                   Bloodshed.MH2)
    (defconst MH3                   Bloodshed.MH2)
    ;;OffHand
    (defconst OH1                   Bloodshed.OH1)
    (defconst OH2                   Bloodshed.OH2)
    (defconst OH3                   Bloodshed.OH3)
    (defconst OH4                   Bloodshed.OH4)
    (defconst OH5                   Bloodshed.OH5)
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
    (defun UDC_MetaData:object{Bloodshed.MD}
        (a:string b:string c:string d:string e:string f:string g:string h:string i:string)
        {"Rarity"           : a
        ,"Dacian"           : b
        ,"Potency"          : c
        ,"Bloodshed"        : d
        ,"Background"       : e
        ,"FirstProtection"  : f
        ,"SecondProtection" : g
        ,"MainHand"         : h
        ,"OffHand"          : i
        }
    )
    (defun UDC_RareByPosition (pos:integer)
        (let
            (
                (p:integer (mod pos 72))
            )
            (cond
                ((= p 1) (UDC_MetaData R2 D1 P1 B1 RR1 MP1 SP1 MH3 OH2))
                ((= p 2) (UDC_MetaData R2 D1 P1 B1 RR2 MP1 SP1 MH3 OH2))
                ((= p 3) (UDC_MetaData R2 D1 P1 B1 RR3 MP1 SP1 MH3 OH2))
                ((= p 4) (UDC_MetaData R2 D1 P2 B2 RR1 MP1 SP1 MH3 OH2))
                ((= p 5) (UDC_MetaData R2 D1 P2 B2 RR2 MP1 SP1 MH3 OH2))
                ((= p 6) (UDC_MetaData R2 D1 P2 B2 RR3 MP1 SP1 MH3 OH2))
                ((= p 7) (UDC_MetaData R2 D1 P3 B3 RR1 MP1 SP1 MH3 OH2))
                ((= p 8) (UDC_MetaData R2 D1 P3 B3 RR2 MP1 SP1 MH3 OH2))
                ((= p 9) (UDC_MetaData R2 D1 P3 B3 RR3 MP1 SP1 MH3 OH2))
                ((= p 10) (UDC_MetaData R2 D2 P1 B1 RR1 MP1 SP1 MH1 OH1))
                ((= p 11) (UDC_MetaData R2 D2 P1 B1 RR2 MP1 SP1 MH1 OH1))
                ((= p 12) (UDC_MetaData R2 D2 P1 B1 RR3 MP1 SP1 MH1 OH1))
                ((= p 13) (UDC_MetaData R2 D2 P2 B2 RR1 MP1 SP1 MH1 OH1))
                ((= p 14) (UDC_MetaData R2 D2 P2 B2 RR2 MP1 SP1 MH1 OH1))
                ((= p 15) (UDC_MetaData R2 D2 P2 B2 RR3 MP1 SP1 MH1 OH1))
                ((= p 16) (UDC_MetaData R2 D2 P3 B3 RR1 MP1 SP1 MH1 OH1))
                ((= p 17) (UDC_MetaData R2 D2 P3 B3 RR2 MP1 SP1 MH1 OH1))
                ((= p 18) (UDC_MetaData R2 D2 P3 B3 RR3 MP1 SP1 MH1 OH1))
                ((= p 19) (UDC_MetaData R2 D3 P1 B1 RR1 MP1 SP2 MH2 OH4))
                ((= p 20) (UDC_MetaData R2 D3 P1 B1 RR2 MP1 SP2 MH2 OH4))
                ((= p 21) (UDC_MetaData R2 D3 P1 B1 RR3 MP1 SP2 MH2 OH4))
                ((= p 22) (UDC_MetaData R2 D3 P2 B2 RR1 MP1 SP2 MH2 OH4))
                ((= p 23) (UDC_MetaData R2 D3 P2 B2 RR2 MP1 SP2 MH2 OH4))
                ((= p 24) (UDC_MetaData R2 D3 P2 B2 RR3 MP1 SP2 MH2 OH4))
                ((= p 25) (UDC_MetaData R2 D3 P3 B3 RR1 MP1 SP2 MH2 OH4))
                ((= p 26) (UDC_MetaData R2 D3 P3 B3 RR2 MP1 SP2 MH2 OH4))
                ((= p 27) (UDC_MetaData R2 D3 P3 B3 RR3 MP1 SP2 MH2 OH4))
                ((= p 28) (UDC_MetaData R2 D4 P1 B1 RR1 MP1 SP1 MH2 OH3))
                ((= p 29) (UDC_MetaData R2 D4 P1 B1 RR2 MP1 SP1 MH2 OH3))
                ((= p 30) (UDC_MetaData R2 D4 P1 B1 RR3 MP1 SP1 MH2 OH3))
                ((= p 31) (UDC_MetaData R2 D4 P2 B2 RR1 MP1 SP1 MH2 OH3))
                ((= p 32) (UDC_MetaData R2 D4 P2 B2 RR2 MP1 SP1 MH2 OH3))
                ((= p 33) (UDC_MetaData R2 D4 P2 B2 RR3 MP1 SP1 MH2 OH3))
                ((= p 34) (UDC_MetaData R2 D4 P3 B3 RR1 MP1 SP1 MH2 OH3))
                ((= p 35) (UDC_MetaData R2 D4 P3 B3 RR2 MP1 SP1 MH2 OH3))
                ((= p 36) (UDC_MetaData R2 D4 P3 B3 RR3 MP1 SP1 MH2 OH3))
                ((= p 37) (UDC_MetaData R2 D5 P1 B1 RR1 MP2 SP1 MH3 OH5))
                ((= p 38) (UDC_MetaData R2 D5 P1 B1 RR2 MP2 SP1 MH3 OH5))
                ((= p 39) (UDC_MetaData R2 D5 P1 B1 RR3 MP2 SP1 MH3 OH5))
                ((= p 40) (UDC_MetaData R2 D5 P2 B2 RR1 MP2 SP1 MH3 OH5))
                ((= p 41) (UDC_MetaData R2 D5 P2 B2 RR2 MP2 SP1 MH3 OH5))
                ((= p 42) (UDC_MetaData R2 D5 P2 B2 RR3 MP2 SP1 MH3 OH5))
                ((= p 43) (UDC_MetaData R2 D5 P3 B3 RR1 MP2 SP1 MH3 OH5))
                ((= p 44) (UDC_MetaData R2 D5 P3 B3 RR2 MP2 SP1 MH3 OH5))
                ((= p 45) (UDC_MetaData R2 D5 P3 B3 RR3 MP2 SP1 MH3 OH5))
                ((= p 46) (UDC_MetaData R2 D6 P1 B1 RR1 MP2 SP2 MH2 OH4))
                ((= p 47) (UDC_MetaData R2 D6 P1 B1 RR2 MP2 SP2 MH2 OH4))
                ((= p 48) (UDC_MetaData R2 D6 P1 B1 RR3 MP2 SP2 MH2 OH4))
                ((= p 49) (UDC_MetaData R2 D6 P2 B2 RR1 MP2 SP2 MH2 OH4))
                ((= p 50) (UDC_MetaData R2 D6 P2 B2 RR2 MP2 SP2 MH2 OH4))
                ((= p 51) (UDC_MetaData R2 D6 P2 B2 RR3 MP2 SP2 MH2 OH4))
                ((= p 52) (UDC_MetaData R2 D6 P3 B3 RR1 MP2 SP2 MH2 OH4))
                ((= p 53) (UDC_MetaData R2 D6 P3 B3 RR2 MP2 SP2 MH2 OH4))
                ((= p 54) (UDC_MetaData R2 D6 P3 B3 RR3 MP2 SP2 MH2 OH4))
                ((= p 55) (UDC_MetaData R2 D7 P1 B1 RR1 MP2 SP1 MH2 OH5))
                ((= p 56) (UDC_MetaData R2 D7 P1 B1 RR2 MP2 SP1 MH2 OH5))
                ((= p 57) (UDC_MetaData R2 D7 P1 B1 RR3 MP2 SP1 MH2 OH5))
                ((= p 58) (UDC_MetaData R2 D7 P2 B2 RR1 MP2 SP1 MH2 OH5))
                ((= p 59) (UDC_MetaData R2 D7 P2 B2 RR2 MP2 SP1 MH2 OH5))
                ((= p 60) (UDC_MetaData R2 D7 P2 B2 RR3 MP2 SP1 MH2 OH5))
                ((= p 61) (UDC_MetaData R2 D7 P3 B3 RR1 MP2 SP1 MH2 OH5))
                ((= p 62) (UDC_MetaData R2 D7 P3 B3 RR2 MP2 SP1 MH2 OH5))
                ((= p 63) (UDC_MetaData R2 D7 P3 B3 RR3 MP2 SP1 MH2 OH5))
                ((= p 64) (UDC_MetaData R2 D8 P1 B1 RR1 MP2 SP1 MH1 OH1))
                ((= p 65) (UDC_MetaData R2 D8 P1 B1 RR2 MP2 SP1 MH1 OH1))
                ((= p 66) (UDC_MetaData R2 D8 P1 B1 RR3 MP2 SP1 MH1 OH1))
                ((= p 67) (UDC_MetaData R2 D8 P2 B2 RR1 MP2 SP1 MH1 OH1))
                ((= p 68) (UDC_MetaData R2 D8 P2 B2 RR2 MP2 SP1 MH1 OH1))
                ((= p 69) (UDC_MetaData R2 D8 P2 B2 RR3 MP2 SP1 MH1 OH1))
                ((= p 70) (UDC_MetaData R2 D8 P3 B3 RR1 MP2 SP1 MH1 OH1))
                ((= p 71) (UDC_MetaData R2 D8 P3 B3 RR2 MP2 SP1 MH1 OH1))
                ((= p 0) (UDC_MetaData R2 D8 P3 B3 RR3 MP2 SP1 MH1 OH1))
                true
            )
        )
    )
    ;;{5.2}  Compute [UC]
    (defun UC_OrderMultiplier:decimal (rarity-range:integer position:integer rarity-elements:integer)
        (enforce (<= position rarity-elements) "Invalid Position To Rarity Elements Value")
        (let
            (
                (rr:decimal (dec rarity-range))
                (p:decimal (dec position))
                (re:decimal (dec rarity-elements))
            )
            (floor (- rr (/ (* rr (- p 1)) (- re 1))) BS-PREC)
        )
    )
    (defun UC_RareOM (position:integer)
        (UC_OrderMultiplier 300 position RARE-S)
    )
    (defun UC_RareScore (position:integer)
        (floor (* RARE (UC_RareOM position)) BS-PREC)
    )
    ;;
    (defun UC_RareLink:string (position:integer small-or-big:bool)
        (let
            (
                (type:string (if small-or-big "512x512" "FULL"))
                (folder:string "/07_Bloodshed/3_Rare/")
                (p:integer (mod position 72))
                (l:string "R_")
                (v:string (format "{}" [(if (= p 0) 72 p)]))
                (padded-num:string 
                    (if (< p 10)
                        (+ "0" v)
                        v
                    )
                )
                (image-str:string (concat [l padded-num ".jpg"]))
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
    (defun A_Rare (patron:string dhb:string pos:[integer])
        @doc "Issue Bloodshed Rare NFT"
        (let
            (
                (ref-U|LST:module{StringProcessorV1} U|LST)
                (ref-DPDC-UDC:module{DpdcUdcV1} DPDC-UDC)
                (ref-TS02-C2:module{TalosStageTwo_ClientTwoV1} TS02-C2)
                (b:string BAR)
                (t:bool true)
                (f:bool false)
                ;;
                (d-l:string "Rare Bloodshed NFT")
                ;;
                (type:object{DpdcUdcV1.URI|Type} (ref-DPDC-UDC::UDC_URI|Type t f f f f f f))
                (zd:object{DpdcUdcV1.URI|Data} (ref-DPDC-UDC::UDC_ZeroURI|Data))
                ;;
            )
            (ref-TS02-C2::C_DPNF|Create
                patron dhb
                (fold
                    (lambda
                        (acc:[object{DpdcUdcV1.DPDC|NonceData}] idx:integer)
                        (let
                            (
                                (p:integer (at idx pos))
                            )
                            (ref-U|LST::UC_AppL acc
                                (ref-DPDC-UDC::UDC_NonceData
                                    R
                                    IR-L
                                    (format "Bloodshed Rare #{}" [p])
                                    d-l
                                    (ref-DPDC-UDC::UDC_NonceMetaData (UC_RareScore p) [0] (UDC_RareByPosition p))
                                    type
                                    (ref-DPDC-UDC::UDC_URI|Data (UC_RareLink p true) b b b b b b)
                                    (ref-DPDC-UDC::UDC_URI|Data (UC_RareLink p false) b b b b b b)
                                    zd
                                )
                            )
                        )
                        
                    )
                    []
                    (enumerate 0 (- (length pos) 1))
                )
            )
        )
    )

)