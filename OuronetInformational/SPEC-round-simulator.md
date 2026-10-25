# SPEC — the round simulator, rebuilt on live chain state

<!-- purpose: What _livesandbox.py --round proves against live chain state — and what it does NOT prove. -->

Owner instruction, 2026-10-24. Supersedes the git-worktree bootstrap in `_chaintxsim.py`.
Companion to `HOW-DEPLOY-ROUNDS-WORK.md`, which carries the reasoning and the post-mortem.

## The problem this replaces

`_chaintxsim.py` builds its sandbox from `git worktree @ HEAD` and patches live content into only
the files "touched by this round's interfaces". The premise — HEAD ≈ what is deployed — is false
here: commits lag deploys, so HEAD carried `IgnisCollectorV3` while the chain ran V4. The result
is a hybrid (live code expecting V4 in a tree that has only V3) that fails on its own seams, and
every such failure reads as a defect in the round. It cost a full day of false diagnoses.

> *"The practice copy has to be built from live chain data, not from my git commit … what's live
> is what matters for the simulation, not what my git head has or hasn't."*

## S1 — The sandbox is built from the chain

1. **Namespace comes from the ROUND**, never a constant. Read `(namespace "...")` from the round's
   own files. A round targeting another namespace must simulate against that one.
2. `(list-modules)` → every module and interface name in that namespace. One call.
3. `describe-module <name>` for each → the real deployed source.
4. Write those sources into a throwaway tree. **That tree is the chain.** No git commit is in the
   path, so nothing can be silently behind live.
5. Replay the round's transactions on top, in order.

**Caching is mandatory, not an optimisation.** A Pact module hash changes on ANY redeploy, so an
unchanged hash means byte-identical source: cache keyed by hash is exact, not heuristic. First run
fetches everything (~370 names); later runs fetch only what was redeployed. `_livemodules.py`
already implements exactly this and should be reused rather than reimplemented.

## S2 — Progress must be visible

The run takes minutes. A spinner that says nothing for three minutes is indistinguishable from a
hang, and the operator cannot tell whether to wait or kill it.

The tool emits one structured line per step on stdout:

```
@@PROGRESS {"phase":"namespace","done":1,"total":1,"label":"ouronet-ns"}
@@PROGRESS {"phase":"enumerate","done":370,"total":370,"label":"370 names"}
@@PROGRESS {"phase":"fetch","done":112,"total":370,"label":"AQP-FVT (cached 258)"}
@@PROGRESS {"phase":"sandbox","done":370,"total":370,"label":"virtual chain assembled"}
@@PROGRESS {"phase":"replay","done":4,"total":12,"label":"04_deploy.pact"}
@@PROGRESS {"phase":"done","done":12,"total":12,"label":"round composes clean"}
```

Rules: `@@PROGRESS ` prefix + one JSON object, one line, flushed immediately. Phases are ordered
and named above. `total` may be 0 when not yet known. Human-readable output is unchanged — this is
additive, so the terminal stays the authority a person reads.

**UI:** `Full-round simulate` opens a modal showing phase, a bar from `done/total`, the current
label, and elapsed time. It must state what is happening in the operator's words — *"asking the
chain which modules exist"*, *"fetching deployed source (112/370, 258 cached)"*, *"building the
virtual sandbox"*, *"replaying transaction 4 of 12"*. Cancellable. On failure it shows the failing
transaction and the raw error, never a bare "failed".

## S3 — Two simulation modes, tied to the deployment mode

Once the replay runs locally against live-built content it has no request-size limit and no batch
seams. That removes the only reason `Chain-simulate` existed (batching a multi-MB round under the
node's ~1–2 MB `/local` cap, with composition unable to cross a batch boundary).

**Retire `Chain-simulate`.** The remaining two map onto the two ways a round is actually sent:

| Consecutive | what the round is | correct check |
|---|---|---|
| **off** | independent transactions | each transaction alone against live — COMPLETE for this mode, no size limit |
| **on** | ordered, each depends on the last | full-round replay — the only thing that can answer it |

The UI already has the Consecutive checkbox; the simulate control follows it instead of asking the
operator to know which of three buttons answers their question.

## S5 — Stated assumptions

Each of these is a thing the tool relies on that is NOT enforced by Pact, so it is written down
rather than discovered by someone later.

### S5.1 — Interface names end in `V<n>`

Owner's own framing: *"the only thing it assumes is the naming of the interfaces, which must end
in V and a number — V1 V2 V3 V4 V5."* The UI badge says so; so does this.

Where it binds: picking the LATEST live version of an interface, and reporting a round that
re-sends an already-deployed one. An interface called `AcquisitionScores` with no suffix is
invisible to that check. The convention is already mandatory
(`ARCHITECTURE/INTERFACE_VERSIONING.md`), so this adds no new rule — it records that a tool now
depends on it.

Note what the simulator does NOT need it for: **load order**. That is derived from the sources
themselves, so a badly-named interface still sorts correctly.

### S5.2 — Placeholder keysets and granted module admin are CORRECT here

The sandbox defines every keyset the live modules ask for as a placeholder, signs with the Stoa
sandbox's own namespace key, and grants `env-module-admin` for each module the round upgrades.

That is not a weakness to be fixed later. The question this tool answers is **"does this round
compose against live code"**, not "is the operator authorised". Authority is proven by the real
signature on the real send, which **the owner supplies through the Codex**. A verify-only tool
holding real signing keys would itself be the security problem it is meant to protect against.

The alternative was seeding real rows — forging a DALOS account guard so `GOV|DSA_ADMIN` would
pass. Forging a governance guard in order to test governance is circular; `env-module-admin` is
the same bypass, declared instead of faked.

### S5.3 — The sandbox tables are EMPTY, and that is the honest limit

`describe-module` returns the source AS DEPLOYED, and what was deployed was an UPGRADE — whose
`create-table` forms were stripped, since `create-table` aborts when the table exists. So every
live source declares its `deftable`s and creates none. The sandbox recreates them from those
declarations, and they come up with **no rows**.

Consequence, which must be stated wherever a green result is shown: a migration is proven to
**execute**, not to transform real data correctly. Row-level behaviour belongs to the REPL suites,
which have fixtures. The `limits` text on the allowlist entry carries this for the UI.

### S5.4 — Live state is historical, not simultaneously consistent

Modules deployed at different times can reference each other's since-changed surfaces. On chain
that costs nothing until someone calls the module; in one blank database it stops the load. Live
`DPL-UR` is the measured case: it names `OuronetDalosV2` while live DALOS implements V3.

So the tool excludes a live module that will not load, and **reports every exclusion** — an
exclusion means the round was checked against slightly less than live state, and a silent one
would be a weaker result wearing a green badge.

Two guards on that, both learned the hard way (see S6):
- **Never heal on a keyset failure or a database "not found"** — both say the SANDBOX is wrong and
  name an innocent module.
- **Attribute by the error ORIGIN, never by a stack frame** — frames name every file on the way in.

## S6 — Failure modes already paid for

Kept because each produced a confident, wrong, chain-level conclusion, and the shape recurs.

| symptom | wrong conclusion | actual cause |
|---|---|---|
| `Module AQP-SCORE has no such member: URCi_RotateOwnership` | live AQP-SCORE lacks the function | it was loaded LATER. Direct qualified calls (`AQP-SCORE.fn`) are load-order edges and were not counted. Live AQP-SCORE defines it — one grep refuted the whole diagnosis |
| a 370-way dependency "cycle" | cycles are inherent in live state | every `Other.fn` mention counted as an edge, including prose in `@doc` strings |
| `AQP-ANK` ↔ `AQP-POOL` cycle | mutual recursion on chain | regex string-stripping mis-paired quotes across Pact's `\` doc continuation, so prose counted as code. ONE false edge made the graph cyclic |
| 28 interfaces "broken on chain" | the namespace is broken | `env-sigs` OVERWRITES; setting a sandbox key wiped the namespace signature. They were unsigned, not broken |
| 20+ modules "broken on chain", DALOS first | cascading chain breakage | a bare search for `_chain.pact:\d+` matched STACK FRAMES, so a round-file error was blamed on a live module, then on the next frame |
| round fails at transaction 01 after an exclusion | file 01 is wrong | `env-module-admin` was still emitted for the EXCLUDED module in every transaction. The failure pointed at the first tx; the cause was the last |

The common thread: **a Pact error message that names a module is not evidence about that module.**
Check the claim before reporting it — `_livesandbox_test.py` pins all six.

## S4 — Acceptance

- Simulating `Deploy/PureV13` reports a clean round, or names the transaction that fails and why.
- No `git worktree`, no `--base-commit`, no `NEW_TO_OLD` map in the bootstrap path.
- A round in another namespace simulates against that namespace.
- Second run of an unchanged chain fetches ~0 sources (cache hit) and is substantially faster.
- The progress modal advances through every phase; a failure names the transaction.

**MET 2026-10-24.** `python3 REPL/tools/_livesandbox.py --round Deploy/PureV13`:

```
namespace (from the round): ouronet-ns
live surface: 370 modules + interfaces
sources: 370 usable (0 fetched, 370 from cache)
closure: 136 live name(s) this round depends on (234 unrelated live name(s) not loaded)
granting module admin for 16 upgraded module(s) in each tx
  excluding live module DPL-UR -- will not load: Runtime typecheck failure ... OuronetDalosV2
  (defined 9 placeholder keyset(s) the live modules expect)
  1 live module(s) are ALREADY BROKEN ON CHAIN and were excluded from the sandbox
  NOTE: this round REDEPLOYS DPL-UR -- the round is what fixes them.
ROUND OK -- 13 transaction(s) composed clean against live content.
```

The single exclusion is real, pre-existing breakage, and `13_deploy.pact` ends it.

**And it is worth knowing what it actually was, because the first explanation was wrong.** The
claim written here and in the round README was that the chain still ran "the original 3,025-line
DPL-UR" and that the archive-mode stub "had sat undeployed since 2026-09-25". Measured:
live DPL-UR **is** the stub — 76 lines, three defuns, zero `implements`. The stubbing shipped.

What did not ship was a **cascade**. DALOS later bumped `OuronetDalosV2` → `V3`; DPL-UR was
missed and still declares `(ref-DALOS:module{OuronetDalosV2} DALOS)`. Live and repo differ in
exactly one token.

The question that exposed this is the right one to carry forward — *"that interface still
exists, so why is it a problem?"* It does exist, and a deployed interface never stops existing.
`module{I}` is a type whose only inhabitants are modules declaring `implements I`, and the
cascade rule has implementors carry only the LATEST version. So `OuronetDalosV2` is a present,
permanently **uninhabited** type, and a modref naming it cannot bind. DALOS *is* a modref — just
not that one.

**This is the cascade rule failing in its characteristic way:** a module dropped from a cascade
does not fail at bump time. It fails later, at BIND time, and stays silent until something
touches it. That is why `_livesurface.py` exists, and why "grep the bumped interface names" is
the step that defines a round's true scope.

Wired into OuronetUI as `livesandbox-purev13` (`plugins/ouronet-scripts.ts`), driving the
"Sequential Simulation" button and the `RoundSimulateProgress` modal over an NDJSON progress
stream. Covered by `REPL/tools/_livesandbox_test.py` (20 assertions on the scan functions) and
`src/components/execute-code/__tests__/round-simulate-progress.test.tsx` (9 on the modal).
