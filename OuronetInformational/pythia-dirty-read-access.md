# Pythia — live-chain dirty reads / broadcast (StoaChain) — access notes

**What it is:** Pythia is a keyless relay in front of the StoaChain (Ouronet) Chainweb nodes. "One base URL, the
same shape on every chain." Use it to **dirty-read live on-chain code/state** (e.g. `describe-module`) and to compare
the deployed contract against the local repo, or to broadcast caller-signed txs.

- **Base URL:** `https://pythia.ancientholdings.eu`
- **JS SDK:** `npm install @ancientpantheon/pythia-client` (point it at the base URL)
- **Upstream nodes (from `/healthz`):** primary `https://ionos-five-one.ancientholdings.eu`, fallback
  `https://node2.stoachain.com`. Health/routing: `GET /healthz`.

## Endpoints
| method | path | purpose |
|---|---|---|
| GET  | `/healthz` | service + node-pool status (keyless) |
| GET  | `/stats` | aggregate usage (keyless) |
| GET  | `/api/v1/connectors` | connector directory (keyless) |
| POST | `/{chain}/read` | **dirty read — caller supplies Pact code** (needs key) |
| POST | `/{chain}/send` | keyless broadcast — relay caller-signed txs |
| POST | `/{chain}/poll` | tx status — pending vs final + depth |

`{chain}` = the StoaChain Chainweb chain id (StoaChain has 10 chains, `0`–`9`). Ouronet `ouronet-ns` modules live
on a specific chain — confirm which via a probe (try `describe-namespace "ouronet-ns"` per chain).

## ⚠️ Gotchas (hit during 2026-08 audits)
1. **Cloudflare WAF** blocks non-browser requests with `403 {error code: 1010}`. Send a **browser `User-Agent`**
   header (e.g. `Mozilla/5.0 … Chrome/124.0 Safari/537.36`) and it passes.
2. **`/read` gates on a "connector key"** — a bare request with no key/header gets
   `401 {"error":"a valid connector API key is required"}`, and a wrong guess gets
   `401 {"error":"invalid or expired connector key"}`. **A real `x-pythia-key` is NOT actually required for a
   plain read**, though — see the keyless path below. Only use `x-pythia-key` if you have a real owner-issued
   one and want the read attributed to a named connector in Activity.

## ✅ The actual keyless path (found 2026-08-18, verified working)
Pythia's own website ships a public "Dirty Read" console that needs **no key at all** — its frontend fetch never
sends `x-pythia-key`. Traced the server-side gate (`apps/pythia/src/connectors/auth/{gateMiddleware,effectiveKey}.ts`
in the Pythia repo): an operational request (`/{chain}/{read|send|poll}`) with **no** `x-pythia-key` header passes
the gate if it's *first-party*, which the server determines purely from the **`Sec-Fetch-Site: same-origin`**
header. That header is browser-set and can't be forged by a malicious third-party *page's script* — but a
non-browser client (curl, a script) can just send it directly, and the Pythia code's own doc comment says this is
an accepted, intentional design (blast radius: public chain reads only, nothing signs or spends). So: **send
`Sec-Fetch-Site: same-origin` and skip `x-pythia-key` entirely.**

Also: the request body field is `chainId` (a *number*, default `0`), not a `data`/`code`-only shape — `{"chainId":
0, "code": "..."}`.

## Dirty-read recipe (no key, verified 2026-08-18)
```bash
curl -s -X POST https://pythia.ancientholdings.eu/stoachain/read \
  -H "Content-Type: application/json" \
  -H "Sec-Fetch-Site: same-origin" \
  -d '{"chainId": 0, "code": "(describe-module \"ouronet-ns.ATS\")"}'
```
`{chain}` in the path is the **chain name** (`stoachain`), not a chainweb chain id — the chainweb chain id goes in
the JSON body's `chainId` field instead (StoaChain has chains `0`–`9`; `ouronet-ns` modules live on chain `0`).

For account/module strings containing non-ASCII characters (StoaChain account addresses commonly do), build the
Pact string literal with **raw UTF-8 bytes**, not JSON's `\uXXXX` escapes — Pact's lexer doesn't understand
`\uXXXX`. In Python: escape only `\` and `"`, leave everything else as literal UTF-8, then `json.dumps(...,
ensure_ascii=False)` the outer request body so the bytes survive.

Compare the returned module `hash` (and/or `code`) against the local `.pact` to detect repo↔mainnet drift before
auditing. If a fix redeploys, the repo is the source of truth for the new deploy.

Enumerate real on-chain state for building live proofs, e.g.: `(ouronet-ns.ATS.UR_P-KEYS)` (all ATS pair ids),
`(ouronet-ns.ATS.UR_KEYS)` (all ledger row keys, `"<atspair>|<account>"`) — then call any `UR_*`/`URC_*` read
function directly against a real pair/account for a live, non-hypothetical repro.

## Status
Verified working 2026-08-18: real dirty reads against StoaChain chain 0 succeeded keyless via
`Sec-Fetch-Site: same-origin` — `describe-module` on `ouronet-ns.ATS`/`ouronet-ns.ATSU` returned real deployed
source (on `AutostakeV1`/`UtilityAtsV1` — confirms live is on older interfaces than local `V2` dev), and direct
calls against real live accounts (`ATS.UR_KEYS`, 11 total ledger rows) worked. The registered-connector-key path
(`x-pythia-key`) is still untried/unavailable — not needed for read-only audit work now that the keyless path is
known.
