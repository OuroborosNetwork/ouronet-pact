This appendix states, in one place, what is verified about this codebase as of the version on the
title page — and, for each claim, the command that re-derives it. Nothing here is asserted without
a way to check it, because a figure in an audit document that cannot be re-derived is a figure that
will be wrong eventually and silently.

Three separate times in this programme a published number was found to have gone stale while every
document agreed with every other document. That is the failure this appendix is built against: the
figures below are re-derivable from the tree, not copied between files.

## The gate

`python3 REPL/tools/_gate.py` is the gate. It runs 92 entrypoints across 321 reachable files on 16
workers, takes roughly five to seven minutes, and is the only thing entitled to the word "green".

```
wall 318.5s   executed 25,035 assertions (20,034 positive, 4,991 negative)
GATE GREEN
```

The distinction between the two counts matters. A **positive** assertion (`expect`) says an
operation produced a specific value. A **negative** assertion (`expect-failure`) says an operation
was refused — and, where the refusal is pinned by *message*, says which guard refused it. Roughly
one assertion in five in this suite is a negative one, which is what a security-oriented suite
should look like; a suite that only proves things work cannot detect a deleted gate.

The gate also runs a set of static checks that are **fatal**, not advisory. A tree that passes every
assertion but fails one of these does not go green:

| check | what it enforces |
|---|---|
| `_pricesync --check` | the generated price sheet matches the price tables in source |
| `_figuresync --check` | the figures in `ARCHITECTURE/*.md` match the tree |
| `_toolpaths --check` | every hard-coded path literal in every tool still resolves |
| `_redteam` | every attack header parses; the register matches the ledger |
| `_booktables --check` | this book's headline tables sum to their own totals |
| `_auditbook --check` | this book is not stale against its chapter sources |
| orphan check | every asserting file is reachable from a gate entrypoint |

The orphan check is the least obvious and the most valuable: a test file that nothing loads is a
test file that passes forever. It found files in this tree.

## Deployment readiness

Confirmed by execution, not inspection:

| check | command | result |
|---|---|---|
| full deploy chain loads | `cd REPL && pact Z.repl` | exit 0, **stderr 0 bytes** |
| no interface left at its live version | `_ifacebump --check` | 0 |
| no interface present at two versions in the tree | as above | 0 |
| every qualified `module{X}` / `object{X.Y}` names a real interface | as above | 0 missing |
| every `implements` names a real interface | as above | 0 missing¹ |
| full gate after the bump | `_gate.py` | GREEN, 25,035 — unchanged from before it |

¹ One `implements` names `stoa-ns.gas-payer-v1`, which is external to this repo and legitimately
not in the tree.

The last row is the one that carries the weight. An interface bump touching **3,333 references
across 116 files** that leaves the assertion count *exactly* where it was is a bump that changed
names and nothing else. Had it changed behaviour, the count would have moved.

Seven interfaces were bumped from V2 to V3: `AcquisitionAnchorsV2`, `AcquisitionPoolsV2`,
`AcquisitionScoresV2`, `AcquisitionVacateV2`, `AqpMtxV2`, `DsaV2`, `IgnisCollectorV2`. The number is
seven and not eleven because the first attempt to derive it parsed the highest version mentioned
*anywhere* in the version record, including prose discussing hypothetical future bumps. Parsing only
the live column of the table cut it from eleven to seven. That error is recorded here because it is
the kind that produces a bump which loads fine and is wrong.

## Coverage worklists, all at zero

Each of these began the programme at a non-zero number and was driven to zero. Each is measured by
a tool that can be re-run; none is a judgement.

| worklist | what an entry means | now |
|---|---|---:|
| owner gates, testable and never observed | a client path acquires this ownership gate, and no test targets it | **0** |
| live unpinned `enforce` sites | a refusal nothing pins by message, in a live module | **0** of 790 |
| cost previews not measured | a client-facing preview whose quote no test compares to the charge | **0** of 414 |
| client entrypoints untested | a `C_`/`A_` surface named in no live `.repl` | **0** of 452 |
| modref class-B | a call to an interface member that is defined nowhere | **0** live |
| vacuous assertions | an assertion that passes regardless of the code under test | **0** |
| module coverage | a module with no suite of its own | **88 / 88** |

Two of these rows carry deliberate, stated exclusions, and the exclusions are the honest part:

- **Unpinned enforces**: 24 unpinned sites remain in `00_DPMF.pact`, which is superseded by `DPOF`
  and deployed only for provenance. They are excluded as dead, and the tool names the module rather
  than silently shrinking its own denominator — which an earlier version of it did.
- **Owner gates**: the observed figure is **85**, of which **66** are attributed at depth 0 — that
  is, the refusal was proven to come from the called operation's *own* gate rather than from a gate
  it composes. Eighty-two gates were never observed at all. {{ch:ownergates}} is about why that gap is
  reported as a bound rather than closed, and why an earlier version of this same measurement was
  wrong four times, twice in each direction.

## Scale

Measured from the tree, not from memory:

| | |
|---|---:|
| Pact modules (`1_SOVEREIGN` + `2_CITIZEN`) | 93 |
| test files (`REPL/**/*.repl`) | 275 |
| gate entrypoints | 92 |
| files reachable from the gate | 321 |
| assertions executed per full run | 25,035 |
| client-facing cost previews | 414 |
| priced operations in the generated price sheet | 442 |
| red-team attacks | 38 |

## What is not verified

An audit book that lists only what it proved is a sales document. The following are known,
deliberate limits of the work in this volume:

- **The attacks are a bounded sample.** Thirty-eight attacks across eleven families is what was run.
  No claim is made that the space is covered; {{ch:register}} shows its shape so the reader can judge
  the shape of what is missing.
- **Owner-gate attribution is a bound, not a proof.** Eighty-five gates were *observed* to refuse
  someone. Sixty-six of those refusals were attributed to the gate itself. The remaining eighty-two
  gates have never been seen to refuse anybody, and the honest statement is that nothing is known
  about them from the outside — not that they are broken.
- **One instrument's alarm path is not self-demonstrated.** `_eagerlet.py --check` gates the count
  of un-annotated eager-`let` shadows. Three attempts to demonstrate its alarm with a synthetic
  shadow failed to trigger it. That limitation is written into the tool's own docstring rather than
  smoothed over, and it means the tool's *green* is weaker evidence than the others here.
- **Nothing here is a statement about the deployed chain.** Every figure is about the tree. The
  interface versions recorded as "live" are a snapshot of on-chain state taken before the bump, and
  are explicitly not refreshed from the tree, because the tree is now ahead of the chain.
- **Economic design is out of scope.** This programme tested whether the system does what it says.
  Whether what it says is a good idea — whether a deterrent is set at the right level, whether a
  share price should round the way it does — is a question for a different document.
