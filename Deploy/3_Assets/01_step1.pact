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
;;   The set's ARTWORK is baked into `A_BunnyRGBSet` as of 2026-10-02 -- it no longer needs a
;;   follow-up URI write:
;;     uri-primary   (512x512) https://arweave.net/O8Qy9Lv4BqtYcZSfjsv6IbTU-arQN8fb0S10F9q2Tn0
;;     uri-secondary (FULL)    https://arweave.net/C0PgEGQdK_PGtvnit2jZuVttup2GJtVmZ6MScvYL8Ac
;;     uri-tertiary            unset (BAR)
;;   Pinned by `[5.4]_PopulateBunnies` TX-03 `<<KBN-RGB-URI>>`, which asserts the two slots hold
;;   the two DIFFERENT links -- because until that date both slots held the SAME placeholder.
;;
;; -------------------------------------------------------------------------------------------
;; READ THIS BEFORE SIGNING ANYTHING -- TWO PREREQUISITES, AND THE SECOND IS NOT REVERSIBLE
;; -------------------------------------------------------------------------------------------
;;
;; (1) KBN ON CHAIN MUST BE THE NEW BUILD.
;;     `KBN` IS live on mainnet (Deploy/LIVE-MODULES.json, hash
;;     5nVlXL2e0s3PFdhxzwWFmIgcl52ka49pIeIDJEjsqZs) and the live copy predates the artwork
;;     change -- so it still carries the PLACEHOLDER strings. Running this step against the
;;     live module writes "SmallPhoto-IPFS-Link" into both URI slots.
;;
;;     => REDEPLOY KBN FIRST: `Deploy/1_Pure/22_deploy.pact`. (Not 23 -- 23 is AQP-BOOT.)
;;
;; (2) THE SET MUST NOT ALREADY EXIST. `XI_PrimordialSet` computes
;;         (set-class = (+ (UR_SetClassesUsed id son) 1))
;;     so this call does NOT overwrite and is NOT idempotent. Running it a second time creates
;;     a SECOND "Bunny RGB Set" at set-class 2, and the first one stays exactly as it was.
;;
;;     CHECK, as a /local read, before signing:
;;
;;         (ouronet-ns.DPDC.UR_SetClassesUsed "KBN-<hash>" false)
;;
;;       0  -> no set defined yet. Do prerequisite (1), then run PATH A below.
;;      >=1 -> a set already exists. DO NOT run PATH A. Use PATH B.
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
;; SIGNING
;; -------------------------------------------------------------------------------------------
;;   `GOV|AQP_BOOT_ADMIN` (the AQP-BOOT admin key), plus whatever `KBN.A_BunnyRGBSet` requires
;;   downstream -- it routes through TS02-C2 and will charge the patron.
;; ===========================================================================================

(namespace "ouronet-ns")

;; ===========================================================================================
;; PATH A -- FIRST DEFINITION.  Use when UR_SetClassesUsed returned 0.
;; Requires the redeployed KBN from 22_deploy; the artwork comes from the module, not from here.
;; ===========================================================================================

(AQP-BOOT.C_Step1_CreateBunnySet
    PATRON_KONTO
    "KBN_COLLECTION_ID"          ;; <- the live Bunnies collection id. Reused verbatim in tx 2 and tx 3.
)

;; ===========================================================================================
;; PATH B -- REPAIR AN ALREADY-DEFINED SET.  Use when UR_SetClassesUsed returned >= 1.
;;
;; This is the ONLY way to correct the artwork of a set that already exists: re-running PATH A
;; would add a set rather than fix one. It needs NO redeploy -- it writes the links directly, so
;; it works against the live KBN as it stands.
;;
;; Run it INSTEAD of PATH A, not after. Delete whichever path you are not using before signing.
;; ===========================================================================================

;; (ouronet-ns.TS02-C2.DPNF|C_UpdateSetNonceURI
;;     PATRON_KONTO
;;     "COLLECTION_OWNER_KONTO"              ;; holds role-set-new-uri AND signs
;;     "KBN_COLLECTION_ID"                   ;; the live collection id
;;     1                                     ;; set-class -- "Bunny RGB Set" is Set Class 1
;;     true                                  ;; nos = Native (not Split)
;;     (ouronet-ns.DPDC-UDC.UDC_URI|Type true false false false false false false)
;;     ;; primary = the 512x512, secondary = the FULL. This order is the collection's convention
;;     ;; for every individual Element (KBN.UC_IpfsLink small-or-big) and the Set follows it.
;;     (ouronet-ns.DPDC-UDC.UDC_URI|Data
;;         "https://arweave.net/O8Qy9Lv4BqtYcZSfjsv6IbTU-arQN8fb0S10F9q2Tn0" "|" "|" "|" "|" "|" "|")
;;     (ouronet-ns.DPDC-UDC.UDC_URI|Data
;;         "https://arweave.net/C0PgEGQdK_PGtvnit2jZuVttup2GJtVmZ6MScvYL8Ac" "|" "|" "|" "|" "|" "|")
;;     (ouronet-ns.DPDC-UDC.UDC_ZeroURI|Data)
;; )

;; ===========================================================================================
;; VERIFY, either path -- /local reads, no signature
;; ===========================================================================================
;; (ouronet-ns.DPDC-S.UR_SetNonceData "KBN_COLLECTION_ID" false 1)
;;   -> "uri-primary"   .image must be the ...O8Qy9Lv4... (512x512) link
;;      "uri-secondary" .image must be the ...C0PgEGQd... (FULL)    link
;;      the two MUST differ; equal values are the defect this change fixed.
