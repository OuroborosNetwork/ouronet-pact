# How audit publishing works — the judgement gate

<!-- purpose: MANDATORY before regenerating the Audit Book or OuronetDocumentation, or whenever new audit data must be processed: the one command, why it blocks, and how to write the judgement block that unblocks it. -->

Written down because the shape of this work repeats. Any change to a Pact entrypoint's
signature reopens it, and the request that starts it is always the same sentence: **"we have
new audit data, process it."** This file is what that sentence should be enough to trigger.

## The invariant

**The repository is the source of truth, and the audit is generated from it.** Never hand-edit
a generated artefact — edit its source, or write the one file that is deliberately
hand-written, and regenerate. Two publications are cut from this repo (the Audit Book and
`OuronetDocumentation/`), and one command rebuilds both:

```bash
python3 REPL/tools/_publishprep.py --check          # what is stale (offline)
python3 REPL/tools/_publishprep.py --write --docx   # rebuild both publications
```

**Order is Audit, then Documentation, never the other way.** `_publishprep.py` runs
`_auditall.py` (4 generators → `Audit/`) then `_docsall.py` (5 generators →
`OuronetDocumentation/`), because the docs cite the audit's figures and the audit never cites
the docs'. Rebuilding docs against a stale book would propagate a stale number into the second
publication and make both agree — which is the exact failure the Audit Book's own third rule
(below) exists to catch.

`--write` asks the chain (it passes `--probe` so `_docsall` regenerates each module's live hash
and size); `--check` never does, because the gate runs offline. A `--check` that reached the
network would turn a failed build into a network diagnosis.

## The one thing no generator can produce

`REPL/tools/_auditdelta.py` derives, from git, every entrypoint whose **signature** changed
since the pre-sweep baseline. That is facts, and facts are cheap to regenerate. What it cannot
derive is **judgement** — which assertions a re-audit must re-run, which prior findings are
invalidated, narrowed or superseded, which new gates need an adversarial test. Those are written
by hand in `Audit/AUDIT-V2-DELTA.md`, under a `### <file>.pact` heading per changed module, and
`--check` — now wired into step 4 of `_auditall.py`, so it is enforced in `--write` mode too, not
only offline — **fails the build** until every changed module is accounted for.

That failure is not a bug to route around. It is the point: the audit must not be re-published
with modules whose re-verification nobody has decided on.

## The guard is lenient on purpose — do not mistake green for done

A module counts as covered if the ledger **names it anywhere** — a `### <file>` heading of its
own, or a mention inside a downstream-consequence list. That is a plain substring match on the
filename. The tool is lenient on purpose: requiring a bespoke heading for every file would force
one for every module that changed only because a caller did, and a checklist that demands
busywork gets satisfied with filler, not judgement.

So the check **cannot tell a real judgement from the filename sitting in a comment.** It is not
trying to. The procedure below is the thing that makes green mean something. If you ever find
yourself adding a mention of a file just to clear the check, you have inverted the tool — stop,
and write the judgement instead. Equally: do not "fix" a red step by loosening the tool. The
block is the feature; a red `_auditdelta.py --check` is it working.

## The procedure

1. **Read the delta, not just its verdict.**
   ```bash
   python3 REPL/tools/_auditdelta.py --check
   ```
   For every module it lists as uncovered, read the signature diff it prints
   (`was (…)` / `now (…)`, `NEW entrypoint`, `REMOVED or RENAMED`). That diff is the shadow of
   the change, not the change itself — do not write the judgement from it alone.

2. **Classify the change before writing about it.** Each uncovered module is one of:
   - a **signature change** on an existing entrypoint — who may call it, and with what;
   - a **new entrypoint** — a surface that has never been audited;
   - a **removed/renamed entrypoint** — prior findings about it may be moot, or may not be,
     because a deployed Pact module cannot be removed from the chain; prefer "superseded" to
     "deleted" when the old code is still live;
   - a module that changed **only because a caller did** (a downstream consequence).

3. **Open the module and read the actual diff.** The signature line is not the change; it is
   the shadow of one. Read the `@doc`s, the capability bodies, and — when the question is
   "is the named actor actually bound to who is allowed", not just "is someone required" — trace
   the call into whatever module proves it. The binding is sometimes one hop away (a forward
   call, a same-module `XI_` hop, a defpact step, an intra-Talos sibling call); the ledger's
   cross-cutting section and its `FORWARDED`/`INDIRECT` discussion name the shapes this has
   already taken. Check whether a REPL suite already exercises the new or changed surface, and
   whether the specific adversarial case (a *wrong-but-owned* actor, not just a non-owner) is
   among its assertions — a happy-path test where the named actor always equals the real one
   never exercises the binding at all.

4. **Write the block**, under `### <file>.pact` in `Audit/AUDIT-V2-DELTA.md`, covering:
   - a one-line statement of **what changed** and its scale;
   - which existing assertions must be **re-run**, named;
   - which prior findings are **invalidated**, **narrowed**, or **unaffected** — say which,
     and prefer "superseded" over "deleted" per the removed/renamed case above;
   - which new gates need an **adversarial** (red-team) test, and whether one already exists;
   - anything you could not resolve, **said plainly as unresolved** — per the third rule below,
     scope is part of a result.

   Follow the shape of the existing blocks; `### 00_DPMF.pact` (archival) and `### 06_VCT.pact`
   (a local proof twin) are good exemplars of two different shapes a block can take.

5. **Re-run the rebuild.**
   ```bash
   python3 REPL/tools/_publishprep.py --write --docx
   ```
   Exit 0 is the goal. A failure here is almost never a stale artefact — it is a missing
   judgement block, which is written by hand and blocks on purpose.

6. **State provenance in the release note** — see below. Do this every time, not only when the
   chain actually moved.

## Three rules the book is written to — your additions obey them too

1. **A figure appears only if it was read from source or a REPL/tool run, never remembered.**
   Re-run `_auditdelta.py`, `_executorenforced.py`, `_registry.py --check`, whatever is relevant
   — do not carry a number forward from a previous session or from this document.
2. **A count is reported with its exclusions, or not at all.** A total that reconciles is the
   strongest possible signal the parts were checked, and is evidence of nothing by itself.
3. **Where a check cannot see something, say so.** Scope is part of a result — e.g. a tool that
   proves an executor is enforced says nothing about whether the right executor is *named*
   where a reader would look for it.

## Provenance, every time

The book is built from `Deploy/OURONET-REGISTRY.json`. Before publishing, run:

```bash
python3 REPL/tools/_registry.py --check
```

and quote its **"last confirmed against mainnet"** line in the release note. If the snapshot has
not been confirmed since the last deploy, the audit is accurate about the **repository** and
silent about the **chain** — say which; do not imply both. `Audit/AUDIT-RELEASE.md` is itself
generated (by `_auditbook.py`, one of `_auditall.py`'s four generators) and already carries
version, release date, build commit and the "what changed" log — it is the release note's
source of truth, not a separate document to maintain by hand.

## What this is not

This file does not tell you what to *say* about any particular module — that is judgement, and
judgement is read off the code, not off a procedure document. It tells you the sequence that
makes the judgement durable: read the delta, classify, open the source, write the block, rebuild,
state provenance. Skipping a step to clear the gate faster produces a green check and an audit
that is not actually re-verified — which is the one failure mode this whole mechanism exists to
prevent.
