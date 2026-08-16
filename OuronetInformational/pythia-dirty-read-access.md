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

## ⚠️ Two gotchas (both hit during 2026-08 audits)
1. **Cloudflare WAF** blocks non-browser requests with `403 {error code: 1010}`. Send a **browser `User-Agent`**
   header (e.g. `Mozilla/5.0 … Chrome/124.0 Safari/537.36`) and it passes.
2. **`/read` requires an API key** — without it you get `401 {"error":"a valid connector API key is required"}`.
   Pass it as the **`x-pythia-key: <KEY>`** header. (The docs frame the key as "attribution so usage shows by name
   in Activity," but in practice `/read` rejects keyless calls.) **The connector API key is an owner-supplied
   secret — ask the owner for it; do not hard-code it into the repo.**

## Dirty-read recipe (Python, no SDK)
```python
import json, urllib.request
KEY = "<x-pythia-key from owner>"
CHAIN = "0"   # confirm the ouronet-ns chain
H = {"User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/124.0 Safari/537.36",
     "Content-Type":"application/json", "Accept":"application/json", "x-pythia-key": KEY}
def read(code):
    body = json.dumps({"code": code}).encode()
    req = urllib.request.Request(f"https://pythia.ancientholdings.eu/{CHAIN}/read",
                                 data=body, headers=H, method="POST")
    return urllib.request.urlopen(req, timeout=30).read().decode()
print(read('(describe-module "ouronet-ns.ATS")'))   # -> {hash, code/interface, blessed, …}
```
Compare the returned module `hash` (and/or `code`) against the local `.pact` to detect repo↔mainnet drift before
auditing. If a fix redeploys, the repo is the source of truth for the new deploy.

## Status
Verified reachable 2026-08-15: `/healthz` → `{"service":"ok","version":"3.1.5", …}`; `/read` returns
`401 needs-key` (keyless) — **owner must supply the `x-pythia-key`** to run live diffs.
