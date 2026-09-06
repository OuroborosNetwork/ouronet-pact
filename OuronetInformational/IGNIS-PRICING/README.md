# IGNIS-PRICING — the #76 re-pricing documents

Everything about how an Ouronet op is priced lives here. Read in this order.

| document | what it is | freshness |
|---|---|---|
| **IGNIS-PRICING-PLAN.md** | **START HERE** — the phase plan with a dated status table, what is done, what is open, and the verification rules | **current** |
| **IGNIS-PRICING-SPEC.md** | the settled owner directives (2026-09-05) the implementation targets | **current**, with the later owner amendments listed in its header |
| **IGNIS-PRICE-SHEET.md** | GENERATED — the per-op price list off live code (`python3 REPL/_ignis_price_sheet.py > …`) | **current**, regenerate after any price change |
| **IGNIS-DETER-WORKSHEET.md** | GENERATED — per-op compute estimate + the owner-decided deterrence factors (`python3 REPL/_ignis_deter_worksheet.py > …`) | **current**, same |
| **URCI-COST-ARCHITECTURE.md** | the Option-A decision that introduced the `URCi_` prefix | implemented — read for the WHY |
| **GAS-SCHEDULE-DESIGN.md** | the parametric-gas-schedule design | adopted in principle; the `IG\|U` single-knob shape did NOT ship |
| **IGNIS-COST-ANALYSIS.md** | why the OLD cost structure was wrong | historical (pre-rehaul) |
| **IGNIS-COST-INVENTORY.md** | generated snapshot of what every op charged BEFORE the rehaul | historical (pre-rehaul baseline) |

## The model in one line

```
IGNIS charged = deter (IG|DETER) + the op's own compute (IG|COMPONENTS)      ;; UC_IgnisPrice
STOA  charged = only on ISSUE ops, the same dollar value, at the live peg    ;; UC_StoaPrice
```

Internal write legs inside `XI_`/`XB_` writers price from `IG|LEGS`; the cost-model primitives that
`IG|COMPONENTS` is computed from live in `IG|WEIGHTS`. All four tables are in
`1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` — a price is retuned there and nowhere else.

## Rules

* Every client op bills through `UC_IgnisPrice`. **No reader charges deterrence alone**, and no
  client path charges a legacy `UDC_<tier>Cumulator`.
* Every op has a `URCi_` cost reader; every INFO preview is a thin wrapper over that reader, so
  preview and execution cannot drift.
* **Verify price work with `ZALL.repl`, not `Z.repl`** — `Z.repl` skips the suite the price
  assertions live in.
