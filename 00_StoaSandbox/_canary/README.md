# `_canary/coin-pre-upgrade.pact` — the OLD-SCHEMA fixture

This is the `coin` module **as it was deployed on StoaChain before the PureV26 upgrade**,
fetched from the chain itself with `(at "code" (describe-module "coin"))` — not reconstructed
from git, because the repo copy had drifted from the chain (it had lost an `@event`; see
`FINDINGS-2026-11-08.md` F9).

It exists for one purpose: `REPL/CANARY-coin-upgrade.repl` loads **this** module first, seeds the
UrStoa vault row through genesis, and only then applies the current `00_StoaSandbox/coin.pact` as
an upgrade. That is the only way to produce a row that is **missing a field the new schema
declares** — the state that halted chain 0 on 2026-11-09.

**A freshly-created row cannot reproduce it.** `insert` on the new schema always supplies every
field, which is exactly why 32,000 green assertions said nothing about this: every REPL fixture
builds its rows with the new module already loaded. The bug lives in the gap between an old row
and new code, and only an old module can create an old row.

**Refresh this file whenever a `coin` upgrade is deployed** — it must track the LIVE module, so
that the next upgrade is tested against what is actually on chain:

```bash
python3 - <<'PY'
import sys,json,io; sys.path.insert(0,"/tmp")
from live import call
st,d = call('(at "code" (describe-module "coin"))')
io.open("00_StoaSandbox/_canary/coin-pre-upgrade.pact","w",encoding="utf8").write(d)
PY
```
