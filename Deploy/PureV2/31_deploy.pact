;; =========================================================================================
;; OURONET DEPLOY -- ROUND V2, file 31
;; The custody guard, and the authority reader that 29 shipped broken
;; =========================================================================================
;; TWO MODULES, MODULE-ONLY, IN LOAD ORDER. Neither interface changes: `AcquisitionAnchorsV1`
;; and `OUiThirteenV1` are both live and immutable, and both new/changed functions are declared
;; in their modules alone.
;;
;; -----------------------------------------------------------------------------------------
;; a] AQP-ANK -- UEV_ExecutorNotCustodial
;; -----------------------------------------------------------------------------------------
;; Refuses the three smart accounts that hold tokens as CUSTODY, never as management:
;;
;;     SWP|SC_NAME   every liquidity-pool token
;;     VST|SC_NAME   every frozen and reserved special token
;;     ATS|SC_NAME   the hot-RBTs
;;
;; OWNER RULING, 2026-10-04: owning a token as a protocol function must never be a route to
;; managing it. Management flows through the parent -- an LP through its POOL OWNER, a special
;; through the owner of the token it was derived from -- which is what
;; `URCv_AnchorableDptfAuthority` already resolves.
;;
;; IT SITS ON THE SHARED AUTHORITY CHECK, so it covers ISSUE and REVOKE alike: a custodial
;; account must not be able to revoke an anchor either.
;;
;; DEFENCE IN DEPTH, NOT THE PRIMARY GATE, and the `@doc` says so -- an enforce that is already
;; unreachable invites deletion. The authority resolution ALREADY keeps these accounts out: an
;; LP resolves to the pool owner, so SWP is not the authority for its own LP token and
;; `CAP_TF|Owner` refuses it. This earns its place by catching a loosened resolution, a fourth
;; custodial account, and by failing with a message that NAMES custody where the ownership gate
;; would only say the executor is not the authority.
;;
;; WHY IT IS NOT ALREADY ON CHAIN: it was written in the same session as PureV2/27 and never
;; carried into a deploy file -- 27 shipped AQP-ANK's LP work, 28 the Talos rename, 29 the
;; reader, 30 the previews, and this fell between them. Verified absent before writing this:
;;     (ouronet-ns.AQP-ANK.UEV_ExecutorNotCustodial "x")
;;       -> "Module ouronet-ns.AQP-ANK has no such member"
;;
;; -----------------------------------------------------------------------------------------
;; b] O-UI-THIRTEEN -- the authority reader, FIXED
;; -----------------------------------------------------------------------------------------
;; 29 shipped a `URH_13|MyAuthorityTrueFungibles` that walked the special link BACKWARDS.
;; `XE_UpdateSpecialTrueFungible` writes that link in BOTH directions, so `UR_Frozen` answers
;; the PARENT when handed a special -- and VST|SC_NAME owns the specials. Measured on the live
;; module as it stands:
;;
;;     URH_13|MyAuthorityTrueFungibles (VST|SC_NAME)
;;       -> ["ELITEAURYN-8Nh-JO8JO4F5", "SPARK-6B42e2_oW8j0",
;;           "VST-8Nh-JO8JO4F5", "OURO-8Nh-JO8JO4F5"]
;;
;; Four tokens VST neither owns nor may anchor, offered to it as manageable.
;;
;; TWO CHANGES, because one alone would be fragile:
;;   - the link is followed only FROM a core token (an `F|`/`R|` id IS a counterpart; it has
;;     none to find), and
;;   - the whole result is then filtered by `URCv_AnchorableDptfAuthority(id) == account` --
;;     asking the authority rule directly rather than trusting the derivation that produced the
;;     candidate. The derivation only has to be a superset; the filter decides. That keeps the
;;     reader correct even if a link direction or a prefix set changes under it.
;;
;; The REPL test passed over the bug because the fixture only had an account owning a CORE
;; token, which walks the link the intended way. `[6.2.9]` <<OUI13-A7>> now asserts the
;; authority property directly, which is what the second change makes checkable.
;;
;; -----------------------------------------------------------------------------------------
;; ORDER
;; -----------------------------------------------------------------------------------------
;; AQP-ANK first. O-UI-THIRTEEN's new filter calls `ref-ANK::URCv_AnchorableDptfAuthority`
;; through a modref; the function has been live since PureV2/27, so the order is belt-and-braces
;; rather than strictly required -- but sovereign core before a citizen read module is the
;; standing rule and there is no reason to depart from it.
;;
;; -----------------------------------------------------------------------------------------
;; SIGNING / VERIFY
;; -----------------------------------------------------------------------------------------
;; `GOV|AQP_ANK_ADMIN` then `GOV|O_UI_THIRTEEN_ADMIN`. Afterwards, as /local reads:
;;
;;   (ouronet-ns.O-UI-THIRTEEN.URH_13|MyAuthorityTrueFungibles (ouronet-ns.DALOS.GOV|VST|SC_NAME))
;;     -> must be []   (it is four tokens today)
;;   (ouronet-ns.AQP-ANK.UEV_ExecutorNotCustodial (ouronet-ns.DALOS.GOV|SWP|SC_NAME))
;;     -> must FAIL, with a message naming CUSTODY
;; =========================================================================================

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev2.py

(namespace "ouronet-ns")

;; ---- source: 2_CITIZEN/Stage_Z/../../1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact (module only -- its interface is already live)
(module AQP-ANK GOV
    @doc "Sovereign anchor module for AQP. Stores anchor definitions, BoostClasses (7-slot \
        \ groupings), per-asset anchor bookkeeping, per-user anchor promile, \
        \ per-user/boost-class aggregates, and a reverse score-link index. Issues \
        \ true/semi/non-fungible (trait or set) anchors, revokes anchors/BoostClasses, and \
        \ updates each holder's aggregate promile on stake/unstake. Includes the revoke-lock \
        \ and re-score sweep hooks; anchors feed score boosting in AQP-SCORE."

    ;;<=========================================================================>
    ;;{0}  IMPLEMENTERS
    ;; REPL observability: REPL/Stage_02/[6.2.1]_AQP-ANK.repl tags each intra-tx group as TXnnn · mm · <slug> in ;;==== … ==== and (print "--- [TXnnn · mm · …] ---"); mm is 01.. within each begin-tx.
    ;;
    (implements OuronetPolicyV2)
    (implements AcquisitionAnchorsV1)

    ;;<=========================================================================>
    ;;{1}  GOVERNANCE
    ;;{G1}  constants
    ;;
    (defconst GOV|MD_AQP-ANK                            (keyset-ref-guard (GOV|Demiurgoi)))
    ;;{G2}  schemas
    ;;{G3}  tables
    ;;{G4}  capabilities
    (defcap GOV ()                                      (compose-capability (GOV|ANK_ADMIN)))
    (defcap GOV|ANK_ADMIN ()                            (enforce-guard GOV|MD_AQP-ANK))
    ;;{G5}  functions
    (defun GOV|Demiurgoi ()
        @doc "Resolves the governance keyset from DALOS."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::GOV|Demiurgoi)
        )
    )
    (defun GOV|AqpKey ()
        @doc "Governance keyset name for the AQP smart account (canonical — sibling AQP modules ref AQP-ANK)."
        (+ (CT_Namespace) ".dh_sc_aqp-keyset")
    )
    (defun GOV|AQP|SC_NAME ()
        @doc "Symbolic name of the AQP sovereign smart DALOS account (canonical)."
        (at 0 ["Σ.ЖřÎzэóΣQз3ÌĄăådìÜλÅË9γğ7χûПæ0₳ПûÖŞrĄθXtFìмkщsGвÅgλąÇπЩAĚЭDíéαэБùđáżñИïПÆΣтцξsηåäялÃБц¢r6ÁíäзуμþĄĐЫîÉAćýìЧыQPнŁзßξĂйjay£üѺçRЫfУQșÏΠÜqîÔĄťß6ЗSρŠeΦñëdmûΦøШâΞýκъиřк"])
    )
    (defun GOV|AQP|PBL ()
        @doc "Public branding/license payload for AQP|SC_NAME smart account deploy (canonical)."
        (at 0 ["9G.632vHq208xaznBw9AfwrFGmLBqkr7tqEzf2Msq389xqEknmfAk8qI5MM1MaszdgMtEBpo6rbuC09Do7F6pjc91jzy3JxI6fjCkyuIbDpDD5i8CxeCBL0dKdDu3d2uAAwl6wE6npnm4Mjxx6JhiFq1sKddsGjLH9BjHF0ljtegHrn39qIADru76Ftr9Kgxh6Ds2aj4EufG07uK9sFG38ej5vooDMr0wp8alqGdnIiJxbhmwEKEg44l8pI5LDq2EotoM2jq86x1EJ5hM4wkfhtq4ye610tkAMIdLrDD87Euk14aJgMwnrLmytzcCc3Kakrnhs8Jxy5dFeowGxzlx1bGHqfwEen0pLcd6nl9udGE9hfFucLjM1seKzv542nwzz5jrpKmvzebI4BLK00Br1ocvxs4uor2nEv2Fng1l6qAiLcbv0hMnbLDEEcLpF1bD55gw55of7H2c3ieozahorkuCe5FEkAkEAhcGwJ35HCletrbcn2Ebo0fsD0tf2zxKsbzinpcJCtpv4EF4AyyhwD1LbtEd6qsEbgyJkA2DqdGBE5Fuqudzf8082Ei88d"])
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
    (defcap P|ANK|CALLER ()
        true
    )
    (defcap P|SECURE-CALLER ()
        (compose-capability (P|ANK|CALLER))
        (compose-capability (SECURE))
    )
    ;;{P5}  functions
    (defun P|Info ()
        @doc "Returns policy metadata key from DALOS policy module."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (ref-DALOS::P|Info)
        )
    )
    (defun P|UR:guard (policy-name:string)
        @doc "Reads one policy guard by policy name."
        (at "policy" (read P|T policy-name ["policy"]))
    )
    (defun P|UR_IMP:[guard] ()
        @doc "Reads imported policy guards list."
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
        @doc "Enforces that caller matches an imported policy guard."
        (let
            (
                (ref-U|G:module{OuronetGuardsV2} U|G)
            )
            (ref-U|G::UEV_Any (P|UR_IMP))
        )
    )
    (defun P|A_Add (policy-name:string policy-guard:guard)
        @doc "Writes or updates one local policy guard entry."
        (with-capability (GOV|ANK_ADMIN)
            (write P|T policy-name
                {"policy" : policy-guard}
            )
        )
    )
    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \
            \ IDEMPOTENT: a guard already in the chain is left alone rather than appended \
            \ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (GOV|ANK_ADMIN)
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
        (with-capability (GOV|ANK_ADMIN)
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
        (with-capability (GOV|ANK_ADMIN)
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
        @doc "No IMP registration, and that is a MEASURED conclusion rather than an omission. \
            \ \
            \ This module bills -- `C_Issue*Anchor` all end on IGNIS' STOA collector, which became \
            \ `P|UEV_IMC`-gated on 2026-09-20. It still needs no guard of its own in IGNIS' IMP, \
            \ because every one of those call sites is a plain `C_` reached through TS02-C3, and \
            \ `P|UEV_IMC` is DEPTH-INVARIANT: the `P|TALOS-SUMMONER` capability TS02-C3 acquires \
            \ at the top is still in scope when the collector is reached. TS02-C3's guard is \
            \ registered; this module's would be a second answer to a question already answered. \
            \ \
            \ That is not free to add. `P|UEV_IMC` -> `U|G::UEV_Any` maps `UC_Try` over the WHOLE \
            \ guard list with no short-circuit, so every entry in IGNIS' IMP costs gas on EVERY \
            \ billed operation on the chain. A redundant registration is a permanent tax. \
            \ \
            \ WHAT WOULD CHANGE THIS: a billing call site inside a `defpact` step. A step arrives \
            \ in its own transaction via `continue-pact` with an EMPTY capability scope and \
            \ inherits nothing -- which is exactly what caught MTX-SWP. If one is ever added here, \
            \ this module needs its own guard registered, or that step must acquire `P|ANK|CALLER` \
            \ itself. Verified 2026-09-20 by `REPL/tools/_impdiff.py`: this registration never \
            \ landed in the genesis chain and the full gate was green regardless."
        true
    )

    ;;<=========================================================================>
    ;;{3}  CST
    ;;{3.1}  constants
    (defconst AQP|SC_KEY                                (GOV|AqpKey))
    (defconst AQP|SC_NAME                               (GOV|AQP|SC_NAME))
    (defconst BAR                                       (CT_Bar))
    (defconst E-ANK
        {"promile"                  : 0.0
        ,"ouronet-account"          : BAR
        ,"anchor-id"                : BAR}
    )
    ;; M6 #15 — anchor-definition sanity bounds enforced at issue (UEV_Promile + ANK|C>ISSUE-DPTF).
    (defconst CT_ANK_PRECISION:integer                  3)          ;; anchors use exactly 3 decimals of promile precision
    (defconst CT_ANK_MIN_PROMILE:decimal                1.0)        ;; minimum anchor promile
    (defconst CT_ANK_MAX_PROMILE:decimal                10000.0)    ;; maximum anchor promile (caps a single anchor's boost)
    ;;The three NATIVE liquidity-pool token prefixes. Same set as `05_DPTF.pact`'s DPTF|C>MINT
    ;;and `03_AQP.pact`'s LP predicate -- named here so the anchor authority rule and those two
    ;;cannot drift apart silently. `F|` wrappers are stripped BEFORE this is consulted.
    (defconst CT_ANK_LP_PREFIXES:[string]               ["S|" "W|" "P|"])
    (defconst CT_ANK_MIN_DPTF_AMOUNT:decimal            1000.0)     ;; minimum TF-anchor denominated amount
    (defconst CT_ANK_MAX_DPTF_AMOUNT:decimal            1000000.0)  ;; maximum TF-anchor denominated amount
    ;;{3.2}  schemas
    ;;
    ;;1]General Anchor Definition
    ;;2]BoostClass Definition
    ;;3]Per-Asset Bookkeeping
    ;;4]User Anchor Values
    ;;5]Per-User Per-BoostClass Aggregate
    ;;{3.3}  tables
    ;;
    (deftable ANK|T|Anchor:{AcquisitionSchemasV1.ANK|Schema})                        ;;Key = <Anchor-ID>
    (deftable ANK|T|BoostClass:{AcquisitionSchemasV1.ANK|BoostClass})                ;;Key = <Boost-Class-ID>
    (deftable ANK|T|AssetAnchors:{AcquisitionSchemasV1.ANK|AssetAnchors})            ;;Key = <Asset-ID>
    (deftable ANK|T|BoostClassScoreLinks:{AcquisitionSchemasV1.ANK|BoostClassScoreLinks}) ;;Key = <Boost-Class-ID>
    ;;
    (deftable ANK|T|Anchors:{AcquisitionSchemasV1.ANK|UserSchema})                   ;;Key = <Ouronet-Account> | <Anchor-ID>
    (deftable ANK|T|UserBoost:{AcquisitionSchemasV1.ANK|UserBoostSchema})            ;;Key = <Ouronet-Account> | <Boost-Class-ID>

    ;;<=========================================================================>
    ;;{4}  CAPABILITIES
    ;;{C1}  Trivial [bronze]
    ;;
    (defcap SECURE ()
        true
    )
    (defcap ANK|C>BUMP-BOOST-CLASS-LINKS (boost-class-id:string)
        @doc "Authorizes AQP-SCORE (forward) to +1 a BoostClass score-link count — the H4 (#9) revoke lock."
        (compose-capability (SECURE))
    )
    (defcap ANK|XE>SWEEP ()
        @doc "Forward (re-score sweep · MTX-AQP): authorize the anchor-retire sweep's ANK writes — per-holder \
            \ aggregate-promile refold + swept anchor removal. NO fund movement. Composes SECURE."
        (compose-capability (SECURE))
    )
    ;;{C2}  Simple
    (defcap AQP|GOV ()
        @doc "Interface/deploy surface for AQP|SC_NAME governor rotate. Runtime compose: AQP-POOL.AQP|GOV only — \
            \ do not compose this cap from other modules."
        true
    )
    ;;{C3}  Composed
    (defcap ANK|C>UPDATE-DPTF (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Authorizes updating user promile for all live DPTF-backed anchors on <dptf-id> after stake/unstake."
        @event
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;1]<total-dptf-amount> must be non-negative (0.0 allowed — vacate/unstake refresh)
            ;;
            ;;DATA-INTEGRITY BACKSTOP, NOT A CLIENT-FACING CHECK. The value is never caller-supplied.
            ;;The only caller is FVT::XI_RefreshTrueFungibleStakeAnchors, reaching this cap through
            ;;AQP-ANK::XE_UpdateTrueFungibleUserAnchorValues, which opens with (P|UEV_IMC) — so no
            ;;external account can present an argument here at all. What FVT passes is the post-stake
            ;;tracker total, a sum over AQP|T|DPTFTracker balances, each of which is itself non-negative
            ;;by the custody cap (AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY refuses an unstake larger than the
            ;;staked balance, so a row can reach 0.0 but never go below it). A negative therefore cannot
            ;;be constructed from any sequence of user actions; only a corrupt tracker write could
            ;;produce one, which is precisely what this line exists to catch. Kept deliberately at >=
            ;;rather than >: 0.0 is the legal vacate/unstake refresh value.
            ;;Backed by REPL/modules/AQP.repl <<AQP-G45>>, which asserts the IMC gate and the
            ;;non-negativity of the derivation rather than pretending to drive the guard.
            ;;UNREACHABLE
            (enforce (>= total-dptf-amount 0.0) "total-dptf-amount must be non-negative")
            ;;2]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;3]<dptf-id> must exist
            (ref-DPTF::UEV_id dptf-id)
            ;;4] when positive, <total-dptf-amount> must conform to DPTF precision
            (if (> total-dptf-amount 0.0)
                (ref-DPTF::UEV_Amount dptf-id total-dptf-amount)
                true
            )
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>UPDATE-DPSF (account:string dpsf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPSF-backed anchors on one asset (delegates to UPDATE-DPDC, SF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpsf-id nonces true))
    )
    (defcap ANK|C>UPDATE-DPNF (account:string dpnf-id:string nonces:[integer])
        @doc "Authorizes updating user promile for DPNF-backed anchors on one asset (delegates to UPDATE-DPDC, NF)."
        @event
        (compose-capability (ANK|C>UPDATE-DPDC account dpnf-id nonces false))
    )
    (defcap ANK|C>UPDATE-DPDC (account:string asset-id:string nonces:[integer] son:bool)
        @doc "Authorizes a DPDC anchor-value update for <account> on <asset-id>'s <nonces> \
            \ (<son> discriminates the set / non-set collectable fungibility mode). Validates the \
            \ account exists and the nonces exist for the target DPDC asset; composes SECURE for the write."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;1]<account> must exist
            (ref-DALOS::UEV_EnforceAccountExists account)
            ;;2]<nonces> must exist for the target DPDC asset + fungibility mode
            (ref-DPDC::UEV_NonceMapper asset-id son nonces)
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>REVOKE-BOOST-CLASS (boost-class-id:string)
        @doc "Authorizes revoking an empty BoostClass."
        @event
        (let
            (
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
            )
            (enforce (= (at "anchors" bc) 0) (format "{} BoostClass {} not empty" [E-ANK boost-class-id]))
            (enforce (at "class-active" bc) (format "{} BoostClass {} already inactive" [E-ANK boost-class-id]))
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|C>ISSUE-DPTF
        (executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Validates DPTF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
            )
            ;;LIQUIDITY-POOL TOKENS ARE ANCHORABLE AS OF 2026-10-03. The enforce that used to
            ;;stand here blocked them, in two clauses that together implemented lines 4] and 5]
            ;;of CAP_TF|Owner's doc:
            ;;
            ;;    (!= first-two "S|") (!= first-two "W|") (!= first-two "P|")
            ;;        -- a NATIVE LP token, by its prefix.
            ;;    (!= fourth BAR)
            ;;        -- a FROZEN LP, `F|W|...`, whose FOURTH character is the bar. Compact, and
            ;;           the only thing that caught a frozen LP at all.
            ;;
            ;;It is REMOVED rather than narrowed, because what it protected against is gone. It
            ;;existed because an LP token's owner is SWP|SC_NAME -- a smart account nobody can
            ;;sign for -- so issuance would have failed later and far less legibly.
            ;;`URCv_AnchorableDptfAuthority` now resolves an LP (native or frozen) to its
            ;;swpair's POOL OWNER, a real signable account, which is the authority every other
            ;;LP operation already uses: 15_SWP's XE_EnableFrozenLP says in as many words that
            ;;"SWP's executor is the POOL owner (UR_OwnerKonto swpair)", as distinct from the LP
            ;;token's owner. With that resolution in place this enforce blocks a legal operation
            ;;and nothing else.
            ;;
            ;;THE ASYMMETRY IS WHY IT CHANGED. A frozen ORDINARY token resolved to its parent
            ;;and was accepted; a frozen LP resolved to the native LP and was refused. Same
            ;;rule, opposite outcome, for no reason a user could see -- and a pool owner could
            ;;not anchor their own pool's LP token.
            ;;
            ;;SHAPE VALIDATION IS NOT LOST WITH IT: `UEV_id` two lines below is what actually
            ;;checks the id, and always was.
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPTF::UEV_id dptf-id)
            (ref-DPTF::UEV_Amount dptf-id dptf-amount)
            ;; M6 #15: TF-anchor denominated amount must sit within [1000, 1,000,000] so a tiny denominator can't
            ;; leverage the pro-rated promile into an insane boost.
            (enforce
                (and (>= dptf-amount CT_ANK_MIN_DPTF_AMOUNT) (<= dptf-amount CT_ANK_MAX_DPTF_AMOUNT))
                "TF anchor denominated amount (dptf-amount) must be within [1000, 1,000,000]"
            )
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (CAP_TF|Owner dptf-id)
            (UEV_ExecutorIzAssetAuthority executor dptf-id [true true])
            (if acnoi
                (UEV_AssetAnchorCap dptf-id)
                (UEV_IssueAnchor dptf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPSF
        (executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Validates DPSF anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpsf-id true)
            (ref-DPDC::UEV_Nonce dpsf-id true dpsf-nonce)
            (ref-DPDC::CAP_OwnerOrCreator dpsf-id true)
            (UEV_ExecutorIzAssetAuthority executor dpsf-id [false true])
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpsf-id)
                (UEV_IssueAnchor dpsf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>ISSUE-DPNF
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Validates DPNF trait-anchor issuance. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (meta-data:object
                    (ref-DPDC::UR_N|RawMetaData
                        (ref-DPDC::UR_NativeNonceData dpnf-id false 1)
                    )
                )
                (iz-key-present:bool (contains dpnf-trait-key meta-data))
                (l:integer (length dpnf-trait-value))
            )
            (enforce
                (fold (and) true 
                    [
                        iz-key-present
                        (>= l 2)
                        (<= l 256)
                        (!= dpnf-trait-value BAR)
                    ]
                )
                "Invalid Non-Fungible Key or Invalid Promile DPNF Trait-Value"
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|C>ISSUE-DPNF-SET
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Validates DPNF set-anchor issuance via nonce-class model. When acnoi=true, validates boost-class-name for inline creation; when false, validates existing BoostClass."
        @event
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (classes-used:integer (ref-DPDC::UR_SetClassesUsed dpnf-id false))
            )
            (enforce
                (and (>= dpnf-nonce-class 0) (<= dpnf-nonce-class classes-used))
                (format "Invalid DPNF nonce-class {} for collection {}." [dpnf-nonce-class dpnf-id])
            )
            (compose-capability (ANK|XI>ISSUE-DPNF-COMMON executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile))
        )
    )
    (defcap ANK|XI>ISSUE-DPNF-COMMON
        (executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal)
        @doc "Common DPNF issuance checks shared by trait and set modes."
        (let
            (
                (ref-U|ATS:module{UtilityAtsV3} U|ATS)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            ;;AUTHORISATION FIRST (2026-09-14 ruling), and it is NEW here. Until 2026-09-20 the two
            ;;DPNF anchor paths reached NO ownership enforce at all, while their DPTF sibling ran
            ;;CAP_TF|Owner and their DPSF sibling ran CAP_OwnerOrCreator. The asymmetry mattered:
            ;;UEV_AssetAnchorCap caps an asset at 49 anchors, so a stranger could mint 49 anchors
            ;;against a collection he did not own, exhaust the cap permanently, and own every
            ;;resulting boost class. Bounded by STOA cost, but cheap next to blocking a collection
            ;;forever. Closed here because AQP is pre-mainnet and the gap is free to close now.
            (ref-DPDC::CAP_OwnerOrCreator dpnf-id false)
            (UEV_ExecutorIzAssetAuthority executor dpnf-id [false false])
            (ref-U|ATS::UEV_AutostakeIndex anchor-name)
            (ref-DPDC::UEV_id dpnf-id false)
            (if acnoi
                (ref-U|ATS::UEV_AutostakeIndex boost-class-name-or-id)
                true
            )
            (UEV_Promile anchor-precision anchor-promile)
            (if acnoi
                (UEV_AssetAnchorCap dpnf-id)
                (UEV_IssueAnchor dpnf-id boost-class-name-or-id)
            )
            (compose-capability (SECURE))
        )
    )
    (defcap ANK|C>REVOKE (executor:string anchor-id:string)
        @doc "Authorizes anchor revocation for <anchor-id>; requires the anchor to be ALIVE + owned. H4 (#9) \
            \ temp-patch: blocked while the anchor's BoostClass is linked by any score — vacate/unlink first (the \
            \ re-score-sweep unwind is not built yet; see Audit/ANCHOR-STALENESS-INVENTORY.md)."
        @event
        ;; L4 #17: reject a dead/never-existed anchor up front (revoke sets State→false), so a double-revoke aborts
        ;; cleanly here instead of deep in UC_RemoveItemAt — and the H4 lock below never reads a revoked anchor.
        (UEV_LiveAnchor anchor-id)
        (CAP_Owner anchor-id)
        ;;ATTRIBUTION (canon 2.2, 2026-09-22). CAP_Owner above enforces on the ANCHORED ASSET's
        ;;authority -- a DERIVED account naming no actor, HANDOFF 4g. This binds the declared
        ;;executor to that same authority.
        ;;
        ;;DELIBERATELY BELOW UEV_LiveAnchor, and this is not stylistic. The binder resolves the
        ;;anchored asset out of the anchor row, so on a NON-EXISTENT anchor it would raise a raw
        ;;table error -- replacing the liveness message that [6.2.10] <<TX-AQP-NEG-OWNER2>> exists
        ;;to pin, and which was itself only made reachable by turning UR_ANK|State into a
        ;;defaulted read. Reading an owner before proving the entity exists is the standing hazard
        ;;in HANDOFF's rules list; here it has a named test that would have caught it.
        (UEV_ExecutorIzAnchorAuthority executor anchor-id)
        ;; #9 lock: cannot revoke an anchor whose BoostClass is employed by ≥1 score (stale-boost prevention).
        (enforce
            (= (UR_BC|ScoreLinkCount (UR_ANK|BoostClassId anchor-id)) 0)
            "Anchor's BoostClass is in use by a score — revoke locked until scores are vacated/unlinked"
        )
        (compose-capability (SECURE))
    )
    (defcap ANK|XE>SWEEP-REVOKE (anchor-id:string)
        @doc "Forward (re-score sweep terminal): authorize SWEPT revocation of an EMPLOYED anchor — liveness + \
            \ owner enforced, but NOT the #9 score-link lock (the sweep has already refreshed every affected \
            \ holder, so no staleness remains). Distinct from ANK|C>REVOKE (gated on set==0 for UNemployed anchors)."
        @event
        (UEV_LiveAnchor anchor-id)
        (CAP_Owner anchor-id)
        (compose-capability (SECURE))
    )
    ;;UNUSED and REDUNDANT -- harmless. The live revoke path (XI at ~2280) acquires
    ;;ANK|C>REVOKE-BOOST-CLASS directly, and that cap is itself @event and carries both real
    ;;guards (empty class, still active). This wrapper only re-emits around it, so nothing is
    ;;lost by it never being reached: no guard is skipped and the inner event still fires.
    ;;Contrast ATS|S>CONTROL-DIRECT-RECOVERY, whose orphaning DOES skip a guard. Flagged 2026-09-10.
    (defcap ANK|C>REVOKE-BOOST-CLASS-ENTRY (boost-class-id:string)
        @doc "Authorizes revoking a BoostClass entity."
        @event
        (compose-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id))
    )
    ;;{C4}  Ownership [gold]

    ;;<=========================================================================>
    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun CT_Namespace ()
        @doc "Namespace prefix for AQP governance keyset name."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_NS_USE)
        )
    )
    (defun CT_Bar ()
        @doc "Returns CT_BAR constant."
        (let
            (
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
            )
            (ref-U|CT::CT_BAR)
        )
    )
    ;;
    ;; [UDC] construct
    (defun UDC_ANK|Schema:object{AcquisitionSchemasV1.ANK|Schema}
        (a:string b:[bool] c:string d:integer e:bool f:decimal g:decimal h:integer i:string j:string k:integer l:string)
        @doc "Constructs anchor definition row for ANK|T|Anchor."
        {"ank-asset"            : a
        ,"ank-fungibility"      : b
        ,"boost-class-id"       : c
        ,"ank-precision"        : d
        ,"ank-active"           : e
        ,"ank-promile"          : f
        ,"dptf-amount"          : g
        ,"dpsf-nonce"           : h
        ,"dpnf-trait-key"       : i
        ,"dpnf-trait-value"     : j
        ,"dpnf-nonce-class"     : k
        ,"anchor-id"            : l}
    )
    (defun UDC_BoostClass:object{AcquisitionSchemasV1.ANK|BoostClass}
        (a:string b:string c:string d:string e:string f:string g:string h:integer i:bool j:string k:string)
        @doc "Constructs BoostClass object. `k` is the class-owner (creator); only it may attach anchors."
        {"anchor-primary"       : a
        ,"anchor-secondary"     : b
        ,"anchor-tertiary"      : c
        ,"anchor-quaternary"    : d
        ,"anchor-quinary"       : e
        ,"anchor-senary"        : f
        ,"anchor-septenary"     : g
        ,"anchors"              : h
        ,"class-active"         : i
        ,"boost-class-id"       : j
        ,"class-owner"          : k}
    )
    (defun UDC_EmptyInternalGroup:object{AcquisitionSchemasV1.ANK|InternalGroup} ()
        @doc "Constructs empty InternalGroup (all BAR, anchors=0)."
        {"anchor-primary"       : BAR
        ,"anchor-secondary"     : BAR
        ,"anchor-tertiary"      : BAR
        ,"anchor-quaternary"    : BAR
        ,"anchor-quinary"       : BAR
        ,"anchor-senary"        : BAR
        ,"anchor-septenary"     : BAR
        ,"anchors"              : 0}
    )
    (defun UDC_IG|WithAddedAnchor:object{AcquisitionSchemasV1.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in an InternalGroup."
        (let
            (
                (a1:string (at "anchor-primary" ig))
                (a2:string (at "anchor-secondary" ig))
                (a3:string (at "anchor-tertiary" ig))
                (a4:string (at "anchor-quaternary" ig))
                (a5:string (at "anchor-quinary" ig))
                (a6:string (at "anchor-senary" ig))
                (a7:string (at "anchor-septenary" ig))
                (n:integer (at "anchors" ig))
            )
            (cond
                ((= a1 BAR) {"anchor-primary": new-anchor-id, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a2 BAR) {"anchor-primary": a1, "anchor-secondary": new-anchor-id, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a3 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": new-anchor-id, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a4 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": new-anchor-id, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a5 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": new-anchor-id, "anchor-senary": a6, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a6 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": new-anchor-id, "anchor-septenary": a7, "anchors": (+ n 1)})
                ((= a7 BAR) {"anchor-primary": a1, "anchor-secondary": a2, "anchor-tertiary": a3, "anchor-quaternary": a4, "anchor-quinary": a5, "anchor-senary": a6, "anchor-septenary": new-anchor-id, "anchors": (+ n 1)})
                ig
            )
        )
    )
    (defun UDC_IG|WithRemovedAnchor:object{AcquisitionSchemasV1.ANK|InternalGroup}
        (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} revoked-anchor-id:string)
        @doc "Removes anchor-id from group, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" ig)
                     (at "anchor-secondary" ig)
                     (at "anchor-tertiary" ig)
                     (at "anchor-quaternary" ig)
                     (at "anchor-quinary" ig)
                     (at "anchor-senary" ig)
                     (at "anchor-septenary" ig)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" ig))
            )
            {"anchor-primary"   : (at 0 lst-v2)
            ,"anchor-secondary" : (at 1 lst-v2)
            ,"anchor-tertiary"  : (at 2 lst-v2)
            ,"anchor-quaternary": (at 3 lst-v2)
            ,"anchor-quinary"   : (at 4 lst-v2)
            ,"anchor-senary"    : (at 5 lst-v2)
            ,"anchor-septenary" : (at 6 lst-v2)
            ,"anchors"          : (- n 1)}
        )
    )
    (defun UDC_BC|WithAddedAnchor:object{AcquisitionSchemasV1.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} new-anchor-id:string)
        @doc "Adds anchor-id to first free slot in a BoostClass."
        (let
            (
                (a1:string (at "anchor-primary" bc))
                (a2:string (at "anchor-secondary" bc))
                (a3:string (at "anchor-tertiary" bc))
                (a4:string (at "anchor-quaternary" bc))
                (a5:string (at "anchor-quinary" bc))
                (a6:string (at "anchor-senary" bc))
                (a7:string (at "anchor-septenary" bc))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (co:string (at "class-owner" bc))
                (co:string (at "class-owner" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (cond
                ((= a1 BAR) (UDC_BoostClass new-anchor-id a2 a3 a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a2 BAR) (UDC_BoostClass a1 new-anchor-id a3 a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a3 BAR) (UDC_BoostClass a1 a2 new-anchor-id a4 a5 a6 a7 (+ n 1) ca bcid co))
                ((= a4 BAR) (UDC_BoostClass a1 a2 a3 new-anchor-id a5 a6 a7 (+ n 1) ca bcid co))
                ((= a5 BAR) (UDC_BoostClass a1 a2 a3 a4 new-anchor-id a6 a7 (+ n 1) ca bcid co))
                ((= a6 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 new-anchor-id a7 (+ n 1) ca bcid co))
                ((= a7 BAR) (UDC_BoostClass a1 a2 a3 a4 a5 a6 new-anchor-id (+ n 1) ca bcid co))
                bc
            )
        )
    )
    (defun UDC_BC|WithRemovedAnchor:object{AcquisitionSchemasV1.ANK|BoostClass}
        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} revoked-anchor-id:string)
        @doc "Removes anchor-id from BoostClass, compacts slots."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (lst:[string]
                    [(at "anchor-primary" bc)
                     (at "anchor-secondary" bc)
                     (at "anchor-tertiary" bc)
                     (at "anchor-quaternary" bc)
                     (at "anchor-quinary" bc)
                     (at "anchor-senary" bc)
                     (at "anchor-septenary" bc)]
                )
                (position-to-remove:integer
                    (cond
                        ((= revoked-anchor-id (at 0 lst)) 0)
                        ((= revoked-anchor-id (at 1 lst)) 1)
                        ((= revoked-anchor-id (at 2 lst)) 2)
                        ((= revoked-anchor-id (at 3 lst)) 3)
                        ((= revoked-anchor-id (at 4 lst)) 4)
                        ((= revoked-anchor-id (at 5 lst)) 5)
                        ((= revoked-anchor-id (at 6 lst)) 6)
                        -1
                    )
                )
                (lst-v1 (ref-U|LST::UC_RemoveItemAt lst position-to-remove))
                (lst-v2 (ref-U|LST::UC_AppL lst-v1 BAR))
                (n:integer (at "anchors" bc))
                (ca:bool (at "class-active" bc))
                (co:string (at "class-owner" bc))
                (bcid:string (at "boost-class-id" bc))
            )
            (UDC_BoostClass (at 0 lst-v2) (at 1 lst-v2) (at 2 lst-v2) (at 3 lst-v2)
                (at 4 lst-v2) (at 5 lst-v2) (at 6 lst-v2) (- n 1) ca bcid co
            )
        )
    )
    (defun UDC_AA|PlaceAnchor:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} new-anchor-id:string)
        @doc "Places anchor in first group with a free slot; creates new group if needed. \
            \ Pure constructor — no enforce. Caller (issue caps via UEV_*) must ensure \
            \ anchors-active < 49 (implies a free group slot exists under 7×7)."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (let
                (
                    (result:list
                        (fold
                            (lambda (acc:list gi:integer)
                                (if (= (at 1 acc) 1)
                                    acc
                                    (let
                                        (
                                            (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                            (gn:integer (at "anchors" grp))
                                        )
                                        (if (< gn 7)
                                            [(UDC_IG|WithAddedAnchor grp new-anchor-id) 1 gi]
                                            acc
                                        )
                                    )
                                )
                            )
                            [(UDC_EmptyInternalGroup) 0 -1]
                            (enumerate 0 6)
                        )
                    )
                    (placed:integer (at 1 result))
                )
                (if (= placed 1)
                    (let
                        (
                            (updated-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (at 0 result))
                            (slot:integer (at 2 result))
                            (prev-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa slot))
                            (new-ga:integer
                                (if (and (= (at "anchors" prev-grp) 0) (> (at "anchors" updated-grp) 0))
                                    (if (> ga (+ slot 1)) ga (+ slot 1))
                                    ga
                                )
                            )
                        )
                        (URC_AA|SetGroupAtSlot aa updated-grp slot (+ ta 1) new-ga false)
                    )
                    (let
                        (
                            (new-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_IG|WithAddedAnchor (UDC_EmptyInternalGroup) new-anchor-id))
                        )
                        (URC_AA|SetGroupAtSlot aa new-grp ga (+ ta 1) ga true)
                    )
                )
            )
        )
    )
    (defun UDC_AA|RemoveAnchor:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} revoked-anchor-id:string)
        @doc "Removes anchor from its group in AssetAnchors."
        (let
            (
                (ga:integer (at "groups-active" aa))
                (ta:integer (at "anchors-active" aa))
                (aid:string (at "asset-id" aa))
            )
            (fold
                (lambda (acc:object{AcquisitionSchemasV1.ANK|AssetAnchors} gi:integer)
                    (let
                        (
                            (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot acc gi))
                        )
                        (if (URC_IG|ContainsAnchor grp revoked-anchor-id)
                            (let
                                (
                                    (updated-grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_IG|WithRemovedAnchor grp revoked-anchor-id))
                                    (was-ga:integer (at "groups-active" acc))
                                    (was-ta:integer (at "anchors-active" acc))
                                    (grp-now-empty:bool (= (at "anchors" updated-grp) 0))
                                )
                                (URC_AA|SetGroupAtSlot acc updated-grp gi (- was-ta 1) was-ga grp-now-empty)
                            )
                            acc
                        )
                    )
                )
                aa
                (enumerate 0 6)
            )
        )
    )
    (defun UDC_AccountAnchor:object{AcquisitionSchemasV1.ANK|UserSchema}
        (a:decimal b:string c:string)
        @doc "Constructs user-anchor contribution object."
        {"promile"              : a
        ,"ouronet-account"      : b
        ,"anchor-id"            : c}
    )
    (defun UDC_UserBoost:object{AcquisitionSchemasV1.ANK|UserBoostSchema}
        (aggregate-promile:decimal ouronet-account:string boost-class-id:string)
        @doc "Constructs user-boost aggregate row for ANK|T|UserBoost."
        {"aggregate-promile"   : aggregate-promile
        ,"ouronet-account"     : ouronet-account
        ,"boost-class-id"      : boost-class-id}
    )
    ;;{5.2}  Compute [UC]
    ;; [UC]  compute
    (defun UCk_Anchors:string
        (account:string anchor-id:string)
        @doc "Composite key for ANK|T|Anchors (account BAR anchor-id)."
        (concat [account BAR anchor-id])
    )
    (defun UCk_UserBoost:string
        (account:string boost-class-id:string)
        @doc "Composite key for ANK|T|UserBoost (account BAR boost-class-id)."
        (concat [account BAR boost-class-id])
    )
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    ;; [UR]  read
    ;; Reads follow schema order: (1) ANK|Schema (2) ANK|BoostClass (3) ANK|AssetAnchors (4) ANK|UserSchema (5) ANK|UserBoostSchema
    ;; Policy P|T, P|MT — not ANK rows; use P|Info, P|UR, P|UR_IMP above.
    ;;
    ;; Core row: UR_ANK|Data
    (defun UR_ANK|Data:object{AcquisitionSchemasV1.ANK|Schema} (anchor-id:string)
        @doc "Reads full anchor definition row from ANK|T|Anchor."
        (read ANK|T|Anchor anchor-id)
    )
    (defun UR_ANK|AnchoredAsset:string (anchor-id:string)
        @doc "Reads anchored asset id from anchor row."
        (at "ank-asset" (read ANK|T|Anchor anchor-id ["ank-asset"]))
    )
    (defun UR_ANK|Fungibility:[bool] (anchor-id:string)
        @doc "Reads anchor fungibility marker."
        (at "ank-fungibility" (read ANK|T|Anchor anchor-id ["ank-fungibility"]))
    )
    (defun UR_ANK|BoostClassId:string (anchor-id:string)
        @doc "Reads the BoostClass-ID this anchor belongs to."
        (at "boost-class-id" (read ANK|T|Anchor anchor-id ["boost-class-id"]))
    )
    (defun UR_ANK|Precision:decimal (anchor-id:string)
        @doc "Reads anchor precision as decimal."
        (dec (at "ank-precision" (read ANK|T|Anchor anchor-id ["ank-precision"])))
    )
    (defun UR_ANK|State:bool (anchor-id:string)
        @doc "Reads anchor active flag. DEFAULTED: an anchor that does not exist is not active, \
            \ which is what every caller means by this question."
        ;;This was a bare `read`, so for an anchor that does not exist it raised
        ;;`No value found in table ouronet-ns.AQP-ANK_ANK|T|Anchor for key: <id>` -- and
        ;;`UEV_LiveAnchor`, the validator built on it, could therefore never deliver its own
        ;;message ("Anchor <id> must be alive for operation") for the one input that most needs it.
        ;;Both callers are correct under the default: UEV_LiveAnchor wants false, and the anchor
        ;;filter at ~1193 already screens BAR and wants false for anything not alive.
        ;;Same shape as DPTF's UEV_id, which defaults <supply> to -1.0 for exactly this reason.
        ;;Pinned by RedTeam/[RT-K]_PreviewParity.repl <<RT-K-007a/b>>.
        (with-default-read ANK|T|Anchor anchor-id
            { "ank-active" : false }
            { "ank-active" := a }
            a
        )
    )
    (defun UR_ANK|Promile:decimal (anchor-id:string)
        @doc "Reads anchor promile value."
        (at "ank-promile" (read ANK|T|Anchor anchor-id ["ank-promile"]))
    )
    ;;
    (defun UR_ANK|TFAmount:decimal (anchor-id:string)
        @doc "Reads DPTF amount for TF anchor."
        (at "dptf-amount" (read ANK|T|Anchor anchor-id ["dptf-amount"]))
    )
    (defun UR_ANK|SFNonce:integer (anchor-id:string)
        @doc "Reads DPSF nonce for SF anchor."
        (at "dpsf-nonce" (read ANK|T|Anchor anchor-id ["dpsf-nonce"]))
    )
    (defun UR_ANK|NFTraitKey:string (anchor-id:string)
        @doc "Reads DPNF trait key for NF anchor."
        (at "dpnf-trait-key" (read ANK|T|Anchor anchor-id ["dpnf-trait-key"]))
    )
    (defun UR_ANK|NFTraitValue:string (anchor-id:string)
        @doc "Reads DPNF trait value for NF anchor."
        (at "dpnf-trait-value" (read ANK|T|Anchor anchor-id ["dpnf-trait-value"]))
    )
    (defun UR_ANK|NFNonceClass:integer (anchor-id:string)
        @doc "Reads DPNF nonce-class for NF set-anchor mode."
        (at "dpnf-nonce-class" (read ANK|T|Anchor anchor-id ["dpnf-nonce-class"]))
    )
    (defun UR_ANK|ID:string (anchor-id:string)
        @doc "Reads anchor-id field from anchor row."
        (at "anchor-id" (UR_ANK|Data anchor-id))
    )
    ;;
    (defun UR_BC|Data:object{AcquisitionSchemasV1.ANK|BoostClass} (boost-class-id:string)
        @doc "Reads full BoostClass row."
        (read ANK|T|BoostClass boost-class-id)
    )
    (defun UR_BC|Anchors:integer (boost-class-id:string)
        @doc "Reads anchor count from BoostClass."
        (at "anchors" (read ANK|T|BoostClass boost-class-id ["anchors"]))
    )
    (defun UR_BC|Active:bool (boost-class-id:string)
        @doc "Reads active flag from BoostClass."
        (at "class-active" (read ANK|T|BoostClass boost-class-id ["class-active"]))
    )
    (defun UR_BC|ScoreLinks:[string] (boost-class-id:string)
        @doc "The SET of score-ids employing this BoostClass — the H4 reverse index (sweep phase 1). Empty when \
            \ absent. Enumerated by the re-score sweep to find every score/position an anchor change touches."
        (with-default-read ANK|T|BoostClassScoreLinks boost-class-id
            {"score-links": []}
            {"score-links" := sl}
            sl
        )
    )
    (defun UR_BC|ScoreLinkCount:integer (boost-class-id:string)
        @doc "Count of SCORE links referencing this BoostClass (H4 #9 revoke lock) = length of the reverse-index \
            \ set; 0 when absent. Single source of truth is UR_BC|ScoreLinks."
        (length (UR_BC|ScoreLinks boost-class-id))
    )
    (defun UR_BC|ID:string (boost-class-id:string)
        @doc "Reads boost-class-id from BoostClass row."
        (at "boost-class-id" (read ANK|T|BoostClass boost-class-id ["boost-class-id"]))
    )
    ;;
    (defun UR_AA|Data:object{AcquisitionSchemasV1.ANK|AssetAnchors} (asset-id:string)
        @doc "Reads full per-asset bookkeeping row (with-default-read when absent)."
        (let
            (
                (eg:object{AcquisitionSchemasV1.ANK|InternalGroup} (UDC_EmptyInternalGroup))
            )
            (with-default-read ANK|T|AssetAnchors asset-id
                {"group-primary"     : eg
                ,"group-secondary"   : eg
                ,"group-tertiary"    : eg
                ,"group-quaternary"  : eg
                ,"group-quinary"     : eg
                ,"group-senary"      : eg
                ,"group-septenary"   : eg
                ,"groups-active"     : 0
                ,"anchors-active"    : 0
                ,"asset-id"          : asset-id}
                {"group-primary"     := g1
                ,"group-secondary"   := g2
                ,"group-tertiary"    := g3
                ,"group-quaternary"  := g4
                ,"group-quinary"     := g5
                ,"group-senary"      := g6
                ,"group-septenary"   := g7
                ,"groups-active"     := ga
                ,"anchors-active"    := aa
                ,"asset-id"          := aid}
                {"group-primary"     : g1
                ,"group-secondary"   : g2
                ,"group-tertiary"    : g3
                ,"group-quaternary"  : g4
                ,"group-quinary"     : g5
                ,"group-senary"      : g6
                ,"group-septenary"   : g7
                ,"groups-active"     : ga
                ,"anchors-active"    : aa
                ,"asset-id"          : aid}
            )
        )
    )
    (defun UR_AA|GroupsActive:integer (asset-id:string)
        @doc "Reads groups-active from asset anchors row."
        (at "groups-active" (UR_AA|Data asset-id))
    )
    (defun UR_AA|AnchorsActive:integer (asset-id:string)
        @doc "Reads anchors-active from asset anchors row."
        (at "anchors-active" (UR_AA|Data asset-id))
    )
    (defun UR_ANK|AnchorsForAsset:[string] (asset-id:string)
        @doc "Live anchor-ids for an asset. Reads the single AssetAnchors row, \
            \ iterates all groups and slots, collects non-BAR active anchors."
        (let
            (
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data asset-id))
                (ga:integer (at "groups-active" aa))
            )
            (if (<= ga 0)
                []
                (fold
                    (lambda (acc:[string] gi:integer)
                        (let
                            (
                                (grp:object{AcquisitionSchemasV1.ANK|InternalGroup} (URC_AA|GroupAtSlot aa gi))
                                (q:integer (at "anchors" grp))
                            )
                            (if (<= q 0)
                                acc
                                (fold
                                    (lambda (acc2:[string] ai:integer)
                                        (let
                                            (
                                                (aid:string (URC_IG|AnchorIdAtSlot grp ai))
                                            )
                                            (if (and (!= aid BAR) (UR_ANK|State aid))
                                                (+ acc2 [aid])
                                                acc2
                                            )
                                        )
                                    )
                                    acc
                                    (enumerate 0 (- q 1))
                                )
                            )
                        )
                    )
                    []
                    (enumerate 0 6)
                )
            )
        )
    )
    ;;
    ;; Core row: UR_ANK-U|Data
    (defun UR_ANK-U|Data:object{AcquisitionSchemasV1.ANK|UserSchema} (account:string anchor-id:string)
        @doc "Core read: user cumulative promile row for account x anchor."
        (with-default-read ANK|T|Anchors (UCk_Anchors account anchor-id)
            (UDC_AccountAnchor 0.0 account anchor-id)
            {"promile"                  := p
            ,"ouronet-account"          := oa
            ,"anchor-id"                := aid}
            (UDC_AccountAnchor p oa aid)
        )
    )
    (defun UR_ANK-U|Promile:decimal (account:string anchor-id:string)
        @doc "Reads promile from user-anchor row."
        (at "promile" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|Account:string (account:string anchor-id:string)
        @doc "Reads account id from user-anchor row."
        (at "ouronet-account" (UR_ANK-U|Data account anchor-id))
    )
    (defun UR_ANK-U|ID:string (account:string anchor-id:string)
        @doc "Reads anchor id from user-anchor row."
        (at "anchor-id" (UR_ANK-U|Data account anchor-id))
    )
    ;;
    (defun UR_UB|Data:object{AcquisitionSchemasV1.ANK|UserBoostSchema} (account:string boost-class-id:string)
        @doc "Reads user-boost aggregate row (with-default-read when absent)."
        (with-default-read ANK|T|UserBoost (UCk_UserBoost account boost-class-id)
            (UDC_UserBoost 0.0 account boost-class-id)
            {"aggregate-promile"   := ap
            ,"ouronet-account"     := oa
            ,"boost-class-id"      := bcid}
            (UDC_UserBoost ap oa bcid)
        )
    )
    (defun UR_UB|AggregatePromile:decimal (account:string boost-class-id:string)
        @doc "Reads aggregate promile for user in a BoostClass."
        (at "aggregate-promile" (UR_UB|Data account boost-class-id))
    )
    ;;
    (defun URC_TrueFungibleAnchorPromile:decimal 
        (anchor-id:string total-dptf-amount:decimal)
        @doc "Promile from staked DPTF vs anchor reference amount, times anchor promile. \
            \ Reads anchor row via UR_*; if reference amount is non-positive, yields 0.0 (no enforce — use UEV on issue paths)."
        (let
            (
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dptf-amount:decimal (UR_ANK|TFAmount anchor-id))
            )
            (if (<= dptf-amount 0.0)
                0.0
                (floor (* (/ total-dptf-amount dptf-amount) ank-promile) ank-precision)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Computes SF anchor promile from nonce equality model."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-nonces:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_NonFungibleAnchorPromile:decimal
        (account:string anchor-id:string nonces:[integer] direction:bool)
        @doc "Computes NF anchor promile using trait mode or nonce-class mode."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (current-promile:decimal (UR_ANK-U|Promile account anchor-id))
                ;;
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
                (computed-promile-to-consider:decimal (* (dec conform-nonces) ank-promile))
            )
            (if direction
                (+ current-promile computed-promile-to-consider)
                (- current-promile computed-promile-to-consider)
            )
        )
    )
    (defun URC_SemiFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Absolute SF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ref-U|LST:module{StringProcessorV2} U|LST)
                ;;
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpfs-nonce:integer (UR_ANK|SFNonce anchor-id))
                (anchor-nonce-position:[integer] (ref-U|LST::UC_Search nonces dpfs-nonce))
                (l:integer (length anchor-nonce-position))
                (conform-amount:integer
                    (if (= l 0)
                        0
                        (at (at 0 anchor-nonce-position) nonce-amounts)
                    )
                )
            )
            (floor (* (dec conform-amount) ank-promile) ank-precision)
        )
    )
    (defun URC_NonFungibleAnchorPromileAbsolute:decimal
        (anchor-id:string nonces:[integer])
        @doc "Absolute NF promile from full cross-pool nonce inventory (C_SyncCollectableAnchors resync)."
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-promile:decimal (UR_ANK|Promile anchor-id))
                (ank-precision:integer (floor (UR_ANK|Precision anchor-id)))
                (dpnf-trait-key:string (UR_ANK|NFTraitKey anchor-id))
                (dpnf-trait-value:string (UR_ANK|NFTraitValue anchor-id))
                (trait-mode:bool (URC_TraitOrClass anchor-id))
                (conform-nonces:integer
                    (if trait-mode
                        (URC_ConformNonces ank-asset nonces dpnf-trait-key dpnf-trait-value)
                        (URC_ConformNoncesByClass ank-asset nonces (UR_ANK|NFNonceClass anchor-id))
                    )
                )
            )
            (floor (* (dec conform-nonces) ank-promile) ank-precision)
        )
    )
    (defun URC_TraitOrClass:bool (anchor-id:string)
        @doc "Returns true for trait-mode; false for nonce-class mode."
        (fold (and) true
            [
                (!= (UR_ANK|NFTraitKey anchor-id) BAR)
                (!= (UR_ANK|NFTraitValue anchor-id) BAR)
                (= (UR_ANK|NFNonceClass anchor-id) -1)
            ]
        )
    )
    (defun URC_ConformNonces:integer (dpnf-id:string nonces:[integer] trait-key:string trait-value:string)
        @doc "Outputs how many nonces from <nonces> have the proper MetaData Trait"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (nonce-meta-data:object 
                                (ref-DPDC::UR_N|RawMetaData 
                                    (ref-DPDC::UR_NativeNonceData dpnf-id false nonce)
                                )
                            )
                            (has-trait-key:bool (contains trait-key nonce-meta-data))
                            (output:integer
                                (if (or (< nonce 0) (not has-trait-key))
                                    0
                                    (if (= trait-value (at trait-key nonce-meta-data))
                                        1
                                        0
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_ConformNoncesByClass:integer (dpnf-id:string nonces:[integer] nonce-class:integer)
        @doc "Outputs how many nonces from <nonces> conform to nonce-class mode."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (fold
                (lambda
                    (acc:integer idx:integer)
                    (let
                        (
                            (nonce:integer (at idx nonces))
                            (output:integer
                                (if (< nonce 0)
                                    0
                                    (if (= nonce-class 0)
                                        1
                                        (if (= (ref-DPDC::UR_NonceClass dpnf-id false nonce) nonce-class)
                                            1
                                            0
                                        )
                                    )
                                )
                            )
                        )
                        (+ acc output)
                    )
                )
                0
                (enumerate 0 (- (length nonces) 1))
            )
        )
    )
    (defun URC_TrueFungibleStakeAnchorRefreshIgnis:decimal (n-live:integer)
        @doc "Internal: ignis|small per live TF anchor refreshed (n_live = length UR_ANK|AnchorsForAsset). Zero when n_live ≤ 0."
        (if (<= n-live 0)
            0.0
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (unit:decimal (ref-IGNIS::UC_IgnisLeg "tier-small"))
                )
                (* (dec n-live) unit)
            )
        )
    )
    ;; --- AssetAnchors / BoostClass slot helpers (in-memory; UDC_AA|* and XI_2|Recompute*) ---
    (defun URC_BC|AnchorIdAtSlot:string (bc:object{AcquisitionSchemasV1.ANK|BoostClass} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from a BoostClass object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" bc))
            ((= idx 1) (at "anchor-secondary" bc))
            ((= idx 2) (at "anchor-tertiary" bc))
            ((= idx 3) (at "anchor-quaternary" bc))
            ((= idx 4) (at "anchor-quinary" bc))
            ((= idx 5) (at "anchor-senary" bc))
            ((= idx 6) (at "anchor-septenary" bc))
            BAR
        )
    )
    (defun URC_AA|GroupAtSlot:object{AcquisitionSchemasV1.ANK|InternalGroup} (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} idx:integer)
        @doc "URC: reads internal group at slot idx (0..6) from an AssetAnchors object (in-memory)."
        (cond
            ((= idx 0) (at "group-primary" aa))
            ((= idx 1) (at "group-secondary" aa))
            ((= idx 2) (at "group-tertiary" aa))
            ((= idx 3) (at "group-quaternary" aa))
            ((= idx 4) (at "group-quinary" aa))
            ((= idx 5) (at "group-senary" aa))
            ((= idx 6) (at "group-septenary" aa))
            (UDC_EmptyInternalGroup)
        )
    )
    (defun URC_IG|AnchorIdAtSlot:string (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} idx:integer)
        @doc "URC: reads anchor-id at slot idx (0..6) from an InternalGroup object (in-memory)."
        (cond
            ((= idx 0) (at "anchor-primary" ig))
            ((= idx 1) (at "anchor-secondary" ig))
            ((= idx 2) (at "anchor-tertiary" ig))
            ((= idx 3) (at "anchor-quaternary" ig))
            ((= idx 4) (at "anchor-quinary" ig))
            ((= idx 5) (at "anchor-senary" ig))
            ((= idx 6) (at "anchor-septenary" ig))
            BAR
        )
    )
    (defun URC_IG|ContainsAnchor:bool (ig:object{AcquisitionSchemasV1.ANK|InternalGroup} anchor-id:string)
        @doc "URC: true when InternalGroup contains anchor-id (in-memory scan of seven slots)."
        (or (= anchor-id (at "anchor-primary" ig))
        (or (= anchor-id (at "anchor-secondary" ig))
        (or (= anchor-id (at "anchor-tertiary" ig))
        (or (= anchor-id (at "anchor-quaternary" ig))
        (or (= anchor-id (at "anchor-quinary" ig))
        (or (= anchor-id (at "anchor-senary" ig))
            (= anchor-id (at "anchor-septenary" ig))))))))
    )
    (defun URC_AA|SetGroupAtSlot:object{AcquisitionSchemasV1.ANK|AssetAnchors}
        (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} grp:object{AcquisitionSchemasV1.ANK|InternalGroup} slot:integer ta:integer ga:integer adjust-ga:bool)
        @doc "URC: returns updated AssetAnchors with group replaced at slot (in-memory; used by UDC_AA|PlaceAnchor / RemoveAnchor)."
        (let
            (
                (g1:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 0) grp (at "group-primary" aa)))
                (g2:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 1) grp (at "group-secondary" aa)))
                (g3:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 2) grp (at "group-tertiary" aa)))
                (g4:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 3) grp (at "group-quaternary" aa)))
                (g5:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 4) grp (at "group-quinary" aa)))
                (g6:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 5) grp (at "group-senary" aa)))
                (g7:object{AcquisitionSchemasV1.ANK|InternalGroup} (if (= slot 6) grp (at "group-septenary" aa)))
                (new-ta:integer ta)
                (new-ga:integer
                    (if adjust-ga
                        (if (= (at "anchors" grp) 0)
                            (- ga 1)
                            (+ ga 1)
                        )
                        ga
                    )
                )
            )
            {"group-primary"    : g1
            ,"group-secondary"  : g2
            ,"group-tertiary"   : g3
            ,"group-quaternary" : g4
            ,"group-quinary"    : g5
            ,"group-senary"     : g6
            ,"group-septenary"  : g7
            ,"groups-active"    : new-ga
            ,"anchors-active"   : new-ta
            ,"asset-id"         : (at "asset-id" aa)}
        )
    )
    ;; [URH] heavy-read
    (defun URH_ANK|AllAnchorIds:[string] ()
        @doc "Returns all row keys from ANK|T|Anchor."
        (keys ANK|T|Anchor)
    )
    (defun URH_BC|AllBoostClassIds:[string] ()
        @doc "Returns all row keys from ANK|T|BoostClass."
        (keys ANK|T|BoostClass)
    )
    ;; [URCi]   cost readers — single source for exec billing + INFO preview
    (defun URCi_IssueAnchor:object{IgnisCollectorV3.OutputCumulator} (op-key:string output:[string])
        @doc "IGNIS cost for the 4 anchor-issue ops: a FLAT 500 deterrence for every anchor type \
            \ plus that op's own component cost (owner 2026-09-06). This supersedes the \
            \ 2026-09-05 rule of half the anchored asset's issuance price, which is why the \
            \ caller now passes its TALOS OP KEY (AQP-ANK|C_Issue…Anchor) rather than a deter \
            \ tier — the tier is the same for all four. <output> carries \
            \ anchor-id[+boost-class-id]. Shared by exec and the INFO_* previews."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice op-key "anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) output)
        ))
    (defun URCi_IssueAnchorStoa:decimal (acnoi:bool)
        @doc "STOA cost for anchor-issue: the deterrence expressed in DOLLARS, converted at the live \
            \ STOA price by UC_StoaPrice (anchor = $5 => 50 STOA). Previously read the raw \
            \ 'standard' usage price (0.01), a pre-rehaul STOA amount that was never \
            \ dollar-denominated and so ignored the peg entirely. Doubled when <acnoi>."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (* (ref-IGNIS::UC_StoaPrice "anchor") (if acnoi 2.0 1.0))
        ))
    (defun URCi_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeAnchor — owner-priced 100 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeAnchor" "revoke-anchor") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URCi_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator} ()
        @doc "IGNIS cost for C_RevokeBoostClass — owner-priced 500 deterrence + its component cost, via the central IG|DETER/IG|COMPONENTS \
            \ map. Shared by exec and the INFO_* preview."
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator (ref-IGNIS::UC_IgnisPrice "AQP-ANK|C_RevokeBoostClass" "revoke-boost") AQP|SC_NAME (ref-IGNIS::URC_IsVirtualGasZero) [])
        ))
    (defun URC_AnchorableAssetOwner:string (ank-asset:string asset-fungibility:[bool])
        @doc "The OWNER konto of an anchorable asset -- the account an anchor issuance must name as \
            \ its executor. For a DPTF this resolves F|/R| to the core token first; for a collectable \
            \ it is the owner (the CREATOR is also an authority -- see UEV_ExecutorIzAssetAuthority -- \
            \ but only one of the two can be 'the' owner, and this reader answers that). \
            \ Exists because the answer is frequently NOT the obvious account: sovereign assets such \
            \ as OURO are owned by a SMART account, and the human admin merely holds its key. Before \
            \ the executor was named, that distinction was invisible at every call site."
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (if (= asset-fungibility [true true])
                (URCv_AnchorableDptfAuthority ank-asset)
                (ref-DPDC::UR_OwnerKonto ank-asset (= asset-fungibility [false true]))
            )
        )
    )
    (defun URCv_CoreDptf:string (dptf-id:string)
        @doc "The CORE DPTF behind an anchored DPTF id: an `F|` frozen or `R|` reserved token \
            \ resolves to its parent, anything else is already core. Extracted from CAP_TF|Owner \
            \ (2026-09-20) so the executor check and the ownership gate read the SAME rule -- two \
            \ copies of a resolution that must agree is the failure class this refactor's own \
            \ tooling was built to prevent."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (first-two:string (take 2 dptf-id))
            )
            (cond
                ((= first-two "F|") (ref-DPTF::UR_Frozen dptf-id))
                ((= first-two "R|") (ref-DPTF::UR_Reservation dptf-id))
                dptf-id
            )
        )
    )
    (defun URCv_AnchorableDptfAuthority:string (dptf-id:string)
        @doc "The ACCOUNT that may anchor <dptf-id>. ONE rule, read by all THREE places that \
            \ need it -- URC_AnchorableAssetOwner (the reader), CAP_TF|Owner (the ownership \
            \ gate) and UEV_ExecutorIzAssetAuthority (the executor check). Three copies of a \
            \ resolution that must agree is the failure class URCv_CoreDptf was extracted to \
            \ prevent; this extends the same discipline to the liquidity-pool case. \
            \ \
            \ FOUR SHAPES: \
            \   pure DPTF        -> its own owner \
            \   F| / R| special  -> its PARENT's owner (URCv_CoreDptf follows the link) \
            \   native LP        -> the POOL OWNER of the swpair behind it \
            \   F| frozen LP     -> the same pool owner, through the same two steps \
            \ \
            \ WHY THE LP BRANCH EXISTS (2026-10-03). It did not, and the asymmetry it left was \
            \ indefensible: a frozen special resolved to its parent and was ACCEPTED, so a \
            \ frozen LP resolved to the native LP -- owned by SWP|SC_NAME, a smart account \
            \ nobody can sign for -- and was REFUSED. Same rule, opposite outcome, for no \
            \ reason a user could see. A pool owner could not anchor their own pool's LP token. \
            \ \
            \ The pool owner is the right answer and the system already said so elsewhere: \
            \ 15_SWP's XE_EnableFrozenLP records that SWP's executor is the POOL owner \
            \ (UR_OwnerKonto swpair), as distinct from the LP TOKEN's owner, which is a smart \
            \ account. Anchoring now draws the same distinction every other LP operation does."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                ;;
                ;;Specials first. An `F|`/`R|` id resolves through the back-link that
                ;;XE_UpdateSpecialTrueFungible writes in BOTH directions. A frozen LP lands here
                ;;too -- C_EnableFrozenLP creates it through VST::C_CreateFrozenLink, the same
                ;;path -- so past this line a frozen LP is indistinguishable from a native one.
                (core:string (URCv_CoreDptf dptf-id))
            )
            (if (contains (take 2 core) CT_ANK_LP_PREFIXES)
                (ref-SWP::UR_OwnerKonto (ref-SWP::UR_GetLpSwpair core))
                (ref-DPTF::UR_Konto core)
            )
        )
    )
    ;;{5.4}  Validate [UEV/CAP]
    ;; [UEV] enforce
    (defun UEV_AnkFungibility (asset-fungibility:[bool])
        @doc "Validates asset-fungibility tuple (TF/SF/NF discriminator) for anchor-class / asset-summary tables."
        (let
            (
                (l:integer (length asset-fungibility))
            )
            (enforce (and (= l 2) (!= asset-fungibility [true false])) "Invalid Fungibility")
        )
    )
    (defun UEV_Promile (anchor-precision:integer anchor-promile:decimal)
        @doc "M6 #15: anchor precision is exactly CT_ANK_PRECISION (3); anchor-promile is conform to that precision \
            \ and within [CT_ANK_MIN_PROMILE, CT_ANK_MAX_PROMILE] = [1, 10000] (caps a single anchor's boost)."
        (enforce
            (fold (and) true
                [
                    (= anchor-precision CT_ANK_PRECISION)                             ;;<anchor-precision> must be exactly 3
                    (= (floor anchor-promile CT_ANK_PRECISION) anchor-promile)        ;;<anchor-promile> conform to precision 3
                    (>= anchor-promile CT_ANK_MIN_PROMILE)                            ;;<anchor-promile> must be >= 1.0
                    (<= anchor-promile CT_ANK_MAX_PROMILE)                            ;;<anchor-promile> must be <= 10000.0
                ]
            )
            "Invalid Promile Variables: precision must be 3 and promile within [1, 10000]"
        )
    )
    (defun UEV_IssueAnchor (ank-asset:string boost-class-id:string)
        @doc "Validates BoostClass exists, is active, has a free slot, and IS OWNED BY THE CALLER; also \
            \ validates asset 49-anchor cap. Used when acnoi=false (attaching to an EXISTING class)."
        ;;OWNERSHIP ADDED 2026-09-19. Issuing an anchor is gated on CAP_OwnerOrCreator of the
        ;;ANCHORED ASSET -- but on this path that is the caller's OWN asset, which gates nothing
        ;;about the class being joined. A BoostClass had no owner at all, so anyone holding any
        ;;anchorable asset could attach it to someone else's class and hand their holders a boost
        ;;inside that vault's scoring; a 7-slot class with one anchor used offered six such grants.
        ;;Enforced via account ownership rather than a passed patron so no defcap signature moves:
        ;;CAP_EnforceAccountOwnership checks the transaction is signed by that account's guard.
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership (at "class-owner" bc))
            (enforce (at "class-active" bc) (format "{} BoostClass {} must be active" [E-ANK boost-class-id]))
            (enforce (< (at "anchors" bc) 7) (format "{} BoostClass {} full (7 anchors)" [E-ANK boost-class-id]))
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_ExecutorNotCustodial (executor:string)
        @doc "Refuses the three smart accounts that hold tokens as CUSTODY, never as management. \
            \ \
            \   SWP|SC_NAME  owns every liquidity-pool token \
            \   VST|SC_NAME  owns every frozen and reserved special token \
            \   ATS|SC_NAME  owns the hot-RBTs \
            \ \
            \ OWNER RULING, 2026-10-04: those three own tokens as a PROTOCOL FUNCTION, and that \
            \ must never become a route to managing them. Management flows through the parent -- \
            \ an LP through its POOL OWNER, a special through the owner of the token it was \
            \ derived from -- which is exactly what `URCv_AnchorableDptfAuthority` resolves. \
            \ \
            \ THIS IS DEFENCE IN DEPTH, NOT THE PRIMARY GATE, and saying so matters because an \
            \ enforce that is already unreachable invites deletion. The authority resolution \
            \ ALREADY keeps these accounts out: an LP resolves to the pool owner, so SWP is not \
            \ the authority for its own LP token and `CAP_TF|Owner` refuses it. This catches the \
            \ case where that resolution is ever wrong, loosened, or outgrown by a fourth \
            \ custodial account -- and it fails with a message that NAMES custody, where the \
            \ ownership gate would only say the executor is not the authority. \
            \ \
            \ It is on the shared authority check, so it covers ISSUE and REVOKE alike: a \
            \ custodial account must not be able to revoke an anchor either."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
            )
            (enforce
                (not (contains executor
                        [(ref-DALOS::GOV|SWP|SC_NAME)
                         (ref-DALOS::GOV|VST|SC_NAME)
                         (ref-DALOS::GOV|ATS|SC_NAME)]))
                (format "{} Executor {} holds tokens as CUSTODY only; anchor management flows \
                    \ through the asset's parent -- a pool's owner, or the owner of the token a \
                    \ special was derived from" [E-ANK executor])
            )
        )
    )
    (defun UEV_ExecutorIzAssetAuthority (executor:string ank-asset:string asset-fungibility:[bool])
        @doc "Enforces that <executor> IS the anchored asset's authority, mirroring -- never replacing \
            \ -- the CAP_ gate running alongside it. The authority differs by asset kind, and that \
            \ difference is why this is one helper rather than three inline checks: a DPTF has exactly \
            \ ONE authority (URCv_AnchorableDptfAuthority: its own owner, or its parent's for an \
            \ F|/R| special, or the POOL OWNER for a liquidity-pool token), a collectable has \
            \ TWO (owner OR creator) and is therefore a DISJUNCTION, not a value. Band 1's usual \
            \ prescription -- 'enforce executor equals the derived owner' -- has no single owner to \
            \ equal in the collectable case, which is exactly why MTX-AQP's C_2|SweepRevokeAnchor \
            \ could not be done inline and waited for this."
        (UEV_ExecutorNotCustodial executor)
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (enforce
                (if (= asset-fungibility [true true])
                    (= executor (URCv_AnchorableDptfAuthority ank-asset))
                    (let
                        (
                            (son:bool (= asset-fungibility [false true]))
                        )
                        (or (= executor (ref-DPDC::UR_OwnerKonto ank-asset son))
                            (= executor (ref-DPDC::UR_CreatorKonto ank-asset son)))
                    )
                )
                (format "Executor {} is not an authority for anchored asset {}; authority is {}"
                    [executor ank-asset
                        (if (= asset-fungibility [true true])
                            [(URCv_AnchorableDptfAuthority ank-asset)]
                            (let
                                (
                                    (son:bool (= asset-fungibility [false true]))
                                )
                                [(ref-DPDC::UR_OwnerKonto ank-asset son)
                                 (ref-DPDC::UR_CreatorKonto ank-asset son)]
                            )
                        )
                    ]
                )
            )
        )
    )
    (defun UEV_ExecutorIzClassOwner (executor:string boost-class-id:string)
        @doc "Enforces that <executor> IS the BoostClass's recorded creator, AND that the \
            \ transaction is signed for that account. \
            \ \
            \ BOTH HALVES ARE NEW HERE (2026-09-22), and the second is a fix rather than an \
            \ attribution. ANK|C>REVOKE-BOOST-CLASS validated only that the class is EMPTY and \
            \ ACTIVE -- it checked no account at all -- so any account reachable through Talos \
            \ could revoke any empty BoostClass that was not theirs. Not a funds hole: a revoked \
            \ class holds no anchors by construction. It is a griefing and denial vector, and it \
            \ costs the victim real money, because re-creating the class is the 2x-STOA inline \
            \ path in C_Issue*Anchor. \
            \ \
            \ The ATTACH path already did exactly this -- UEV_AttachToExistingClass runs \
            \ (CAP_EnforceAccountOwnership (at \"class-owner\" bc)) and the schema comment beside \
            \ <class-owner> explains why it was added on 2026-09-19. The REVOKE path was not \
            \ carried over with it. Same field, same rule, one path short. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                (co:string (at "class-owner" (UR_BC|Data boost-class-id)))
            )
            (enforce (= executor co)
                (format "{} Executor {} is not BoostClass {}'s owner; owner is {}"
                    [E-ANK executor boost-class-id co]))
            (ref-DALOS::CAP_EnforceAccountOwnership co)
        )
    )
    (defun UEV_ExecutorIzAnchorAuthority (executor:string anchor-id:string)
        @doc "Anchor-level form of UEV_ExecutorIzAssetAuthority: resolves the anchored asset and its \
            \ fungibility from the anchor row, then defers. This is the shape MTX-AQP needs for \
            \ C_2|SweepRevokeAnchor, which holds an anchor-id and no asset."
        (UEV_ExecutorIzAssetAuthority executor
            (UR_ANK|AnchoredAsset anchor-id) (UR_ANK|Fungibility anchor-id))
    )
    (defun UEV_AssetAnchorCap (ank-asset:string)
        @doc "Validates asset 49-anchor cap. Used when acnoi=true (BoostClass is new)."
        (let
            (
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (enforce (< (at "anchors-active" aa) 49) (format "{} Asset {} at 49-anchor cap" [E-ANK ank-asset]))
        )
    )
    (defun UEV_LiveAnchor (anchor-id:string)
        @doc "Validates anchor exists and is active."
        (let
            (
                (iz-anchor-active:bool (UR_ANK|State anchor-id))
            )
            (enforce iz-anchor-active (format "Anchor {} must be alive for operation" [anchor-id]))
        )
    )
    ;; WU_UserBoost|AggregatePromile — not used: mutates via WW_UserBoost (full row).
    ;; WU_UserBoost|Account — select key; WU not needed.
    ;; WU_UserBoost|BoostClassId — select key; WU not needed.
    (defun CAP_Owner (anchor-id:string)
        @doc "Enforces Anchor Ownership; This is computed as: \
        \ 1] For DPTFs Computed via <CAP_TF|Owner> \
        \ 2] For DPSFs and DPNFs can be either its Owner or Creator"
        (let
            (
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (ank-fungibility:[bool] (UR_ANK|Fungibility anchor-id))
            )
            (if (= ank-fungibility [true true])
                (CAP_TF|Owner ank-asset)
                (if (= ank-fungibility [false true])
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset true)
                    (ref-DPDC::CAP_OwnerOrCreator ank-asset false)
                )
            )
        )
    )
    (defun CAP_TF|Owner (dptf-id:string)
        @doc "Enforces dptf-id Ownership, as underlying Dptf-Based Anchor Ownership. \
        \ FIVE DPTF variants can exist as underlying anchored asset, and the rule for each is \
        \ URCv_AnchorableDptfAuthority's -- this gate only enforces what that returns: \
        \ 1] Pure DPTF      = Its Owner \
        \ 2] Frozen DPTF    = DPTF Parent Ownership \
        \ 3] Reserved DPTF  = DPTF Parent Ownership \
        \ 4] LP DPTF        = The POOL OWNER of its swpair \
        \ 5] Frozen LP DPTF = The same pool owner \
        \ \
        \ CORRECTED 2026-10-03. Lines 4] and 5] read 'Cannot exist as underlaying DPTF-Based \
        \ Anchor', which was true and indefensible: an LP token is owned by SWP|SC_NAME with \
        \ can-change-owner false, so the ownership enforce could never pass and a pool owner \
        \ could not anchor their own pool's LP token. Worse, it was INCONSISTENT -- 2] accepts \
        \ a frozen token by resolving to its parent, so a frozen LP resolved to the native LP \
        \ and was then refused for being owned by a contract. Same rule, opposite outcome. \
        \ \
        \ Note 4] and 5] were never an enforce: they were a CONSEQUENCE, which is why nothing \
        \ caught the inconsistency. [6.2.1] <<TX-ANK-VAR4b>> pinned the old refusal; it now \
        \ pins the new acceptance."
        (let
            (
                (ref-DALOS:module{OuronetDalosV2} DALOS)
                ;;
                (owner:string (URCv_AnchorableDptfAuthority dptf-id))
            )
            (ref-DALOS::CAP_EnforceAccountOwnership owner)
        )
    )
    ;;{5.5}  Write [W]
    ;; [W]   write
    ;; Five blocks — one per deftable (table order). Within each block: WI → WW → WU → WU2+ (only when needed).
    ;; WU lists every schema field: defun when used; comment when [.], select key, or mutates via WW_*.
    ;;
    (defun WI_Anchor:string
        (anchor-id:string row:object{AcquisitionSchemasV1.ANK|Schema})
        @doc "Insert ANK|T|Anchor full row (issue only)."
        (require-capability (SECURE))
        (insert ANK|T|Anchor anchor-id row)
    )
    ;; WW_Anchor — not used: issue path is WI_Anchor; revoke uses WU_Anchor|State.
    ;; WU_Anchor|AnchoredAsset — not mutable [.]
    ;; WU_Anchor|Fungibility — not mutable [.]
    ;; WU_Anchor|BoostClassId — not mutable [.]
    ;; WU_Anchor|Precision — not mutable [.]
    (defun WU_Anchor|State:string
        (anchor-id:string ank-active:bool)
        @doc "Update ank-active on ANK|T|Anchor."
        (require-capability (SECURE))
        (update ANK|T|Anchor anchor-id {"ank-active": ank-active})
    )
    (defun WU_BC|AddScoreLink:string
        (boost-class-id:string score-id:string)
        @doc "Add score-id to the BoostClass reverse-index set (idempotent — no-op if already present). Upsert. \
            \ H4 reverse index + #9 revoke lock (locked while the set is non-empty)."
        (require-capability (SECURE))
        (let
            (
                (sl:[string] (UR_BC|ScoreLinks boost-class-id))
            )
            (write ANK|T|BoostClassScoreLinks boost-class-id
                {"score-links"     : (if (contains score-id sl) sl (+ sl [score-id]))
                ,"boost-class-id"  : boost-class-id})
        )
    )
    (defun WU_BC|RemoveScoreLink:string
        (boost-class-id:string score-id:string)
        @doc "Remove score-id from the BoostClass reverse-index set (a score re-pointed/unlinked its \
            \ boost-class-link AWAY — M4 #13 / sweep unlink). Upsert. Releases the class's revoke lock once empty."
        (require-capability (SECURE))
        (write ANK|T|BoostClassScoreLinks boost-class-id
            {"score-links"     : (filter (lambda (s:string) (!= s score-id)) (UR_BC|ScoreLinks boost-class-id))
            ,"boost-class-id"  : boost-class-id})
    )
    ;; WU_Anchor|Promile — not mutable [.]
    ;; WU_Anchor|TFAmount — not mutable [.]
    ;; WU_Anchor|SFNonce — not mutable [.]
    ;; WU_Anchor|NFTraitKey — not mutable [.]
    ;; WU_Anchor|NFTraitValue — not mutable [.]
    ;; WU_Anchor|NFNonceClass — not mutable [.]
    ;; WU_Anchor|ID — select key; WU not needed.
    ;;
    (defun WI_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV1.ANK|BoostClass})
        @doc "Insert ANK|T|BoostClass full row (inline issue when acnoi)."
        (require-capability (SECURE))
        (insert ANK|T|BoostClass boost-class-id row)
    )
    (defun WW_BoostClass:string
        (boost-class-id:string row:object{AcquisitionSchemasV1.ANK|BoostClass})
        @doc "Upsert full ANK|T|BoostClass row (bookkeeping add/remove anchor slots)."
        (require-capability (SECURE))
        (write ANK|T|BoostClass boost-class-id row)
    )
    ;; WU_BoostClass|Primary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Secondary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Tertiary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quaternary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Quinary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Senary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Septenary — not used: mutates via WW_BoostClass (full row).
    ;; WU_BoostClass|Anchors — not used: mutates via WW_BoostClass (full row).
    (defun WU_BoostClass|Active:string
        (boost-class-id:string class-active:bool)
        @doc "Update class-active on ANK|T|BoostClass."
        (require-capability (SECURE))
        (update ANK|T|BoostClass boost-class-id {"class-active": class-active})
    )
    ;; WU_BoostClass|ID — select key; WU not needed.
    ;;
    ;; WI_AssetAnchors — not used: first row touch is WW_AssetAnchors (upsert path).
    (defun WW_AssetAnchors:string
        (asset-id:string row:object{AcquisitionSchemasV1.ANK|AssetAnchors})
        @doc "Upsert full ANK|T|AssetAnchors row (place/remove anchor in groups)."
        (require-capability (SECURE))
        (write ANK|T|AssetAnchors asset-id row)
    )
    ;; WU_AssetAnchors|GroupPrimary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSecondary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupTertiary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuaternary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupQuinary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupSeptenary — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|GroupsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AnchorsActive — not used: mutates via WW_AssetAnchors (full row).
    ;; WU_AssetAnchors|AssetId — select key; WU not needed.
    ;;
    ;; WI_Anchors — not used: first row touch is WW_Anchors (upsert path).
    (defun WW_Anchors:string
        (account:string anchor-id:string promile:decimal)
        @doc "Upsert user promile on ANK|T|Anchors for (account, anchor-id). L6 #18: floors the stored promile at \
            \ 0 — this is the SOLE write chokepoint for per-anchor user promile (every TF/SF/NF, incremental AND \
            \ absolute, path routes here), so an incremental delta can never persist a negative. The trigger is \
            \ real and outside AQP's control (NFT metadata on a trait-anchor is mutable at the DPDC layer, even by \
            \ module admin), so AQP guards its own accounting at its boundary. The aggregate (Σ of these) is then \
            \ non-negative too; the …PromileAbsolute resync recomputes the true value. Floor, not enforce — a hard \
            \ abort would strand a staker's assets; the clamp lets unstake always succeed."
        (require-capability (SECURE))
        (write ANK|T|Anchors (UCk_Anchors account anchor-id)
            (UDC_AccountAnchor (if (< promile 0.0) 0.0 promile) account anchor-id)
        )
    )
    ;; WU_Anchors|Promile — not used: mutates via WW_Anchors (full row).
    ;; WU_Anchors|Account — select key; WU not needed.
    ;; WU_Anchors|ID — select key; WU not needed.
    ;;
    ;; WI_UserBoost — not used: first row touch is WW_UserBoost (upsert path).
    (defun WW_UserBoost:string
        (account:string boost-class-id:string aggregate-promile:decimal)
        @doc "Upsert aggregate-promile on ANK|T|UserBoost."
        (require-capability (SECURE))
        (write ANK|T|UserBoost (UCk_UserBoost account boost-class-id)
            (UDC_UserBoost aggregate-promile account boost-class-id)
        )
    )
    ;;{5.6}  Aux/X
    ;; [XI]
    ;;
    ;; Depth: C_* → XI_* (depth 0) → XI_1|* … ; XE_* / XB_* → XI_1|* (depth 1) → XI_2|* …
    ;; Blocks: map first, then functions in map order (entry → children → shared leaves).
    ;;
    ;; --- Block A · C_Issue*Anchor ---
    ;;   C_Issue*Anchor
    ;;     ├ XI_IssueBoostClass (optional)
    ;;     └ XI_IssueAnchor
    ;;          └ XI_PlaceAnchorInBookkeeping
    ;; --- Block B · C_RevokeAnchor ---
    ;;   C_RevokeAnchor → XI_RevokeAnchorBookkeeping
    ;; --- Block C · TF user promile (FVT phase 2.2 backward) ---
    ;;   XE_UpdateTrueFungibleUserAnchorValues
    ;;     └ XI_1|UpdateTrueFungibleUserAnchorValues
    ;; --- Block D · SF user promile ---
    ;;   XE_UpdateSemiFungibleUserAnchorValues
    ;;     └ XI_1|UpdateSemiFungibleUserAnchorValues
    ;; --- Block E · NF user promile ---
    ;;   XE_UpdateNonFungibleUserAnchorValues
    ;;     └ XI_1|UpdateNonFungibleUserAnchorValues
    ;; --- Block F · shared leaf ---
    ;;   XI_2|RecomputeAffectedBoostAggregates (TF / SF / NF / resync)
    ;;
    ;;Protection: Class 1 — Innate protection offered by WI_BoostClass
    (defun XI_IssueBoostClass:string
        (boost-class-name:string class-owner:string)
        @doc "Internal (C_Issue*Anchor · depth 0]): create BoostClass inline when acnoi; returns boost-class-id. \
            \ `class-owner` is recorded so only the creator may later attach anchors (2026-09-19)."
        ;; SECURE: granted by WI_BoostClass (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (boost-class-id:string (ref-U|DALOS::UDC_Makeid boost-class-name))
            )
            (WI_BoostClass boost-class-id
                (UDC_BoostClass BAR BAR BAR BAR BAR BAR BAR 0 true boost-class-id class-owner)
            )
            boost-class-id
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WI_Anchor
    (defun XI_IssueAnchor:string
        (
            ank-name:string ank-asset:string ank-fungibility:[bool] boost-class-id:string ank-precision:integer ank-promile:decimal
            dptf-amount:decimal dpsf-nonce:integer dpnf-trait-key:string dpnf-trait-value:string dpnf-nonce-class:integer
        )
        @doc "Internal (C_Issue*Anchor · depth 0]): insert ANK|T|Anchor row; returns anchor-id."
        ;; SECURE: granted by WI_Anchor (underlying W_).
        (let
            (
                (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
                ;;
                (anchor-id:string (ref-U|DALOS::UDC_Makeid ank-name))
            )
            (WI_Anchor anchor-id
                (UDC_ANK|Schema
                    ank-asset ank-fungibility boost-class-id ank-precision true ank-promile
                    dptf-amount dpsf-nonce dpnf-trait-key dpnf-trait-value dpnf-nonce-class anchor-id
                )
            )
            anchor-id
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_BoostClass, WW_AssetAnchors
    (defun XI_PlaceAnchorInBookkeeping (anchor-id:string asset-id:string boost-class-id:string)
        @doc "Internal (C_Issue*Anchor · depth 1]): place anchor in BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data asset-id))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithAddedAnchor bc anchor-id))
            (WW_AssetAnchors asset-id (UDC_AA|PlaceAnchor aa anchor-id))
        )
    )
    ;;
    ;; --- Block B · C_RevokeAnchor ---
    ;;Protection: Class 1 — Innate protection offered by C_RevokeAnchor, WW_BoostClass,
    ;;Protection:          WW_AssetAnchors
    (defun XI_RevokeAnchorBookkeeping (anchor-id:string)
        @doc "Internal (C_RevokeAnchor · depth 0]): remove anchor from BoostClass + AssetAnchors bookkeeping."
        ;; SECURE: granted by WW_BoostClass and WW_AssetAnchors (underlying W_).
        (let
            (
                (ank-asset:string (UR_ANK|AnchoredAsset anchor-id))
                (boost-class-id:string (UR_ANK|BoostClassId anchor-id))
                (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data boost-class-id))
                (aa:object{AcquisitionSchemasV1.ANK|AssetAnchors} (UR_AA|Data ank-asset))
            )
            (WW_BoostClass boost-class-id (UDC_BC|WithRemovedAnchor bc anchor-id))
            (WW_AssetAnchors ank-asset (UDC_AA|RemoveAnchor aa anchor-id))
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateTrueFungibleUserAnchorValues
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Internal (XE_Update*TF · depth 1]): rewrite user promile for each live TF anchor on dptf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPTF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_TrueFungibleAnchorPromile aid total-dptf-amount))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Internal (XE_Update*SF · depth 1]): rewrite user promile for each live SF anchor on dpsf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPSF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_SemiFungibleAnchorPromile account aid nonces nonce-amounts direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Internal (XE_Update*NF · depth 1]): rewrite user promile for each live NF anchor on dpnf-id, then XI_2|RecomputeAffectedBoostAggregates."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            ;; map: live anchors on this DPNF asset (write user promile; collect boost-class-id)
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal (URC_NonFungibleAnchorPromile account aid nonces direction))
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|ResyncSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Internal (XE_ResyncSemiFungible* · depth 1]): absolute promile per live SF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_SemiFungibleAnchorPromileAbsolute aid nonces nonce-amounts)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;Protection: Class 1 — Innate protection offered by WW_Anchors
    (defun XI_1|ResyncNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer])
        @doc "Internal (XE_ResyncNonFungible* · depth 1]): absolute promile per live NF anchor from rollup nonce inventory."
        ;; SECURE: granted by WW_Anchors (map) and XI_2|RecomputeAffectedBoostAggregates (WW_UserBoost).
        (let
            (
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
            )
            (if (= (length aids) 0)
                true
                (let
                    (
                        (affected-bcs:[string]
                            (map
                                (lambda (aid:string)
                                    (let
                                        (
                                            (new-promile:decimal
                                                (URC_NonFungibleAnchorPromileAbsolute aid nonces)
                                            )
                                        )
                                        (WW_Anchors account aid new-promile)
                                        (UR_ANK|BoostClassId aid)
                                    )
                                )
                                aids
                            )
                        )
                    )
                    (XI_2|RecomputeAffectedBoostAggregates account (distinct affected-bcs))
                )
            )
        )
    )
    ;;
    ;; --- Block F · shared leaf ---
    ;;Protection: Class 1 — Innate protection offered by WW_UserBoost
    (defun XI_2|RecomputeAffectedBoostAggregates (account:string boost-class-ids:[string])
        @doc "Internal (user promile update · depth 2 · shared leaf]): recompute ANK|T|UserBoost aggregate-promile per boost-class-id."
        ;; SECURE: granted by WW_UserBoost (underlying W_).
        ;; map: distinct boost-class-ids touched by anchor promile refresh
        (map
            (lambda (bcid:string)
                (let
                    (
                        (bc:object{AcquisitionSchemasV1.ANK|BoostClass} (UR_BC|Data bcid))
                        (n:integer (at "anchors" bc))
                    )
                    (if (<= n 0)
                        ;; class has NO anchors left ⇒ aggregate-promile is 0. Must WRITE it (not skip) — the sweep
                        ;; can remove the LAST anchor from a class, and a skipped write would leave a stale nonzero
                        ;; aggregate (surfaced by the re-score sweep proof). Normal stake/unstake never hits n<=0.
                        (WW_UserBoost account bcid 0.0)
                        (let
                            (
                                (agg:decimal
                                    ;; fold: anchor slots 0..n-1 in this BoostClass (sum user promile)
                                    (fold
                                        (lambda (acc:decimal idx:integer)
                                            (let
                                                (
                                                    (aid:string (URC_BC|AnchorIdAtSlot bc idx))
                                                )
                                                (if (= aid BAR)
                                                    acc
                                                    (+ acc (UR_ANK-U|Promile account aid))
                                                )
                                            )
                                        )
                                        0.0
                                        (enumerate 0 (- n 1))
                                    )
                                )
                            )
                            (WW_UserBoost account bcid agg)
                        )
                    )
                )
            )
            boost-class-ids
        )
    )
    ;; [XE]
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|XE>SWEEP-REVOKE
    (defun XE_SweepRevokeAnchor:string
        (anchor-id:string)
        @doc "Forward (re-score sweep terminal · MTX-AQP): revoke an EMPLOYED anchor after the sweep has refreshed \
            \ every affected holder — set state false + remove it from its BoostClass/AssetAnchors, SKIPPING the #9 \
            \ score-link lock (which C_RevokeAnchor enforces for UNemployed anchors). The reverse-index set is \
            \ UNCHANGED: scores keep employing the class (via its other anchors, or an emptied class contributing \
            \ 0 boost). No IGNIS (the sweep defpact bills). P|UEV_IMC + ANK|XE>SWEEP-REVOKE (liveness + owner + SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|XE>SWEEP-REVOKE anchor-id)
            (WU_Anchor|State anchor-id false)
            (XI_RevokeAnchorBookkeeping anchor-id)
        )
        anchor-id
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>BUMP-BOOST-CLASS-LINKS
    (defun XE_BumpBoostClassScoreLinks:string
        (boost-class-id:string score-id:string)
        @doc "Forward (AQP-SCORE::XI_CreateBoostClassLink): register score-id in the BoostClass reverse-index set, \
            \ locking revoke of any anchor in this class while the set is non-empty (H4 #9 lock + the sweep's \
            \ enumerable index). Idempotent. P|UEV_IMC + ANK|C>BUMP-BOOST-CLASS-LINKS (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|C>BUMP-BOOST-CLASS-LINKS boost-class-id)
            (WU_BC|AddScoreLink boost-class-id score-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>BUMP-BOOST-CLASS-LINKS
    (defun XE_UnbumpBoostClassScoreLinks:string
        (boost-class-id:string score-id:string)
        @doc "Forward (AQP-SCORE::XI_CreateBoostClassLink re-point/unlink): remove score-id from the BoostClass \
            \ reverse-index set (M4 #13 / sweep unlink). Releases the class's revoke lock once the set empties. \
            \ P|UEV_IMC + ANK|C>BUMP-BOOST-CLASS-LINKS (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|C>BUMP-BOOST-CLASS-LINKS boost-class-id)
            (WU_BC|RemoveScoreLink boost-class-id score-id)
        )
    )
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|XE>SWEEP
    (defun XE_RecomputeUserBoostAggregates:string
        (account:string boost-class-ids:[string])
        @doc "Forward (re-score sweep): refold this user's aggregate-promile for the given boost-classes from the \
            \ anchors CURRENTLY in each class. After a sweep removes (or re-prices) an anchor GLOBALLY, this \
            \ re-derives each holder's stored aggregate-promile so it no longer reflects the retired anchor — the \
            \ DEEPER recompute (the deb refresh alone assumes the aggregate is correct). NO fund movement; the \
            \ sweep defpact bills IGNIS. P|UEV_IMC + ANK|XE>SWEEP (composes SECURE)."
        (P|UEV_IMC)
        (with-capability (ANK|XE>SWEEP)
            (XI_2|RecomputeAffectedBoostAggregates account boost-class-ids)
            (format "ANK sweep: refolded {} boost aggregate(s) for {}" [(length boost-class-ids) account])
        )
    )
    ;;
    ;; --- Block C · TF user promile ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_UpdateTrueFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dptf-id:string total-dptf-amount:decimal)
        @doc "Backward (FVT::XI_RefreshTrueFungibleStakeAnchors / C_Sync*): P|UEV_IMC + XI_1|UpdateTrueFungibleUserAnchorValues \
            \ when n_live > 0; IGNIS = ignis|small × n_live (live anchors on dptf-id). \
            \ IGNIS interactor = AQP|SC_NAME (pool vault receiver)."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dptf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPTF account dptf-id total-dptf-amount)
                    (XI_1|UpdateTrueFungibleUserAnchorValues account dptf-id total-dptf-amount)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dptf-id]
            )
        )
    )
    ;;
    ;; --- Block D · SF user promile ---
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>UPDATE-DPSF
    (defun XE_UpdateSemiFungibleUserAnchorValues
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer] direction:bool)
        @doc "Updates user promile for each live SF anchor on dpsf-id, then recomputes affected BoostClass aggregates."
        (P|UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
            (XI_1|UpdateSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts direction)
        )
    )
    ;;
    ;; --- Block E · NF user promile ---
    ;;Protection: Class 5 — IMC is the gate; also acquires (validation, not protection):
    ;;Protection:          ANK|C>UPDATE-DPNF
    (defun XE_UpdateNonFungibleUserAnchorValues
        (account:string dpnf-id:string nonces:[integer] direction:bool)
        @doc "Updates user promile for each live NF anchor on dpnf-id, then recomputes affected BoostClass aggregates."
        (P|UEV_IMC)
        (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
            (XI_1|UpdateNonFungibleUserAnchorValues account dpnf-id nonces direction)
        )
    )
    ;;
    ;; --- Block D′ · SF resync (C_SyncCollectableAnchors · son=true) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ResyncSemiFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpsf-id:string nonces:[integer] nonce-amounts:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite SF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpsf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPSF account dpsf-id nonces)
                    (XI_1|ResyncSemiFungibleUserAnchorValues account dpsf-id nonces nonce-amounts)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpsf-id]
            )
        )
    )
    ;;
    ;; --- Block E′ · NF resync (C_SyncCollectableAnchors · son=false) ---
    ;;Protection: Class 4 — IMC (P|UEV_IMC, which composes SECURE)
    (defun XE_ResyncNonFungibleUserAnchorValues:object{IgnisCollectorV3.OutputCumulator}
        (account:string dpnf-id:string nonces:[integer])
        @doc "Backward (AQP::C_SyncCollectableAnchors): rewrite NF promile from full rollup inventory; IGNIS per live anchor."
        (P|UEV_IMC)
        (let
            (
                (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                ;;
                (aids:[string] (UR_ANK|AnchorsForAsset dpnf-id))
                (n-live:integer (length aids))
                (trigger:bool (ref-IGNIS::URC_IsVirtualGasZero))
            )
            (if (> n-live 0)
                (with-capability (ANK|C>UPDATE-DPNF account dpnf-id nonces)
                    (XI_1|ResyncNonFungibleUserAnchorValues account dpnf-id nonces)
                )
                true
            )
            (ref-IGNIS::UDC_ConstructOutputCumulator
                (URC_TrueFungibleStakeAnchorRefreshIgnis n-live)
                AQP|SC_NAME
                trigger
                [account dpnf-id]
            )
        )
    )
    ;;{5.7}  User [A/C]
    ;;
    ;; [C]   client
    ;;
    (defun C_RevokeBoostClass:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string boost-class-id:string)
        @doc "Revokes an empty BoostClass. \
            \ \
            \ Executor: ENFORCED DIRECTLY, and THE ENFORCE IS NEW. See \
            \ UEV_ExecutorIzClassOwner: this entrypoint checked no account whatsoever, so any \
            \ account reachable through Talos could revoke any empty BoostClass. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (UEV_ExecutorIzClassOwner executor boost-class-id)
        (with-capability (ANK|C>REVOKE-BOOST-CLASS boost-class-id)
            (WU_BoostClass|Active boost-class-id false)
            (URCi_RevokeBoostClass)
        )
    )
    (defun C_IssueTrueFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dptf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dptf-amount:decimal)
        @doc "Issues a DPTF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPTF executor anchor-name dptf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dptf-amount)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [true true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dptf-id fungibility boost-class-id anchor-precision anchor-promile
                            dptf-amount 0 BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dptf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueTrueFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueSemiFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpsf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpsf-nonce:integer)
        @doc "Issues a DPSF anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPSF executor anchor-name dpsf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpsf-nonce)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false true])
                    (anchor-id:string
                        (XI_IssueAnchor 
                            anchor-name dpsf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 dpsf-nonce BAR BAR -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpsf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueSemiFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueNonFungibleAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-trait-key:string dpnf-trait-value:string)
        @doc "Issues a DPNF trait-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-trait-key dpnf-trait-value)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 dpnf-trait-key dpnf-trait-value -1
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_IssueNonFungibleSetAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-name:string dpnf-id:string acnoi:bool boost-class-name-or-id:string anchor-precision:integer anchor-promile:decimal dpnf-nonce-class:integer)
        @doc "Issues a DPNF set-anchor. When acnoi=true creates a new BoostClass inline (2x STOA); when false links to existing (1x STOA). \
            \ IGNIS output list: [anchor-id] or [anchor-id boost-class-id] when acnoi."
        (P|UEV_IMC)
        (with-capability (ANK|C>ISSUE-DPNF-SET executor anchor-name dpnf-id acnoi boost-class-name-or-id anchor-precision anchor-promile dpnf-nonce-class)
            (let
                (
                    (ref-IGNIS:module{IgnisCollectorV3} IGNIS)
                    ;;
                    (boost-class-id:string (if acnoi (XI_IssueBoostClass boost-class-name-or-id executor) boost-class-name-or-id))
                    (fungibility:[bool] [false false])
                    (anchor-id:string
                        (XI_IssueAnchor
                            anchor-name dpnf-id fungibility boost-class-id anchor-precision anchor-promile
                            0.0 0 BAR BAR dpnf-nonce-class
                        )
                    )
                )
                (XI_PlaceAnchorInBookkeeping anchor-id dpnf-id boost-class-id)
                (ref-IGNIS::XE_CollectStoa patron (URCi_IssueAnchorStoa acnoi))
                (URCi_IssueAnchor "AQP-ANK|C_IssueNonFungibleSetAnchor" (if acnoi [anchor-id boost-class-id] [anchor-id]))
            )
        )
    )
    (defun C_RevokeAnchor:object{IgnisCollectorV3.OutputCumulator}
        (patron:string executor:string anchor-id:string)
        @doc "Revokes an anchor and updates BoostClass and AssetAnchors bookkeeping. \
            \ \
            \ Executor: PROVEN INDIRECTLY, and named. ANK|C>REVOKE runs (CAP_Owner anchor-id), \
            \ which resolves the ANCHORED ASSET's authority and enforces on it -- a DERIVED \
            \ account naming no actor, HANDOFF 4g. UEV_ExecutorIzAnchorAuthority supplies the \
            \ other half. That helper already existed, written for MTX-AQP's \
            \ C_2|SweepRevokeAnchor, and it is a DISJUNCTION rather than an equality because a \
            \ collectable has two authorities (owner OR creator) where a DPTF has one. \
            \ (patron/executor canon 2.2, 2026-09-22.)"
        (P|UEV_IMC)
        (with-capability (ANK|C>REVOKE executor anchor-id)
            (WU_Anchor|State anchor-id false)
            (XI_RevokeAnchorBookkeeping anchor-id)
            (URCi_RevokeAnchor)
        )
    )

)



;;

;; ---- source: 2_CITIZEN/Stage_Z/AppReads/OuronetUI/13_O-UI-THIRTEEN.pact (module only -- its interface is already live)
(module O-UI-THIRTEEN GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiThirteenV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-THIRTEEN          (keyset-ref-guard (GOV|Demiurgoi)))
    ;;The two SPECIAL true-fungible prefixes, mirroring `URCv_CoreDptf`'s own `cond`. Named here
    ;;because the special link is SYMMETRIC -- `UR_Frozen` answers the parent when handed a
    ;;special -- so "is this already a special" is the test that stops a link walk going
    ;;backwards. It is not a copy of `CT_ANK_LP_PREFIXES`; those are a different set for a
    ;;different question.
    (defconst CT_13_SPECIAL_PREFIXES:[string]   ["F|" "R|"])
    (defcap GOV ()                          (compose-capability (GOV|O_UI_THIRTEEN_ADMIN)))
    (defcap GOV|O_UI_THIRTEEN_ADMIN ()      (enforce-guard GOV|MD_O-UI-THIRTEEN))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{5}  FUNCTIONS
    ;;{5.3}  Read [UR/URC/URH]

    (defun URC_13|AnchorKind:string (asset-fungibility:[bool])
        @doc "The anchored asset's kind, as one word, from the [bool] discriminator AQP-ANK \
            \ stores. Slot 0 is `is a true fungible`; slot 1 is the collectable `son`. \
            \ \
            \ Returned as a STRING rather than the raw tuple because every consumer -- the \
            \ row \
            \ renderer, the name lookup, the staleness reader, the repair button -- \
            \ dispatches \
            \ on it, and a two-element [bool] is the kind of value each of them would \
            \ decode \
            \ slightly differently."
        (if (at 0 asset-fungibility)
            "dptf"
            (if (at 1 asset-fungibility) "dpsf" "dpnf")
        )
    )

    (defun URC_13|AssetName:object (asset-id:string asset-fungibility:[bool])
        @doc "Name and ticker of an anchored asset, from whichever module owns it: DPTF \
            \ true fungible, DPDC for a collectable. \
            \ \
            \ An anchor row is useless without this: `SBN-SUVEHxb9UQ6_` tells a user \
            \ nothing \
            \ and `DemiBunnies` tells them everything."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPDC:module{DpdcV2} DPDC)
                ;;
                (kind:string (URC_13|AnchorKind asset-fungibility))
            )
            (if (= kind "dptf")
                {"name"   : (ref-DPTF::UR_Name asset-id)
                ,"ticker" : (ref-DPTF::UR_Ticker asset-id)}
                (let
                    (
                        (son:bool (= kind "dpsf"))
                    )
                    {"name"   : (ref-DPDC::UR_Name asset-id son)
                    ,"ticker" : (ref-DPDC::UR_Ticker asset-id son)}
                )
            )
        )
    )

    (defun URC_13|AnchorTerms:string (anchor-id:string)
        @doc "The anchor's terms, rendered: what you must have staked to earn its \
            \ \
            \ Four shapes, one per issuance entrypoint, and only ONE of the four stored \
            \ fields \
            \ is meaningful for any given anchor; the rest hold their unset sentinels \
            \ (0.0, 0, \
            \ BAR, -1). Rendering it here rather than in the client is what stops four UIs \
            \ deciding independently which field to believe."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (kind:string (URC_13|AnchorKind (ref-ANK::UR_ANK|Fungibility anchor-id)))
            )
            (if (= kind "dptf")
                (format "{} staked per unit" [(ref-ANK::UR_ANK|TFAmount anchor-id)])
                (if (= kind "dpsf")
                    (format "nonce {} - 1 per unit" [(ref-ANK::UR_ANK|SFNonce anchor-id)])
                    ;;DPNF splits again: a SET anchor carries a nonce-class and no trait, a
                    ;;TRAIT anchor the reverse. AQP-ANK has a purpose-built discriminator --
                    ;;URC_TraitOrClass -- which checks all THREE conditions (both trait fields
                    ;;non-BAR *and* nonce-class = -1). An earlier version derived it from the
                    ;;nonce class alone: it agrees on every anchor the four entrypoints issue,
                    ;;and would diverge on a row written any other way.
                    (if (ref-ANK::URC_TraitOrClass anchor-id)
                        (format "trait {} = {}"
                            [(ref-ANK::UR_ANK|NFTraitKey anchor-id)
                             (ref-ANK::UR_ANK|NFTraitValue anchor-id)])
                        (format "set class {}" [(ref-ANK::UR_ANK|NFNonceClass anchor-id)])
                    )
                )
            )
        )
    )

    (defun URC_13|AnchorRow:object (anchor-id:string)
        @doc "One anchor, every field a list row needs, with the asset named and the terms \
            \ rendered. The unit both the catalogue and the account view are built from -- \
            \ so \
            \ the two cannot drift in what a row means."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (asset:string (ref-ANK::UR_ANK|AnchoredAsset anchor-id))
                (fung:[bool] (ref-ANK::UR_ANK|Fungibility anchor-id))
            )
            (let
                (
                    (named:object (URC_13|AssetName asset fung))
                )
                {"anchor-id"        : anchor-id
                ,"asset-id"         : asset
                ,"asset-name"       : (at "name" named)
                ,"asset-ticker"     : (at "ticker" named)
                ,"asset-kind"       : (URC_13|AnchorKind fung)
                ,"boost-class-id"   : (ref-ANK::UR_ANK|BoostClassId anchor-id)
                ,"promille"         : (ref-ANK::UR_ANK|Promile anchor-id)
                ,"precision"        : (ref-ANK::UR_ANK|Precision anchor-id)
                ,"active"           : (ref-ANK::UR_ANK|State anchor-id)
                ,"terms"            : (URC_13|AnchorTerms anchor-id)}
            )
        )
    )

    (defun URC_13|NeedsSync:bool (account:string asset-id:string asset-kind:string)
        @doc "Is this account's anchor value on <asset-id> out of date? \
            \ \
            \ Three readers, one per asset kind, because AQP keeps a separate sync counter \
            \ per kind. Extracted from URC_13|AnchorDetail rather than nested inline: a \
            \ three-way ternary at that depth put the arms at column 46, where the only way \
            \ to see which reader an arm called was to count parentheses."
        (let
            (
                (ref-AQP:module{AcquisitionPoolsV1} AQP-POOL)
            )
            (if (= asset-kind "dptf")
                (ref-AQP::URC_BenDptfAnchorsNeedSync account asset-id)
                (if (= asset-kind "dpsf")
                    (ref-AQP::URC_BenDpsfAnchorsNeedSync account asset-id)
                    (ref-AQP::URC_BenDpnfAnchorsNeedSync account asset-id)
                )
            )
        )
    )

    (defun URC_13|AnchorDetail:object (anchor-id:string account:string)
        @doc "One anchor as the detail panel shows it: the row, this account's promille in it, \
            \ and whether that figure is STALE. \
            \ \
            \ Staleness is per ANCHORED ASSET, not per anchor, because the repair is: \
            \ `AQP|C_SyncTrueFungibleAnchors patron executee dptf-id` refreshes EVERY \
            \ anchor \
            \ standing on that asset in one call. A per-anchor flag would invite a per- \
            \ anchor \
            \ button and bill the user once per anchor for one piece of work."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (row:object (URC_13|AnchorRow anchor-id))
            )
            (let
                (
                    (asset:string (at "asset-id" row))
                    (kind:string (at "asset-kind" row))
                )
                {"row"              : row
                ,"my-promille"      : (ref-ANK::UR_ANK-U|Promile account anchor-id)
                ,"my-class-total"   : (ref-ANK::UR_UB|AggregatePromile
                                          account (at "boost-class-id" row))
                ;;The repair unit, named so the client does not have to re-derive it.
                ,"repair-asset-id"  : asset
                ,"needs-sync"       : (URC_13|NeedsSync account asset kind)}
            )
        )
    )

    (defun URC_13|AnchorFull:object (anchor-id:string account:string)
        @doc "EVERYTHING about one anchor, for the detail view behind a row click. \
            \ \
            \ Every one of ANK|Schema's twelve fields is reachable through the interface, so \
            \ this needed no new sovereign reader -- it is composition, not capability. What \
            \ it adds over URC_13|AnchorDetail is the CONTEXT a row cannot carry: what else is \
            \ anchored on the same asset, how full that asset's 49-slot cap is, and what the \
            \ boost class looks like from the inside. \
            \ \
            \ MODE is NAMED rather than left to the caller to infer. Only ONE of the four \
            \ terms fields is live on any anchor; the rest hold sentinels (0.0, 0, \
            \ BAR, -1), so a client deciding for itself which to believe is a client that will \
            \ eventually believe the wrong one."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (row:object (URC_13|AnchorRow anchor-id))
                (fung:[bool] (ref-ANK::UR_ANK|Fungibility anchor-id))
            )
            (let
                (
                    (kind:string (URC_13|AnchorKind fung))
                    (asset:string (at "asset-id" row))
                    (bc:string (at "boost-class-id" row))
                )
                {"row"              : row
                ,"mode"             : (if (= kind "dptf") "amount"
                                      (if (= kind "dpsf") "nonce"
                                      (if (ref-ANK::URC_TraitOrClass anchor-id)
                                          "trait" "set-class")))
                ;;THE RAW TERMS FIELDS, all four, unfiltered. The detail shows which one is live
                ;;AND what the others hold, because "nonce-class: -1" is how a reader CONFIRMS
                ;;this is a trait anchor rather than taking the mode above on trust.
                ,"tf-amount"        : (ref-ANK::UR_ANK|TFAmount anchor-id)
                ,"sf-nonce"         : (ref-ANK::UR_ANK|SFNonce anchor-id)
                ,"trait-key"        : (ref-ANK::UR_ANK|NFTraitKey anchor-id)
                ,"trait-value"      : (ref-ANK::UR_ANK|NFTraitValue anchor-id)
                ,"nonce-class"      : (ref-ANK::UR_ANK|NFNonceClass anchor-id)
                ,"fungibility"      : fung
                ;;THE ASSET and its anchor bookkeeping. `anchors-on-asset` against the cap of 49
                ;;(UEV_AssetAnchorCap: 7 groups x 7 slots) is what a manager needs before
                ;;issuing another; `groups-on-asset` is the other half of that structure.
                ,"asset-owner"      : (ref-ANK::URC_AnchorableAssetOwner asset fung)
                ,"anchors-on-asset" : (ref-ANK::UR_AA|AnchorsActive asset)
                ,"groups-on-asset"  : (ref-ANK::UR_AA|GroupsActive asset)
                ;;SIBLINGS -- the other anchors on the same asset. They matter for one concrete
                ;;reason: the repair is per ASSET, so syncing this one refreshes all of them,
                ;;and the detail view should say which.
                ,"siblings"         : (filter (lambda (a:string) (!= a anchor-id))
                                          (ref-ANK::UR_ANK|AnchorsForAsset asset))
                ;;THE CLASS, from the inside. A non-zero score-link count LOCKS the class's
                ;;anchors against revocation, which is why an owner's revoke is refused.
                ,"class-active"     : (ref-ANK::UR_BC|Active bc)
                ,"class-slots"      : (ref-ANK::UR_BC|Anchors bc)
                ,"class-score-links": (ref-ANK::UR_BC|ScoreLinkCount bc)
                ;;MINE.
                ,"my-promille"      : (ref-ANK::UR_ANK-U|Promile account anchor-id)
                ,"my-class-total"   : (ref-ANK::UR_UB|AggregatePromile account bc)
                ,"needs-sync"       : (URC_13|NeedsSync account asset kind)}
            )
        )
    )

    (defun URH_13|AnchorCatalogue:[object] ()
        @doc "B view -- EVERY anchor on chain, whether or not it concerns the caller. \
            \ \
            \ HEAVY: reaches AQP-ANK's own `URH_ANK|AllAnchorIds` and then reads ~10 \
            \ fields per \
            \ anchor. The scan is the callee's, so this composes normally -- but the \
            \ prefix is \
            \ `URH_` because the COST is heavy, and a caller reading `URC_` would budget \
            \ for a \
            \ point read. Not `try`-composable: RULES.md rule 5."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (map (lambda (a:string) (URC_13|AnchorRow a)) (ref-ANK::URH_ANK|AllAnchorIds))
        )
    )

    (defun URH_13|MyAnchors:[object] (account:string)
        @doc "A view -- the anchors this account holds a NON-ZERO promille in, with staleness. \
            \ \
            \ Filtered on the server side deliberately. The client could fetch the \
            \ catalogue and \
            \ filter, but then every wallet downloads every anchor on the chain to find \
            \ its own \
            \ three, and the filter predicate lives in two places."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
            )
            (map
                (lambda (a:string) (URC_13|AnchorDetail a account))
                (filter
                    (lambda (a:string) (< 0.0 (ref-ANK::UR_ANK-U|Promile account a)))
                    (ref-ANK::URH_ANK|AllAnchorIds)
                )
            )
        )
    )

    (defun URH_13|BoostClasses:[object] (account:string)
        @doc "C view -- every boost class, with its members, its lock state and this account's \
            \ aggregate in it. \
            \ \
            \ MEMBERS ARE DERIVED, NOT READ. `UR_BC|Anchors` returns only a COUNT, and the \
            \ seven \
            \ `anchor-*` slot fields live in the module-only `UR_BC|Data`. Filtering the \
            \ anchor \
            \ list by `UR_ANK|BoostClassId` gets the same answer from a list already \
            \ fetched, \
            \ and avoids the in-module dot call that would hard-break this module on an \
            \ AQP-ANK \
            \ upgrade (see the header). \
            \ \
            \ NO `class-owner`. It is reachable only through that same module-only reader; \
            \ the \
            \ UI reads it at /local top level in the same request. The header gives the \
            \ form."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (all-anchors:[string] (ref-ANK::URH_ANK|AllAnchorIds))
            )
            (map
                (lambda (c:string)
                    (let
                        (
                            (members:[string]
                                (filter
                                    (lambda (a:string)
                                        (= c (ref-ANK::UR_ANK|BoostClassId a)))
                                    all-anchors))
                        )
                        {"boost-class-id"   : c
                        ,"slots-used"       : (ref-ANK::UR_BC|Anchors c)
                        ,"active"           : (ref-ANK::UR_BC|Active c)
                        ;;Non-zero LOCKS the class's anchors against revocation. A client-side
                        ;;fact because it is why a manager's revoke button is refused.
                        ,"score-links"      : (ref-ANK::UR_BC|ScoreLinkCount c)
                        ,"my-aggregate"     : (ref-ANK::UR_UB|AggregatePromile account c)
                        ,"members"          : (map (lambda (a:string) (URC_13|AnchorRow a))
                                                   members)
                        ,"max-promille"     : (fold (+) 0.0
                                                  (map (lambda (a:string)
                                                           (ref-ANK::UR_ANK|Promile a))
                                                       members))}
                    )
                )
                (ref-ANK::URH_BC|AllBoostClassIds)
            )
        )
    )

    (defun URH_13|MyAuthorityTrueFungibles:[string] (account:string)
        @doc "True fungibles this account may ANCHOR BUT DOES NOT OWN. \
            \ \
            \ `URH_OwnedTrueFungibles` selects on `owner-konto`, so it answers ownership and \
            \ nothing else. Anchoring authority is wider than ownership in exactly two ways, \
            \ both of them deliberate, and a manager who sees only what they own cannot reach \
            \ either: \
            \ \
            \   SPECIALS. An `F|` frozen or `R|` reserved token is owned by the VESTING \
            \     contract -- `XI_CreateSpecialTrueFungibleLink` issues it to VST|SC_NAME with \
            \     can-change-owner false -- but `CAP_TF|Owner` resolves it to its PARENT and \
            \     enforces the parent's ownership. So the parent's owner is the authority. \
            \     Measured on mainnet: VST owns F|ELITEAURYN, F|SPARK, F|VST and R|OURO, and \
            \     they appeared in the manager ONLY when the VST smart account was selected. \
            \ \
            \   LP TOKENS. A liquidity-pool token is owned by SWP|SC_NAME, also permanently. \
            \     Since 2026-10-03 `URCv_AnchorableDptfAuthority` resolves it to the POOL \
            \     OWNER of its swpair, so the pool's owner is the authority. \
            \ \
            \ BOTH ARE CUSTODY, NOT MANAGEMENT. The owner's ruling is that VST, ATS and SWP own \
            \ tokens as a protocol function and must never be a route to managing them; the \
            \ authority resolves through to the real party instead. This reader is the read-side \
            \ of that ruling -- the contract already enforced it, and nothing showed it. \
            \ \
            \ RETURNS IDS ONLY, and never one the account already owns: the caller concatenates \
            \ this onto `URH_OwnedTrueFungibles`, so a token owned outright must not appear \
            \ twice. Deduped against that list here rather than at the call site, because a \
            \ duplicate asset in the picker is indistinguishable from two real assets."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-SWP:module{SwapperV4} SWP)
                (ref-U|CT:module{OuronetConstantsV2} U|CT)
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (owned:[string] (ref-DPTF::URH_OwnedTrueFungibles account))
                (bar:string (ref-U|CT::CT_BAR))
            )
            (let
                (
                    ;;THE SPECIAL LINK IS SYMMETRIC, AND THAT IS WHAT MADE THE FIRST VERSION OF
                    ;;THIS WRONG. `XE_UpdateSpecialTrueFungible` calls `XI_UpdateFrozen` TWICE --
                    ;;core -> special AND special -> core -- so `UR_Frozen` answers the PARENT
                    ;;when handed a special. Measured on mainnet:
                    ;;
                    ;;    UR_Frozen "F|ELITEAURYN-8ZLws7IkbT7x" -> "ELITEAURYN-8Nh-JO8JO4F5"
                    ;;    UR_Frozen "ELITEAURYN-8Nh-JO8JO4F5"   -> "F|ELITEAURYN-8ZLws7IkbT7x"
                    ;;
                    ;;So walking the links from VST|SC_NAME -- which OWNS the four specials --
                    ;;returned their four PARENTS, tokens VST neither owns nor may anchor. The
                    ;;manager showed EliteAuryn, Spark, Vesta and Ouroboros as VST's to manage.
                    ;;
                    ;;Hence the `core-only` filter: follow the link only FROM a core token. An
                    ;;id that is already `F|`/`R|` has no counterpart to find -- it IS one.
                    (core-only:[string]
                        (filter (lambda (i:string)
                                    (not (contains (take 2 i) CT_13_SPECIAL_PREFIXES)))
                                owned))
                    ;;The LP token of every swpair this account owns. One pool, one LP token.
                    (lps:[string]
                        (map (lambda (p:string) (ref-SWP::UR_TokenLP p))
                             (ref-SWP::URH_OwnedSwapPairs account)))
                )
                (let
                    (
                        ;;`UR_Frozen`/`UR_Reservation` answer BAR when no counterpart was ever
                        ;;created, so this filter separates "has one" from "has none".
                        (specials:[string]
                            (filter
                                (lambda (i:string) (!= i bar))
                                (+ (map (lambda (i:string) (ref-DPTF::UR_Frozen i)) core-only)
                                   (map (lambda (i:string) (ref-DPTF::UR_Reservation i))
                                        core-only))))
                    )
                    ;;FILTERED BY THE AUTHORITY RULE ITSELF, not by the derivation that produced
                    ;;the candidate. This is the invariant the page needs -- "ids this account
                    ;;may anchor" -- and asking `URCv_AnchorableDptfAuthority` directly makes the
                    ;;reader correct even if a link direction or a prefix set changes under it.
                    ;;The derivation above only has to be a superset; this decides.
                    (filter (lambda (i:string)
                                (and (not (contains i owned))
                                     (= (ref-ANK::URCv_AnchorableDptfAuthority i) account)))
                            (distinct (+ specials lps)))
                )
            )
        )
    )
    (defun URH_13|MyAnchorableAssets:[object] (account:string)
        @doc "MANAGER: what this account owns that an anchor can be issued against, over \
            \ three asset kinds, each with its name and its current anchor count. \
            \ \
            \ `anchors-used` is the thing a manager needs before issuing: an asset caps at \
            \ 49 \
            \ anchors (`UEV_AssetAnchorCap`), and nothing else on the page would say how \
            \ close \
            \ it is. \
            \ \
            \ VERY HEAVY -- THREE scans, two of them owner scans over whole-collection \
            \ tables. \
            \ `DPDC::URH_OwnedCollectables` measured FAILING at a 150,000 gas limit and \
            \ passing \
            \ at 1,500,000, so this is `/local` only and needs a generous limit."
        (let
            (
                (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
                (ref-DPDC:module{DpdcV2} DPDC)
            )
            (+
                (+
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [true true]))
                        (ref-DPTF::URH_OwnedTrueFungibles account))
                    ;;AUTHORITY, NOT OWNERSHIP -- the two extra true-fungible sources.
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [true true]))
                        (URH_13|MyAuthorityTrueFungibles account)))
                (+
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [false true]))
                        (ref-DPDC::URH_OwnedCollectables account true))
                    (map
                        (lambda (i:string) (URC_13|AnchorableAsset i [false false]))
                        (ref-DPDC::URH_OwnedCollectables account false))
                )
            )
        )
    )

    (defun URC_13|AnchorableAsset:object (asset-id:string asset-fungibility:[bool])
        @doc "One owned asset as the manager's picker shows it. Split out of \
            \ URH_13|MyAnchorableAssets so the three kinds share one shape rather than \
            \ three \
            \ near-identical inline objects."
        (let
            (
                (ref-ANK:module{AcquisitionAnchorsV1} AQP-ANK)
                ;;
                (named:object (URC_13|AssetName asset-id asset-fungibility))
            )
            {"asset-id"         : asset-id
            ,"asset-name"       : (at "name" named)
            ,"asset-ticker"     : (at "ticker" named)
            ,"asset-kind"       : (URC_13|AnchorKind asset-fungibility)
            ;;Against the 49-slot cap in UEV_AssetAnchorCap.
            ,"anchors-used"     : (ref-ANK::UR_AA|AnchorsActive asset-id)}
        )
    )
)

