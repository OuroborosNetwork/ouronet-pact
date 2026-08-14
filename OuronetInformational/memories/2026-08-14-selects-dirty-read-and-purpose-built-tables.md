# 2026-08-14 — Selects, dirty-read, and purpose-built tables (owner guidance)

Durable rules learned during the M3 #12 deb-staleness work. Apply going forward.

## Selects are cheap under the 2M execution ceiling
Owner ran, via Pythia on **mainnet** state (a 15k-row NFT-nonce table):
- `DPDC.URD_ExistingCollectables "DHB-…" false` (select over 15k rows) → **~40,031 gas**
- `DPDC.URD_AccountNonces <account> "DHB-…" false` (returns ~700–800 filtered nonces of 15k) → **~59,231 gas**

Against the ~2,000,000 execution ceiling that is a 30–50× margin. So `select`/`keys` are **not**
a gas problem at realistic Ouronet scale. The StoicSyntax "no scans on the execution path" rule is
a *discipline / determinism* preference, not primarily a gas limit — and it can be relaxed for
infrequent, admin/gas-station-paid, `CC_`/`AA_`-marked (R3) paths (inject, wipe, sweep).

Deploy ceiling is ~150k gas (different budget); a select can exceed that but rarely the 2M exec ceiling.

## Dirty-read + locked-function pattern (for reads that DON'T fit in a tx)
`select`/`keys` were "never meant for a transactional context." When an enumeration is too big to run
in-tx, run it in **dirty read mode** (local / non-consensus, e.g. Pythia or a `local` call), then pass
the resulting list as an **argument** into a capability-locked transactional function that re-validates
and mutates. This is exactly how the wiping paths work: `URD_…` (select) enumerates → the list feeds
`XE_…Debit…(… wipe-mode:true)` under caps. Safe when a bad/incomplete caller-list can only *weaken* the
result, never corrupt state (e.g. refreshing a non-member is a no-op).

## Purpose-built tables for data you need
If computing something live requires many layers of enumeration (e.g. FVT → its score entities →
per-score aqpool-links → dedup pools → per-pool-class tracker selects → dedup users), **don't** compute
it live — **maintain a purpose-built table/structure** updated at the cheap write points. Prefer a
**dedicated boolean-membership table** (e.g. `key = A|B → is-present:bool`, with A and B as select-keys)
over a growing **list-in-a-row**: the boolean gives O(1) point-write maintenance and one select over a
small dedicated table, whereas a big list makes *every* read of the owning row carry the whole list
(and membership checks re-read it repeatedly). Add-only is often enough — a stale "present" row that
should be gone is harmless if the consumer no-ops on it; lazily prune later.

## No hidden select primitives
The codebase uses plain documented `select`/`keys`. `fold-db` (fold over a table w/ filter+accumulator,
no full-list materialization) exists in Pact and *could* be marginally cheaper on huge tables, but is
used nowhere here and is unnecessary given the gas data above. `URD_` prefix marks these heavy reads.

## Concrete application — M3 #12 2c (planned)
Enumerating "all users in an FVT" has no cheap path (RPS|User is keyed User-first). Chosen shape:
new `FVT|UserPresence` table `fvt-id | ouronet-id → is-present`, add-only, written on stake (per staked
pool's scores → `ScoreFvtLink` → write true). `CC_InjectChecked` selects it per fvt (cheap), refreshes
stale positions (settle-old → refresh SCORE deb → `XI_SyncFvtTotalDebMirrors`), re-checks, injects.
