# 2026-04-07 — Stoa `coin` tests (`Stage00a_StoaTests.repl`)

## What changed

- **`REPL/Stage00a_StoaTests.repl`:** Holds the full Stoa `coin` regression script (same content lineage as the legacy script in `DH_Pact/DemiourgosSC/ModulesV8/REPL/Stage00a_Stoa.repl` / former `StoaCoin_Tests.repl`). No separate `StoaCoin_Tests.repl` or thin loader.
- **Removed** loading `0_Stoa/coin-contract/coin-interfaces-repl.pact` and `coin-repl.pact` — **`coin` is already deployed** by **`00_StoaSandbox`**.
- **Removed** duplicate genesis tx (`GENESIS` + `A_InitialiseStoaChain`) — already done in **`init-phase-04-coin.repl`**.
- **Removed** `free.stoa_master_*` keyset definitions — live **`coin`** uses **`stoa-ns.stoa_master_*`** from the sandbox.
- **Foundation sender:** `SKC.CS00_NAME` / k:65235… → account name **`"stoa-foundation"`** (matches sandbox init). Env-sig for the old foundation pubkey replaced with **`test-capability`** on the corresponding **`coin.UR|TRANSFER`** / **`coin.TRANSFER`** caps where needed.
- **Vault target:** hardcoded `c:fxSmpw8…` → **`(coin.URV|KONTO)`** (live vault principal).
- **Namespace:** tests run in **`ouronet-ns`** so **`SKC`** constants resolve; **`coin.*`** stays fully qualified.

## Load order (Z.repl)

1. Kadena + Stoa sandboxes — **`Stage00_Sanboxes.repl`**
2. Stoa coin tests — **`Stage00a_StoaTests.repl`**
3. Stage01 / Stage02 testers

## Genesis vs live code

Sandbox **order/payloads** follow **`0_Stoa/genesis/*.json`**; **module source** is the **live** tree under **`00_StoaSandbox/`** (`ns.pact`, `coin.pact`, `util/*`, `stoa-ns/*`), not the frozen genesis `.pact` text (unless they match by design).
