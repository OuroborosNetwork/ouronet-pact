# Deploy — round V2

Round V1 is `../1_Pure/` (24 transactions) + `../2_Init/` + `../3_Assets/`. It shipped on
2026-09-24 and is **kept exactly as it went out**. This folder is the next round and numbers
from 1 again: the two are siblings, not a sequence.

## Why the old round stays

A deploy pipeline is a record of what was actually executed, and that record is worth more than
the disk it costs. Round V1 already answered three questions this round would otherwise have to
rediscover:

- **Pact refuses to deploy an interface name twice — identical bytes included.** Transactions 11
  and 21 both died on it. The emitted files show exactly which interfaces were skipped, which
  were version-bumped, and why.
- **The round deployed in UPGRADE mode** — zero `create-table` across all 24 files — which is
  how we know no table was recreated and no entity id moved. That fact retired an entire wrong
  diagnosis.
- **Transaction boundaries are a fact of record once a round is live.** Mid-round, a re-pack
  silently changed 24 transactions into 23 while 19 were already on chain announcing "of 24".
  The planner now pins boundaries for exactly that reason.

Delete the folder and all three become things somebody remembers rather than things anybody can
check.

## This round

| file | contents | state |
|---|---|---|
| `01_deploy.pact` | `OuronetIdsV1` + `OUiOneV1` + `O-UI-ONE` | ready |

**Hand-authored, not generated.** `_deploybundle.py` plans the sovereign tree; AppReads modules
land one at a time as their UI wiring is written, so there is no round to plan — the owner
deploys each slice when its consumer is ready. The folder is allowlisted by name in the bundler
for that reason.

## Signing

**Namespace keyset only.** All three are first deploys, and a module's first deploy checks no
governance because there is nothing yet to govern.

Worth carrying forward: an **upgrade** of `O-UI-ONE` *will* check `GOV|O_UI_ONE_ADMIN`. The key
that ships a module is not automatically the key that can change it.

## Measured

Against a fixture carrying Stage 1 + Stage 2 and nothing from this round — the shape mainnet is
in before it runs:

```
deploy   26,781 gas    (~1.3% of a 2,000,000 block)
read     23,683 gas    URC_01|Header, all four zones ok
```
