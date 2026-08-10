# HANDOFF — Repair day 8 clobber + reset last-day (after A_Flush accumulate fix)

**Prerequisite:** Deploy fixed `23_PYTHIA.pact` first (`A_Flush` ADDs deltas; seal does not replace).

**Damage:** replace-path flush set day 8 = last delta only (`3049` petitions…) instead of
`90256 + 3049`. Also left `last-day = 19` from the wrong-epoch window.

**Also repairs `PythTotal`:** the replace path did `total − oldDay + newDay`, so the grand total
lost the same clobbered mass. Adding it back onto day 8 **and** `total-metrics` restores
`Σ days = total`.

**Signer:** Demiurgoi / `acquire-module-admin PYTHIA`.

---

## Repair tx (single `let` + read-back)

```pact
(namespace "ouronet-ns")
(acquire-module-admin PYTHIA)
(let
    (
        (now:time (at "block-time" (chain-data)))
        (row8:object (read PYTHIA.PYTHIA|T|PythDaily "8"))
        (m8:object (at "metrics" row8))
        (tot:object (read PYTHIA.PYTHIA|T|PythTotal "stoachain"))
        (tm:object (at "total-metrics" tot))
        ;; Safety: current day 8 should be the clobbered seal flush remnant
        (_e0:bool (enforce (at "iz-sealed" row8) "REPAIR ABORT: day 8 not sealed"))
        (_e1:bool (enforce (= (at "petitions" m8) 3049) "REPAIR ABORT: day 8 petitions != 3049"))
        (_e2:bool (enforce (= (at "pondus" m8) 140216.612) "REPAIR ABORT: day 8 pondus != 140216.612"))
        (_e3:bool (enforce (= (at "gas-reserved" m8) 1000) "REPAIR ABORT: day 8 gas-reserved != 1000"))
        (_e4:bool (enforce (= (at "transactions" m8) 1) "REPAIR ABORT: day 8 transactions != 1"))
        ;; Clobbered mass to ADD back (ex day-19 / admin-repair base that was overwritten)
        (add-pet:integer 90256)
        (add-pondus:decimal 4649794.283)
        (add-gas:integer 22277)
        (add-tx:integer 7)
        (_w8:string
            (update PYTHIA.PYTHIA|T|PythDaily "8"
                { "iz-sealed": true
                , "flushed-at": now
                , "metrics":
                    { "petitions": (+ (at "petitions" m8) add-pet)
                    , "pondus": (+ (at "pondus" m8) add-pondus)
                    , "transactions": (+ (at "transactions" m8) add-tx)
                    , "gas-reserved": (+ (at "gas-reserved" m8) add-gas)
                    , "failed-transactions": (at "failed-transactions" m8)
                    , "wasted-gas-reserved": (at "wasted-gas-reserved" m8)
                    }
                }
            )
        )
        (_wt:string
            (write PYTHIA.PYTHIA|T|PythTotal "stoachain"
                { "last-day": 9
                , "total-metrics":
                    { "petitions": (+ (at "petitions" tm) add-pet)
                    , "pondus": (+ (at "pondus" tm) add-pondus)
                    , "transactions": (+ (at "transactions" tm) add-tx)
                    , "gas-reserved": (+ (at "gas-reserved" tm) add-gas)
                    , "failed-transactions": (at "failed-transactions" tm)
                    , "wasted-gas-reserved": (at "wasted-gas-reserved" tm)
                    }
                }
            )
        )
        (d8:object (read PYTHIA.PYTHIA|T|PythDaily "8"))
        (t:object (read PYTHIA.PYTHIA|T|PythTotal "stoachain"))
    )
    [d8 t]
)
```

**Expected day 8 after repair:**

| field | value |
|-------|-------|
| petitions | 93305 |
| pondus | 4790010.895 |
| gas-reserved | 23277 |
| transactions | 8 |
| iz-sealed | true |

**Expected total:** `last-day = 9`; `total-metrics` increased by the same add-* deltas.

---

## Deploy order

1. Redeploy **`1_SOVEREIGN/STAGE_01/2_Core/23_PYTHIA.pact`** (accumulate fix).
2. Sign + submit this repair tx.
3. Next Khronoton flush continues on day 9+ with ADD semantics.
