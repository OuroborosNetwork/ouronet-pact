# Glossary

> **This page is GENERATED.** Edit `REPL/tools/_docsref.py`, never this file — the
> gate regenerates it and diffs the result. It carries no prose for that reason.

Every function prefix the tree actually uses, with what the name **promises**.

The prefix is not decoration. It is the subject of the structural checks described in
`../60-methodology/02-semi-self-auditing.md` — *"does any function claiming to be pure
read a table?"* has a mechanical answer only because the claim is in the name.

Counts are of definitions in the tree, interface declarations included.

| prefix | uses | what it promises |
|---|---:|---|
| `UR_` | 1,469 | reads one row or field by key |
| `C_` | 1,374 | client entry — builds the bill; reachable only through Talos |
| `URC_` | 755 | reads and derives; no `enforce` |
| `INFO_` | 625 | operation preview returning a client-facing cost and description |
| `URCi_` | 615 | **cost reader** — the single source both billing and the preview call |
| `UEV_` | 595 | reads and `enforce`s; failure aborts the transaction |
| `A_` | 555 | admin-key mutation |
| `UC_` | 440 | pure compute on arguments only — no table reads, no `enforce` |
| `XI_` | 388 | internal write, this module only, under a capability |
| `UDC_` | 330 | data construction — a named constructor for an object |
| `XE_` | 328 | entry point for other modules only |
| `CT_` | 279 | a constant, exposed as a function |
| `GOV|` | 158 | governance — keysets and protocol constants |
| `URH_` | 128 | **scan** — walks a table. Off the execution path; cost grows with data |
| `P|` | 121 | policy — inter-module authorisation |
| `CC_` | 86 | client entry that reaches a **scan** |
| `XB_` | 70 | callable both internally and externally |
| `WU_` | 62 | write — update |
| `UCk_` | 60 | **key builder** — composes a table's composite row key. Pure; returns a string, not a table |
| `SC_` | 52 | smart-contract account name — a constant, exposed as a function |
| `URCv_` | 36 | `URC_` with an intrinsic guard |
| `CCp_` | 36 | client recipe that reaches a scan |
| `UCv_` | 34 | `UC_` whose `enforce` is intrinsic to its own computation |
| `CAP_` | 33 | account-ownership enforcement |
| `WW_` | 28 | write — upsert |
| `URCx_` | 26 | `URC_` auxiliary |
| `AU_` | 22 | admin utility |
| `URHC_` | 22 | scan and derive. Off the execution path |
| `WI_` | 20 | write — insert |
| `UCx_` | 15 | pure-compute auxiliary — a helper factored out of a `UC_` |
| `AA_` | 11 | admin mutation that reaches a **scan** |
| `Cp_` | 10 | client multi-transaction recipe, no scan |
| `XBv_` | 10 | `XB_` with an intrinsic guard |
| `UDCx_` | 9 | constructor auxiliary |
| `XIv_` | 8 | internal write with an intrinsic guard |
| `URv_` | 8 | `UR_` with an intrinsic guard |
| `URU_` | 4 | version-upgrade read, admin only |
| `REPL_` | 4 | **test fixture only.** Bootstrap helpers that exist for the harness. Present in the repository and, where a module has been redeployed since, absent from the chain — which is why the module pages compare the two |
| `AUx_` | 1 | admin-utility auxiliary |
| `URCix_` | 1 | cost-reader auxiliary |
| `Ap_` | 1 | admin multi-transaction recipe |

## Defined here but unused

Entries with no definition in the tree — a prefix that has been retired, or one
documented before it existed. Either way it is stated rather than rendered as if
live.

`AAp_`

## Sentinels and conventions

| | |
|---|---|
| `"\|"` | **unset**. Never an empty string or list. Code testing for emptiness gets the wrong answer; code passing it onward uses it as a table key, which fails uncatchably. |
| a doubled prefix (`CC_`, `AA_`) | the function can reach a **scan** somewhere in its call tree, at any depth. Cost grows with data. |
| `V\|` `Z\|` `H\|` `F\|` `R\|` `E\|` | derived-token prefixes: vested, sleeping, hibernating, frozen, reserved, equity. |
| `S\|` `W\|` `P\|` | swap-pool kinds: stable, weighted, plain constant product. |
| 162 characters | the length of an Ouronet account. **287 bytes** — most of the alphabet is outside ASCII. |
