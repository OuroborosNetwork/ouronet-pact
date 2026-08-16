# Repo vs mainnet — dirty-read comparison (owner-run)

The audit environment has **no network access**, so the repo-vs-live comparison must be run by the owner against a
node and the results pasted back here. Goal: confirm the repository source matches what is deployed under
`ouronet-ns` on mainnet (owner expects them to match; this rules out auditing stale source).

## What to capture, per module

For each SWP module, run a `local` (read-only) call of `describe-module` and capture the **`hash`** field (the
module's code hash) and, if convenient, the full **`code`**:

```lisp
(describe-module "ouronet-ns.SWP")     ;; -> { "hash": "...", "interfaces": [...], "code": "...", ... }
(describe-module "ouronet-ns.SWPI")
(describe-module "ouronet-ns.SWPL")
(describe-module "ouronet-ns.SWPLC")
(describe-module "ouronet-ns.SWPU")
(describe-module "ouronet-ns.SWPT")
(describe-module "ouronet-ns.MTX-SWP")
(describe-module "ouronet-ns.U_SWP")
```

(Adjust the exact module names if the on-chain names differ from the repo module names above.)

## How the comparison is decided

- **Fastest:** paste each module's `hash`. If the owner also deploys the repo source to a scratch env and captures
  the same hashes, matching hashes ⇒ identical code. (Hashes depend on code + dependency set, so this is exact.)
- **Most direct:** paste each module's on-chain `code` string; the auditor diffs it against the repo `.pact` file
  line-by-line. Any divergence is recorded as a finding (`DRIFT-nn`) here and audited on the LIVE version.

## Results (paste here)

| module | mainnet hash | matches repo? | notes |
|--------|--------------|---------------|-------|
| SWP     | _pending_ | | |
| SWPI    | _pending_ | | |
| SWPL    | _pending_ | | |
| SWPLC   | _pending_ | | |
| SWPU    | _pending_ | | |
| SWPT    | _pending_ | | |
| MTX-SWP | _pending_ | | |
| U_SWP   | _pending_ | | |

Until this table is filled, the audit proceeds on the **repository** code.
