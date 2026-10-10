# Deploy — round 4: the IPFS → Arweave URI migration

**23 transactions, 15,648 rows, 7 collections, 0 modules deployed, 0 role changes.**

## What I need from you

**Two things now, and a decision.**

**1. The Arweave links.** If you uploaded as a **directory** — ArDrive, arkb, turbo,
anything producing an Arweave **path manifest** — the folder tree survived and only the
gateway prefix changed, so `links/LINKS.json` is three lines:

```json
{ "mode": "manifest", "manifest": "https://arweave.net/<manifest-txid>/" }
```

If every file got its own txid I need all **5,978** of them, keyed by the old IPFS URL.
`python3 REPL/tools/_arweave.py --files` prints the exact key list.

**2. A decision on 34 malformed links.** 34 WonderCoach `uri-secondary` rows read

```
<CID>/FULL05_WonderCoach/WC_nn.jpg        <- the separator after FULL is MISSING
```

This is **pre-existing on chain**, not something this round introduces. Manifest mode
swaps the prefix and keeps the path, so it would faithfully carry the malformation into
Arweave. Either name them that way in the Arweave tree, or put the 34 tidy names in
`overrides`. `links/CHAIN-URIS.json` → `malformed` lists them; `--check` will not let you
ship them silently either way.

**And one thing about the signer, which is the whole prerequisite:** sign as the
account that holds `role-nft-recreate`, which is **`UR_CreatorKonto`** — the same
account on all seven collections — and **not** the collection owner.

```pact
(ouronet-ns.DPDC.UR_CreatorKonto "DHB-SUVEHxb9UQ6_" false)   ;; == UR_Verum6, all 7
```

Nothing needs moving, nothing needs granting. `--simulate` reports **OK** for all 23
files as they stand.

## The four corrections that rebuilt this round

This folder was first generated on 2026-10-08 from the **minter arithmetic**. Then it was
checked against the chain, and almost all of it was wrong. Recording that here because
every one of the four was invisible to the checks that existed:

**1. 84% of the old links were wrong.** The tool ported the `UC_*Link` functions to Python
and derived each nonce's current IPFS URL. Diffed against mainnet: **13,060 of 15,548 rows
disagreed.** Every DHB `uri-secondary` is `.png` on chain and the port hardcoded `.jpg`
(12,928 rows), and the "padding anomaly" the port carefully reproduced **does not exist** —
the chain holds `E_48.jpg` / `R_72.jpg` / `C_144.jpg`, not `E_048` / `R_072` / `C_00144`.
The old README devoted a section to that phantom defect and advised uploading those names
*both ways* to accommodate it.

This was the worst available failure mode: the plan was **self-consistent**, so coverage,
budget and the byte-for-byte stale diff all passed, and the round would have written
Arweave URLs pointing at files that are not the ones those nonces display.
**Fixed by reading the chain** (`--record` → `links/CHAIN-URIS.json`), which also deletes
the un-checkable "ladder assumption" the old README called its biggest risk: a snapshot is
keyed by the nonce the chain reported, so there is no position arithmetic left to be offset.

**2. Half the collections were missing.** The round covered 3 of the **7** live
collections. `CodingDivision` (11), `OuronetCustodians` (4) and `WonderCoach` (34) are all
on IPFS and were absent — 49 nonces plus 5 set-classes. They are semi-fungible, so they
also needed an entrypoint the emitter did not have (below).

**3. The collection ids were placeholders, and the guess was wrong.** Every file said
`KBN_COLLECTION_ID`. The bunnies collection is **`SBN-SUVEHxb9UQ6_` / "DemiBunnies"** —
`KBN` is the *minter module's* name, not the collection's. Ids now read off
`(keys ouronet-ns.DPDC.DPSF|T|Properties)` and confirmed by `UR_Name` / `UR_Ticker` /
`UR_NoncesUsed`.

**4. The entrypoint was hardcoded to `DPNF|`.** Correct while the round held only
non-fungible collections. Four of the seven are semi-fungible, and for those the entrypoint
is in a **different Talos module** — `TS02-C1.DPSF|C_UpdateNonces`, not `TS02-C2`. The
emitter now dispatches on `son`.

## RETRACTED: there is no prerequisite, and the equity collection is in scope

This section used to say the round could not work without a role-move transaction,
and that the equity collection was structurally immutable. **Both were wrong**, and
the error is worth keeping because the measurements behind it were all correct.

What was measured, and is still true:

* the collection **owner** does not hold `role-nft-recreate` on any collection;
* `E|DH-SUVEHxb9UQ6_`'s `UR_OwnerKonto` **is** the DPDC smart account, so
  `C_MoveRecreateRole` — which enforces `UEV_ExecutorIsCollectionOwner` — can never
  be run for it by any signer.

What was concluded, and was wrong: *therefore the role must be moved, and therefore
equity can never be touched.*

**`DPDC-N|C>SET-DATA` never checks collection ownership.** It checks
`UEV_RoleNftRecreateON` — the **role** — plus the signer's own account ownership. So
"the role cannot be MOVED" had been read as "the role is not HELD". Different
sentences. Measured:

| | |
|---|---|
| `UR_CreatorKonto` | one single account, **identical on all 7 collections** |
| `UR_Verum6` (the recreate-role holder) | **the same account** |
| `UR_CA\|R-Recreate <id> <son> <creator>` | **`true`**, all 7 |

The role was already exactly where it needed to be. Confirmed by simulating an
equity update signed as the creator: it stops at `UEV_StandardAccOwn` — the keyset —
meaning the role gate passed. `--simulate` now reports **OK** for all 23 files.

### The role transactions were not merely unnecessary — they were a trap

`00_PREREQUISITE_roles.pact` moved the role **from the creator to the owner**. Run it
and then sign the batches as the creator, and *every batch fails*, because `00` had
just taken the role away from the signer. And `--simulate` would have endorsed that
order: it reported `OK` for `00` and `NEEDS-00` for the other 25 — a coherent,
confident, wrong story, produced by simulating as the owner because the tool had
already assumed the owner was the signer.

Both files are gone. `emit_roles` is kept in the tool, unreferenced, because the
owner route is still *valid*: move the role, sign as owner. It is strictly worse —
two extra transactions, a one-way transfer of the authority to rewrite any nonce's
entire data, and a restore step needing a value the move destroys.

**Sign as `UR_CreatorKonto`, not the collection owner.** That is the whole
prerequisite, and it is a choice of signer rather than a transaction.

### Consequently: no PureV5 module change is needed

The architectural gap this round seemed to prove — that equity collections cannot
have their metadata modified — **does not exist**. `DPSF|C_UpdateNonces` through
`TS02-C1` already writes any field of any equity nonce, for the creator. No
`EquityV4` interface bump, no Talos wrapper, no cascade.

## This is not a `PureVn` round, and the distinction is the whole design

You asked for "the next V6". It isn't one. `Deploy/PureV2…V5/` are **module** rounds —
they ship `(module …)` bodies, and their tools check dot-pin ordering, interface cascades
and surviving `create-table` forms. Changing a nonce's artwork link deploys nothing: the
link is a **string in a table row**, written by `DPDC-N`, and the only way to change it is
a data transaction.

So this folder is a sibling of **`Deploy/3_Assets/`**, numbered in that family, and it is
checked by `REPL/tools/_arweave.py` rather than by a `_purevN.py`. None of the module-round
checks apply; all of the ones that do apply are different ones (coverage, exclusions,
per-batch gas, the ladder cross-check).

`Deploy/PureV5/` stays what it was: the empty scaffold for the next *module* round.

## What is in scope

Read off the chain by `--record`, not computed. `--inventory` re-derives this table.

| collection | id | son | kind | rows |
|---|---|---|---|---|
| DemiBunnies | `SBN-SUVEHxb9UQ6_` | F | nonce | 1,120 |
| DemiourgosHoldingsNosferatu | `DHN-SUVEHxb9UQ6_` | F | nonce | 1,500 |
| DemiourgosHoldingsBloodshed | `DHB-SUVEHxb9UQ6_` | F | nonce | 12,928 |
| CodingDivision | `DHCD-SUVEHxb9UQ6_` | T | nonce | 11 |
| OuronetCustodians | `DHOC-SUVEHxb9UQ6_` | T | nonce | 4 |
| WonderCoach | `DHWC-SUVEHxb9UQ6_` | T | nonce | 34 |
| **Equity^DemiourgosHoldings** | `E\|DH-SUVEHxb9UQ6_` | T | nonce | **8** |
| DemiourgosHoldingsBloodshed | | F | set-class | 38 |
| CodingDivision | | T | set-class | 1 |
| WonderCoach | | T | set-class | 4 |
| **total** | | | | **15,648** |

Each row carries **two** links — `uri-primary` (512x512) and `uri-secondary` (FULL) — so
**31,296 strings** are rewritten. `uri-tertiary.image` and all six non-image slots are
`BAR` on **every** row (measured; `--record` is *fatal* on a non-BAR tertiary rather than
silently leaving a link behind).

Only **5,978 distinct FILES** need an Arweave counterpart, because Bloodshed's images are
shared — 12,928 rows point at 272 images. That is why `links/LINKS.json` is keyed by **old
link** rather than by nonce.

## What is excluded, and why each one is not a choice

**1. The RGB bunny — already done, and the tool works it out rather than being told.**
DemiBunnies set-class 1 has been on Arweave since 2026-10-02. `--record` scopes by the
**gateway**: a row already off the IPFS prefix is reported as out of scope, not skipped by
name and not crashed on.

**2. 63 minted Bloodshed Set instances — frozen by the chain, permanently.**
`UEV_NotSetInstance` enforces `UR_NonceClass = 0` when `nost ∧ ¬son`, and the Talos nonce
path passes `nost = true`. So for an NFT a Made Set instance **cannot** have its data
changed by any entrypoint, ever, and **one such row aborts the whole transaction**. Those
63 (nonces 12929–12991) and DemiBunnies 1121 stay on IPFS.

Scope is **derived** from `UR_NonceClass` per nonce, never from a remembered count — which
is what keeps `12928` and `1120` from going stale the next time something is minted.

**But the filter is NFT-only.** For `son = true` the guard short-circuits, and `10_DPDC-N`
says why: *"SFT Sets are unaffected: an SFT set-class has exactly one shared nonce ... so
its data legitimately stays editable."* Filtering SFTs the same way silently **dropped real
work** — DHCD nonce 11 and DHWC 31–34 are set-instance nonces carrying live IPFS links. And
`UR_NativeNonceData` (`UR_NonceElement`) is a **different row** from `UR_SetNonceData`
(`UR_Set`) even when both hold the same string, measured — so migrating only the set row
leaves the nonce row behind. Both are in scope, which is why DHCD and DHWC each ship a nonce
batch *and* a set batch.

**3. Nothing else.** The equity collection used to be listed here. See the retraction above.

## Why `C_UpdateNonces` and not `C_UpdateNonceURI`

`C_UpdateNonceURI` is the entrypoint whose *name* matches the task. It is the wrong one at
this scale. Measured 2026-10-08, `env-gasmodel "table"`, against the `CNF-98c486052a51`
fixture:

| entrypoint | gas / row | IGNIS / row | round total |
|---|---|---|---|
| `DPNF\|C_UpdateNonceURI` | 8,600 | 17.0 | ~134M gas, 264,962 IGNIS, **79 transactions** |
| `DPNF\|C_UpdateNonces` | **1,559** | **1.0** | **24.6M gas, 15,648 IGNIS, 23 transactions** |

**6× the gas and 17× the IGNIS**, because the single-field op pays the whole
capability + Talos + IGNIS-collection overhead once *per nonce*, while the bulk op pays it
once *per call*. The IGNIS difference is in the pricing readers and is not an accident:
`URCi_UpdateNonces` is `count × UC_IgnisLeg "tier-smallest"` = `count × 1.0`, a **usage**
tier, while `URCi_UpdateNonceField` is a flat **17.0 setup** charge per invocation.

The sweep is linear to within 12 gas over a 192× range:

```
N=1  9,512    N=8  19,403    N=64  98,237    N=192  278,428
gas(N) = 8,104 + 1,408·N          (+151/row on a realistic Bloodshed-sized row → 1,559)
```

The marginal cost rises with **row size** because the read-overlay reads the whole row;
Bloodshed is 12,928 of the 15,648 rows, so the fat figure is the one budgeted.

### The cost of choosing the bulk op, and how it is paid

`C_UpdateNonces` takes a whole `DPDC|NonceData` row, not a URI field. A naive use of it
retypes `name` / `description` / `meta-data` / `asset-type` / both royalties by hand and
**silently destroys whatever it gets wrong** — across 15,648 rows, with no way to recover
the originals.

It is used here through a **read-overlay** instead. The emitted lambda reads the live row
and replaces exactly two keys:

```pact
(+  { "uri-primary"   : (… (at 0 (at i links)) "|" "|" "|" "|" "|" "|")
    , "uri-secondary" : (… (at 1 (at i links)) "|" "|" "|" "|" "|" "|") }
    (remove "uri-secondary" (remove "uri-primary"
        (ouronet-ns.DPDC.UR_NativeNonceData id false (at i nonces)))))
```

Every other field is carried across **by the chain**, not by the generator. There is
nothing for the tool to get wrong. `REPL/Stage_02/[6.1.10]_ARWEAVE-SHAPE.repl` asserts
exactly this — that `name`, `description`, `meta-data` and `asset-type` survive a URI write
— because it is the one claim a parse check cannot make.

A side benefit: `C_UpdateNonceURI` would have **overwritten `asset-type`** from its own
`ay` argument. The overlay preserves it.

## What replaced the ladder assumption

The first draft called this "the real risk in this round": links were addressed **by
position** using the minters' arithmetic, which matches the mint only if each collection
held zero nonces when its populate ladder began, and nothing on chain enforces that. It
also devoted a section to a **padding defect** in `BSD-E/R/C` that it had found while
porting them, and advised uploading `E_048.jpg`-style names to accommodate it.

**Both sections are gone because both problems are gone, and one of them never existed.**
The padding anomaly was an artefact of the port — the chain holds `E_48.jpg`, `R_72.jpg`,
`C_144.jpg`. And there is no position arithmetic left to be offset: `links/CHAIN-URIS.json`
is keyed by the nonce the chain reported, so a ladder offset cannot express itself.

What remains worth checking before signing is narrower and concrete: the snapshot has a
**date**. If anything has been minted or re-URI'd since it was recorded, re-run `--record`
and re-`--write`. `--check` compares the emitted files to the snapshot byte for byte, so it
catches an edited file — it cannot tell you the snapshot itself has aged.

## Supplying the links

Two modes, because the shape of your upload decides which is even expressible. Schema in
`links/LINKS.schema.json`, template in `links/LINKS.example.json`.

**`manifest`** — the upload is an Arweave **path manifest** (what ArDrive / arkb / turbo
produce from a *directory*). The folder tree survives, so only the gateway prefix changes
and the whole 5,978-file map is three lines:

```json
{ "mode": "manifest", "manifest": "https://arweave.net/<manifest-txid>/" }
```

**`explicit`** — every file got its own independent Arweave transaction id, so every one
must be named: `{"mode": "explicit", "explicit": { "<old ipfs url>": "<new arweave url>" }}`
with all 5,978 keys. `--files` prints them; `--check` reports any that are missing or any
you name that is not in scope.

Either mode accepts `overrides` for stragglers.

> `links/LINKS.json` currently holds a **placeholder manifest txid**, used only to prove the
> emitted shape. The 20 files in this folder are therefore **shape-correct and
> value-wrong**. Replace it, re-run `--write`, and check the diff before signing anything.

## The round

`python3 REPL/tools/_arweave.py --plan` re-derives this table.

| file | rows | ~gas total | contents |
|---|---|---|---|
| `01`–`02` `SBN` | 1078, 42 | 1,717,238 / 73,582 | DemiBunnies nonces |
| `03`–`04` `DHN` | 1078, 422 | 1,733,655 / 666,002 | Nosferatu nonces |
| `05`–`16` `DHB` | 1078 ×11, 1070 | ~1,740,000 each | Bloodshed nonces |
| `17_DHCD_n00001-00011` | 11 | 25,253 | CodingDivision nonces (SFT) |
| `18_DHOC_n00001-00004` | 4 | 14,340 | OuronetCustodians nonces (SFT) |
| `19_DHWC_n00001-00034` | 34 | 61,110 | WonderCoach nonces (SFT) |
| `20_EDH_n00001-00008` | 8 | 20,576 | **Equity nonces (SFT)** |
| `21_DHB_sets00001-00038` | 38 | 67,346 | Bloodshed set-classes |
| `22_DHCD_sets00001-00001` | 1 | 9,663 | CodingDivision set-class (SFT) |
| `23_DHWC_sets00001-00004` | 4 | 14,340 | WonderCoach set-classes (SFT) |
| **total** | **15,648** | **25.2M** | 23 transactions, worst 1,740,297 of the 1,800,000 cap |

Largest emitted file is **240,168 bytes**, inside the 320,000 byte cap.

**The batch size is 1,078 rows, and that number is solved rather than divided.** Owner
instruction was ~1.8M gas per transaction. Dividing the cap by the 1,559 gas/row exec cost
gives **1,149** rows — and 1,149 rows measures **1,870,467** gas, over the cap, because a
transaction is also charged for its SIZE and that charge grows as the **seventh power** of
the bytes. The planner therefore solves `exec(N) + size(bytes(N)) <= 1,800,000`.

Worth being honest about the model: the seventh-power calibration comes from the wallet's
**deploy editor**, i.e. from module-deploy payloads, and this repository has not measured
whether a non-deploy `exec` payload is charged by the same curve. It is used as a
*conservative reserve* — it can only make batches smaller than necessary — and the real
guard is `--check`, which recomputes the total from the **emitted bytes** and is fatal.
That check is negative-tested: give the planner an optimistic bytes-per-row and it reports
12 violations with the exec/size split named.

**All 23 files are order-independent and idempotent** — re-running one rewrites
the same rows with the same strings, so a failure needs no unwinding: fix and re-send that
one file. To find out whether a file already landed, run its precondition read; an Arweave
link means it did.

That property is deliberate and it is why a 25-transaction round is tolerable at all. The
`3_Assets` round had to run in strict order because its steps *created* things; this one
only overwrites, so it has no state of its own.

**There is no exception any more.** The round has no ordered step and no state of its own:
23 independent, idempotent transactions, signable in any order, by one signer. `00`/`99`
are gone — see the retraction.

### Signing

The **creator** signs (not the owner) and the patron pays. **No admin key and no namespace write**
— nothing is deployed.

The **signer** must hold **`role-nft-recreate`** — not `role-set-new-uri`, and not
`role-nft-update`. All three exist on a DPDC account and all three are held separately.
The collection OWNER holds `role-nft-update` and lacks the one that matters; the
**CREATOR** holds `role-nft-recreate`. Sign as the creator:

```
C_UpdateNonceURI  -> DPDC-N|C>SET-URI   -> UEV_RoleSetNewUriON   -> R-SetUri
C_UpdateNonces    -> DPDC-N|C>SET-DATA  -> UEV_RoleNftRecreateON -> R-Recreate
```

`R-Recreate` is **move-only** (`DPNF|C_MoveRecreateRole`); there is no toggle for it.

**This was wrong in the first draft of this round, and the way it was wrong is the
instructive part.** The draft named `role-update` in all 20 headers it then had, on the reasonable
assumption that the "update nonces" entrypoint wants the "update" role. That assumption is
doubly unlucky, because the owner **does** hold `role-nft-update` on chain — so the draft
named a role the owner really has, while the gate wants one it does not. Two things hid it:
`UEV_RoleNftRecreateON` and `UEV_RoleNftUpdateON` emit the **byte-identical** refusal
string, so a failed call would never have said which role it wanted; and the REPL fixture
owner holds *every* role, so an assertion on `R-Update` passed and the body succeeded
regardless. A positive test cannot distinguish two gates when the subject satisfies both.

`ARW-SHAPE-02` in the self-test is what settles it: it revokes `role-update`, leaves
`role-recreate`, and runs the same generated body. It succeeds — so `role-update`
is provably not the gate.

## What checks this folder

`python3 REPL/tools/_arweave.py --check`, fatal inside `_gate.py`:

- **COVERAGE** — every collection's nonces are contiguous `1..n` with no row covered twice.
- **EXCLUSION** — the out-of-scope rows stay out: the already-Arweave DemiBunnies set-class,
  the 63 frozen Bloodshed set instances, the DPDC-owned equity collection.
- **SNAPSHOT** — the old links come from `links/CHAIN-URIS.json` and nowhere else. The tool
  carries no link arithmetic any more, so there is no derivation left to drift from the
  chain. The snapshot is dated, and `--record` is the only thing that touches the network.
- **GATEWAY** — the IPFS prefix is read out of the three minter sources, never hardcoded,
  and **disagreement between them is fatal** rather than resolved by precedence: if the
  minters stop agreeing, no single migration can be correct.
- **BUDGET** — no batch over `GAS_BUDGET`, no emitted file over 320,000 bytes.
- **LINKS** — every in-scope file resolved; anything named that is not in scope is an error.
- **STALE** — every file is regenerated into memory and diffed byte for byte, so a change to
  the grammar or the link map cannot land without the transactions following it.

## One file instead of 23 pastes: `--multipact`

`python3 REPL/tools/_arweave.py --multipact` writes **`ROUND.multipact.json`** — the
entire round as a single file, for the loader in OuronetUI (**Admin → Execute Code**).
Load it, see what was detected, simulate, execute. The alternative is 23 manual pastes of
~230 KB each, where the only thing that can go wrong is a human.

The format lives in `REPL/tools/_multipact.py`, which is the one place its rules are
spelled — the reader ports `validate()` rather than re-deriving it.

**It is one PARALLEL group**, and that is a claim about *this* round rather than a default:
every transaction is idempotent and they touch disjoint nonces, so there is no order to
preserve and a failure needs no unwinding. A module deploy round would be one SEQUENTIAL
group, because dependency order is everything there. Groups themselves always run in
order, so a mixed round — interfaces, then the modules implementing them — is expressible
as a sequential group followed by a parallel one.

**Every transaction carries its own `sha256`, and the manifest carries a hash of the
group structure.** Not for transport corruption — because the signer **cannot read what
they are signing**: 230 KB of generated Pact per transaction, 3.5 MB a round. The only
honest way to offer "click once" is for the artefact to carry its own integrity and for
the reader to refuse a mismatch. A manifest whose hashes go unchecked is just a convenient
way to sign something unexamined.

**`draft: true` loads but cannot be executed.** While `links/LINKS.json` holds
placeholders the manifest says so, and the reader refuses to send it. That puts the guard
in one checked field instead of relying on a banner inside a body nobody reads.

**It is deliberately NOT committed.** It is a byte-for-byte re-packaging of the 23 `.pact`
files beside it, which `--check` already diffs, so it carries no state of its own;
committing 3.5 MB of already-checked duplication buys nothing. `.gitignore`d, and
regenerated in one command. The small committed fixture for the reader's *tests* is
`links/SAMPLE.multipact.json` — two groups, both modes, and `draft: false`, so a test can
reach the execute branch that the real draft manifest never exercises.

## The two modes that touch the network, and why they are not in the gate

`_gate.py` must run offline, so it checks the **recorded** snapshot and never the chain.
These are the deliberate, dated acts that talk to mainnet — the same split
`_registrylive.py --record` uses, for the same reason.

**`--record`** reads every in-scope row and rewrites `links/CHAIN-URIS.json`. Run it if
anything has been minted or re-URI'd since the date in its `_provenance`. It derives scope
rather than remembering it (`UR_NoncesUsed` for the extent, `UR_NonceClass` for the frozen
tail, the gateway prefix for already-migrated rows) and is **fatal** on a non-BAR
`uri-tertiary`, because the emitter overlays only two slots and a third populated one would
be silently left behind.

**`--simulate`** sends all 27 emitted bodies to `/local` **unsigned**, with the real owner
substituted, and classifies *where each one stops*:

```
01_SBN_n00001-01078.pact          OK            stops at the signature
 ... all 23 files ...
23_DHWC_sets00001-00004.pact      OK            stops at the signature
```

Unsigned means it cannot write, so the stopping point is the signal. `OK` means everything
up to the signature resolved — which is the verdict every file should carry. A
`NEEDS-00` (stopped at `UEV_RoleNftRecreateON`) now means the signer does **not** hold the
recreate role, i.e. it has been moved off the creator; that should never appear.
**Anything else is a real defect: do not sign.** A wrong collection id, a stale snapshot nonce, a renamed entrypoint
or a bad arity all land in that third bucket, and none of them can surface offline.

**Run `--simulate` before the first signature and again if anything is re-recorded.** All
23 should read `OK`. It is the only check that can see a stale snapshot, a renamed
entrypoint, a moved role or a wrong collection id, because all four live on chain.

> The first run of `--simulate` reported `FAIL` on all 27 files. The cause was in the
> checker, not the round: Ouronet account ids are non-ASCII and a default `json.dumps`
> escapes them to `\uXXXX`, which Pact rejects outright. A checker that fails everything
> looks exactly like a round that is broken everywhere, which is worth knowing about any
> all-red result.

And `REPL/Stage_02/[6.1.10]_ARWEAVE-SHAPE.repl`, generated by `--selftest`, **executes** the
emitted body against the REPL's `CNF` fixture. It is rendered from `emit_code` — the same
function that writes these files — rather than retyped, so what the gate proves is what you
sign. A self-test that re-spelled the body would prove a *copy* of it parses, which is the
failure mode the duplicated `unwrap` already cost this project once.

## The `UC_*Link` functions stay as they are — OWNER RULING, 2026-10-08

This round migrates the **rows**. It does not touch the `UC_*Link` functions, which build
their URL in code and still carry the IPFS gateway as a string literal
(`02_KBunnies.pact:131`). Verified: `C_Fix` writes the URI slots through `UC_IpfsLink`
(`01_NOSFERATU.pact:183-184`), so running an `A_Fix*` rung after this migration **would**
overwrite Arweave links with IPFS ones.

**That is not a pending task.** Owner ruling: the minting was algorithmic and one-time, the
`A_Fix`/`C_Fix` rungs were one-time repairs for a defect in that algorithmic mint, and
**neither will be run again**. Nothing is going to be minted into these collections.

So the exposure is conditional on an action that will not happen, and changing seven
citizen modules to retire a constant nobody will invoke would be churn. It is recorded here
rather than dropped, because the next reader to notice an IPFS literal in a minter will
otherwise re-raise it as a defect — and because the ruling, not the code, is what makes it
safe. **If anyone ever does plan a new mint or a fix rung into these collections, this
becomes live again and the gateway constant must be changed first.**
