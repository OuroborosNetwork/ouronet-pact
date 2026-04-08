# 2026-04-07 — kadena-coin rename, StoaSandbox, ouronet-ns REPL migration

## Summary

- **00_KadenaSandbox:** Root token module renamed **`coin` → `kadena-coin`** in `kda-env/kadena/coin-v6.pact` (bless lines removed as upgrade hashes no longer apply). Call sites updated in `init-test-accounts.repl`, `example.pact`, `repl-coin-tools.pact`.
- **init-namespaces.repl:** Stopped pre-defining **`free`** and **`stoa-ns`** so Stoa genesis can own them.
- **00_StoaSandbox/stoa-env:** New phased **`init-phase-01` … `init-phase-05`** + **`init.repl`** — genesis order: `ns` + registry + namespaces, `stoa-ns` interfaces + `stoic-predicates` + master keysets, `util` guards + gas-guards, root **`coin`** + tables + `A_InitialiseStoaChain`, **`stoic-xchain`** + gas accounts. Added **`util/guards.pact`** (from genesis-3 guards segment).
- **REPL/Stage00_Sanboxes.repl:** Loads Kadena then Stoa sandbox only.
- **REPL/** (all `*.repl`): **`free` → `ouronet-ns`** for namespace declarations, keyset prefixes, and `free.MODULE` qualified refs.
- **REPL/Stage00a_StoaTests.repl:** Stoa `coin` REPL tests (full script; run after sandboxes).

## Follow-ups if REPL fails

- **`(namespace "")`** in `init-phase-04-coin.repl`: use root-namespace reset per your Pact version if empty string is invalid.
- **`test-capability (coin.GOVERNANCE)`:** if `A_InitialiseStoaChain` still fails, add env-sigs for genesis Stoa master keys or additional `test-capability` steps mirroring on-chain governance.
