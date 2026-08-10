# HANDOFF — PYTHIA ledger repair txs (mis-flushed day 18/19 → 7/8)

**Cause:** `UR_PythLedgerEpochStart` was briefly `2026-07-21` (+11 ordinal shift). Epoch is already fixed to `2026-08-01`. These txs only repair the bad daily rows.

**Schema mapping (handoff ↔ on-chain):**

| Handoff wording | Real `PYTHIA|T|PythDaily` field |
|-----------------|----------------------------------|
| flat counters | nested under `"metrics"` |
| `iz-complete` | `"iz-sealed"` |
| `iz-active` | **does not exist** on daily rows — ignore |

**Table:** `ouronet-ns.PYTHIA.PYTHIA|T|PythDaily`  
**Keys:** `"7"`, `"8"`, `"18"`, `"19"`  
**Signer:** Demiurgoi / module admin (`GOV|MD_PYTHIA` → `DALOS.GOV|Demiurgoi`).

**`PythTotal`:** leave alone. Bad flush *added* day-18 + day-19 into totals; after repair the same mass sits on day-7+day-8, so running totals stay consistent. `last-day` may remain `19` (rows still exist, zeroed) — next correct flush will advance as usual.

---

## 0) Pre-read (local / keyless) — confirm before signing

```pact
(namespace "ouronet-ns")
[
  (PYTHIA.UR_PythLedgerEpochStart)   ;; expect 2026-08-01T00:00:00Z
  (PYTHIA.UR_PythDay 7)
  (try { "missing": true } (PYTHIA.UR_PythDay 8))
  (PYTHIA.UR_PythDay 18)
  (PYTHIA.UR_PythDay 19)
  (PYTHIA.UR_PythTotal)
]
```

Day 7 should match:
`petitions 147564 · pondus 7456757.388 · gas-reserved 435108 · transactions 3 · sealed false`.

---

## 1) Repair tx — single `let` (admin + 4 writes + read-back)

Sign with Demiurgoi. Tx result is the four repaired rows `[day7, day8, day18, day19]`.

```pact
(namespace "ouronet-ns")
(acquire-module-admin PYTHIA)
(let
    (
        (now:time (at "block-time" (chain-data)))
        (row7:object (read PYTHIA.PYTHIA|T|PythDaily "7"))
        (m7:object (at "metrics" row7))
        (sealed7:bool (at "iz-sealed" row7))
        ;; Safety: day 7 must match the known pre-repair snapshot
        (_e0:bool (enforce (not sealed7) "REPAIR ABORT: day 7 already sealed"))
        (_e1:bool (enforce (= (at "petitions" m7) 147564) "REPAIR ABORT: day 7 petitions != 147564"))
        (_e2:bool (enforce (= (at "pondus" m7) 7456757.388) "REPAIR ABORT: day 7 pondus != 7456757.388"))
        (_e3:bool (enforce (= (at "gas-reserved" m7) 435108) "REPAIR ABORT: day 7 gas-reserved != 435108"))
        (_e4:bool (enforce (= (at "transactions" m7) 3) "REPAIR ABORT: day 7 transactions != 3"))
        ;; (1) day 7 += ex-day-18, seal
        (_w7:string
            (update PYTHIA.PYTHIA|T|PythDaily "7"
                { "iz-sealed": true
                , "flushed-at": now
                , "metrics":
                    { "petitions": (+ (at "petitions" m7) 3027)
                    , "pondus": (+ (at "pondus" m7) 143743.424)
                    , "transactions": (+ (at "transactions" m7) 1)
                    , "gas-reserved": (+ (at "gas-reserved" m7) 1017)
                    , "failed-transactions": (+ (at "failed-transactions" m7) 0)
                    , "wasted-gas-reserved": (+ (at "wasted-gas-reserved" m7) 0)
                    }
                }
            )
        )
        ;; (2) day 8 <- ex-day-19, leave OPEN
        (_w8:string
            (write PYTHIA.PYTHIA|T|PythDaily "8"
                { "day": 8
                , "flushed-at": now
                , "iz-sealed": false
                , "metrics":
                    { "petitions": 90256
                    , "pondus": 4649794.283
                    , "transactions": 7
                    , "gas-reserved": 22277
                    , "failed-transactions": 0
                    , "wasted-gas-reserved": 0
                    }
                }
            )
        )
        ;; (3) day 18 zeroed OPEN
        (_w18:string
            (update PYTHIA.PYTHIA|T|PythDaily "18"
                { "iz-sealed": false
                , "flushed-at": now
                , "metrics":
                    { "petitions": 0
                    , "pondus": 0.0
                    , "transactions": 0
                    , "gas-reserved": 0
                    , "failed-transactions": 0
                    , "wasted-gas-reserved": 0
                    }
                }
            )
        )
        ;; (4) day 19 zeroed OPEN
        (_w19:string
            (update PYTHIA.PYTHIA|T|PythDaily "19"
                { "iz-sealed": false
                , "flushed-at": now
                , "metrics":
                    { "petitions": 0
                    , "pondus": 0.0
                    , "transactions": 0
                    , "gas-reserved": 0
                    , "failed-transactions": 0
                    , "wasted-gas-reserved": 0
                    }
                }
            )
        )
        ;; Read-back: confirm rightful values
        (d7:object (read PYTHIA.PYTHIA|T|PythDaily "7"))
        (d8:object (read PYTHIA.PYTHIA|T|PythDaily "8"))
        (d18:object (read PYTHIA.PYTHIA|T|PythDaily "18"))
        (d19:object (read PYTHIA.PYTHIA|T|PythDaily "19"))
    )
    [d7 d8 d18 d19]
)
```

**Expected read-back:**

| Day | `iz-sealed` | petitions | pondus | gas-reserved | transactions |
|-----|-------------|-----------|--------|--------------|--------------|
| 7 | `true` | 150591 | 7600500.812 | 436125 | 4 |
| 8 | `false` | 90256 | 4649794.283 | 22277 | 7 |
| 18 | `false` | 0 | 0.0 | 0 | 0 |
| 19 | `false` | 0 | 0.0 | 0 | 0 |

---

## After repair

Next Khronoton `A_Flush` (correct epoch `2026-08-01`) should touch **day 8** (remainder of 08-08, still open) + **day 9** — not 18/19.
