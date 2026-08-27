# 2026-08-20 — Hoist loop-invariant scans out of per-user CC-batch loops

Found while chasing "why is a 50-user inject 3.96M gas?" during the AQP scale-test pass. Two accidentally-quadratic
scans in the FVT settle path blew CC-batch cost up **super-linearly**. Both fixed by the same move; this note is the
reusable pattern + the audit conclusion that followed.

## The smell

A `CC_*Chunk` (heavy batch client) pages a set of users and does per-user work in a `map`/`fold`. If the per-user
leaf calls a `URH_`/`select` **whose argument does not depend on the user**, that scan re-runs once *per user* — the
loop is O(users × table), not O(users). The scan result is **loop-invariant**, so it should be computed **once** and
passed in.

Both offenders scanned FVT-level tables keyed only by `fvt-id` (never by the user):

| Re-scanned per user | Table | Correct scope |
|---|---|---|
| `URH_FvtEnabledScoreEntityIdsForFvt fvt-id` | `FVT\|T\|ScoreEntityLink` | once per chunk |
| `URH_FVT-RG\|EnabledRewardRows fvt-id` | reward-generator rows | once per chunk |

## The fix pattern — `*In` twins that take the pre-computed list

For each leaf that re-scanned, add a twin taking the scanned list as a parameter; keep the original as a thin
single-user convenience that scans once then delegates:

```lisp
; leaf: was scanning per call
(defun XI_FixUserFvtDeb (fvt user)                       ; convenience — one scan, then delegate
    (XI_FixUserFvtDebIn fvt user (URH_FvtEnabledScoreEntityIdsForFvt fvt)) )
(defun XI_FixUserFvtDebIn (fvt user members)             ; twin — no scan, iterates the passed list
    ...)

; caller: scan ONCE, reuse across the whole chunk
(let ( (batch:[string]   (take chunk stale))
       (members:[string] (URH_FvtEnabledScoreEntityIdsForFvt fvt-id))    ; hoisted
       (reward-rows:[string] (URH_FVT-RG|EnabledRewardRows fvt-id)) )     ; hoisted
    (map (lambda (u) (XI_FixUserFvtDebPenalizedIn fvt-id reward-dptf-id u members reward-rows)) batch))
```

Landed as: member-list hoist (**b529bbb**) + reward-rows hoist (**156af20**). Every caller — batch `CC_*Chunk`,
single-tx `CC_Inject` PHASE-0, MTX `C_2|Inject` defpact, `XE_FvtFixUserChunk`, `XI_FvtSweepRecomputeChunk` — computes
`members` + `reward-rows` once per chunk and threads them down. Shared leaves ⇒ **all three path shapes** (batch /
single-tx / defpact) get the speedup at once.

## Measured effect (50-user scale, `REPL/Kursan/AQP-scale-*.repl`)

| Op | Before | After | Factor |
|---|---|---|---|
| inject fix round (15 users) | 3,957,034 | 276,925 | **14×** |
| inject finalize | 2,106,332 | 146,273 | 14× |
| sweep recompute (15 holders) | 666,317 | 106,300 | **6.3×** |

All now fit the 2M block target with headroom (~18k/user inject, ~7k/holder sweep).

**Watch-out:** a single-tx path can be fixed while a batch path still calls the old convenience leaf. `CCp_InjectFixChunk`
kept calling per-user `XI_FixUserFvtDebPenalized` (the scanning convenience) after the *sweep* path was hoisted — so
sweep dropped to 106k but inject stayed at 1.4M until `CCp_InjectFixChunk` was re-pointed at the `*In` twin (156af20).
**When you hoist, grep every caller of the convenience leaf, not just the one you were measuring.**

## Follow-on audit — are the URH definitions themselves self-quadratic?

Swept every AQP `URH_`/`URHC_` definition for a scan-inside-a-loop. Two shapes, only one is a bug:

- **Benign** — `(map (at "field") (select …))` / `(fold … (select …))`: mapping/folding over **one** scan's output
  rows. One scan, then in-memory work.
- **Quadratic** — `(map (lambda (x) (select … x)) list)`: a **fresh scan per element**.

Findings:
- **FVT builders** (`URH_FVT-RG|EnabledRewardRows` 1825, `URH_FVT|SettleFvtRewardBundle` 1840 the canonical
  "single table pass", `URH_FvtEnabledScoreEntityIdsForFvt` 1878, `URHC_BuildInjectScorePlans` 2545,
  `URHC_BuildStakeSettleBundle` 2565) — all benign / already hoist their scans into a `let` then loop with point reads.
- **VCT vacate lane scanners** (`URH_Vacate*PoolLegs` 1020/1038/1056) — scan **per asset-lane** (`dptf-ids` etc.),
  but a pool holds only a handful of distinct assets, **not** a user-scaling count. Bounded.
- **VCT inventory readers** (`URH_Vacate*Inventory` + `…NonceRows` 1204–1265) — exactly one tracker scan each, then
  `map`/`fold` over its rows. Benign.

**Conclusion: no remaining user-scaling quadratics in the URH definitions.** The only genuine per-user quadratics were
the two hoisted above. A `URH_` that maps over one `select`'s rows is fine; a `URH_` that scans **once per asset-lane**
is fine (lane count is a small constant). The danger is only a scan whose argument is the **loop variable of a
user-sized set**.

Ref: `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/04_FVT.pact` (`*In` twins), `05_VCT.pact` (vacate scanners); scale probes
`REPL/Kursan/AQP-scale-{inject,sweep,vacate}.repl`; commits b529bbb, 156af20.
