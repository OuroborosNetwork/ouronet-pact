;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 13
;; AQP-BOOT.C_IssueGenericEarningVault  --  the Stoicism vault
;; ===========================================================================================
;; ESTIMATED GAS 70,917  (3.5% of a 2,000,000 block)
;;   measured 2026-09-19 via TX-BOOT-GV in [6.2.9]_AQP-BOOT-FULL.repl -- the whole six-operation
;;   vault in ONE transaction, cheaper than transaction 3 alone.
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Stands up a complete earning vault in a single call: users stake Stoicism, they earn wSTOA.
;;
;;   Six operations, which is what a Vault actually needs and what makes it easy to build wrong:
;;     1. issue the SCORE for the staked DPTF          score-class 1
;;     2. issue the POOL the DPTF is staked into        aqp-class 1  (0 is reserved for LP)
;;     3. link score -> pool                            without this the pool scores nothing
;;     4. issue the FVT entity                          fvt-class 1 (Vault)
;;     5. admit the score to the FVT                    score-entity type 1
;;     6. register the reward token on the FVT          multiplet-family-id BAR (plain, not laddered)
;;
;;   Step 6 is not optional and is the one most easily missed: an EMPLOYED score with no reward
;;   link makes every stake abort in the FVT pipeline at 05_FVT.pact:1210. That is the same trap
;;   the `Bloodshed` score is currently sitting in -- see transaction 9.
;;
;; -------------------------------------------------------------------------------------------
;; NAMING -- one input name, three derived, and they MUST differ
;; -------------------------------------------------------------------------------------------
;;   You pass `vault-name`; the function derives
;;       <vault-name>Score    <vault-name>Pool    <vault-name>Vault
;;
;;   They cannot share a name. `UDC_Makeid` is `<name>-<block-hash>`, and ids collide across
;;   families because BRD|BrandingTable is shared (DPDC audit #33M). Three entities minted from
;;   one name in one transaction would produce three byte-identical ids, and the second insert
;;   would hard-abort. Hence the suffixes.
;;
;;   With `"Stoicism"` you get StoicismScore, StoicismPool, StoicismVault.
;;   Pick a base name that is unused -- collision is a hard abort, not a warning.
;;
;; -------------------------------------------------------------------------------------------
;; WHY THIS ONE IS SAFE TO RUN WHILE 8-12 ARE BLOCKED
;; -------------------------------------------------------------------------------------------
;;   The unresolved dispute is about fvt-class for SEMI- and NON-fungibles: two sovereign rules
;;   disagree (URC_ScoreClassMatchesFvtClass vs URC_TripletCategoryMatchesFvtClass).
;;
;;   They AGREE for true fungibles. Score-class 1 is admitted at fvt-class 1 by the first, and
;;   VAULT_TF maps to 1 in the second. A TF-in / TF-out vault is precisely the case both rules
;;   describe identically, so this transaction is unaffected by that dispute and does not depend
;;   on how it is settled.
;;
;;   It is also independent of transactions 0-12 entirely: it shares no entity with them.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING
;; -------------------------------------------------------------------------------------------
;; IN   <- nothing from this sequence. Two live mainnet DPTF ids, which you supply:
;;           stake-dptf-id   the Stoicism token
;;           reward-dptf-id  wSTOA
;;         Both are FULL IDS, not tickers.
;;
;; OUT  -> "AQP-BOOT GenericEarningVault done. names=[score= pool= fvt=]. ids=[score= pool= fvt=].
;;          staked= reward=. Ready for stake/collect."
;;
;;      !! SAVE IT. All three ids carry this block's hash and cannot be recomputed after mining.
;;         Nothing in this sequence consumes them, but the UI and any later wiring will.
;;
;; -------------------------------------------------------------------------------------------
;; TESTED
;; -------------------------------------------------------------------------------------------
;;   `<<AQP-BOOT-GV1>>` in `REPL/Stage_02/[6.2.9]_AQP-BOOT-FULL.repl` drives the real function
;;   end to end against the boot fixture (staking OURO, earning AURYN) and rolls back. It runs in
;;   the gate. Unlike `C_Step7`, this function's success path IS executed.
;;
;; SIGNING: `GOV|AQP_BOOT_ADMIN`; patron pays three issuances and three links.
;; ===========================================================================================

(namespace "ouronet-ns")

;; SIGNING -- measured, not assumed (2026-09-19).
;;   The vault deploys exactly THREE smart accounts: one for the score, one for the pool, one
;;   for the FVT. The patron must therefore sign `coin.TRANSFER` managed caps covering
;;       (DALOS.URC_SplitSTOAPrices patron (* 3.0 (DALOS.UR_UsagePrice "smart")))
;;   which is a FOUR-WAY split -- two `k:` recipients and two `c:` module-guard accounts. All four
;;   caps must be signed; the split is not one transfer.
;;
;;   3.0 is the MINIMUM and it is exact. Verified by bisection against the live suite:
;;   1.0 FAILS, 2.0 FAILS, 3.0 PASSES. The fixture originally signed 8.0 -- a blanket I picked
;;   when writing the test, i.e. a 2.7x over-authorisation. It has been tightened to 3.0, so
;;   <<AQP-BOOT-GV1>> now proves the bound rather than merely clearing it. Do not pad this number
;;   on mainnet: a managed cap is an approval, and the surplus is approved STOA.

(TS02-C3.AQP-FVT|C_IssueGenericEarningVault
    PATRON_KONTO
    OWNER_KONTO                          ;; <- owner of the score and the FVT
    "Stoicism"                           ;; <- base name -> StoicismScore / StoicismPool / StoicismVault
    "STOICISM-hCNmIIxczuBs"              ;; <- live Stoicism DPTF. What users stake.
    "WSTOA-8Nh-JO8JO4F5"                 ;; <- live wSTOA DPTF. What they earn.
)

;; WHY TALOS AND NOT AQP-BOOT
;;   `AQP-BOOT.C_IssueGenericEarningVault` still exists, but it is now a thin delegate to the line
;;   above and is gated on `GOV|AQP_BOOT_ADMIN`. The Talos entrypoint is the supported client path,
;;   needs no admin key, and is the one a user would call -- so it is the one this deployment
;;   exercises. Calling the delegate instead works and costs the same; it just adds a hop and an
;;   admin requirement this transaction does not need.

;; COST PREVIEW (check before sending)
;;   (AQP-INFO.INFO_AQP-FVT|IssueGenericEarningVault
;;       PATRON_KONTO OWNER_KONTO "Stoicism" "STOICISM-hCNmIIxczuBs" "WSTOA-8Nh-JO8JO4F5")
;;   Pinned by <<AQP-INFO-GV1>>: 4360.0 IGNIS full, 2310.8 after the 47% patron discount.
;;   Gas measured in the REPL table model: 70,917 (~3.5% of a 2M block).
