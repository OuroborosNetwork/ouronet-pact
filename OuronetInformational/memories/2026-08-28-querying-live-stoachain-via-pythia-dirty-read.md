# Querying live StoaChain state via Pythia's dirty-read relay (no API key needed)

**Date:** 2026-08-28
**Context:** DALOS audit, finding #30M (`DPTF::UR_Hibernation` read-that-writes backfill). Needed
to check whether any live-deployed DPTF token was missing the `hibernation-link` schema field
before deciding how to fix the function.

## The endpoint

Pythia (`https://pythia.ancientholdings.eu`) is a keyless, failover-safe read/relay gateway for
StoaChain (a Kadena-chainweb-class fork). It exposes:

```
POST https://pythia.ancientholdings.eu/stoachain/read
Content-Type: application/json

{ "code": "<pact source>", "chainId"?: 0-9 (default 0), "data"?: {...}, "sender"?: string, "gasLimit"?: number }
```

The `code` is executed as a real Chainweb `/local` (dirty) read against the live chain — **no
signature required**, and the response is the node's own `/local` result verbatim (`{"gas":...,
"result":{"status":"success","data":...}, ...}`).

## The auth gate — and how to clear it without a connector key

The public web UI's "Dirty Read" button works with zero API key, but calling the same route
directly (e.g. via `curl`) returns `{"error":"a valid connector API key is required"}` unless you
know why. The gate (`apps/pythia/src/connectors/auth/effectiveKey.ts` in the Pythia repo,
`~/ClaudeWS/AncientPantheon/constructors/Pythia`) treats a request as "first-party" — and
auto-injects Pythia's own self-key, clearing the gate — **whenever the request carries
`Sec-Fetch-Site: same-origin`**, which real browsers set automatically for same-origin fetches and
which the code's own comment explicitly says is intentionally acceptable to forge from a
non-browser client ("the blast radius is only public chain reads attributed to Pythia's own
bucket"). So:

```bash
curl -s -X POST https://pythia.ancientholdings.eu/stoachain/read \
  -H "Content-Type: application/json" \
  -H "Sec-Fetch-Site: same-origin" \
  -d '{"code":"(+ 1 2)"}'
```

No `x-pythia-key` header needed. This is a documented, deliberate design choice in Pythia's own
source (`docs/work/read-gate-self-key/design.md` in that repo) — not a security hole being
exploited; it's the free/anonymous read path the owner pointed at.

## Pact code conventions for these queries

- Always start with `(namespace "ouronet-ns")` before referencing any Ouronet module — same as
  every REPL fixture in this repo.
- Reference modules directly by name, e.g. `DALOS.DALOS|AccountTable`, `DPTF.DPTF|PropertiesTable`
  — `keys`/`read`/`select` on a `deftable` are callable from outside the owning module (Pact
  doesn't restrict table access to the declaring module by default), so you can inspect real table
  contents without needing any capability or signature.
- `(read TABLE key ["field-name"])` returns `{}` (empty object) if `key` doesn't exist in the table
  **or** if `"field-name"` isn't present on that row — exactly the "missing field" case
  `UR_Hibernation`'s own `needs-populate` check relies on. Useful for checking schema-migration
  completeness directly, e.g.:
  ```pact
  (namespace "ouronet-ns")
  (let ((ids (keys DPTF.DPTF|PropertiesTable)))
    (map (lambda (id) {"id": id, "has-hibernation-link": (!= (read DPTF.DPTF|PropertiesTable id ["hibernation-link"]) {})}) ids))
  ```

## What this confirmed for #30M (2026-08-28 snapshot)

All 18 DPTF token ids live on StoaChain chain 0 at the time of this check
(`AURYN-8Nh-JO8JO4F5`, `ELITEAURYN-8Nh-JO8JO4F5`, `F|ELITEAURYN-8ZLws7IkbT7x`,
`F|SPARK-6B42e2_oW8j0`, `F|VST-8Nh-JO8JO4F5`, `GAS-8Nh-JO8JO4F5`, `GSTOA-8Nh-JO8JO4F5`,
`OURO-8Nh-JO8JO4F5`, `R|OURO-8Nh-JO8JO4F5`, `SPARK-6B42e2_oW8j0`, `SSTOA-8Nh-JO8JO4F5`,
`STOICISM-hCNmIIxczuBs`, `STOICPAY-64EvuR4kgZHd`, `VST-8Nh-JO8JO4F5`, `VUSDC-dlnv354-4ngb`,
`WSTOA-8Nh-JO8JO4F5`, `WURSTOA-dlnv354-4ngb`, `W|SSTOA-OURO-WSTOA|LP-6D_MJJXmhuz3`) already have
`hibernation-link` populated — **zero gaps**. This confirmed the read-that-writes backfill branch
in `UR_Hibernation` is fully dead code on the real deployed state, so it was safe to simplify to a
pure getter with no migration step needed. See `1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/
ROUND-02-FIXES.md` Fix #25.

## General lesson for future agents

When a finding's resolution depends on "is there anything real on live chain that needs handling,"
don't assume it's unreachable — this gateway makes it a free, no-key, read-only Pact query. Always
check for backward-compatibility/migration branches like this empirically before deciding whether
to keep or remove them; the live state is the ground truth, not what the constructor *currently*
writes (older code paths may have shipped differently before the constructor was fixed).
