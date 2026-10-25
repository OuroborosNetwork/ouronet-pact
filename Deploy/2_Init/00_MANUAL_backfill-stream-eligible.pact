;; ---------------------------------------------------------------------------
;; OURONET INIT -- MANUAL step, hand-authored.
;; Label : backfill stream-eligible onto every pre-existing FVT
;;
;; RUN THIS IMMEDIATELY AFTER the deploy transaction carrying 05_FVT.pact,
;; and BEFORE any other transaction touches an FVT.
;;
;; THIS FILE IS NOT GENERATED -- same reason as its sibling
;; 00_MANUAL_backfill-drift-locked.pact. _deploybundle.py knows it by name.
;;
;; ---------------------------------------------------------------------------
;; WHAT IT DOES
;;
;; The 2026-10-25 (V14) round added `stream-eligible:bool` to
;; FVT|Schema -- the one-way latch an FVT owner sets, after proving
;; every enabled member is drift-locked, to be allowed to open TIME-STREAMED
;; injects. An FVT issued from this round on is born carrying `false`. Every FVT
;; written BEFORE this round has no such field, and this gives them one.
;;
;; Same Pact detail as the sibling: `with-default-read` defaults an absent ROW,
;; not an absent FIELD, and the RewardAggregate readers bind the whole row -- so
;; an un-migrated FVT faults on ordinary inject/collect traffic.
;;
;; ---------------------------------------------------------------------------
;; FALSE IS BOTH THE SAFE DEFAULT AND THE CORRECT GRANDFATHERING
;;
;; An un-latched FVT cannot open a NEW stream. Streams ALREADY RUNNING when this
;; round lands keep dripping untouched, because the drip (XI_ReleaseStream) is
;; driven by the release path and is NOT gated by FVT|C>INJECT-STREAM. That is
;; deliberate: halting a live vesting schedule would strand tokens already in
;; AQP|SC_NAME custody, owed to stakers, with no path out. Owners of such FVTs
;; latch when convenient; until they do, they inject instantly instead, which
;; fixes staleness inline and needs no latch.
;;
;; ---------------------------------------------------------------------------
;; RE-RUNNING LATER IS DESTRUCTIVE -- it writes `false` unconditionally, so a
;; second run would silently UNLATCH an FVT whose owner had already latched it.
;; Run once, here, before the surface is open to owners.
;;
;; ---------------------------------------------------------------------------
;; SIGNING
;;
;; GOV|FVT_ADMIN -- the Demiurgoi keyset. Same shape as AA_MigrateMinInject (which is
;; RPS-side); this one is AQP-FVT's because FVT|Schema is AQP-FVT's table.
;; ---------------------------------------------------------------------------

(namespace "ouronet-ns")

(ouronet-ns.AQP-FVT.AA_MigrateStreamEligible)
