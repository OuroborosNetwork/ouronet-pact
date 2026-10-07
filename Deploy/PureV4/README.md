# Deploy — round V4

Share-based (equity) scoring. **Six transactions, twelve modules, five of them changed.**

Siblings, not a sequence: `../1_Pure/` is round V1 (24 tx, 2026-09-24), `../PureV2/` is V2 (35 tx),
`../PureV3/` is V3 (8 tx, the StoicSyntax 2.16 canon sweep, **fully executed 2026-10-06/07**).
Each folder numbers from 1 again and is kept exactly as it went out.

## Why this round exists

Owner ruling, 2026-10-07. An **`E|` shareholder collection exposes share-based scoring and nothing
else** — it is a *built-in* mechanism, not a definition. The score itself only decides whether the
stake earns debt.

Demiourgos Snakes was *meant* to read "the nonce valued at 500 shares is worth 100 points", and the
system had no way to say it. A semi-fungible score definition stores a weight **per nonce**, while
an equity nonce's worth in shares is derived from the collection's **live** total by
`EQUITY::URC_SingleSharePerMillions` — so the weight is now computed at **stake time**, and a score
definition on an equity collection is **refused** rather than ignored. A stored definition that can
never be read is a lie the UI will eventually display.

### The share count cannot move today — and that is stated, not glossed

The first draft of this folder justified the change with *"raise a collection from 1M to 10M shares
and every stored weight is stale."* **That is not currently possible.**
`C_IssueShareholderCollection` mints exactly 1,000,000 nonce-1 shares and grants `R-AddQuantity` to
`<dpdc>` **alone**; the only two functions that use it (`XI_MakePackageShares`,
`XI_ConvertPackageShares`) credit *package* nonces, never nonce 1, and Make/Break route shares
through `<dpdc>` as **escrow** rather than minting. The observable consequence is in the existing
suite: `URC_CombineCapacity` reads **400,000** and not 450,000 after a 100,000-share Make, which is
only true if nonce-1 *total* supply never left 1,000,000. So `URC_SharesPerMillion` is
`[100 200 500 1000 2000 5000 10000]` on every equity collection in existence.

Two reasons to derive anyway, neither of which needs the false one:

1. **The variable share count is a stated requirement** (owner, 2026-10-07: *"as the company
   increases or decreases shares"*). Deriving now means adding EQUITY's own share-issuance path
   later will not force a re-settling of every score already issued — which is exactly the
   migration a stored table would demand, silently, on rows nobody would think to re-read.
2. **A table has to be written.** Per score × per collection × per nonce, and every one of those
   writes is a chance to enter a wrong number — the failure mode the Bloodshed / Nosferatu /
   Bunnies settling round spent a day on. There is nothing here to write.

| where | what |
|---|---|
| `EQUITY` | `URC_IzEquitySemiFungible` — the `E\|` predicate, **promoted to the interface** so AQP-SCORE can ask. This is why `EquityV2` → `EquityV3`. |
| `AQP-SCORE` | `URCx_EquityShareRawWeight` — Σ over staked nonces of `quantity × share value`: `1.0` for nonce 1 (raw shares), the live `URC_SingleSharePerMillions` for package tiers 2–8, `0.0` outside 1–8. |
| `AQP-SCORE` | `URC_SignedBaseDeltaForDpsfStake` is now three-way: equity → share weight, `sft-equality` → flat, otherwise the stored per-nonce definition. |
| `AQP-SCORE` | `UEV_SemiFungibleScoreDefinition` refuses an equity collection outright. |

An out-of-range nonce contributes `0.0` rather than aborting. An unknown nonce is worth no shares,
which is the honest answer, and it keeps the fold total meaningful instead of losing the whole stake
to one bad entry.

## The tests, and the two things they had to be fixed for

| suite | pins |
|---|---|
| `[6.1.1]_EQUITY.repl` `TX-EQUITY-004` | the `E\|` predicate; the share weights; packaging weight-neutrality; additivity; out-of-range → 0; **and the tracking property** |
| `[6.2.2]_AQP-SCORE.repl` `<<TX-SCORE-15>>` | the definition **refusal**, with its non-vacuity pair |
| `[6.2.2]_AQP-SCORE.repl` `<<TX-SCORE-15b>>` | the **dispatch**, through `URC_SignedBaseDeltaForDpsfStake` |

**The tracking property is now asserted, not printed.** That group used to claim *"asserted rather
than argued"* above three lines that only `print`ed a number. It now drives nonce-1 supply from 1M
to 10M with `env-module-admin` — the same module-admin write the owner uses on mainnet, chosen
because no client path to raise it exists — and asserts the tier weight follows ×10 while a raw
share stays at 1. Restored in the same transaction, so nothing downstream moves.

**The dispatch needed its own transaction, twice over.** Every helper assertion above passed with
the dispatch branch *deleted* — they call the helper directly and never traverse the stake path, so
the one line that makes the feature reachable was unpinned. And the first version of the dispatch
assertion lived inside `<<TX-SCORE-15>>` and read `E|TSEQ-98c486052a51` out of `[6.1.1]`'s fixture,
which **seven of the eight gate entrypoints that load `[6.2.2]` never load**: green under
Stage02_Tester, `No value found in table DPSF|T|Nonces` everywhere else. `<<TX-SCORE-15b>>` issues
its own company under a ticker nothing else uses and rolls the transaction back.

Two lessons worth keeping: a cross-suite fixture is a load-order bet, not a fixture — and assertion
count is not coverage, because a helper test is not a feature test.

## The round

| file | bytes | ~gas | contents |
|---|---|---|---|
| `01_deploy.pact` | 224,435 | 32k | **`EquityV3`** (new interface) + `EQUITY` + `TS02-C1` + `INFO-TWO` + `DEMIPAD-SNAKES` |
| `02_deploy.pact` | 227,245 | 35k | `AQP-SCORE` — the round's subject |
| `03_deploy.pact` | 296,148 | 224k | `RPS` — alone, on size |
| `04_deploy.pact` | 263,187 | 98k | `MTX-AQP` + `AQP-DSA` + `AQP-VCT` |
| `05_deploy.pact` | 202,127 | 15k | `AQP-FVT` |
| `06_deploy.pact` | 184,018 | 8k | `AQP-INFO` + `AQP-BOOT` |
| **total** | **1,397,160** | **412k** | 6 transactions, worst single 224k of a 2.00M budget |

**Deploy 01 → 06 in order.** Do not reorder, do not skip, do not run two concurrently.
Every file is an **upgrade** except the `EquityV3` interface in 01: zero `create-table` survives
into any of them, which is how we know no table is recreated and no entity id moves.

Signing: these are upgrades, so `GOV` is evaluated — the admin key, not the namespace keyset.
`01` is mixed (a first-deploy interface plus four upgrades) and still needs only `GOV` plus
namespace write.

## Why twelve modules for a three-place change

Two cascades. The second is the one that costs.

**Interface cascade.** `EquityV2 → V3`: `AQP-SCORE`, `TS02-C1`, `INFO-TWO` and the citizen
`DEMIPAD-SNAKES` all name it, so all four move together.

**Dot-pin cascade.** `AQP-SCORE` owns 12 tables and is dot-called by `RPS` and `AQP-INFO`; `RPS`
by `AQP-FVT`, `AQP-VCT`, `MTX-AQP`, `AQP-DSA`, `AQP-INFO`; `AQP-FVT` by `AQP-INFO` and `AQP-BOOT`.
A stale dot-caller of a **table-owning** callee does not go quietly stale — it **aborts** with
*"hash not blessed"*. So **seven of these twelve modules are byte-identical to what is already
live** and ship anyway. `EQUITY` itself has **zero** dot-call sites in the tree, which is the only
reason the round is not larger. Ground truth: `python3 REPL/tools/_dotpin.py`.

## Why six transactions and not five

Gas grows as the **seventh power** of transaction size on this network — `gas ≈ 95,225 ×
(KB/256)⁷`, a ceiling near **395 KB / 2.00M gas**. `RPS` alone is ~296 KB, so five transactions
would put ~269 KB on each of the other four: **~760k gas for the round against ~412k at six**, and
2.4× the worst single transaction.

**Fewer files is not cheaper here, and the ceiling is not the budget.** Pairing `05` with `06`
(202 KB + 184 KB = ~377 KB) fits under the ceiling and costs **~1.43M gas** — more than three times
the entire six-transaction round, in one transaction. Balance beats count.

`python3 REPL/tools/_purev4.py --plan` re-derives the table above. It reports **emitted** bytes,
not body bytes: `_purev3.py --plan` reported the body and so understated every transaction by its
header (~5.6 KB), which at the seventh power is ~13k gas on the 296 KB file — while `--check`
enforced the cap on the emitted file. A planner that measures something other than what the check
enforces is the *"proxy whose check is advisory"* trap `CLAUDE.md` already records against
`_deploybundle.py`.

## What checks this folder

`REPL/tools/_purev4.py --check`, fatal inside `_gate.py`. Three classes of failure, none of which
a source diff can see:

- **ORDER** — every dot-callee ships **strictly earlier in the global sequence** than its callers,
  and every new interface before every module naming it. Position, not transaction index: modules
  inside one file load top to bottom, which is exactly why `EquityV3` and its three namers share
  `01`.
- **SHAPE** — zero surviving `create-table` in an upgrade (one aborts the whole transaction on a
  table that already exists), and exactly one `interface` form per `iface+upgrade` source. Too many
  re-sends a live interface and is refused; too few drops the new one and every modref downstream
  fails to resolve.
- **STALE** — the body of every file is regenerated from the module sources and diffed byte for
  byte, so a source edit cannot land without the deploy file following it.

V3 improved on V2 by deriving the order constraint; **V4 improves on V3 by deriving the interface
constraint too.** V3 hard-coded *"AcquisitionScoresV2 must precede its namers"*, which is a fact
about one round; V4 declares `NEW_IFACES` and derives it, because the next round ships a different
interface and a hard-coded name cannot report that it is checking the wrong one.

## One finding this round produced, for whoever writes `C_IssueShares`

Deriving the weight live surfaced a hazard a stored table would have hidden.

`XI_BreakPackageShares` releases `sspm × amount` nonce-1 shares **out of the `<dpdc>` escrow** —
and `sspm` is `URC_SingleSharePerMillions`, which scales with total supply. The escrow does not. So
a share issuance that mints only into the issuer's account leaves **every outstanding package
unbreakable**: the escrow is under-collateralised by exactly the inflation factor, and the Break leg
fails on an insufficient `<dpdc>` balance.

**Requirement:** a correct `C_IssueShares` must top up `<dpdc>`'s nonce-1 balance in proportion to
every outstanding tier unit, not merely credit the issuer.

`UC_Convert` (numerator and denominator both inflate) and `URC_CombineCapacity` (half-shares and
`Σ supplies × spm` both inflate) are scale-invariant, so **Break is the only exposed path**. Noted
because the semantics this implies — outstanding packages keep their *percentage* and gain absolute
share value, so existing holders are not diluted — is a design decision, not an accident, and it is
the one the current derivation already assumes.

## Round V3 is frozen

`_purev3.py`'s `MANIFEST` is now **empty** and its eight files sit in `FROZEN`. They were executed
on mainnet, so they are **records, not sources** — regenerating one when a module later moves would
rewrite what was actually sent. PureV2's notes record that round being bitten by exactly this four
separate times.

Confirmed deployed by the chain rather than by memory: **`URH_AQP|AllPoolIds` returns 7**, and those
pools exist only if Step 7 ran, which requires the `AQP-BOOT` shipped in V3/08.
