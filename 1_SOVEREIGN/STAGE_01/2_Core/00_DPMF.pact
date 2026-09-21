;;<=============================================================================================>
;;  DEPRECATED — HISTORICAL ONLY. SUPERSEDED BY DPOF (06_DPOF.pact).
;;<=============================================================================================>
;;  DPMF is the original MetaFungible module. Live metadata-rich fungible behaviour is DPOF
;;  (OrtoFungible); the rename separated the active path from legacy meta-fungible semantics.
;;  Owner ruling 2026-09-15: KEEP AS IS, as dead material, with commentary only. Nothing below
;;  this banner has been restructured.
;;
;;  MEASURED STATE (2026-09-15) — this module is INERT, not merely unused:
;;
;;    * `create-table` is called ZERO times against FIVE `deftable` declarations. Every other
;;      module in the tree creates its tables at the end of the file. So DPMF is deployed with
;;      NO STORAGE, and every storage-backed function in it errors on contact. Pinned by
;;      REPL/modules/CONFORMANCE.repl <<CONF-06>>, which asserts the exact failure
;;      `Table ouronet-ns.DPMF_P|MT not found`.
;;    * ZERO inbound callers: `ref-DPMF::` appears nowhere in 1_SOVEREIGN/ or 2_CITIZEN/, and no
;;      module names the `DemiourgosPactMetaFungible*` interface. The Talos mentions of "DPMF"
;;      are @doc prose only.
;;    * It carries 13 DEAD MODULE-REFERENCE CALLS (`_audit_modref_calls.py`): eleven
;;      `UDC_<tier>Cumulator` refs that no longer exist on IGNIS, plus
;;      `ref-DALOS::XB_CollectStoaWithTrigger` and `ref-DALOS::XE_CollectStoa` — members that live on
;;      IGNIS, not DALOS. `OuronetDalosV2` declares no `STOA|*` members at all. They would abort
;;      if reached; they cannot be reached.
;;    * 95,601 bytes — about 64% of a ~150k deploy slot, in a system whose deploy-size cap
;;      dictates module ordering.
;;
;;  DO NOT "FIX" ANY OF THE ABOVE IN PLACE. Creating the tables without wiring the callers would
;;  turn an inert module into a live one with dead calls inside it; <<CONF-06>> goes red on
;;  exactly that half-migration, by design.
;;<=============================================================================================>
;;
;; Deploy: load THIS file — interface(s) + module ship together.
;; History/shared registry: 1_SOVEREIGN/STAGE_01/0_Interfaces/02_Core.pact
;;
;; net: v7   ·   dev: v8   ;; ARCHIVE bump -- deploy v8 only if the archived module is ever redeployed
(interface DemiourgosPactMetaFungibleV8
    @doc "ARCHIVE INTERFACE for DPMF, the retired MetaFungible core. \
        \ \
        \ DemiourgosPactMetaFungibleV7 declared 95 functions -- issue, mint, burn, transfer, roles, wipe, \
        \ ownership rotation. DPMF went to ARCHIVE MODE on 2026-09-21 (StoicSyntax-Prefixes \
        \ 7.21) and every one of them was removed, so that interface described a surface that \
        \ no longer exists. An interface is the contract a reader consults to learn what a \
        \ module offers; one left standing after its implementation is gone READS AS VERIFIED \
        \ and is false. \
        \ \
        \ THE SUFFIX BUMPS BY ONE rather than the old version being edited, because a deployed \
        \ interface CANNOT be changed -- and DemiourgosPactMetaFungibleV7 may well be live. The old one is \
        \ removed from this SOURCE, not from the chain; nothing can remove it from the chain, \
        \ and nothing needs to. \
        \ \
        \ What is declared here is exactly what survives: the two schemas the readers return, \
        \ and every read function. No writers, because there are none."

    ;;<=========================================================================>
    ;;{G2}  schemas -- load-bearing: the readers below return these shapes
    (defschema DPMF|Schema
        nonce:integer
        balance:decimal
        meta-data:[object]
    )
    (defschema DPMF|Nonce-Balance
        nonce:integer
        balance:decimal
    )

    ;;<=========================================================================>
    ;;{5.3}  Read [UR/URC/UC/UDC] -- the whole surviving surface
    (defun GOV|Demiurgoi ())
    (defun P|Info ())
    (defun P|UR:guard (policy-name:string))
    (defun P|UR_IMP:[guard] ())
    (defun CT_Bar ())
    (defun UDC_Compose:object{DPMF|Schema} (nonce:integer balance:decimal meta-data:[object]))
    (defun UDC_Nonce-Balance:[object{DPMF|Nonce-Balance}] (nonce-lst:[integer] balance-lst:[decimal]))
    (defun UR_P-KEYS:[string] ())
    (defun UR_KEYS:[string] ())
    (defun UR_Konto:string (id:string))
    (defun UR_Name:string (id:string))
    (defun UR_Ticker:string (id:string))
    (defun UR_Decimals:integer (id:string))
    (defun UR_CanChangeOwner:bool (id:string))
    (defun UR_CanUpgrade:bool (id:string))
    (defun UR_CanAddSpecialRole:bool (id:string))
    (defun UR_CanFreeze:bool (id:string))
    (defun UR_CanWipe:bool (id:string))
    (defun UR_CanPause:bool (id:string))
    (defun UR_Paused:bool (id:string))
    (defun UR_Supply:decimal (id:string))
    (defun UR_TransferRoleAmount:integer (id:string))
    (defun UR_Vesting:string (id:string))
    (defun UR_Sleeping:string (id:string))
    (defun UR_Roles:[string] (id:string rp:integer))
    (defun UR_CanTransferNFTCreateRole:bool (id:string))
    (defun UR_CreateRoleAccount:string (id:string))
    (defun UR_NoncesUsed:integer (id:string))
    (defun UR_RewardBearingToken:string (id:string))
    (defun UR_AccountSupply:decimal (id:string account:string))
    (defun UR_AccountRoleBurn:bool (id:string account:string))
    (defun UR_AccountRoleCreate:bool (id:string account:string))
    (defun UR_AccountRoleNFTAQ:bool (id:string account:string))
    (defun UR_AccountRoleTransfer:bool (id:string account:string))
    (defun UR_AccountFrozenState:bool (id:string account:string))
    (defun UR_AccountUnit:[object{DPMF|Schema}] (id:string account:string))
    (defun UR_AccountNonces:[integer] (id:string account:string))
    (defun UR_AccountBalances:[decimal] (id:string account:string))
    (defun UR_AccountMetaDatas:[[object]] (id:string account:string))
    (defun UR_AccountNonceBalance:decimal (id:string nonce:integer account:string))
    (defun UR_AccountNonceMetaData:[object] (id:string nonce:integer account:string))
    (defun UR_AccountNoncesBalances:[decimal] (id:string nonces:[integer] account:string))
    (defun UR_AccountNoncesMetaDatas:[[object]] (id:string nonces:[integer] account:string))
    (defun URC_IzRBT:bool (reward-bearing-token:string))
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string))
    (defun URC_EliteAurynzSupply (account:string))
    (defun URC_AccountExist:bool (id:string account:string))
    (defun URC_HasVesting:bool (id:string))
    (defun URC_HasSleeping:bool (id:string))
    (defun URCv_Parent:string (dpmf:string))
    (defun URC_IzIdEA:bool (id:string))
    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer]))
    (defun UEV_id (id:string))
)

(module DPMF GOV
    @doc "DPMF — the legacy MetaFungible token core, implementing \
        \ DemiourgosPactMetaFungibleV8. Owns a properties table (ownership, \
        \ name/ticker/decimals, control flags, supply, nonces-used, vesting/sleeping links), \
        \ a per-account balance table of nonce units, and a role table. Client ops cover \
        \ issue, mint, add-quantity, burn, single/multi batch transfer, pause, freeze, \
        \ roles, wipe and ownership rotation. Superseded by DPOF (OrtoFungible) for live \
        \ use; retained for history and migration."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;

    ;;<=========================================================================>

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;;
    ;;ARCHIVE MODE: the three ORIGINAL implements clauses (OuronetPolicyV2,
    ;;BrandingUsagePrimaryV2, DemiourgosPactMetaFungibleV7) are gone. The two SHARED ones are
    ;;gone for good -- that is what takes this module out of every future interface cascade.
    ;;Its OWN interface comes back, bumped, declaring only what is left.
    (implements DemiourgosPactMetaFungibleV8)
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_DPMF                               (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|DPMF_ADMIN)))
    (defcap GOV|DPMF_ADMIN ()                           (enforce-guard GOV|MD_DPMF))
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
    (defconst P|I                                       (P|Info))
    ;;{P2}  schemas
    ;;{P3}  tables
    ;;
    (deftable P|T:{OuronetPolicyV2.P|S})
    (deftable P|MT:{OuronetPolicyV2.P|MS})
    ;;{P4}  capabilities


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







    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst BAR                                       (CT_Bar))
    (defconst DPMF|NEUTRAL
        {"nonce": 0
        ,"balance": 0.0
        ,"meta-data": [{}] }
    )
    (defconst DPMF|NEGATIVE
        {"nonce": -1
        ,"balance": -1.0
        ,"meta-data": [{}] }
    )
    ;;{3.2}  schemas
    ;;
    (defschema DPMF|PropertiesSchema
        owner-konto:string
        name:string
        ticker:string
        decimals:integer
        can-change-owner:bool
        can-upgrade:bool
        can-add-special-role:bool
        can-freeze:bool
        can-wipe:bool
        can-pause:bool
        is-paused:bool
        can-transfer-nft-create-role:bool
        supply:decimal
        create-role-account:string
        role-transfer-amount:integer
        nonces-used:integer
        reward-bearing-token:string
        vesting-link:string
        sleeping-link:string
    )
    (defschema DPMF|BalanceSchema
        @doc "Key = <DPMF id> + BAR + <account>"
        exist:bool
        unit:[object{DemiourgosPactMetaFungibleV8.DPMF|Schema}]
        role-nft-add-quantity:bool
        role-nft-burn:bool
        role-nft-create:bool
        role-transfer:bool
        frozen:bool
    )
    (defschema DPMF|RoleSchema
        r-nft-burn:[string]
        r-nft-create:[string]
        r-nft-add-quantity:[string]
        r-transfer:[string]
        a-frozen:[string]
    )
    ;;{3.3}  tables
    (deftable DPMF|PropertiesTable:{DPMF|PropertiesSchema})
    (deftable DPMF|BalanceTable:{DPMF|BalanceSchema})
    (deftable DPMF|RoleTable:{DPMF|RoleSchema})

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
    (defun CT_Bar ()
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    (defun UDC_Compose:object{DemiourgosPactMetaFungibleV8.DPMF|Schema} (nonce:integer balance:decimal meta-data:[object])
        @doc "Composes a DPMF Object"
        {"nonce" : nonce, "balance": balance, "meta-data" : meta-data}
    )
    (defun UDC_Nonce-Balance:[object{DemiourgosPactMetaFungibleV8.DPMF|Nonce-Balance}] (nonce-lst:[integer] balance-lst:[decimal])
        @doc "Composes a Nonce-Balance Object, needed for Wiping functionality"
        (let
            (
                (nonce-length:integer (length nonce-lst))
                (balance-length:integer (length balance-lst))
            )
            (enforce (= nonce-length balance-length) "Nonce and Balance Lists are not of equal length")
            (zip (lambda (x:integer y:decimal) { "nonce": x, "balance": y }) nonce-lst balance-lst)
        )
    )
    ;;{5.2}  Compute [UC]
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun UR_P-KEYS:[string] ()
        (keys DPMF|PropertiesTable)
    )
    (defun UR_KEYS:[string] ()
        (keys DPMF|BalanceTable)
    )
    ;;
    (defun UR_Konto:string (id:string)
        (at "owner-konto" (read DPMF|PropertiesTable id ["owner-konto"]))
    )
    (defun UR_Name:string (id:string)
        (at "name" (read DPMF|PropertiesTable id ["name"]))
    )
    (defun UR_Ticker:string (id:string)
        (at "ticker" (read DPMF|PropertiesTable id ["ticker"]))
    )
    (defun UR_Decimals:integer (id:string)
        (at "decimals" (read DPMF|PropertiesTable id ["decimals"]))
    )
    (defun UR_CanChangeOwner:bool (id:string)
        (at "can-change-owner" (read DPMF|PropertiesTable id ["can-change-owner"]))
    )
    (defun UR_CanUpgrade:bool (id:string)
        (at "can-upgrade" (read DPMF|PropertiesTable id ["can-upgrade"]))
    )
    (defun UR_CanAddSpecialRole:bool (id:string)
        (at "can-add-special-role" (read DPMF|PropertiesTable id ["can-add-special-role"]))
    )
    (defun UR_CanFreeze:bool (id:string)
        (at "can-freeze" (read DPMF|PropertiesTable id ["can-freeze"]))
    )
    (defun UR_CanWipe:bool (id:string)
        (at "can-wipe" (read DPMF|PropertiesTable id ["can-wipe"]))
    )
    (defun UR_CanPause:bool (id:string)
        (at "can-pause" (read DPMF|PropertiesTable id ["can-pause"]))
    )
    (defun UR_Paused:bool (id:string)
        (at "is-paused" (read DPMF|PropertiesTable id ["is-paused"]))
    )
    (defun UR_Supply:decimal (id:string)
        (at "supply" (read DPMF|PropertiesTable id ["supply"]))
    )
    (defun UR_TransferRoleAmount:integer (id:string)
        (at "role-transfer-amount" (read DPMF|PropertiesTable id ["role-transfer-amount"]))
    )
    (defun UR_Vesting:string (id:string)
        (at "vesting-link" (read DPMF|PropertiesTable id ["vesting-link"]))
    )
    (defun UR_Sleeping:string (id:string)
        (at "sleeping-link" (read DPMF|PropertiesTable id ["sleeping-link"]))
    )
    (defun UR_Roles:[string] (id:string rp:integer)
        (if (= rp 1)
            (with-default-read DPMF|RoleTable id
                { "r-nft-burn" : [BAR]}
                { "r-nft-burn" := rb }
                rb
            )
            (if (= rp 2)
                (with-default-read DPMF|RoleTable id
                    { "r-nft-create" : [BAR]}
                    { "r-nft-create" := rnc }
                    rnc
                )
                (if (= rp 3)
                    (with-default-read DPMF|RoleTable id
                        { "r-nft-add-quantity" : [BAR]}
                        { "r-nft-add-quantity" := rnaq }
                        rnaq
                    )
                    (if (= rp 4)
                        (with-default-read DPMF|RoleTable id
                            { "r-transfer" : [BAR]}
                            { "r-transfer" := rt }
                            rt
                        )
                        (with-default-read DPMF|RoleTable id
                            { "a-frozen" : [BAR]}
                            { "a-frozen" := af }
                            af
                        )
                    )
                )
            )
        )
    )
    (defun UR_CanTransferNFTCreateRole:bool (id:string)
        (at "can-transfer-nft-create-role" (read DPMF|PropertiesTable id ["can-transfer-nft-create-role"]))
    )
    (defun UR_CreateRoleAccount:string (id:string)
        (at "create-role-account" (read DPMF|PropertiesTable id ["create-role-account"]))
    )
    (defun UR_NoncesUsed:integer (id:string)
        (at "nonces-used" (read DPMF|PropertiesTable id ["nonces-used"]))
    )
    (defun UR_RewardBearingToken:string (id:string)
        (at "reward-bearing-token" (read DPMF|PropertiesTable id ["reward-bearing-token"]))
    )
    (defun UR_AccountSupply:decimal (id:string account:string)
        (fold (+) 0.0 (UR_AccountBalances id account))
    )
    (defun UR_AccountRoleBurn:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-nft-burn" : false}
            { "role-nft-burn" := rb }
            rb
        )
    )
    (defun UR_AccountRoleCreate:bool (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-nft-create" : false}
            { "role-nft-create" := rnc }
            rnc
        )
    )
    (defun UR_AccountRoleNFTAQ:bool (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-nft-add-quantity" : false}
            { "role-nft-add-quantity" := rnaq }
            rnaq
        )
    )
    (defun UR_AccountRoleTransfer:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "role-transfer" : false }
            { "role-transfer" := rt }
            rt
        )
    )
    (defun UR_AccountFrozenState:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "frozen" : false}
            { "frozen" := fr }
            fr
        )
    )
    ;;
    (defun UR_AccountUnit:[object{DemiourgosPactMetaFungibleV8.DPMF|Schema}] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" : [DPMF|NEGATIVE]}
            { "unit" := u }
            u
        )
    )
    (defun UR_AccountNonces:[integer] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            {"unit" : [DPMF|NEUTRAL]}
            {"unit" := read-unit}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[integer] item:object{DemiourgosPactMetaFungibleV8.DPMF|Schema})
                        (if (> (at "nonce" item) 0)
                                (ref-U|LST::UC_AppL acc (at "nonce" item))
                                acc
                        )
                    )
                    []
                    read-unit
                )
            )
        )
    )
    (defun UR_AccountBalances:[decimal] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            {"unit" : [DPMF|NEUTRAL]}
            {"unit" := read-unit}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[decimal] item:object{DemiourgosPactMetaFungibleV8.DPMF|Schema})
                        (if (> (at "nonce" item) 0)
                                (ref-U|LST::UC_AppL acc (at "balance" item))
                                acc
                        )
                    )
                    []
                    read-unit
                )
            )
        )
    )
    (defun UR_AccountMetaDatas:[[object]] (id:string account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" : [DPMF|NEUTRAL] }
            { "unit" := read-unit}
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                )
                (fold
                    (lambda
                        (acc:[[object]] item:object{DemiourgosPactMetaFungibleV8.DPMF|Schema})
                        (if (> (at "nonce" item) 0)
                                (ref-U|LST::UC_AppL acc (at "meta-data" item))
                                acc
                        )
                    )
                    []
                    read-unit
                )
            )
        )
    )
    (defun UR_AccountNonceBalance:decimal (id:string nonce:integer account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            {"unit" : [DPMF|NEUTRAL]}
            {"unit" := read-unit}
            (fold
                (lambda
                    (acc:decimal item:object{DemiourgosPactMetaFungibleV8.DPMF|Schema})
                    (let
                        (
                            (nonce-val:integer (at "nonce" item))
                            (balance-val:decimal (at "balance" item))
                        )
                        (if (= nonce-val nonce)
                            balance-val
                            acc
                        )
                    )
                )
                0.0
                read-unit
            )
        )
    )
    (defun UR_AccountNonceMetaData:[object]
        (id:string nonce:integer account:string)
        (UEV_id id)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "unit" : [DPMF|NEUTRAL] }
            { "unit" := read-unit}
            (fold
                (lambda
                    (acc item:object{DemiourgosPactMetaFungibleV8.DPMF|Schema})
                    (let
                        (
                            (nonce-val:integer (at "nonce" item))
                            (meta-data-val (at "meta-data" item))
                        )
                        (if (= nonce-val nonce)
                            meta-data-val
                            acc
                        )
                    )
                )
                []
                read-unit
            )
        )
    )
    (defun UR_AccountNoncesBalances:[decimal] (id:string nonces:[integer] account:string)
        (UEV_id id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (all-nonce-lst:[integer] (UR_AccountNonces id account))
                (all-balance-lst:[decimal] (UR_AccountBalances id account))
            )
            (UEV_NoncesToAccount id account nonces)
            (fold
                (lambda
                    (acc:[decimal] nonce:integer)
                    (ref-U|LST::UC_AppL acc (at (at 0 (ref-U|LST::UC_Search all-nonce-lst nonce)) all-balance-lst))
                )
                []
                nonces
            )
        )
    )
    (defun UR_AccountNoncesMetaDatas:[[object]] (id:string nonces:[integer] account:string)
        (UEV_id id)
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                (all-nonce-lst:[integer] (UR_AccountNonces id account))
                (all-metadata-lst:[[object]] (UR_AccountMetaDatas id account))
            )
            (UEV_NoncesToAccount id account nonces)
            (fold
                (lambda
                    (acc:[[object]] nonce:integer)
                    (ref-U|LST::UC_AppL acc (at (at 0 (ref-U|LST::UC_Search all-nonce-lst nonce)) all-metadata-lst))
                )
                []
                nonces
            )
        )
    )
    (defun URC_IzRBT:bool (reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in any atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) BAR)
            false
            true
        )
    )
    (defun URC_IzRBTg:bool (atspair:string reward-bearing-token:string)
        @doc "Returns a boolean, if token id is RBT in a specific atspair"
        (UEV_id reward-bearing-token)
        (if (= (UR_RewardBearingToken reward-bearing-token) BAR)
            false
            (if (= (UR_RewardBearingToken reward-bearing-token) atspair)
                true
                false
            )
        )
    )
    (defun URC_EliteAurynzSupply (account:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
            )
            (if (!= ea-id BAR)
                (let
                    (
                        (ea-supply:decimal (ref-DPTF::UR_AccountSupply ea-id account))
                        (fea:string (ref-DPTF::UR_Frozen ea-id))
                        (rea:string (ref-DPTF::UR_Reservation ea-id))
                        (vea:string (ref-DPTF::UR_Vesting ea-id))
                        (sea:string (ref-DPTF::UR_Sleeping ea-id))
                        (fea-supply:decimal
                            (if (!= fea BAR)
                                (ref-DPTF::UR_AccountSupply fea account)
                                0.0
                            )
                        )
                        (rea-supply:decimal
                            (if (!= rea BAR)
                                (ref-DPTF::UR_AccountSupply rea account)
                                0.0
                            )
                        )
                        (vea-supply:decimal
                            (if (!= vea BAR)
                                (UR_AccountSupply vea account)
                                0.0
                            )
                        )
                        (sea-supply:decimal
                            (if (!= sea BAR)
                                (UR_AccountSupply sea account)
                                0.0
                            )
                        )
                    )
                    (fold (+) 0.0 [ea-supply fea-supply rea-supply vea-supply sea-supply])
                )
                0.0
            )
        )
    )
    (defun URC_AccountExist:bool (id:string account:string)
        (with-default-read DPMF|BalanceTable (concat [id BAR account])
            { "exist"   : false }
            { "exist"   := e}
            e
        )
    )
    (defun URC_HasVesting:bool (id:string)
        @doc "Returns a boolean if DPMF has a vesting counterpart"
        (if (= (UR_Vesting id) BAR)
            false
            true
        )
    )
    (defun URC_HasSleeping:bool (id:string)
        @doc "Returns a boolean if DPMF has a sleeping counterpart"
        (if (= (UR_Sleeping id) BAR)
            false
            true
        )
    )
    (defun URCv_Parent:string (dpmf:string)
        @doc "Computes <dpmf> parent"
        (let
            (
                (fourth:string (drop 3 (take 4 dpmf)))
            )
            (enforce (!= fourth BAR) "Sleeping LP Tokens not allowed for this operation")
            (let
                (
                    (first-two:string (take 2 dpmf))
                )
                (if (= first-two "V|")
                    (UR_Vesting dpmf)
                    (if (= first-two "Z|")
                        (UR_Sleeping dpmf)
                        dpmf
                    )
                )
            )
        )
    )
    (defun URC_IzIdEA:bool (id:string)
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ea-id:string (ref-DALOS::UR_EliteAurynID))
                (fea:string (ref-DPTF::UR_Frozen ea-id))
                (rea:string (ref-DPTF::UR_Reservation ea-id))
                (vea:string (ref-DPTF::UR_Vesting ea-id))
                (sea:string (ref-DPTF::UR_Sleeping ea-id))
            )
            (contains id [ea-id fea rea vea sea])
        )
    )
    ;;{5.4}  Validate [UEV/CAP]

    (defun UEV_NoncesToAccount (id:string account:string nonces:[integer])
        (let
            (
                (ref-U|INT:module{OuronetIntegersV2} U|INT)
                (all-nonce-lst:[integer] (UR_AccountNonces id account))
                (validate-nonces:bool (ref-U|INT::UEV_ContainsAll nonces all-nonce-lst))
            )
            (enforce validate-nonces (format "Input nonces {} for {} dont all exist on {}" [nonces id account]))
        )
    )
    (defun UEV_id (id:string)
        (with-default-read DPMF|PropertiesTable id
            { "supply" : -1.0 }
            { "supply" := s }
            (enforce
                (>= s 0.0)
                (format "DPMF ID {} does not exist" [id])
            )
        )
    )




















    ;;{5.5}  Write [W]
    ;;{5.6}  Aux/X
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)

    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPMF|C>ISSUE

    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)

    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)

    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)

    ;;
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPMF|S>MOVE_CREATE-R

    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPMF|S>TG_ADD-QTY-R

    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPMF|S>TG_BURN-R

    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)

    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          DPMF|C>UPDATE-SPECIAL

    ;;
    ;;Protection: Class 3 — Custom: DPMF|C>ADD-QTY

    ;;Protection: Class 3 — Custom: DPMF|C>BURN

    ;;Protection: Class 3 — Custom: DPMF|S>RT_OWN

    ;;Protection: Class 3 — Custom: DPMF|S>CTRL

    ;;Protection: Class 3 — Custom: DPMF|C>CREATE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 1 — Innate protection offered by XI_DebitPaired

    ;;Protection: Class 1 — Innate protection offered by XI_DebitAdmin

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 3 — Custom: DPMF|C>MINT

    ;;Protection: Class 3 — Custom: DPMF|S>X_FRZ-ACC

    ;;Protection: Class 3 — Custom: DPMF|S>TG_PAUSE

    ;;Protection: Class 3 — Custom: DPMF|S>X_TG_TRANSFER-R

    ;;Protection: Class 3 — Custom: DPMF|C>TRANSFER

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 2 — SECURE

    ;;Protection: Class 3 — Custom: DPMF|C>TOTAL-WIPE

    ;;Protection: Class 3 — Custom: DPMF|C>PARTIAL-WIPE

    ;;{5.7}  User [A/C]
    ;;


    ;;

















)