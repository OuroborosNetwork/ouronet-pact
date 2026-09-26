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
| `20_deploy.pact` | `INFO-ONE` module upgrade — adds `INFO_DPTF|ClearDispoForeign` | **EXECUTED on mainnet 2026-09-26** |

`20_deploy.pact` closes the only genuine cost-preview gap in the system. Cross-referencing all
**483** IGNIS price keys against all **426** `INFO_` readers found thirteen priced operations
with no exactly-named reader; twelve had one under a different name. `DPTF|C_ClearDispoForeign`
(51.0 IGNIS) had none at all, so no client could show its cost before the user signed.

**It is module-only.** `InfoOneV2` is deployed and a deployed interface cannot be changed, so
declaring the function there would force `InfoOneV3` and the whole cascade. A module may exceed
its interface, two `INFO_VST|Hibernated*Display` readers in this same module already do, and a
tree-wide search for `::INFO_` returns zero — every `INFO_` reader is called off-chain over
`/local`, never by another module. So the interface stays untouched and nothing loses reach.

**Signing differs from every other file in this folder.** The others are first deploys and take
the namespace keyset. This is an UPGRADE, so `GOV` is evaluated and it needs
`ouronet-ns.dh_master-keyset` — the Demiurgoi keyset. The namespace admin key is refused at
`GOV|INFO|DPTF_ADMIN`. Measured: **227,541 bytes, 366,551 gas (18% of the 2,000,000 budget)**,
taken by loading the emitted file on top of a live Stage-01 so the load is a real upgrade.

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

## Verifying a deploy file: never with `env-module-admin`

`15_deploy.pact` shipped without its `acquire-module-admin` calls and failed on chain at the
first table:

```
Module admin is necessary for operation but has not been acquired: ouronet-ns.SWPT
```

It had been "verified" in the REPL first. The check used `(env-module-admin ouronet-ns.SWPT)`,
which **grants** module admin outright — a test-harness escape hatch with no on-chain
equivalent. So the fixture satisfied the permission by removing it, and the one requirement the
transaction actually needed was the one the test could not see.

**Verifying a permission with the thing that bypasses the permission proves nothing.** When a
deploy file's correctness depends on authorisation, the fixture must satisfy it the way the
chain will — `env-sigs` with the real governance keys, and no `env-module-admin` anywhere in the
block. The rewritten check does that, and carries the negative case beside it: the namespace key
alone is refused, which is what proves the grant is still gated rather than merely present.

`env-module-admin` remains correct for *read* fixtures — `(keys SomeModule.SomeTable)` in a test
needs admin the chain would never give a reader, and that is the hatch existing for its purpose.
The rule is narrower than "never use it": **never use it in the test that decides whether a
transaction will be accepted.**
