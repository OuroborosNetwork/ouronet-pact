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

### The STOA rule

An issuance op's STOA fee carries the **same dollar value as its deterrence**, converted at the
hard peg (`stoa|price` = $0.10):

```
STOA = (deter / 100) / stoa|price          ;; IGNIS::UC_StoaPrice
     =  dollars(deter) / 0.10
```

So `issue-tf` deter 1000 → $10 → **100 STOA**; `issue-nft` 2500 → $25 → **250 STOA**;
`issue-swp-pair` 5000 → $50 → **500 STOA**. When a real oracle price replaces the $0.10 peg the
STOA *amount* moves but the *value* the user pays does not. The full asset-issuance table:

| op | deter | = | STOA @ $0.10 |
|---|---:|---:|---:|
| `DPTF\|C_Issue` | 1000 | $10 | 100 |
| `DPOF\|C_Issue` | 1000 | $10 | 100 |
| `DPSF\|C_Issue` | 2000 | $20 | 200 |
| `DPNF\|C_Issue` | 2500 | $25 | 250 |
| `ATS\|C_Issue` | 4000 | $40 | 400 |
| `SWP\|C_IssueStable` / `C_IssueWeighted` | 5000 | $50 | 500 |
| `DPSF\|C_IssueCompany` | 10000 + 2000 | $120 | 1200 |
| `AQP-POOL\|C_Issue` / `AQP-FVT\|C_Issue` / `AQP-SCR\|C_Issue*Score` | 1000 | $10 | 100 |
| `AQP-ANK\|C_Issue*Anchor` | 500 | $5 | 50 |
| account deploy — standard / smart | 500 / 1000 | $5 / $10 | 50 / 100 |
| branding blue flag, **per month** | 2500 | $25 | 250 |

Every one of these derives from `IG|DETER` through `UC_StoaPrice`. **No STOA price is a hardcoded
amount** — retune the dollar value in `IG|DETER` and every consumer follows.

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
