;; ===========================================================================================
;; OURONET AQP ASSET TREE -- TRANSACTION 1
;; AQP-BOOT.C_Step1_CreateBunnySet
;; ===========================================================================================
;; ESTIMATED GAS 9,491  (0.5% of a 2,000,000 block)
;;   measured, TX-BOOT-01
;; ===========================================================================================
;;
;; WHAT THIS DOES
;;   Creates the Bunny RGB set definition on the KBN collection, by calling
;;   `KBN.A_BunnyRGBSet patron kbn-id`. One call, under `GOV|AQP_BOOT_ADMIN`.
;;
;; -------------------------------------------------------------------------------------------
;; CHAINING -- what comes in, what goes out
;; -------------------------------------------------------------------------------------------
;; IN   <- NOT from Step 0. Step 0 publishes no id (its `aqp-sc` is a compile-time constant).
;;         `kbn-id` is the KBN Bunnies COLLECTION id, which is already on mainnet. You supply it.
;;         REPL value, for shape only: "KBN-98c486052a51"
;;         The suffix is a block hash, so the mainnet id will differ -- this is exactly the kind
;;         of id that cannot be computed and must be carried in by hand.
;;
;; OUT  -> "AQP-BOOT Step 1 done. kbn-id={}. NEXT=Step2,Step3:kbn-id={}."
;;         The step ECHOES `kbn-id` unchanged. It creates no new identifier.
;;         **Steps 2 and 3 both take the same `kbn-id`** -- so the value you paste below is the
;;         value you paste into transactions 2 and 3. Keep it.
;;
;; -------------------------------------------------------------------------------------------
;; PREREQUISITE TO CHECK
;; -------------------------------------------------------------------------------------------
;;   THE KBN MODULE MUST BE ON CHAIN. This step calls `KBN.A_BunnyRGBSet`, so the Bunnies minter
;;   module itself -- not just the collection -- has to be deployed. KBN is NOT in this round's
;;   `1_Pure/` (it names no bumped interface, so the cascade does not pull it in) and it is NOT in
;;   the on-chain interface snapshot. That snapshot lists modules by the interface they implement,
;;   so a module implementing none is absent from it without being absent from chain -- the same
;;   blind spot that hid the utilities. So its absence there proves nothing either way.
;;   CONFIRM `KBN` is live before running this. If it is not, it must be added to the round.
;;
;; -------------------------------------------------------------------------------------------
;; SIGNING
;; -------------------------------------------------------------------------------------------
;;   `GOV|AQP_BOOT_ADMIN` (the AQP-BOOT admin key), plus whatever `KBN.A_BunnyRGBSet` requires
;;   downstream -- it routes through TS02-C2 and will charge the patron.
;; ===========================================================================================

(namespace "ouronet-ns")

(AQP-BOOT.C_Step1_CreateBunnySet
    PATRON_KONTO
    "KBN_COLLECTION_ID"          ;; <- the live Bunnies collection id. Reused verbatim in tx 2 and tx 3.
)

(ouronet-ns.TS02-C2.DPNF|C_UpdateSetNonceURI
    "<patron>"
    "<collection owner konto>"            ;; holds role-set-new-uri AND signs
    "KBN-<hash>"                          ;; the live collection id
    1                                     ;; set-class -- "Bunny RGB Set" is Set Class 1
    true                                  ;; nos = Native (not Split)
    (ouronet-ns.DPDC-UDC.UDC_URI|Type true false false false false false false)
    (ouronet-ns.DPDC-UDC.UDC_URI|Data "https://arweave.net/<TXID-512>"  "|" "|" "|" "|" "|" "|")
    (ouronet-ns.DPDC-UDC.UDC_URI|Data "https://arweave.net/<TXID-FULL>" "|" "|" "|" "|" "|" "|")
    (ouronet-ns.DPDC-UDC.UDC_ZeroURI|Data)
)