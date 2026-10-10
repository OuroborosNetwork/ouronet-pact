;; #########################################################################################
;; ##   DRAFT -- DO NOT SIGN THIS FILE.
;; ##
;; ##   links/LINKS.json still carries placeholder values, so the Arweave URLs
;; ##   below are NOT REAL. Every structural check in _arweave.py passes on this
;; ##   file -- coverage, budget, the byte-for-byte stale diff -- because all of
;; ##   them are about SHAPE, and a placeholder is shape-perfect. Nothing except
;; ##   this banner distinguishes a drafted round from a finished one.
;; ##
;; ##   Replace the link map, re-run `_arweave.py --write`, and this banner
;; ##   disappears on its own. If you can still read it, the links are fake.
;; #########################################################################################
;;
;; =========================================================================================
;; OURONET IPFS -> ARWEAVE URI MIGRATION -- TRANSACTION 18 OF 23
;; OuronetCustodians :: nonce 1-4
;; =========================================================================================
;; ESTIMATED GAS 14,340  (0.7% of a 2,000,000 block)
;;   = 8,104 fixed + 4 x 1,559 -- the N-sweep in REPL/tools/_arweave.py
;; IGNIS 4  (4 x 1.0; URCi_UpdateNonces = count x tier-smallest)
;; =========================================================================================
;;
;; WHAT THIS DOES
;;   Rewrites `uri-primary` (512x512) and `uri-secondary` (FULL) on 4 nonces of
;;   OuronetCustodians, from the IPFS gateway to Arweave.
;;
;;   NOTHING ELSE ON THE ROW IS TOUCHED, and that is structural rather than careful:
;;   the lambda READS the live row with UR_NativeNonceData and overlays
;;   exactly those two keys, so `name`, `description`, `meta-data`, `asset-type` and
;;   both royalties are carried across BY THE CHAIN rather than retyped here. That is
;;   the whole reason this round drives the BULK entrypoint through a read-overlay
;;   instead of calling the single-field `C_UpdateNonceURI` once per nonce.
;;
;;   This file is GENERATED. Edit REPL/tools/_arweave.py and re-run --write.
;;
;; -----------------------------------------------------------------------------------------
;; READ THIS BEFORE SIGNING -- THREE PRECONDITIONS
;; -----------------------------------------------------------------------------------------
;;
;; (1) THE EXECUTOR MUST HOLD role-RECREATE.
;;     Not role-set-new-uri, and not role-update. All three exist on a DPDC account
;;     and all three are separately held:
;;
;;       C_UpdateNonceURI  -> DPDC-N|C>SET-URI  -> UEV_RoleSetNewUriON  -> R-SetUri
;;       C_UpdateNonces    -> DPDC-N|C>SET-DATA -> UEV_RoleNftRecreateON -> R-Recreate
;;
;;     This round drives the second one, so R-Recreate is what gates it. Read:
;;
;;         (ouronet-ns.DPDC.UR_CA|R-Recreate "DHOC-SUVEHxb9UQ6_" true "OWNER_KONTO")
;;
;;       true  -> proceed.
;;       false -> move it first (`DPNF|C_MoveRecreateRole`; it is move-only, there is
;;                no toggle). Do NOT switch to C_UpdateNonceURI to dodge this:
;;                measured, that is 6x the gas and 17x the IGNIS across the round.
;;
;;     `UEV_RoleNftRecreateON` and `UEV_RoleNftUpdateON` emit the BYTE-IDENTICAL
;;     refusal -- "... Element Data cannot be Updated while using the ... Account" --
;;     so if this is wrong, the error message will not tell you which role is
;;     missing. That is why the read above names the role explicitly.
;;
;; (2) THE LADDER MUST LINE UP WITH THE MINT, and nothing on chain enforces that.
;;     The links below are addressed by position using the minter's own arithmetic,
;;     which matches the mint only if the collection held ZERO nonces when the
;;     populate ladder began -- the exact hazard NOSFERATU's `UC_Nonces` @doc records.
;;     If the collection was offset, every batch rewrites the NEIGHBOURS of what it
;;     means to, and does it silently, because every row gets a plausible link.
;;
;;     The read that settles it, for this batch's first nonce:
;;
;;         (at "image" (at "uri-primary"
;;             (ouronet-ns.DPDC.UR_NativeNonceData "DHOC-SUVEHxb9UQ6_" true 1)))
;;
;;     MUST return EXACTLY:
;;         https://ipfs.io/ipfs/QmYjHPWPxCeHGu9vgYUbzjmWo34A2z3CNuYmU6MEzgUSzP/512x512/01_Custodians/1_BronzeStar.jpg
;;
;;     A different link means the ladder is offset: STOP, and re-plan the round.
;;     Do not sign this file or any later one.
;;
;; (3) NO NONCE IN THIS BATCH MAY BE A MINTED NFT SET INSTANCE.
;;     `DPDC-N.UEV_NotSetInstance` (DPDC Audit #12Hc) refuses a data change on any NFT
;;     nonce whose `UR_NonceClass` is non-zero -- a Set instance's composition record is
;;     frozen at Make, deliberately and permanently. Such a row CANNOT be migrated by
;;     any entrypoint in the module, now or ever.
;;
;;     ONE of them ABORTS THE WHOLE TRANSACTION, because `C_UpdateNonces` writes the
;;     batch under a single capability. Spot-check:
;;
;;         (ouronet-ns.DPDC.UR_NonceClass "DHOC-SUVEHxb9UQ6_" true 1)   ;; expect 0
;;
;;     If any are Sets, delete them from BOTH lists below -- keeping the two lists the
;;     same length is what keeps link i paired with nonce i -- and record them as
;;     permanently on IPFS.
;;
;; -----------------------------------------------------------------------------------------
;; SIGNING
;; -----------------------------------------------------------------------------------------
;;   The collection OWNER (holder of role-update) signs; the patron pays. No admin key
;;   and no namespace write: this round deploys nothing.
;;
;; -----------------------------------------------------------------------------------------
;; RESUMING -- which matters, because this round is 23 signed transactions
;; -----------------------------------------------------------------------------------------
;;   Every file is INDEPENDENT and IDEMPOTENT: re-running one rewrites the same rows
;;   with the same strings. There is no cursor and no ordering requirement between
;;   files, so a failure needs no unwinding -- fix and re-send that one file.
;;
;;   To find out whether THIS file already landed, run precondition 2's read: an
;;   Arweave link means it did.
;;
;;   The dotted `ouronet-ns.MODULE.function` calls below are CORRECT and must not be
;;   'fixed' to `::`. The dot rule is about calls made from INSIDE a module, where a
;;   dot pins the callee's hash at the caller's deploy time; a signed transaction has
;;   no deploy time to pin. Deploy/3_Assets uses dots throughout, for this reason.
;; =========================================================================================

(namespace "ouronet-ns")

;;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_arweave.py
(let
    (
        (patron:string "PATRON_KONTO")
        (executor:string "OWNER_KONTO")
        (id:string "DHOC-SUVEHxb9UQ6_")
        (nonces:[integer]
            [
            1 2 3 4
            ]
        )
        (links:[[string]]
            [
              ["https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/512x512/01_Custodians/1_BronzeStar.jpg" "https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/FULL/01_Custodians/1_BronzeStar.jpg"]
              ["https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/512x512/01_Custodians/2_SilverStar.jpg" "https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/FULL/01_Custodians/2_SilverStar.jpg"]
              ["https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/512x512/01_Custodians/3_GoldenStar.jpg" "https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/FULL/01_Custodians/3_GoldenStar.jpg"]
              ["https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/512x512/01_Custodians/4_OG.jpg" "https://arweave.net/SHAPE_TEST_NOT_A_REAL_MANIFEST_TXID/FULL/01_Custodians/4_OG.jpg"]
            ]
        )
    )
    (ouronet-ns.TS02-C1.DPSF|C_UpdateNonces patron executor id nonces true
        (map
            (lambda (i:integer)
                (+
                    { "uri-primary"   : (ouronet-ns.DPDC-UDC.UDC_URI|Data (at 0 (at i links)) "|" "|" "|" "|" "|" "|")
                    , "uri-secondary" : (ouronet-ns.DPDC-UDC.UDC_URI|Data (at 1 (at i links)) "|" "|" "|" "|" "|" "|") }
                    (remove "uri-secondary"
                        (remove "uri-primary"
                            (ouronet-ns.DPDC.UR_NativeNonceData id true (at i nonces))
                        )
                    )
                )
            )
            (enumerate 0 (- (length links) 1))
        )
    )
)
