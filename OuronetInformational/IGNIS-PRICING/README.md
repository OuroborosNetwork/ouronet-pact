# IGNIS-PRICING — the #76 re-pricing documents

## Where to look

**Want the price of a function? → [`IGNIS-PRICE-SHEET.md`](IGNIS-PRICE-SHEET.md). That is the only
file you need.** It is generated from live code, grouped by Talos entity, and gives every op its
IGNIS total and STOA fee. This is the file the Chapter-2 documentation is written from.

Everything else in this folder explains *why* those numbers are what they are. You do not need
any of it to read a price.

| if you want to… | open |
|---|---|
| **look up what an op costs** | **`IGNIS-PRICE-SHEET.md`** ← the answer, 99% of the time |
| see what is done and what is still open | `IGNIS-PRICING-PLAN.md` |
| re-read the owner directives being implemented | `IGNIS-PRICING-SPEC.md` |
| see the raw compute estimate behind a price | `IGNIS-DETER-WORKSHEET.md` |
| understand why `URCi_` readers exist at all | `URCI-COST-ARCHITECTURE.md` |
| understand the parallel-wipe design | `HYDRA-WIPE-DESIGN.md` |
| dig into a past decision | `memories/` |
| read pre-rehaul history | `archive/` (nothing current lives there) |

## How to read a price-sheet row

```
| C_UpdateNonceScore | SETUP | **22** | — | $0.22 | deter:setup 5 + components:DPNF|C_UpdateNonce 17 |
                                ^^                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                        what the chain charges          the two halves it is made of
```

* A **bold number** (`**22**`) is exact: that op has fixed logic and always costs that.
* A **`≥` number** (`**≥ 500**`) is a floor: the op scales with how many items you pass it, so the
  real charge is that much *or more*. The Cost column reads `COMPLEX` for these.
* `—` in the STOA column means no STOA is charged. STOA is charged on **ISSUE ops only**.

## The model in one line

```
IGNIS charged = deter (IG|DETER) + the op's own compute (IG|COMPONENTS)      ;; UC_IgnisPrice
STOA  charged = only on ISSUE ops, the same dollar value, at the live peg    ;; UC_StoaPrice
```

Deterrence is **additive, not the total** — a $50 deterrent op still pays its ordinary compute on
top. Internal write legs inside `XI_`/`XB_` writers price from `IG|LEGS`; the primitives
`IG|COMPONENTS` is computed from live in `IG|WEIGHTS`. All four tables sit in
`1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` — **a price is retuned there and nowhere else.**

## Rules

* Every client op bills through `UC_IgnisPrice`. **No reader charges deterrence alone**, and no
  client path charges a legacy `UDC_<tier>Cumulator`.
* Every op has a `URCi_` cost reader; every INFO preview is a thin wrapper over that reader, so
  preview and execution cannot drift.
* **Verify price work with `ZALL.repl`, not `Z.repl`** — `Z.repl` skips the suite the price
  assertions live in.
* Regenerate both generated files after any price change:
  ```bash
  python3 REPL/_ignis_price_sheet.py     > OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md
  python3 REPL/_ignis_deter_worksheet.py > OuronetInformational/IGNIS-PRICING/IGNIS-DETER-WORKSHEET.md
  ```
