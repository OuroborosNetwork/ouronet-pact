# How deploy rounds work — the parity model

<!-- purpose: MANDATORY before building a Deploy/PureVn round: parity model, transitive cascade, backfills, post-deploy sequence. -->

Owner statement, 2026-10-24, written down because it was not written down and an agent rederived
it badly instead. Read this before building any `Deploy/PureVn/` round.

## The invariant

**`1_SOVEREIGN/` IS the live chain code.** Not "a copy of", not "eventually consistent with" —
the folder is supposed to be AT PARITY with what is running on StoaChain right now. That is why
the gate runs against it and why the tests mean anything: they exercise the code that is live.

Everything follows from that one sentence:

- A modification to `1_SOVEREIGN/` is, by definition, a divergence from chain.
- A deploy round exists to END that divergence. Its job is to make chain match the folder again.
- **The modification dictates the round.** Not the other way round, and not a from-scratch plan.
- A module the modification did not touch does not belong in the round.

## Deriving the round — deterministic, in this order

**1. What changed shape?** `python3 REPL/tools/_livemodules.py --diff` compares the repo against
the DEPLOYED source, per module, and prints added/removed functions, capabilities and constants.
This is the authority on "what is actually different from the chain", and it is offline once the
cache is warm (`--probe` refreshes it; a Pact module hash changes on any redeploy, so an unchanged
hash means byte-identical source).

**2. What changed REFERENCE?** — and this is the step `--diff` CANNOT do for you.

`--diff` compares SHAPES. An interface bump changes `module{FooV2}` to `module{FooV3}` in every
consumer WITHOUT adding or removing a single function, so those modules show as identical and are
still mandatory redeploys:

> once RPS implements `AcquisitionRewardPerShareV3`, a module whose modref still says
> `module{AcquisitionRewardPerShareV2}` **cannot bind to it**.

So after `--diff`, grep for the bumped interface names. That set is the cascade, and it is always
a superset of the shape-diff set. Measured on the 2026-10-23 round: **3 modules changed shape,
15 had to redeploy.** Shipping only the 3 would have produced a chain where two thirds of the AQP
family could not call the other third.

**2a. THE CASCADE IS TRANSITIVE, AND ONE GREP DOES NOT FIND IT — added 2026-10-25 after V14 got
this wrong.** The paragraph above says *"grep for the bumped interface names. That set is the
cascade."* That is the FIRST order only. An interface that merely **names a schema object type**
belonging to a bumped interface has its own member signatures changed by the bump, so it must bump
too — and it does not mention the changed module at all, so no grep for the changed module's name
will surface it.

V14 bumped `AcquisitionSchemas` V2→V3. `AcquisitionVacateV3` declares:

```pact
(defun UC_VacateUniqueBeneficiariesFromLegs (legs:[object{AcquisitionSchemasV2.VCT|VacateTfLeg}]) ...)
```

so that member's signature changed, and AQP-VCT then **"does not correctly implement
`UC_VacateUniqueBeneficiariesFromLegs` from Interface `AcquisitionVacateV3`"** — the exact message
the round simulator produced at transaction 09. `AcquisitionVacate` was in neither the shape diff
nor the first-order grep.

**Close it to FIXPOINT, mechanically.** Do not reason about it; the condition to test is *"no
current interface names a superseded interface version"*, iterated until stable. Use the repo's
shared parser so changelog comments (`;; FooV3 -> V4 (date)`) do not produce false hits:

```python
import re, io, os, sys; sys.path.insert(0, "REPL/tools")
from _authsurface import strip_code          # never re-implement comment stripping
# 1. collect every `(interface FamVn` -> family, version      (skip Deploy/, 0_Sample/, sandboxes)
# 2. latest[family] = max version
# 3. for each LATEST interface, scan its own block for `module{FamVn}` / `object{FamVn.Schema}`
#    and FAIL on any n != latest[fam].  Repeat after every bump until the set is empty.
```

Measured on V14 after the fix: **98 interface families, zero current interfaces naming a
superseded one**, and the only consumers still on an old version were two dead scratch files
(`REPL/_cov_draft.repl`, `REPL/Kursan/[6.2.8]_AQP-STAKE-GAS.pact`) that nothing loads. The
fixpoint closed at **six** interfaces, and only three interfaces in the whole tree name a schema
object type at all — which is why this is cheap to check and expensive to guess.

**2b. What version does each bumped interface become?** — ASK THE CHAIN. Do not count from the
repo, and do not ask the owner.

The rule is `highest live version + 1`, and the only authority on "highest live" is
`describe-module`. Poll `<Base>V1`, `V2`, `V3` … and take the highest that answers:

```python
reg = <import REPL/tools/_registry.py>
live = [v for v in range(1, 9)
        if (r := reg.rpc(f'(describe-module "ouronet-ns.{base}V{v}")')) and r.get("code")]
target = max(live) + 1
```

**POLL EVERY VERSION, NOT UNTIL THE FIRST MISS.** A probe that stops at the first absent version
reports "nothing is live" the moment `V1` has been superseded and removed from the path it
expects — measured 2026-10-24, a stop-at-first-miss probe returned `-` for all eight AQP
interfaces while `AcquisitionScores` V1, V2 AND V3 were all live.

**WHY THE REPO CANNOT ANSWER THIS.** Commits lag deploys here. The working tree routinely carries
an interface bump that already shipped, so "repo says V2" means nothing about whether the chain
says V1, V2, or V3. On 2026-10-24 this produced a 40-minute false alarm: the repo's V3 was read
against a stale cached "live = V1", concluded as a double-bump, and reported to the owner as a
serious error. Polling showed V1 AND V2 both live, `+1 = V3`, and the repo had been right the
whole time. **Three wrong diagnoses were built on not running this query.**

**3. Map modules to transactions.** `Deploy/MANIFEST.md`'s numbered table says which generated
batch carries which module. Take the batches containing changed modules.

**4. Add what the generator cannot emit.**
  - **Table/schema repairs.** A schema that gains a field leaves every pre-existing row without
    it, and `with-default-read` does NOT cover that (it defaults an absent ROW, not an absent
    FIELD on a present row). That needs a real migration transaction, hand-authored, positioned —
    see `Deploy/2_Init/00_MANUAL_backfill-min-inject.pact` for the shape and the ordering note.
  - **Modules in no deploy chain.** `_deploybundle.py` globs the `deploy-stage0*.repl` loaders;
    AppReads modules load from `modules/APPREADS-OuronetUI.repl` and so appear in NO generated
    batch. `MANIFEST.md` flags them under *"Modules that must redeploy but are in no deploy
    chain"* — carry them into the round by hand or they are silently skipped.

**5. Number the round strictly** into `Deploy/PureVn/`, `01..NN`, with a `README.md` stating
scope, order, and anything that must run at a specific position.

## What MANIFEST.md is, and is not

`Deploy/MANIFEST.md` / `Deploy/1_Pure/` is a **FROM-SCRATCH planner**: a dependency-ordered plan
for building a virgin chain out of all ~79 modules. It has no notion of what is already live and
no upgrade mode. Its 24 transactions are **not** the size of an upgrade round — the 2026-10-23
round was 12, covering 15 modules.

Sending the full 24 is always *correct*, just wasteful (~5M gas redeploying unchanged modules).

## Do not optimise for fewer transactions

The size charge grows as the **seventh power** of transaction size
(`gas_size(S) ≈ 95_225 × (S_KB / 256)^7`, `CLAUDE.md`). Consequences:

- Doubling a transaction's size multiplies its size charge by **128**.
- Small transactions are nearly free. Measured on the V13 round: four small files (104/63/33/29
  KB) cost **~180 gas** in size charges; merged into one 229 KB transaction they would cost
  **~43,300**.
- So **BALANCE matters more than COUNT** — minimise Σ size⁷, not file count. A round with more,
  smaller transactions is usually the cheaper one.

Per-transaction cap is 320,000 bytes, enforced by `_deploybundle.py` and justified by measurement
(`04_RPS.pact` ships at ~316 KB).

## git is not the authority here

`git diff` against HEAD answers "what is uncommitted", which is NOT "what is undeployed". On
2026-10-24 the tree carried **89** modified `.pact` files while only **3** differed from chain in
shape — the rest were comments and formatting on already-live code, with commits simply lagging.

**Never derive a deploy round from `git diff`.** Use `_livemodules.py --diff` plus the interface
grep. The chain is the authority; the repo is the comparison.

## PENDING ARCHITECTURAL FIX — the round simulator must bootstrap from LIVE, not from git

Owner ruling, 2026-10-24, not yet implemented. Recorded here because the current design is the
root cause of a day of false diagnoses and will keep producing them until it is fixed.

> *"The practice copy has to be built from live chain data, not from my git commit. He can
> construct it with `(describe-namespace "ouronet-ns")`, then describe every module and interface
> live, because what's live is what matters for the simulation, not what my git head has or
> hasn't, which might not be actual. So there is an architectural error in how full round
> simulate works."*

**The defect.** `_chaintxsim.py` creates a `git worktree` at `DEFAULT_BASE_COMMIT = "HEAD"` and
then patches in live-fetched content only for files "touched by this round's interfaces". The
premise is that HEAD ≈ what is deployed. **In this repo it is not**: commits lag deploys, so HEAD
was several interface versions behind live — it still declared `IgnisCollectorV3` while the chain
ran V4. The simulator then assembles a hybrid (live code expecting V4 inside a tree that has only
V3) and fails on the seam. Every such failure LOOKS like a defect in the round.

**The fix.** Build the bootstrap from the chain:
1. `(list-modules)` → every module and interface name in the namespace (one call).
2. `describe-module` each → the real deployed source. Cache by module hash — a Pact module hash
   changes on any redeploy, so unchanged modules are never refetched (`_livemodules.py` already
   implements exactly this).
3. Replay the round on top of THAT. No git commit in the path, so nothing can be "behind live".

**And take the namespace FROM THE ROUND, not from a constant.** A deploy file opens with
`(namespace "...")`; that is the namespace the round targets and therefore the one whose live
surface the simulation must be built from. Hardcoding it makes the tool silently wrong for any
round aimed elsewhere.

### Consequence: two simulation modes, not three

Once the full-round replay runs locally against live-built content it has **no request-size
limit** and **no batch seams**, which removes the only reason the middle button existed:

- **`Chain-simulate` becomes obsolete.** It exists solely because a multi-MB round cannot fit the
  node's `/local` cap (~1–2 MB), so it batches — and composition cannot cross a batch boundary.
  Those seams produce failures that are structurally guaranteed and harmless, and on 2026-10-24
  they actively misled the people reading them. It does evaluate ON the node, which is marginally
  higher fidelity; that is not worth a check that cries wolf by design.
- **The remaining two map onto the two DEPLOYMENT modes**, which is why they are both real:

  | Consecutive | what the round is | correct simulation |
  |---|---|---|
  | **off** | independent transactions, any order | each transaction alone against live — COMPLETE for this mode, and unlimited in size since each is its own call |
  | **on** | ordered, each depends on the last | full-round replay — the only thing that can answer it |

  The UI already has the Consecutive checkbox. The simulate control should follow it rather than
  asking the user to know which of three buttons answers their question.

## STEP ZERO — ask the chain what exists. One call.

```bash
python3 REPL/tools/_livesurface.py                 # the whole live surface
python3 REPL/tools/_livesurface.py --round Deploy/PureVn   # audit a round against it
```

`(list-modules)` returns **every module and interface name in `ouronet-ns` in a single call** —
370 names, 100 versioned families, on 2026-10-24. There is nothing to poll name-by-name, no map
to re-point, no cache to go stale. **The names ARE the answer.**

> owner, 2026-10-24: *"the poller getting the live state of the chain is indispensable, it should
> know what modules exist and what interface versions exist … then you Know EXACTLY how to create
> the deploy pipeline"*

Run `--round` before anything else. It mechanically catches the three failures that actually
shipped broken rounds: wrong interface version, a re-sent live interface, and a genesis bundle
(create-table) aimed at a live chain.

**This is not optional diligence, it is the cheapest check available.** The 2026-10-24 round was
declared ready five times by reasoning from the repo. The first time anyone ran the live surface
against it, it returned **12 problems in under a second** — including an interface
(`TalosStageTwo_DemiPadV3`) that a careful hand-audit of the same round had missed minutes
earlier, because hand-audits work from a list of modules you remembered to look at.

## THE CHECKLIST — run every item, in order, every round

Derived the hard way on 2026-10-24: a round was declared ready **five times** and was wrong each
time. Every failure was a different instance of one mistake — trusting a derived artefact instead
of asking the chain. Work down this list; do not skip an item because the last round passed it.

**1. Poll EVERY interface the round declares. Not a subset.**
```bash
# for each `(interface XxxVn` declared by any file in the round:
#   live = [v for v in 1..8 if describe-module "ouronet-ns.XxxVv" answers]
#   required = max(live) + 1
```
The 2026-10-24 round polled the eight AQP interfaces, passed, and shipped **six** wrong ones:
`AqpMtxV1`, `AcquisitionPoolBootV1`, `DispenserV2`, `OUiThirteenV1`, `OUiFourteenV1` and
`TalosStageTwo_ClientThreeV3` (live at V1–V3, so it needed **V4**). Symptom:
`Interface cannot be upgraded: ouronet-ns.<name>`. **A deployed interface can never be re-sent.**

**2. Is this an UPGRADE round or a GENESIS round? They are not the same artefact.**
`Deploy/1_Pure/` is the FROM-SCRATCH bundle and carries `(create-table ...)`. Against a live chain
those abort:
`Error during database operation: Creation of user table ouronet-ns.AQP-ANK_P|T failed because the
table already exists.`
An upgrade round must have create-table stripped for every module whose tables already exist. Do
NOT build an upgrade round by copying `Deploy/1_Pure/` — that was the 2026-10-24 mistake.
`_deploybundle.py`'s round config carries a `"new"` list of modules that are genuinely new on
chain; anything NOT in it is treated as an upgrade. **That list is hand-maintained and goes stale
the moment a round ships** — it still claimed the whole AQP family was unshipped five weeks after
it shipped. Verify against `_livemodules.py --check` before trusting it.

**3. A module whose interface is already live must ship MODULE-ONLY.**
`Deploy/PureV2/26_deploy.pact` states the rule verbatim: *"MODULE-ONLY, and that is forced rather
than chosen … a deployed interface cannot be re-sent or changed. The new reader is therefore
declared in the MODULE and not in the interface: a module may expose MORE than its interface
declares, and may not expose less."* Either strip the interface, or bump it — never re-send it.

**4. Do not copy generated batches wholesale.**
A generated batch packs modules by SIZE, not by what your round changed. `14_deploy.pact` bundles
`00_Demipad` with `00_AQP-SCHEMAS`; Demipad names no AQP interface and had no business in the
round. Trim to exactly the modules the cascade requires.

**5. Expect "no such member" in the per-file simulator. It is not a defect.**
`Simulate all` runs each transaction ALONE against the live chain, so transaction N referencing an
interface that transaction N−1 deploys MUST fail. That seam is structural. Only the whole-round
replay can answer "does this round work" — and only once items 1–4 are clean.

**6. Table/schema repairs are transactions, and they need a position.**
A schema that gains a field leaves pre-existing rows without it, and `with-default-read` does not
cover that (it defaults an absent ROW, not an absent FIELD on a present row). Write the migration
as its own file, place it in the sequence, and state the ordering constraint in its header. It
cannot be tested in the REPL — the harness builds tables fresh from the current schema, so a row
that predates a field is not constructible there.

**AND THE PASS IS DESTRUCTIVE IF RE-RUN.** Pact will not let a migration ask whether a typed field
is absent, so it writes the default **unconditionally**. For an ordinary field that is merely
wasteful; for a **latch** it is the bug the latch exists to prevent — re-running V14's
`AA_MigrateStreamEligible` after an owner had latched would silently **UN**-latch them. Say this in
the file's own header, and say which signature it needs. Run once, in position.

**7. Does the round add a PRICED op? Then IGNIS ships too.** `UC_IgnisComponents` is
`(at op-key IG|COMPONENTS)` and its own doc says it **"fails fast on an unknown op"** — so a new
`C_`/`CC_` with a new price key aborts on the price lookup until `02_IGNIS.pact` is redeployed with
that key. Easy to miss because it is a Stage-1 module in an otherwise Stage-2 round. The inverse is
also true and is why V13 did NOT need IGNIS: an op that bills through an EXISTING key
(`C_SetMinInjectAmount` → `URCi_ToggleRewardLink`) adds no key and needs no IGNIS deploy.

**8. Is the round TIGHTENING an existing gate? Then it breaks existing fixtures, and `Z.repl`
cannot see it.** A new precondition on a working entrypoint means no existing test can call it any
more. V14 added a stream-eligibility gate to `CC_InjectStream`; **`Z.repl` stayed green at 1,068
assertions** because it loads none of the three suites that stream. Only `_gate.py` runs them.

**The failure signature is what matters, because it does not look like a failure:** the two broken
suites reported **`BROKEN` with a failure count of ZERO**. A load-time abort is not an assertion
failure, so the gate's per-suite detail section was EMPTY for both. Reading the summary table's
`fail` column alone looks like noise. **`BROKEN` is the column that decides; the fail count is
not.** Expect to fix fixtures, not code — and expect the fix to be ordering-sensitive if the new
gate scans (lock the member before the container).

**9. A byte-cap conflict is a DESIGN smell before it is a budget problem.** `_deploybundle.py` caps
emitted transactions at 320,000 bytes, and **a single module cannot be split across
transactions** — so raising `HEADER_RESERVE` does nothing. When V14's `stream-eligible` field
pushed `04_RPS.pact` to 321,970 bytes, the two options were "raise the cap" or "move the field".
**The cap stayed.** The tool's own comment says the repo does not know what binds first at this
size and warns that *two points fit any curve*; CLAUDE.md records the linear extrapolation that
would have produced 100,000,000-gas transactions. Moving the field to `FVT|Schema` fit **and** was
the better design — eligibility is a property of the vault, not of one reward lane — and it deleted
a cross-module hop. Try relocation before you touch a safety parameter you cannot justify moving.

**10. Verify with `_gate.py`, then the round simulator. In that order.**
```bash
python3 REPL/tools/_gate.py                                   # the gate. not Z.repl
python3 REPL/tools/_livesandbox.py --round Deploy/PureVn       # whole-round replay vs LIVE source
python3 REPL/tools/_deploybundle.py --check                    # Deploy/ matches sources byte for byte
```
And if the round is hand-assembled from generated batches, prove the copies are FRESH — a
regenerated `Deploy/1_Pure/` leaves hand-copied round files stale, and `--check` does not look
inside `Deploy/PureVn/`. Containment is enough: every non-header line of a round file must appear
in its `1_Pure` parent (round files are the parent minus already-live interface blocks).

## AFTER THE ROUND LANDS — four artefacts, four different authorities

Added 2026-10-25, because this was the one part of the process nobody could state from memory, and
because **three of these four can agree with each other while all being wrong.**

```
   THE CHAIN                        <- the only authority. "DEPLOYED CODE WINS."
      |  _registry.py --probe        (network; reads describe-module)
      v
   Deploy/OURONET-REGISTRY.json     <- the artefact
      |
      +-- _registrylive.py --record  asks the chain "is this STILL true?" and writes
      |                              ...livecheck.json = A DATE.  Does NOT regenerate.
      |
      |  npm run build (= sync + tsc) in packages/talos-registry
      v
   @ouronet/talos-registry          <- bundles a COPY of the artefact
      |  npm publish  ->  bump the dep in the consumer's package.json
      v
   OuronetUI / ouronet-core / Pythia
```

**Why nothing catches this on its own.** `_pkgsync.py` here and `sync-registry.mjs` in the package
both diff the artefact against **the package's bundled copy of itself**. Neither asks the chain. So
after a deploy the artefact just sits there, **both guards report "in sync"**, and every consumer
validates against a surface that no longer exists — confidently, which is the dangerous part.
`_registrylive.py` is the only thing that asks the chain, and it **cannot join the gate because the
gate must run offline.** That is why this is a manual list and not a check.

**`--record` writes a DATE, not DATA.** It is a verifier. The regenerator is `--probe`. Conflating
the two is the specific misunderstanding this section exists to kill: *"run the scripts"* sounds
like one action and is two different jobs — *re-read the chain*, then *re-confirm the snapshot*.

**Publishing is required when the consumer pins a VERSION rather than a path.** OuronetUI carries
`"@ouronet/talos-registry": "2.3.0"` installed as a real directory in `node_modules`, not a
workspace symlink — so a local `npm run build` changes nothing for the UI until the package is
published and the dep raised.

```bash
python3 REPL/tools/_registry.py --probe          # 1. re-read the chain (the regeneration)
python3 REPL/tools/_registrylive.py --record     # 2. re-confirm it (the date the gate prints)
cd ../../_libs/ouronet-libs/packages/talos-registry
npm run build && npm test                        # 3. sync + tsc, then the builder-arity tests
#    -> bump version, publish, raise the dep in the consumer
python3 REPL/tools/_gate.py                      # 4. confirm
```

Step 1 is also what clears a **preview-pairing** failure whose cause is live-chain state: a round
that adds an `INFO_` reader for an entrypoint shipped previewless by the PREVIOUS round cannot make
that gate line green until it deploys. Do not paper over it with a `PREVIEW_EXEMPT` entry — an
exemption written for a transient condition outlives it and becomes a standing excuse bound to a
`(file, function)` pair. If you need to see the rest of the gate, add the exemption and revert it
**in the same command**.

## The `"new"` list in `_deploybundle.py` — check it, every round

`ROUNDS[<round>]["new"]` names modules that are genuinely NEW on chain. Those keep their
`(create-table ...)` calls; everything else is treated as an upgrade and has them stripped.
Default mode is already `upgrade` — **this list is the only thing that overrides it.**

On 2026-10-24 the active round (`2026-09-full`, `DEFAULT_ROUND`) still read:

```python
"new": ["/03_AQP/", "04_AQP-BOOT.pact"],   # "Owner confirmed 2026-09-18: none of the AQP family is live"
```

The AQP family shipped weeks later. Nobody re-pointed the list, so the planner emitted
create-tables for a family whose tables exist, and transaction 1 died on
`Creation of user table ouronet-ns.AQP-ANK_P|T failed because the table already exists`.

**Two traps here, both cost time on the day:**

1. **`ROUNDS` holds several rounds.** The first fix edited `2026-09-aqp`'s list while
   `DEFAULT_ROUND = "2026-09-full"` — the output did not change and the edit looked ineffective.
   Check `DEFAULT_ROUND` before editing, or pass `--round` explicitly.
2. **"Is it live?" has an authoritative answer.** `_livesurface.py` answers it in one call. A name
   belongs in `"new"` only if the live surface does not already contain it.

Verify after regenerating — it is one command and it is unambiguous:
```bash
grep -c "^(create-table" Deploy/1_Pure/<batch>_deploy.pact      # upgrade round -> 0
```

## MODULE-ONLY: when an interface is already live

A deployed interface can never be re-sent (`Interface cannot be upgraded`). If a round ships a
module whose interface is live AND unchanged, strip the interface and ship the module alone —
a module may expose MORE than its interface declares, and may not expose less. If the interface
itself changed, bump it instead. `Deploy/PureV13/11_deploy.pact` and `12_deploy.pact` (the two
AppReads pages) are the worked example; `Deploy/PureV2/26_deploy.pact` is the original statement
of the rule.

## Never cache "what is live" — the 2026-10-24 lesson, in one rule

`_chaintxsim.py` carried a hardcoded `NEW_TO_OLD` map answering "for this repo name, what is the
live name?". It was written during the PureV10 round, when the repo was one version ahead of the
chain. **PureV10 then shipped**, every "new" name became live, and nothing re-pointed the map —
so the tool fetched **one-version-old source for most of the tree** and spliced it into a round
built against the current one.

Measured that day: `IgnisCollectorV4`, `OuronetDalosV3`, `DemiourgosPactTrueFungibleV3` and all
eight AQP interfaces were live under their "new" names while the map still named the older one.

**Why it was so expensive.** It did not fail loudly. It returned real, valid Pact source — just
the wrong vintage — so the failures looked like genuine defects in the round and pointed at
plausible culprits. Three wrong diagnoses were built and reported before anyone ran
`describe-module`: a module that merely shared a transaction, then a "malformed splice", then an
imagined double-bump that was escalated to the owner as a serious error. **The round was correct
the entire time.**

**The rule:** a cached answer to "what is live" is wrong by construction. It is written when the
repo is ahead of the chain, and it goes stale at the exact moment it is next needed — the deploy.
Resolve by asking: if the repo's own name answers `describe-module`, that IS live; only walk down
versions if it does not. Fixed in `resolve_live_iface()`; the map remains only as a fallback.

**Generalise it:** anything in this tree that hardcodes a belief about chain state is a latent
version of this bug. The chain is cheap to ask — a handful of `describe-module` calls — and it
cannot rot.

## Known drift NOT owned by any round (2026-10-24)

`_livemodules.py --diff` reports `BLOODSHED-C/E/L/R/SETS` and `NOSFERATU` differing from chain:
the deployed copies carry pre-StoicSyntax names (`CommonLink`, `OrderMultiplier`, `N`,
`NosferatuSpawner`) while the repo carries the renamed ones (`UC_CommonLink`,
`UCv_OrderMultiplier`, `A_Fix01`…). This is CITIZEN code, predates the 2026-10-23 round, and is
in no deploy pipeline. Flagged so it is not mistaken for round damage — it needs its own round.
