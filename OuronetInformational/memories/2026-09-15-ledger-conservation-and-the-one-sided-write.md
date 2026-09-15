# Ledger conservation — the invariant nothing had ever checked

*2026-09-15. Red-team Stage 10, family J. One defect found and fixed: `DPTF|C_ClearDispo`.*

## The invariant

For every DPTF: **`UR_Supply id` == the sum of `UR_AccountSupply id account` over every account.**

It had never been asserted. Every conservation assertion in 103,000 lines of REPL was **local and
hand-named** — `op+emma+lumy = 5000`, three accounts, one scenario. Nothing swept.

## Why the two halves can drift

They are written by different code, in different modules:

| | written by | lives in |
|---|---|---|
| supply | `DPTF::XBv_UpdateSupply` | `DPTF|PropertiesTable` |
| balance, non-core token | `DPTF::XI_UpdateBalance` → `WW_UpdateBalance` | `DPTF|BalanceTable` |
| balance, **core** token (OURO, IGNIS) | `XI_UpdateBalance` → **`DALOS::XB_UpdateBalance`** | **`DALOS|AccountTable`** |

So for the two tokens the whole economy is denominated in, supply and balances are not even owned
by the same module.

## The defect

`09_TFT.pact::C_ClearDispo` step 6 called `DALOS::XB_UpdateBalance account true 0.0` **directly**,
with no paired supply update.

A dispo **is** a negative OURO balance — the defcap refuses anything else (`"Dispo Clear requires
Negative OURO"`) — and supply counts it as negative, because the sublimation that opened the dispo
decremented supply by the amount it drove the balance below zero. Zeroing the balance therefore
returns tokens to the ledger, and supply was never told. `ico5`'s burn ends up counted twice: once
against ATS's real OURO, once against the phantom OURO the dispo represented.

Measured after `[6.2]_DPTF` + `[6.3]_SWP`: **296 tokens, 739 rows, 295 exact, OURO off by −8.0**,
i.e. supply 8 BELOW the tokens actually held. Cumulative: the gap widens by every dispo ever cleared.

**Fix** — one line, pairing the write with its supply half:

```pact
    (ref-DALOS::XB_UpdateBalance account true 0.0)
    (ref-DPTF::XBv_UpdateSupply ouro-id ouro-amount true)
```

`ouro-amount` is `(abs …)` of a balance the defcap has already forced strictly negative, so it is
always > 0 and `UEV_Amount` inside `XBv_UpdateSupply` is always satisfied.

## The generalisable check

**`DALOS::XB_UpdateBalance` has five call sites. Four are halves of a pair** — debit+credit of an
IGNIS transfer (`02_IGNIS.pact:1793/1805`), the same for DPDC-T (`07_DPDC-T.pact:855/865`) — or
DPTF's own dispatch (`05_DPTF.pact:2748`), whose callers pair it at the `C_` level.
**ClearDispo was the only one-sided one.** That is the shape to grep for next time: a balance
writer invoked once, with no sibling.

## What made the sweep trustworthy, and what nearly made it a lie

The first run reported OURO conserved and **GAS off by 9302.0225**. *Both were wrong.* Core-token
balances live in DALOS, and the sweep was summing them over only the 6 accounts that happened to own
a DPTF placeholder row, out of 24.

Two guards now make the sweep non-vacuous, and **both fired for real**:

1. **Partition completeness** — two token ids CONTAIN the key separator (`F|VST-…`, `R|OURO-…`), so
   splitting a balance key on the first bar misattributes them. Rows are matched on the full id
   prefix, counted per token and summed, so a row matching two ids is counted twice and goes red.
2. **Account-set completeness** — the swept set must BE every account that exists, proven against
   `URH_AccountCounter`. It caught the 6-of-24 error, then fired again when `[6.3]_SWP` raised the
   count from 24 to 26 by deploying two more accounts.

> Without guard 2 the sweep would have reported a different wrong number with equal confidence.

## Structural fact worth keeping

**`DALOS|AccountTable` has no on-chain key enumerator** — only `URH_AccountCounter`, a *count*.
`AU_OuronetAccounts`'s own `@doc` says *"Get Accounts with `(keys DALOS|AccountTable)`"*, i.e. the
caller supplies the list from **off-chain**. So OURO and IGNIS conservation **cannot be verified
on-chain by anything**. The sweep works only because a test harness may hold a list the chain will
not give it.

Two other readers of the same row disagree by design, and that is fine: `UEV_EnforceAccountExists`
defaults the elite field to `DALOS|VOID` (deb 0.0 → absent) while `UR_Elite` defaults to
`DALOS|PLEB` (deb **1.0**). All five consumers of `UR_Elite-DEB` use it as a **score multiplier**,
where PLEB's 1.0 is the correct neutral value — so the lenient default is right for them. It is
simply **not an existence check**; use `try` around `UEV_EnforceAccountExists` for that.

## Instrument gap closed alongside

`RED-TEAM-REPORT.md`'s register table was hand-typed and had drifted to *"9 attacks"* while
`_redteam.py` said 14. `_figuresync.py` guards every other figure in that directory against
`REPL_SUITE_STATS.md`; it has no opinion about the attack register, so nothing compared the two.
The table is now generated between markers by `_redteam.py --sync` and diffed by `--check` in the
gate. **A missing marker is an error, not a pass** — the `_figuresync` lesson.
