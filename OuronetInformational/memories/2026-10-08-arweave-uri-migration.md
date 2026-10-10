# 2026-10-08 — the Arweave URI migration round

Built `Deploy/4_Arweave/` + `REPL/tools/_arweave.py`, then **checked it against the chain
and rebuilt almost all of it — twice**. Final shape: **15,648 rows across 7 collections in
23 transactions**, one signer, no role changes, no module changes.

---

# PART I — the five findings that generalise past this round

## 1. A DERIVED value that is never compared to the thing it models is not evidence

The tool first computed each nonce's current IPFS URL by porting the minters' `UC_*Link`
functions to Python. Diffed against mainnet: **13,060 of 15,548 rows wrong — 84%.**

* every DHB `uri-secondary` is **`.png`** on chain; the port hardcoded `.jpg` (12,928 rows)
* the **"padding anomaly" did not exist.** The port produced `E_048.jpg` / `R_072.jpg` /
  `C_00144.jpg`; the chain holds `E_48` / `R_72` / `C_144`. A whole README section
  documented that phantom defect and advised uploading the odd names *as well*, to
  accommodate a bug the tool had invented.

**Why nothing caught it.** The plan was *self-consistent*. Coverage, per-batch budget and
the byte-for-byte stale diff are all statements about SHAPE, and a uniformly-wrong
derivation is shape-perfect. The failure would have been silent and unrecoverable: Arweave
URLs written for files that are not the ones those nonces display.

The fix was not a better port — it was **deleting the port**. `--record` reads the live
rows into `links/CHAIN-URIS.json` and the tool now carries no link arithmetic at all. That
also dissolved the risk the old README called its biggest: the "ladder assumption" that
nonce = base + position. A snapshot keyed by the nonce the chain reported cannot be offset.

**The transferable rule: if a tool models chain state, make it read the state and diff.**
The derivation was carefully written, documented, and tested against itself.

## 2. A placeholder hides a wrong guess as effectively as a right one

Every emitted file said `KBN_COLLECTION_ID`. The bunnies collection is
**`SBN-SUVEHxb9UQ6_` / "DemiBunnies"** — `KBN` is the *minter module's* name. Because the
value was never real, nothing ever compared it to anything. Ids now come from
`(keys ouronet-ns.DPDC.DPSF|T|Properties)` and are confirmed by `UR_Name` / `UR_Ticker` /
`UR_NoncesUsed`.

Related: the round covered **3 of the 7 live collections.** `CodingDivision`,
`OuronetCustodians` and `WonderCoach` are all on IPFS and were simply absent, and the
coverage check could not notice because its collection list was hardcoded to the same three
the plan used — **the list and the plan were two copies of one assumption.** Both now
derive from `COLL_ORDER`.

## 3. The role a bulk entrypoint needs is not the one its name suggests

*(Read finding 5 after this one. The conclusion drawn here — that the round needed a role
move — was WITHDRAWN the same day: the creator already held the role. What survives is the
part about why a positive test cannot tell two gates apart.)*

`C_UpdateNonces` → `DPDC-N|C>SET-DATA` → `UEV_RoleNftRecreateON` → **`role-nft-recreate`**,
not `role-nft-update`.

Two layers of bad luck here, and the second is the interesting one:

1. The first draft named `role-update` in all 20 headers. `UEV_RoleNftRecreateON` and
   `UEV_RoleNftUpdateON` emit **byte-identical** refusal strings, and the REPL fixture owner
   holds *every* role — so a positive assertion passed and the body succeeded either way.
   **A positive test cannot distinguish two gates when the subject satisfies both.** Settled
   by `ARW-SHAPE-02`, which *revokes* `role-update`, keeps `role-recreate`, and shows the
   body still works.
2. **On mainnet the owner holds `role-nft-update` and NOT `role-nft-recreate`.** So the
   draft named a role the owner really has while the gate wants one it does not — the round
   would have aborted on its first capability, 25 times.

Proven rather than inferred: a generated batch simulated against mainnet stops at exactly
`UEV_RoleNftRecreateON` and nowhere earlier — which simultaneously shows the role is the
blocker **and** that every module reference, arity, the read-overlay lambda and the SFT
dispatch resolve live.

`00_PREREQUISITE_roles.pact` moves the role in; `99_AFTER_roles-restore.pact` moves it back,
and 99 ships *as part of the round* because `role-nft-recreate` is the authority to rewrite
any nonce's entire data and transaction 00 is a **move, not a loan**.

## 4. `son` selects the TALOS MODULE, not just the entrypoint prefix

`DPNF|C_UpdateNonces` lives in **TS02-C2**; `DPSF|C_UpdateNonces` lives in **TS02-C1**. The
emitter hardcoded `DPNF|`/`TS02-C2`, correct while the round held only NFT collections and
wrong the moment three semi-fungible ones joined.

And the **set-instance filter is NFT-only**: `UEV_NotSetInstance` is
`(if (and nost (not son)) <enforce class = 0> true)`, so for `son=true` it short-circuits —
`10_DPDC-N` says so outright (*"SFT Sets are unaffected ... its data legitimately stays
editable"*). Applying the NFT filter to SFTs silently **dropped real work**: DHCD nonce 11
and DHWC 31–34 are set-instance nonces carrying live IPFS links. Worse,
`UR_NativeNonceData` (`UR_NonceElement`) is a **different row** from `UR_SetNonceData`
(`UR_Set`) even when both hold the same string — measured — so migrating only the set row
leaves the nonce row on IPFS.

## 5. "The role cannot be MOVED" is not "the role is not HELD" — and I wrote the round twice because of it

The most expensive error of the day, and every measurement under it was correct.

Measured, and still true: the collection **owner** holds no `role-nft-recreate` on any
collection; and the equity collection's `UR_OwnerKonto` **is** the DPDC smart account, so
`C_MoveRecreateRole` — which enforces `UEV_ExecutorIsCollectionOwner` — can never run for
it. Concluded, and wrong: *therefore the role must be moved, therefore equity is
structurally immutable, therefore a `PureV5` module change with an `EquityV4` bump is
needed.*

**`DPDC-N|C>SET-DATA` never checks collection ownership.** It checks
`UEV_RoleNftRecreateON` — the ROLE — plus the signer's own account ownership. The question
"can the role be moved?" had quietly replaced "is the role already in the right place?"
It was:

```
UR_CreatorKonto == UR_Verum6 == the recreate-role holder,
ONE account, identical on all SEVEN collections
```

Three consequences, in increasing order of how bad the miss was:

1. **No module change.** `DPSF|C_UpdateNonces` through `TS02-C1` already writes any field
   of any equity nonce for the creator. The "architectural gap" did not exist. An interface
   bump, a Talos wrapper and a whole deploy round were about to be built for it.
2. **No prerequisite.** The round went 27 transactions → 23, and gained the equity
   collection (+8 nonces / 16 links) rather than losing it.
3. **The role transactions were a TRAP, not just waste.** `00` moved the role *from the
   creator to the owner*. Run it, then sign as the creator — which is what the simpler
   round does — and all 25 batches fail, because `00` had just taken the role off the
   signer.

**And the verification agreed with the error.** `--simulate` reported `OK` for `00` and
`NEEDS-00` for the other 25: a coherent, confident, wrong story. It read that way because
the tool resolved its signer with `UR_OwnerKonto` — the assumption under test was also the
assumption used to test it. A checker that shares a premise with the thing it checks will
confirm it. The fix was one line (`UR_CreatorKonto`), after which all 23 read `OK`.

**The transferable rule:** when a capability refuses, read *which* enforce refuses before
reasoning about how to satisfy it. "Who owns this" and "who may write this" were different
questions in the same module, and the gap between them was four hours and a deploy round.

## 6. Dividing a gas cap by the per-row cost overshoots it, because size gas is non-linear

Owner instruction: cap each transaction at ~1.8M gas. `(1,800,000 - 8,104) / 1,559` gives
**1,149 rows**. Measured, 1,149 rows is **1,870,467 gas** — over the cap — because a
transaction is charged for its bytes as well as its execution, and that charge grows as the
**seventh power** of the size (`gas_size(S) ≈ 95,225 × (S_KB/256)^7`). The planner now
*solves* `exec(N) + size(bytes(N)) ≤ cap`, giving 1,078.

Two disciplines came out of it, both borrowed from `_deploybundle`'s history:

* **the estimate is rounded the safe way.** Bytes-per-row was measured at 215.6 on the
  DRAFT emission — whose placeholder manifest txid is 38 characters where a real Arweave
  txid is 43. Two links a row means the real files are ~10 bytes/row fatter than anything
  the planner can currently see, so the constant is set to 240. A budget calibrated on the
  draft would be wrong on the only emission that gets signed.
* **the check reads the emitted file, and is fatal.** Negative-tested by giving the planner
  an optimistic bytes-per-row: it reports 12 violations, each naming the exec/size split.
  A proxy that is checked against the real thing is fine; a proxy whose check is advisory
  is not a budget.

Honest limit: the seventh-power calibration comes from the wallet's **deploy editor**, i.e.
module-deploy payloads. Whether chainweb charges a non-deploy `exec` payload by the same
curve is **not measured here**, so it is used as a conservative reserve — it can only make
batches smaller than needed.


## 7. A LOAD failure in one suite reports as a dozen unrelated suites BROKEN

Worth keeping because it sent me looking in the wrong place first. Adding the SFT
self-test twin, I invented a one-line fee cap naming `ouronet-ns.STOA.GOV|STOA|SC_NAME`
— **a constant that does not exist**. The file then failed to *load*, and the gate
reported:

```
166.5  721  100  0  BROKEN ZALL.repl
 44.6  405   80  0  BROKEN Kursan/_verify_finding_DPDC-I_33M_makeid_same_block_collision.repl
 40.5  405   80  0  BROKEN Kursan/_verify_finding_DPDC-S_31M_primordial_element_bounds.repl
 ... nine more, all at exactly 405/80 ...
```

None of those suites were touched. They share a process with the file that failed to
load, so they all died at the same point — which is why the **identical assertion count
across unrelated files** is the tell. A load error is not a local failure, and the list
of BROKEN files is not the list of suspects: the one to read is the file whose *name* is
in the error, which appeared only once in 5,500 lines of ZALL output.

Also: **`Stage02_Tester.repl` is not standalone.** Running it alone fails at
`Namespace not found: ouronet-ns` because Stage 00/01 create the namespace. Reproducing a
Stage-2 suite failure means `ZALL.repl` (or `Z.repl`), not the stage tester.

The fee-cap block is now factored into `fee_caps(usage)` and shared by both fixtures,
derived from `URC_SplitSTOAPrices` over the live usage price rather than written down.

---

# PART II — the round's own facts

## The bulk nonce entrypoint is 6x cheaper in gas and 17x cheaper in IGNIS

Measured, `env-gasmodel "table"`, `CNF-98c486052a51` fixture:

| | gas/row | IGNIS/row |
|---|---|---|
| `DPNF\|C_UpdateNonceURI` (single field) | 8,600 | 17.0 |
| `DPNF\|C_UpdateNonces` (bulk, read-overlay) | 1,559 | 1.0 |

`gas(N) = 8,104 + 1,408·N`, linear to within 12 gas over a 192x range; +151/row for a
realistic metadata row, because the read-overlay reads the whole row.

The IGNIS gap is in the pricing readers and is deliberate: `URCi_UpdateNonces` is
`count × UC_IgnisLeg "tier-smallest"` = `count × 1.0`, a **usage** leg, while
`URCi_UpdateNonceField` is a flat **17.0 setup** charge *per invocation*. So for any
field-level change to more than one nonce, the bulk entrypoint is the right one and the
named single-field op is a trap. **This applies to every `C_UpdateNonce*` op, not just URI.**

The safe way to use it is a **read-overlay**: it takes a whole `DPDC|NonceData`, so read
the live row and `remove`/`+` only the keys you mean to change. Everything else is then
carried by the chain rather than by your generator, and there is nothing to get wrong.
A free side benefit over `C_UpdateNonceURI`: the overlay preserves `asset-type`, which the
single-field op overwrites from its own `ay` argument.

## 2. THREE distinct roles guard nonce data, and two of them are indistinguishable

```
C_UpdateNonceURI  -> DPDC-N|C>SET-URI   -> UEV_RoleSetNewUriON    -> R-SetUri
C_UpdateNonces    -> DPDC-N|C>SET-DATA  -> UEV_RoleNftRecreateON  -> R-Recreate
                                        (NOT UEV_RoleNftUpdateON  -> R-Update)
```

`R-Recreate` is **move-only** (`DPNF|C_MoveRecreateRole`); `R-Update` and `R-SetUri` have
toggles.

**`UEV_RoleNftRecreateON` and `UEV_RoleNftUpdateON` emit the BYTE-IDENTICAL refusal**
(`"{} Collection {} Element Data cannot be Updated while using the {} Ouronet Account"`),
so a failing call cannot tell you which role it wanted.

This round's first draft named `R-Update` in all 20 emitted files. **Two things hid it**:
the identical message, and the fact that the REPL fixture owner holds *every* role — so an
assertion on the wrong role passed and the body succeeded regardless. A positive test
cannot distinguish two gates when the subject satisfies both. Settled by `ARW-SHAPE-02`,
which **revokes `role-update`, keeps `role-recreate`, and shows the op still succeeds**.

General rule: when two guards share a message, only an experiment that *removes one of
them* identifies which is live.

## 3. A minted NFT Set instance's data is frozen forever

`DPDC-N.UEV_NotSetInstance` (DPDC Audit #12Hc): for `son=false` and `nost=true`, it enforces
`UR_NonceClass id son nonce = 0`. So **any NFT nonce that has been Made into a Set instance
can never have its name, metadata or URIs changed by any entrypoint in the module** — the
composition record is fixed at Make by design.

Consequence for this round, and for any future data migration: such rows **stay on IPFS
permanently**, and because `C_UpdateNonces` writes a batch under one capability, **one
frozen row aborts the whole transaction**. It cannot be checked offline; every emitted
file carries the `UR_NonceClass` read.

SFT set-classes are unaffected (one shared nonce, never re-derived per Make), and
set-class *definitions* (`nost=false`) stay editable on both — which is how
`Deploy/3_Assets/01_step1.pact` PATH B repairs the Bunny RGB Set.

## WITHDRAWN: the "padding defect in BSD-E / BSD-R / BSD-C"

This section claimed 132 Bloodshed nonces ask for `E_048.jpg` / `R_072.jpg` /
`C_00144.jpg`, from reading the three `UC_*Link` functions as padding on `p` while
formatting `v`. **The chain holds `E_48.jpg`, `R_72.jpg`, `C_144.jpg`.** The defect was
in the Python port, not in the Pact, and it is kept here only as the clearest example of
finding 1: a careful reading of source, written up with a code excerpt and a row count,
produced a confident claim about chain state that one `/local` read falsified.

It also travelled. The first README advised uploading those names **both ways** to
accommodate it, and `LINKS.example.json` shipped two of them as its override template —
so a phantom defect had already generated a work instruction and a config example before
anyone compared it to a row.

---

# OWNER RULINGS, 2026-10-08

**The `UC_*Link` IPFS literals stay.** The minters build each URL in code
(`UC_IpfsLink` etc.) with the IPFS gateway as a string literal, and `C_Fix` writes the
URI slots through it — verified — so an `A_Fix*` rung run after the migration would
overwrite Arweave links with IPFS ones. The ruling: the mint was algorithmic and
one-time, the `A_Fix`/`C_Fix` rungs were one-time repairs for a defect in it, and
neither will run again; nothing more will be minted into these collections. So the
exposure is conditional on an action that will not happen, and a seven-module change to
retire an uninvoked constant is churn. **Recorded, not dropped** — a future reader
spotting an IPFS literal in a minter will otherwise re-raise it, and if a new mint or fix
rung is ever planned, the constant must change first.

**No `PureV5` for equity metadata.** Superseded by finding 5 above: the path was already
open. Worth noting the decision sequence, because it is the failure mode of a confident
wrong answer — the owner authorised a module round, an interface bump and a cascade *on
my analysis*, and the analysis was wrong. The cost of being wrong here was not a bug, it
was a deploy round someone was about to pay for.

---

# CROSS-REPO, SAME DAY, TWICE: a `//` comment inside a generated string

Both halves of 2026-10-08's work shipped a broken generated artefact for the identical reason,
hours apart and in different languages.

**In `_arweave.py`** a Python comment was written inside the `"""…"""` that builds the emitted
Pact body; its backticks terminated the string.

**In `OuronetUI`'s `fvtChain.ts`** a `//` comment was written inside the template literal that
builds the reward-lanes read. A `//` inside a template literal is not a comment — it is TEXT.
It was emitted into the Pact object and the node rejected the entire read:

```
ParseError: Expected: ['}']
```

The owner saw "The reward lanes read failed" on a perfectly healthy aggregator.

**WHY THE TESTS DID NOT CATCH IT, which is the part worth keeping.** Every assertion on those
builders was `toContain("URC_StreamStatus")`-shaped. A substring check CANNOT SEE A MALFORMED
SURROUNDING: the needle is still present in a string that no longer parses. The tests were
measuring the right facts and were structurally incapable of noticing the defect.

The fix is not the one-line edit. It is a check on the SHAPE OF THE WHOLE STRING, run over every
builder:

* no `//` anywhere (Pact's comment is `;;`, so a `//` can only have come from the host language)
* balanced parens and braces
* no surviving `${` and no stray `undefined`

Cheap, total, and it would have caught both incidents. **When a tool GENERATES a language, assert
on the generated artefact's shape, not only on its contents** — and prefer a check that can fail
on a string you did not anticipate writing.

A related near-miss the same day: `/local` does not enforce module admin, so a generated read
using `(keys OtherModule.Table)` simulated clean and failed in a signed transaction. Same family
of error — the check could not see the thing that mattered. `/local` proves a body RESOLVES; it
does not prove the privileges are there.
