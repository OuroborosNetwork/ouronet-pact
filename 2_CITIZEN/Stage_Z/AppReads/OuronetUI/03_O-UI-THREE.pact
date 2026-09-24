;; ===========================================================================================
;; O-UI-THREE -- OuronetUI entity 3: ELITE ACCOUNT.
;; ===========================================================================================
;; Template: 01_O-UI-ONE.pact. Rules: ../RULES.md. Entity map: ../README.md.
;;
;; REPLACES DPL-UR::URC_0032_EliteAccount and URC_0035_EliteAccountRichList -- the only two
;; reads the Elite Account page makes (verified against src/hooks/useEliteAccount.ts and
;; useEliteRichList.ts).
;;
;; ------------------------------------------------------------------------------------------
;; TWO CLIENT READS, AND THEY ARE DELIBERATELY NOT COMPOSED TOGETHER
;; ------------------------------------------------------------------------------------------
;;   URC_01|EliteAccount  -- one account's panel. Six cards under `try`, flat 63-key output.
;;   URH_02|RichList      -- every Standard account, ranked. A SCAN. Standalone by necessity.
;;
;; The rich list cannot join the composer and the reason is structural, not stylistic: it runs
;; `(keys DALOS.DALOS|AccountTable)`, and Pact evaluates a `try` body in READ-ONLY mode where
;; `keys` is disallowed. Folding it in would make the panel abort wholesale instead of degrade.
;; It is also the one function here a page can render without -- a leaderboard is not the panel.
;;
;; `URH_` not `URC_`, so the cost is legible from the name. It is the heaviest read in the app.
;;
;; ------------------------------------------------------------------------------------------
;; THE TIER RULE IS DUPLICATED FROM O-UI-TWELVE ON PURPOSE -- read this before "fixing" it
;; ------------------------------------------------------------------------------------------
;; `UC_MaxSpecialFeeTargets` also exists in O-UI-TWELVE. Two copies of a rule is exactly how the
;; original defect happened: DPL-UR carried this logic twice and the copies disagreed, one
;; seeding its `or`-fold with `true` (whose identity is FALSE), so every owner below tier 2 was
;; told 7 targets instead of 1.
;;
;; So why copy it again? Because the alternative is worse. Calling O-UI-TWELVE from here would
;; make one read module a deploy dependency of another, and a read module being independently
;; redeployable is the single property this whole split buys. RULES.md rule 8 says the same of
;; formatters.
;;
;; WHAT MAKES THE DUPLICATION SAFE IS A TEST, NOT DISCIPLINE. RDUI-09 asserts that this copy and
;; O-UI-TWELVE's agree on every tier 0..7. Divergence fails the gate. That assertion is the
;; thing that was missing when the first two copies drifted -- not vigilance.
;; ===========================================================================================

(namespace "ouronet-ns")

(interface OUiThreeV1
    @doc "Elite Account page reads: the per-account panel and the ranked rich list."

    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroCard:object ())
    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal))
    (defun UC_Index:string (index:decimal))
    (defun UC_MaxSpecialFeeTargets:integer (major:integer))
    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Standing:object (account:string))
    (defun URC_Variants:object (account:string))
    (defun URC_Indices:object ())
    (defun URC_Dispo:object (account:string))
    (defun URC_Discounts:object (account:string))
    (defun URC_Unlocks:object (account:string))
    ;;  CLIENT READS -- the only two a UI calls.
    (defun URC_01|EliteAccount:object (account:string))
    (defun URH_02|RichList:[object] ())
)

(module O-UI-THREE GOV

    ;;{0}  IMPLEMENTERS
    (implements OUiThreeV1)

    ;;{1}  GOVERNANCE
    (defconst GOV|MD_O-UI-THREE             (keyset-ref-guard (GOV|Demiurgoi)))
    (defcap GOV ()                          (compose-capability (GOV|O_UI_THREE_ADMIN)))
    (defcap GOV|O_UI_THREE_ADMIN ()         (enforce-guard GOV|MD_O-UI-THREE))
    (defun GOV|Demiurgoi ()
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS)) (ref-DALOS::GOV|Demiurgoi))
    )

    ;;{3}  CST
    (defconst BAR (let ((ref-U|CT:module{OuronetConstantsV2} U|CT)) (ref-U|CT::CT_BAR)))

    ;;{5}  FUNCTIONS
    ;;{5.1}  Construct [CT/UDC]
    (defun UDC_ZeroCard:object ()
        @doc "What a failing card yields from URC_01|EliteAccount; `card-ok` false."
        {"card-ok" : false}
    )

    ;;{5.2}  Compute [UC]
    (defun UC_Amount:string (amount:decimal)
        @doc "Four-decimal display form; sub-threshold reads as <0.0001."
        (let ((v:string (format "{}" [(floor amount 4)])))
            (if (= v "0.0") "<0.0001" v)
        )
    )
    (defun UC_Index:string (index:decimal)
        @doc "Index display form: whole part, then four 3-digit groups of the fraction."
        (let*
            ( (fis:string (format "{}" [(floor index 12)]))
              (l1:string (take -3 fis)) (l2:string (take -3 (drop -3 fis)))
              (l3:string (take -3 (drop -6 fis))) (l4:string (take -3 (drop -9 fis)))
              (whole:string (drop -13 fis)) )
            (concat [whole ",[" l4 "." l3 "." l2 "." l1 "]"])
        )
    )
    (defun UC_MaxSpecialFeeTargets:integer (major:integer)
        @doc "How many SWP special-fee targets an Elite major tier permits. \
            \ \
            \ A DELIBERATE COPY of O-UI-TWELVE's function -- see the module header. Written as \
            \ an explicit comparison rather than an `or`-fold so there is no seed to get wrong, \
            \ which is precisely how DPL-UR's two copies came to disagree. RDUI-09 pins this \
            \ against O-UI-TWELVE's for every tier, so a divergence fails the gate rather than \
            \ waiting to be noticed by a user who was shown 7 where the rule says 1."
        (cond
            ((= major 2) 2)
            ((= major 3) 3)
            ((= major 4) 4)
            ((>= major 5) 7)
            1
        )
    )

    ;;{5.3}  Read [UR/URC/URH/URCi/INFO]
    (defun URC_Standing:object (account:string)
        @doc "Class, name, tier and DEB -- the account's Elite identity."
        (let ((ref-DALOS:module{OuronetDalosV2} DALOS))
            {"card-ok" : true
            ,"elite-class" : (ref-DALOS::UR_Elite-Class account)
            ,"elite-name" : (ref-DALOS::UR_Elite-Name account)
            ,"elite-tier" : (ref-DALOS::UR_Elite-Tier account)
            ,"elite-tier-major" : (ref-DALOS::UR_Elite-Tier-Major account)
            ,"elite-tier-minor" : (ref-DALOS::UR_Elite-Tier-Minor account)
            ,"elite-deb" : (ref-DALOS::UR_Elite-DEB account)}
        )
    )

    (defun URC_Variants:object (account:string)
        @doc "Every Elite-Auryn variant the account holds, and what the next tier costs. \
            \ \
            \ Six variants: native, Frozen, Reservation, Vesting, Sleeping, Hibernation. The \
            \ first three are DPTF balances, the last three DPOF -- which is why they are read \
            \ through different modules. Each id is guarded against BAR: a variant that has \
            \ never been linked reads as absent rather than throwing, which is the difference \
            \ between a card that renders six rows and a card that renders none."
        (let*
            ( (ref-U|CT:module{OuronetConstantsV2} U|CT)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-ELITE:module{EliteV2} ELITE)
              (ea:string (ref-DALOS::UR_EliteAurynID))
              (fea:string (if (!= ea BAR) (ref-DPTF::UR_Frozen ea) BAR))
              (rea:string (if (!= ea BAR) (ref-DPTF::UR_Reservation ea) BAR))
              (vea:string (if (!= ea BAR) (ref-DPTF::UR_Vesting ea) BAR))
              (sea:string (if (!= ea BAR) (ref-DPTF::UR_Sleeping ea) BAR))
              (hea:string (if (!= ea BAR) (ref-DPTF::UR_Hibernation ea) BAR))
              (eas:decimal (if (!= ea BAR) (ref-DPTF::UR_AccountSupply ea account) 0.0))
              (feas:decimal (if (!= fea BAR) (ref-DPTF::UR_AccountSupply fea account) 0.0))
              (reas:decimal (if (!= rea BAR) (ref-DPTF::UR_AccountSupply rea account) 0.0))
              (veas:decimal (if (!= vea BAR) (ref-DPOF::UR_AccountSupply vea account) 0.0))
              (seas:decimal (if (!= sea BAR) (ref-DPOF::UR_AccountSupply sea account) 0.0))
              (heas:decimal (if (!= hea BAR) (ref-DPOF::UR_AccountSupply hea account) 0.0))
              (total:decimal (ref-ELITE::URC_EliteAurynzSupply account))
              (et:[decimal] (ref-U|CT::CT_ET))
              (et-last:decimal (at (- (length et) 1) et))
              (next:decimal
                (if (>= total et-last)
                    0.0
                    (- (fold (lambda (acc:decimal tier:decimal)
                                (if (and (> tier total) (< tier acc)) tier acc))
                             et-last et)
                       total))) )
            {"card-ok" : true
            ,"ea-id" : ea,   "ea-supply" : (UC_Amount eas),   "ea-supply-hover" : eas
            ,"fea-id" : fea, "fea-supply" : (UC_Amount feas), "fea-supply-hover" : feas
            ,"rea-id" : rea, "rea-supply" : (UC_Amount reas), "rea-supply-hover" : reas
            ,"vea-id" : vea, "vea-supply" : (UC_Amount veas), "vea-supply-hover" : veas
            ,"sea-id" : sea, "sea-supply" : (UC_Amount seas), "sea-supply-hover" : seas
            ,"hea-id" : hea, "hea-supply" : (UC_Amount heas), "hea-supply-hover" : heas
            ,"total-elite-aurynz" : (UC_Amount total)
            ,"total-elite-aurynz-hover" : total
            ,"elite-aurynz-for-next-tier" : (UC_Amount next)
            ,"elite-aurynz-for-next-tier-hover" : next}
        )
    )

    (defun URC_Indices:object ()
        @doc "Auryndex and EliteAuryndex, which feed the dispo arithmetic. \
            \ \
            \ Resolved through UR_RewardToken on OURO and AURYN -- the pool that REWARDS each \
            \ token. Account-independent, so this card is identical for every caller and is the \
            \ one here worth caching across users."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-ATS:module{AutostakeV3} ATS)
              (a:string (at 0 (ref-DPTF::UR_RewardToken (ref-DALOS::UR_OuroborosID))))
              (e:string (at 0 (ref-DPTF::UR_RewardToken (ref-DALOS::UR_AurynID))))
              (av:decimal (ref-ATS::URC_Index a))
              (ev:decimal (ref-ATS::URC_Index e)) )
            {"card-ok" : true
            ,"auryndex-id" : a, "auryndex-name" : (ref-ATS::UR_IndexName a)
            ,"auryndex-value" : (UC_Index av), "auryndex-value-hover" : av
            ,"elite-auryndex-id" : e, "elite-auryndex-name" : (ref-ATS::UR_IndexName e)
            ,"elite-auryndex-value" : (UC_Index ev), "elite-auryndex-value-hover" : ev}
        )
    )

    (defun URC_Dispo:object (account:string)
        @doc "The OURO dispo credit: how far the account may overspend against its native \
            \ Elite-Auryn, and whether that credit is currently locked. \
            \ \
            \ `elite-auryn-dispo-locked` is TRUE when the OURO balance is NEGATIVE -- the \
            \ account has already spent into its credit, and native Elite-Auryn cannot move \
            \ until it is back at zero. A negative OURO balance is normal here, not an error."
        (let*
            ( (ref-U|DPTF:module{UtilityDptfV2} U|DPTF)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-TFT:module{TrueFungibleTransferV2} TFT)
              (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
              (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
              (ouro:string (ref-DALOS::UR_OuroborosID))
              (bal:decimal (ref-DPTF::UR_AccountSupply ouro account))
              (cap:decimal (ref-U|DPTF::UC_OuroDispo (ref-TFT::UDC_GetDispoData account)))
              (minimum:decimal (ref-TFT::URC_MinimumOuro account))
              (virtual:decimal (ref-TFT::URC_VirtualOuro account))
              (locked:bool (< bal 0.0))
              (pct:decimal
                (if (< (dec major) 3.0)
                    0.0
                    (floor (+ (/ (- (+ (* (- (dec major) 1.0) 7.0) (dec minor)) 15.0) 10.0) 11.5)
                           1))) )
            {"card-ok" : true
            ,"dispo-overspend-percent" : pct
            ,"dispo-overspend-text" :
                (format "{}% of native Elite-Auryn OURO-value may be overspent (requires Major Tier >= 3)"
                        [pct])
            ,"ouro-id" : ouro
            ,"ouro-balance" : (UC_Amount bal), "ouro-balance-hover" : bal
            ,"ouro-dispo-capacity" : (UC_Amount cap), "ouro-dispo-capacity-hover" : cap
            ,"ouro-minimum" : (UC_Amount minimum), "ouro-minimum-hover" : minimum
            ,"ouro-virtual" : (UC_Amount virtual), "ouro-virtual-hover" : virtual
            ,"elite-auryn-dispo-locked" : locked
            ,"elite-auryn-dispo-locked-text" :
                (if locked
                    "Native Elite-Auryn is dispo-locked until OURO balance returns to >= 0"
                    "Native Elite-Auryn is transferable (OURO not negative)")}
        )
    )

    (defun URC_Discounts:object (account:string)
        @doc "IGNIS, STOA and DEX fee discounts. \
            \ \
            \ Two numbers per discount and they are NOT the same thing: the MULTIPLIER is what \
            \ the account pays (1.0 = full price), the PERCENT is what it saves. Reporting only \
            \ one invites a UI showing 'discount 0.85' where it means 15%. \
            \ \
            \ DEX fees intentionally reuse the IGNIS curve -- SWPI::URC_EliteFeeReduction applies \
            \ the non-native gas discount to LP/special/boost fees -- so the two are equal by \
            \ construction rather than by coincidence."
        (let*
            ( (ref-U|DALOS:module{UtilityDalosV2} U|DALOS)
              (ref-DALOS:module{OuronetDalosV2} DALOS)
              (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
              (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
              (im:decimal (ref-DALOS::URC_IgnisGasDiscount account))
              (sm:decimal (ref-DALOS::URC_StoaGasDiscount account))
              (ip:decimal (ref-U|DALOS::UC_GasDiscount major minor false))
              (sp:decimal (ref-U|DALOS::UC_GasDiscount major minor true)) )
            {"card-ok" : true
            ,"ignis-cost-multiplier" : im, "ignis-discount-percent" : ip
            ,"ignis-discount-text" :
                (format "IGNIS Discount {}% (You pay only {}% of IGNIS costs)" [ip (* im 100.0)])
            ,"stoa-cost-multiplier" : sm, "stoa-discount-percent" : sp
            ,"stoa-discount-text" :
                (format "STOA Discount {}% (You pay only {}% of STOA costs)" [sp (* sm 100.0)])
            ,"dex-fee-cost-multiplier" : im, "dex-fee-discount-percent" : ip
            ,"dex-fee-discount-text" :
                (format "DEX Fee Discount {}% (LP/Special/Boost fees; same curve as IGNIS)" [ip])}
        )
    )

    (defun URC_Unlocks:object (account:string)
        @doc "What the account's tier unlocks elsewhere: SWP special-fee targets, branding \
            \ months, and Elite-ATS cold-recovery positions."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-BRD:module{BrandingV2} BRD)
              (major:integer (ref-DALOS::UR_Elite-Tier-Major account))
              (minor:integer (ref-DALOS::UR_Elite-Tier-Minor account))
              (deb:decimal (ref-DALOS::UR_Elite-DEB account)) )
            {"card-ok" : true
            ,"deb-bonus-text" :
                (format "DEB x{} on AQP scores when deb-boost is enabled" [deb])
            ,"max-swp-special-fee-targets" : (UC_MaxSpecialFeeTargets major)
            ,"max-branding-blue-months" : (ref-BRD::URC_MaxBluePayment account)
            ,"elite-ats-cold-recovery-positions" : (if (= major 0) 1 major)
            ,"elite-ats-cold-recovery-duration-index" :
                (if (= major 0) 0 (+ (* (- major 1) 7) minor))}
        )
    )

    ;;=======================================================================================
    ;;  CLIENT READS -- the only two a UI calls. Everything above is an internal component.
    ;;=======================================================================================

    (defun URC_01|EliteAccount:object (account:string)
        @doc "THE ELITE PANEL, IN ONE CALL. Flat, with exactly the keys \
            \ DPL-UR::URC_0032_EliteAccount returned, so a consumer swaps the module path and \
            \ changes nothing else. \
            \ \
            \ Six cards under `try`: a card that cannot read flags itself in `<name>-ok` and \
            \ leaves its fields at placeholder, while the rest render. \
            \ \
            \ THE RICH LIST IS NOT IN HERE. It scans, a scan cannot live inside a `try`, and \
            \ folding it in would make this panel abort wholesale on the heaviest read in the \
            \ app. Call URH_02|RichList separately -- in parallel, it costs no extra latency."
        (let*
            ( (st:object (try (UDC_ZeroCard) (URC_Standing account)))
              (v:object (try (UDC_ZeroCard) (URC_Variants account)))
              (ix:object (try (UDC_ZeroCard) (URC_Indices)))
              (dp:object (try (UDC_ZeroCard) (URC_Dispo account)))
              (dc:object (try (UDC_ZeroCard) (URC_Discounts account)))
              (un:object (try (UDC_ZeroCard) (URC_Unlocks account))) )
            (+ {"account" : account
               ,"standing-ok" : (at "card-ok" st), "variants-ok" : (at "card-ok" v)
               ,"indices-ok" : (at "card-ok" ix),  "dispo-ok" : (at "card-ok" dp)
               ,"discounts-ok" : (at "card-ok" dc),"unlocks-ok" : (at "card-ok" un)}
               (+ (remove "card-ok" st)
                  (+ (remove "card-ok" v)
                     (+ (remove "card-ok" ix)
                        (+ (remove "card-ok" dp)
                           (+ (remove "card-ok" dc) (remove "card-ok" un)))))))
        )
    )

    (defun URH_02|RichList:[object] ()
        @doc "Every Standard Ouronet account ranked by total Elite-Auryn, highest first. \
            \ \
            \ `URH_` AND STANDALONE, both forced. It runs `(keys DALOS.DALOS|AccountTable)` -- a \
            \ CROSS-MODULE scan, which Pact admin-gates in transactional mode and a node permits \
            \ in `/local` only with `--allowReadsInLocal`. It therefore cannot sit inside a \
            \ `try`, and so cannot join URC_01|EliteAccount's composer. \
            \ \
            \ IT IS ALSO THE HEAVIEST READ IN THE APPLICATION and grows worse than linearly: it \
            \ walks every account, then INSERTION-SORTS the result, which is O(n^2) in accounts \
            \ under a 10,000,000 gas /local ceiling. At ~195 accounts that is comfortable. It \
            \ will not always be. When it stops fitting the answer is pagination in the caller, \
            \ not a bigger ceiling -- and the time to notice is before a page depends on it \
            \ loading synchronously."
        (let*
            ( (ref-DALOS:module{OuronetDalosV2} DALOS)
              (ref-DPTF:module{DemiourgosPactTrueFungibleV2} DPTF)
              (ref-DPOF:module{DemiourgosPactOrtoFungibleV2} DPOF)
              (ref-CODEX:module{CodexV2} CODEX)
              (ouro:string (ref-DALOS::UR_OuroborosID))
              (ea:string (ref-DALOS::UR_EliteAurynID))
              (fea:string (if (!= ea BAR) (ref-DPTF::UR_Frozen ea) BAR))
              (rea:string (if (!= ea BAR) (ref-DPTF::UR_Reservation ea) BAR))
              (vea:string (if (!= ea BAR) (ref-DPTF::UR_Vesting ea) BAR))
              (sea:string (if (!= ea BAR) (ref-DPTF::UR_Sleeping ea) BAR))
              (hea:string (if (!= ea BAR) (ref-DPTF::UR_Hibernation ea) BAR))
              (standard:[string]
                (filter (lambda (a:string) (not (ref-DALOS::UR_AccountType a)))
                        (keys DALOS.DALOS|AccountTable)))
              (rows:[object]
                (map (lambda (a:string)
                    (let*
                        ( (ob:decimal (if (!= ouro BAR) (ref-DPTF::UR_AccountSupply ouro a) 0.0))
                          (s1:decimal (if (!= ea BAR) (ref-DPTF::UR_AccountSupply ea a) 0.0))
                          (s2:decimal (if (!= fea BAR) (ref-DPTF::UR_AccountSupply fea a) 0.0))
                          (s3:decimal (if (!= rea BAR) (ref-DPTF::UR_AccountSupply rea a) 0.0))
                          (s4:decimal (if (!= vea BAR) (ref-DPOF::UR_AccountSupply vea a) 0.0))
                          (s5:decimal (if (!= sea BAR) (ref-DPOF::UR_AccountSupply sea a) 0.0))
                          (s6:decimal (if (!= hea BAR) (ref-DPOF::UR_AccountSupply hea a) 0.0))
                          (tot:decimal (fold (+) 0.0 [s1 s2 s3 s4 s5 s6]))
                          (locked:bool (< ob 0.0))
                          (stba:object (ref-CODEX::UR_STBA|DataOrNull a)) )
                        {"account" : a
                        ,"stoic-tag" : (if (at "has-stoictag" stba) (at "tag-name" stba) BAR)
                        ,"elite-class" : (ref-DALOS::UR_Elite-Class a)
                        ,"elite-name" : (ref-DALOS::UR_Elite-Name a)
                        ,"elite-tier" : (ref-DALOS::UR_Elite-Tier a)
                        ,"ouro-balance" : ob
                        ,"elite-auryn-dispo-locked" : locked
                        ,"ea-id" : ea, "ea-supply" : s1
                        ,"ea-movable" : (if locked 0.0 s1)
                        ,"fea-id" : fea, "fea-supply" : s2
                        ,"rea-id" : rea, "rea-supply" : s3
                        ,"vea-id" : vea, "vea-supply" : s4
                        ,"sea-id" : sea, "sea-supply" : s5
                        ,"hea-id" : hea, "hea-supply" : s6
                        ,"total-elite-aurynz" : tot}))
                    standard)) )
            ;;Insertion sort, descending. O(n^2) and named as such in the @doc rather than
            ;;hidden -- a reader deciding whether to call this deserves to know.
            (fold (lambda (sorted:[object] row:object)
                    (let ( (t:decimal (at "total-elite-aurynz" row)) )
                        (+ (filter (lambda (x:object) (> (at "total-elite-aurynz" x) t)) sorted)
                           (+ [row]
                              (filter (lambda (x:object) (<= (at "total-elite-aurynz" x) t))
                                      sorted)))))
                  [] rows)
        )
    )
)
