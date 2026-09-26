# The StoicPay (KPAY) sale card — the one AppReads reader still missing

`KPaySale.tsx` is the last OuronetUI page reading a function that does not exist. Three of its
four broken symbols were repaired at source in `ouronet-core` on 2026-09-26 (the module was
`DEMIPAD-STOICPAY`, not `DEMIPAD-KPAY`; the Talos wrapper is `TS02-CPAD.KPAY|C_BuyStoicPay`, not
`TS02-DPAD.KPAY|C_BuyKpay`; both gained a slippage-derived argument). The fourth,
**`DEMIPAD-KPAY.UR_Kpay`, is not a rename** — the deployed module has no per-account data object
at all.

This file is the spec for the reader that would replace it, so that "the page's data shape needs
deciding" stops being the blocker. **Every field below has a confirmed on-chain source.** What
actually needs a human is the WORDING of five display strings.

## What the page reads

Enumerated from `components/launchpad/KPaySale.tsx`, not guessed — seventeen keys.

| field | source | note |
|---|---|---|
| `kpay-id` | `DEMIPAD-STOICPAY::UR_KpayID` | |
| `open-for-business` | `DEMIPAD::UR_OpenForBusiness kpay-id` | page tests `=== true` |
| `start-date` | `(at "starting-time" (DEMIPAD::UR_Price kpay-id))` | **see the caveat below** |
| `period-ceiling` | `URv_PeriodAllocation (UR_GetPeriod)` | `0.0` before start and after 3 years |
| `remaining-for-mint` | `DEMIPAD-STOICPAY::UR_KpayLeft` | already period-aware |
| `minted` | `100000000.0 - (* 0.4 (DPTF::UR_AccountSupply kpay-id DEMIPAD\|SC_NAME))` | the `sold` term inside `UR_KpayLeft`; **not** separately exposed |
| `circulating-supply` | `DPTF::UR_Supply kpay-id` | |
| `account-kpay` | `DPTF::UR_AccountSupply kpay-id account` | the only per-account field |
| `kpay-wkda` | `(at "wstoa" (URC_KpayAmountCosts 1 0.0))` | per-unit WSTOA price |
| `native-buy-max` | `URC_GetMaxBuy account true` | |
| `wkda-buy-max` | `URC_GetMaxBuy account false` | |
| `sale-progress` | `(/ minted period-ceiling)` × 100 | **the page already computes this itself** |
| `stage-text` | formatted from `UR_GetPeriod` | wording needed |
| `sold-text` | formatted from `minted` | wording needed |
| `ceiling-text` | formatted from `period-ceiling` | wording needed |
| `remaining-text` | formatted from `remaining-for-mint` | wording needed |
| `next-stage-text` | formatted from `UR_GetPeriod` + period length | wording needed |

`sale-progress` is worth a decision rather than a port: the page derives it from `minted` and
`period-ceiling` already, and a reader that also returns it creates two places the same
percentage is computed. Prefer dropping it, and pair it with `*-hover` raw values the way
`O-UI-*` does — the AppReads convention is a formatted string beside the number it formats, so a
caller that needs precision is never handed only the display form.

## The caveat that stops this being mechanical

**`DEMIPAD::UR_Price` returns an untyped `object` whose keys differ per sale.** Measured on
mainnet for the live Spark sale:

```
(DEMIPAD.UR_Price (DEMIPAD-SPARK.UR_SparkID))
  => {"id": "SPARK-6B42e2_oW8j0", "boost": 400, "pid": 1.01}
```

No `starting-time`. Yet `DEMIPAD-STOICPAY::UR_GetPeriod` reads exactly that key off its own price
row, so the StoicPay row must carry a different shape. **That cannot be confirmed from the chain
today**, because:

> **The StoicPay sale is not initialised.** Every `DEMIPAD-STOICPAY` read currently fails with
> *"No value found in table `ouronet-ns.DEMIPAD-STOICPAY_KPAY|T|Properties` for key:
> `StoicPayV3`"*. The names resolve; the row does not exist.

So `UR_GetPeriod`, `UR_KpayLeft`, `URv_PeriodAllocation` and `URC_KpayAmountCosts` are all
**unexercised on mainnet**. Writing the card reader against them is sound — they are ordinary
readers on a deployed module — but **its first real run will be the first run of that whole
period/allocation path.** Worth a REPL scenario before a deploy rather than after.

## Order of work

1. **Initialise the sale** (or accept that the page cannot be verified end to end). Until the
   `StoicPayV3` row exists, no amount of reader work makes `KPaySale.tsx` render.
2. Decide the five strings' wording, and whether `sale-progress` belongs in the reader.
3. Write the reader. It fits the AppReads pattern exactly — one object, one page, `card-ok` first
   — and `O-UI-THREE::URC_Dispo` is the closest model: a single account argument, a formatted
   string beside each raw number.
4. Delete `getKpayData` from `ouronet-core` and add the redirect row, the way the other 47 reads
   were migrated.

Until step 3 lands, `DEMIPAD-KPAY.UR_Kpay` is the one remaining entry in
`OuronetUI/scripts/check-chain-symbols.py`'s accept-list that has a written path forward rather
than a blocked one. The other seven are `MB` (a module that was never deployed) and three
`DPL-UR` swap reads belonging to an unrouted, superseded surface.
