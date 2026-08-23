# Time-streamed reward inject (linear vesting release) — Phase-0 design

**Status:** ✅ APPROVED / LOCKED by owner 2026-08-23. Implementation started (build order §9). Evidence base = 3
deep-read traces (RPS accumulator flow, Elite-tier + smart/sovereign resolution, dust/conservation behaviour).

**Feature:** a reward inject may optionally release its amount **linearly over a duration** instead of instantly.
`inject 240 PURO over 24h` ⇒ the amount vests continuously (sub-second granularity), and whoever is staked during
each slice earns that slice. Instant inject (`duration = 0`) is unchanged. Canonical use case: a daily automation
injects cumulated IGNIS gas over 24h — "gas earned by validators like a real chain."

---

## DECISIONS (locked with owner during design discussion)

- **D1 — Semantics = S1 (open stream).** Late stakers earn the portion of the stream released *after* they join
  (superposition of who-is-staked-when). This is the defining difference from instant inject (where late stakers
  miss it entirely). The cohort-locked S2 variant (only inject-time stakers benefit) is explicitly **NOT** built.
- **D2 — Scope = every FVT class** (farm class 0 + vault/treasury class 1/2).
- **D3 — Drip accuracy = A1 (exact).** The accumulator is checkpointed ("dripped") at *every* weight change. Vault
  drip is O(1); farm drip is O(members) (re-runs the split) — accepted, and only paid while a stream is live.
- **D4 — Independent overlapping streams, NO merge.** A new inject never mutates a running stream's rate/finish.
  During an overlap window both streams pay simultaneously. (Synthetix single-rate merge was rejected: it dilutes
  the old stream's tail.)
- **D5 — Cap by Elite tier of the FVT owner konto**, snapshot at inject time. `slots = max(1, (major−1)×7 + minor)`
  — everyone gets ≥1, max 49. Smart accounts resolve to their sovereign standard account. Slots full ⇒ only
  direct/instant injects until a stream finishes and frees a slot. Finished streams are pruned → free their slot.
- **D6 — Storage = keyed side table** `FVT|T|RPS|Stream` (position 1..49) + a `stream-count` on the Global row.
  **Compacted** (occupied is always positions 1..count) — no `occupied`/`available` flags needed. UI renders as 7×7.
- **D7 — Duration bounds:** `0` = instant (unchanged path); else `1h ≤ duration ≤ 365d` (3,600 … 31,536,000s).
- **D8 — Min-rate guard (anti-degeneracy, stream-only):** `amount / duration ≥ STREAM_MIN_UPS × 10^(−decimals)`,
  `STREAM_MIN_UPS = 10,000,000` (10M smallest token-units per second). Precision-normalized ⇒ uniform across tokens.
  Instant inject gets **no new limit** (keeps existing `amount > 0`).
- **D9 — Dust = option (i):** reuse the existing 48-dp index (`CT_FVT_RPS_PREC = 48`) + last-claimant sweep. NO
  settle rework. Zero-weight interval → `zombie-rewards`. Exact-remainder flush at each stream's finish (release
  `amount − released`) guarantees per-stream conservation; sub-token crumbs stay conserved to the last claimant
  exactly as today (proven by `[6.4]_AQP-TRIPLET-COLLECT` CL04 / `[6.2.4]_AQP-FVT` FVT-09).
- **D10 — Enforced-fresh gate stays at inject** (`CC_Inject` Phase-0 stale-fix runs before a streamed inject too).
- **D11 — Talos exposes both** a *direct* (instant) and a *delayed* (streamed) inject wrapper. Add
  `URC_LiveClaimable` for real-time UI. **No public `poke`** — the UI reader is a live *projection* (derives vested
  value from the clock, not stored state), so it never goes stale; the stored accumulator self-heals on the next
  interaction, and pools drip constantly from normal traffic. A poke would only help an external consumer of the raw
  stored accumulator, of which there are none. Dropped as dead weight.

**Owner review:** D7 min-duration = **1h** (owner, 2026-08-20); public poke **dropped** (owner, 2026-08-20). Both
resolved — nothing blocks the build.

---

## 1. The key realization

Streaming maps onto **two different distribution models** the codebase already has (trace 1):

| Class | Today's distribution | Where the drip feeds |
|---|---|---|
| **Vault/Treasury** (1/2) | inject bumps the global accumulator `current-rps` (G); users read `(G−last-rps)×w` lazily. | `G += UC_ComputeInjectGainedRps(releasable, S)` — **O(1)** |
| **Farm** (0) | inject splits by *live per-member STOA weight* and bumps each member index `Lᵢ` (`XI_1\|FarmSplitInject`). No global accumulator. | `XI_1\|FarmSplitInject(releasable)` — **O(members)** |

The elegant part: **streaming only changes how much is fed and when — not the distribution itself.** The drip
computes one aggregate `releasable` and hands it to the *existing* machinery at the *current* weight. Because a drip
runs at every weight change (D3), each inter-drip interval has constant weight, so splitting `(interval × rate)` by
that constant weight equals the time-integral **exactly** — no approximation, any number of overlapping streams.

The only genuinely new state is the **stream ledger** (rate/finish per active stream) and the **drip** that walks
it. Everything downstream (available-rewards, member vaults, last-claimant sweep, deb-staleness) is untouched.

---

## 2. Schema deltas (all module-local, FVT V1 edited in place — pre-mainnet)

### 2a. New table — the stream ledger
```
(defschema FVT|RPS|Stream
    @doc "Key = <FVT-ID> | <DPTF-ID> | <position 1..49>. One live linear-release stream on a reward lane. \
        \ Positions are kept COMPACT (occupied = 1..stream-count); a finished stream is pruned and later \
        \ positions shift down. UI renders position n as tier-style major.minor (major=ceil(n/7), \
        \ minor=((n-1) mod 7)+1)."
    rate:decimal          ;; token-per-second (amount / duration), high precision
    finish:time           ;; block-time when this stream stops releasing
    amount:decimal        ;; original streamed amount (for the exact-remainder flush)
    released:decimal      ;; cumulative released so far (drives flush = amount - released at finish)
    ;; Select keys
    fvt-id:string
    dptf-id:string
    position:integer
)
(deftable FVT|T|RPS|Stream:{FVT|RPS|Stream})   ;; Key = <FVT-ID> | <DPTF-ID> | <position>
```

### 2b. New fields on `FVT|RPS|Global`
```
stream-count:integer        ;; occupied stream positions on this lane (0 = no active stream)
stream-last-release:time    ;; shared lane checkpoint — every stream's start ≤ this (adds are drip-preceded)
stream-unreleased:decimal   ;; custodied-but-not-yet-dripped total (held at AQP|SC_NAME, invisible to
                            ;; available-rewards / M1 sweep until dripped)
```
(A shared `stream-last-release` is sound because a new stream is only ever added *after* a drip, so every active
stream's start ≤ the shared checkpoint — the per-stream releasable is then `rate × (min(now,finish) − last-release)`.)

### 2c. New constants
```
(defconst STREAM_MIN_UPS       10000000)    ;; min smallest-token-units/sec for a stream (anti-degeneracy floor)
(defconst STREAM_MAX_DURATION  31536000)    ;; 365 days, in seconds
(defconst STREAM_MIN_DURATION  3600)        ;; 1 hour (D7)
(defconst STREAM_MAX_LANES     49)          ;; hard ceiling (7×7); the per-account cap is ≤ this
```

---

## 3. The drip — `XI_ReleaseStream(fvt-id, dptf-id)`

> **NB — the block below is illustrative PSEUDOCODE, not Pact.** The `for … in`, `+=`, `min(…)`, and imperative
> mutation are only to convey the algorithm. The real implementation is idiomatic Pact/StoicSyntax: the position
> walk is a `fold` (or a recursive `XI_` helper) accumulating functionally — no mutable loop; reads via `with-read`
> / `UR_*`; writes via `WU_*` under `require-capability`; `now` = `(at "block-time" (chain-data))`, elapsed =
> `(diff-time now last)`; distribution via the existing `UC_ComputeInjectGainedRps` / `XI_1|FarmSplitInject`. All
> pseudocode in this doc (§4, §5) is the same — spec, not source.

The checkpoint. Guarded so **non-streamed lanes pay ~nothing** (single read → return).

```
XI_ReleaseStream(fvt-id, dptf-id):
    count = UR stream-count
    if count == 0: return                                   ; fast no-op — the common case
    now  = (at "block-time" (chain-data))
    last = UR stream-last-release
    total = 0.0 ; keep = []                                 ; survivors after prune
    for pos in 1..count:
        s = read FVT|T|RPS|Stream (fvt|dptf|pos)            ; {rate, finish, amount, released}
        remaining = s.amount - s.released
        if now >= s.finish:
            rel = remaining                                 ; EXACT-REMAINDER FLUSH (zero dust)
        else:
            rel = min( (* s.rate (diff-time now last)), remaining )   ; clamp ≤ remaining (rate-rounding safe)
            keep += [ {s | released: s.released + rel} ]     ; survives
        total += rel
    ; --- distribute `total` through the EXISTING machinery at the CURRENT weight ---
    S = class==0 ? URC_FarmInjectDenominatorFresh : URC_InjectDenominator
    if S > 0:
        class==0 ? XI_1|FarmSplitInject(total)
                 : ( G += UC_ComputeInjectGainedRps(total, S) ; available-rewards += total )
    else:
        zombie-rewards += total                             ; D9 zero-weight interval → escrow
    ; --- commit ledger: rewrite survivors to compacted positions 1..len(keep), set count, unreleased, last ---
    write keep to positions 1..len(keep) ; stream-count = len(keep)
    stream-unreleased -= total
    stream-last-release = now
```

**Notes.** `rel` is kept at full decimal precision (the 48-dp floor lives inside `UC_ComputeInjectGainedRps` / the
payout, both already conserved). The clamp `min(…, remaining)` + the finish-flush guarantee `Σ rel = amount` exactly
per stream, so no stream can over- or under-release. Compaction = rewrite survivors to the front; pruned tail rows
are stale garbage we never read (overwritten on the next add).

---

## 4. Cap resolver + guard

### 4a. `URC_MaxStreamLanes(account) -> integer` (via the existing DALOS ref)
```
tier-acct = (UR_AccountType account) ? (UR_AccountSovereign account) : account   ; smart → sovereign
major = UR_Elite-Tier-Major tier-acct   ; 0..7
minor = UR_Elite-Tier-Minor tier-acct   ; 0..7
return max(1, (+ (* (- major 1) 7) minor))    ; 0.0→1, 1.1→1, 1.2→2, 2.5→12, 7.7→49
```

### 4b. `UEV_StreamParams(owner, fvt-id, dptf-id, amount, duration, reward-dec)`
Only fires for `duration > 0` (instant path skips it):
```
enforce (fold (and) true [ (>= duration STREAM_MIN_DURATION)
                           (<= duration STREAM_MAX_DURATION)
                           (>= (/ amount duration) (* STREAM_MIN_UPS (^ 10.0 (- reward-dec)))) ])  "..."
enforce (< (UR stream-count) (URC_MaxStreamLanes owner))   "stream slots full — use a direct inject"
```

---

## 5. Touch-points — where the drip hooks in

The drip runs **per reward lane** (fvt-id | dptf-id), inside the existing per-reward-DPTF loops
(`URH_FVT-RG|EnabledRewardRows`). Checkpoint-first everywhere a weight changes or a payout is read:

| Site | Fn (line) | Action |
|---|---|---|
| **Inject** | `XI_FvtInjectCore` (4876) via `XB_FvtInject` (5097) | drip lane → then: `duration=0` distribute now (today's path); `duration>0` `UEV_StreamParams` + add stream at `count+1`, `count++`, `stream-unreleased += amount`, custody transfer |
| **Stake** | `XI_RpsPreScore` (4294) | drip lane **before** the weight mutation (`XI_SyncFvtTotalDebMirrors` 4172 / triplet 4203 / farm ghost 4375) |
| **Unstake** | `XI_RpsPreScore` (4294) | drip lane before weight mutation (last unstake → next drip sees weight 0 → zombie) |
| **Collect** | `C_Collect` (3507) | drip lane before `URC_CollectClaimableRewards` (2407) |
| **Deb-fix** | `XI_FixUserMemberDeb` / `CC_InjectFixChunk` (3287) | drip lane before settle |
| **Sweep** | `XI_FvtSweepRecomputeChunk` | drip lane before recompute |

Independent-streams create (inject, `duration>0`): **drip first**, then append — never merge. Instant inject during
live streams: drip first, distribute immediately, **no slot consumed**.

---

## 6. Reads (UI)

- `URC_LiveClaimable(user, fvt, score, dptf)` — read-only; computes the effective index *as if dripped to now*
  (`index + projected releasable / S`) so the UI shows accrual ticking with no tx. Purely computational — it derives
  the vested value from the clock, not stored state, so it never goes stale even on a long-idle stream.
- `URC_StreamStatus(fvt, dptf)` — `{active-count, total-rate, earliest-finish, unreleased}` for the 7×7 UI.

*(No public `poke` — dropped per D11. Lazy drip + this projecting reader fully cover correctness and display; a
long-idle stream catches up exactly in one O(1)/O(members) drip on the next interaction, cost independent of elapsed
time.)*

---

## 7. Conservation & dust (D9 — no settle rework)

- Streams route their released amount through the **same** `available-rewards` (vault) / member vault (farm), so
  they inherit the audited last-claimant sweep — floored crumbs are conserved to the terminal claimant, never lost.
- Per-stream `Σ rel = amount` exactly (clamp + finish-flush), so no stream strands custody.
- Zero-weight interval → `zombie-rewards` (existing escrow), flushed by the next non-zero drip/inject.
- The min-rate guard (D8) blocks degenerate micro-streams at inject; the 48-dp index gives ~7+ orders of headroom
  above any token's precision, so realistic streams never round at the index.

---

## 8. Test plan (REPL, mirror `[6.2.x]`/`[6.4]` canonical layout)

1. **Guard/resolver units:** rate-floor pass/fail, duration bounds, slot-cap reject, `URC_MaxStreamLanes`
   (smart→sovereign, `max(1,…)` at 0.0/1.1/1.2/2.5/7.7).
2. **Superposition:** two overlapping 24h streams → during overlap both pay; after the first finishes only the
   second continues (the owner's 50-min example).
3. **Late staker (S1):** Alice@h0, Bob@h12 on `240/24h` → Alice 180 / Bob 60 (proves late stakers capture the drip).
4. **Compaction:** create 5 streams, finish #3 → positions compact to 1..4, `count=4`, new create reuses position 5.
5. **Cap:** create up to the tier cap → next streamed inject rejected; a *direct* inject still succeeds; a stream
   finishes → a slot frees → streamed inject allowed again.
6. **Zero-weight → zombie:** everyone unstakes mid-stream → elapsed slice lands in `zombie-rewards`; next inject
   flushes it.
7. **Dust/conservation:** `Σ payouts = injected` across a streamed lane; last-claimant sweep drains vaults to ~0
   (mirror CL04 / FVT-09).
8. **Farm A1 exactness + gas:** streamed farm dripped on every stake/unstake; measure the O(members) drip cost
   (calibrate against the existing scale harness).
9. **Instant coexist:** instant inject during a live stream distributes immediately, consumes no slot, unchanged.
10. **Integration:** daily-gas scenario — repeated daily streamed IGNIS injects with a rolling overlap window.

---

## 9. Interface versioning & build order

**Versioning:** FVT is pre-mainnet **V1 → edited in place**. New schema/table/constants are module-local. The
inject entrypoints gain a `duration` param → cascade the signature to the Talos wrappers (TS02-C3 `AQP-FVT|C_Inject`
1748 / `CC_Inject` 1766 / `CC_InjectFinalize` 1806, and `MTX-AQP|C_2|Inject` 1826) and the MTX defpact. New URC
readers that return module schemas stay module-only (interface object-return rule).

**Build order (each step green before the next):**
1. Schema + `deftable` + constants + `UDC_FVT|RPS|Stream` constructor; add the 3 Global fields (+ defaults).
2. `URC_MaxStreamLanes` + `UEV_StreamParams`.
3. `XI_ReleaseStream` — vault branch first (prove drip + compaction + flush on a treasury), then the farm branch.
4. Wire the drip into inject (instant vs add-stream), then stake/unstake/collect/deb-fix/sweep.
5. `URC_LiveClaimable` + `URC_StreamStatus`.
6. Talos direct + delayed wrappers; thread `duration` through.
7. Tests 1→10; then a gas pass on the streamed farm drip.

---

*Author: design discussion 2026-08-20. Awaiting owner ✅ before implementation.*
