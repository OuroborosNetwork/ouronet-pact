# Part V — The patron/executor/executee canon sweep

> Source records: `OuronetInformational/HANDOFFS/HANDOFF-executor-canon-sweep.md` (the canon, the
> 46-module worklist and eighteen recorded lessons), `Audit/AUDIT-V2-DELTA.md` (a per-module entry
> for all 46), and `OuronetInformational/StoicSyntax-Prefixes.md` §2.2 (the rule itself).

## The question this round asked

Parts I and II asked *"is this right?"*. Part III asked *"can I make it do something it should
not?"*. This Part asked a third question, and it is the one that turns out to be hardest to
answer by reading:

> **"Who did this?"**

Not *may* they — that is authorisation, and the red team spent a round on it. **Who.** Ouronet is
a gas-station system: a **patron** pays for a transaction that somebody else performs. So every
client entrypoint has at least two accounts in it whether or not it names them, and before this
round the great majority named only one.

The canon states the fix in one line:

> Every `A_`/`AA_`/`C_`/`CC_` entrypoint takes **`patron` first, `executor` second, `executee`
> third** when one exists. Position is canon. `P|` policy functions are exempt.

- **patron** — who *pays*.
- **executor** — who *acts*. The account the ledger should name when asked who did this.
- **executee** — who is *acted upon*. Validated, sometimes not consulted at all, never the actor.

Position, not merely presence. Pact arguments are positional, so an executor sitting fourth is
non-conforming, and correcting a signature **rewrites every call site that reaches it** — in the
modules, in the Talos wrappers, and in every REPL fixture.

## The numbers

**46 modules. 776 entrypoints. 0 remaining.** Three days, 57 commits, 2026-09-20 to 2026-09-22.

| measure | at the start | at the end |
|---|---:|---:|
| `A_`/`C_` entrypoints conforming to the canon | 302\* | **776** |
| …with the executor's ownership PROVEN | — | **756 of 756** |
| entrypoint signatures changed vs. the pre-sweep baseline | — | **694** in 58 files |
| assertions executed per full gate run | 25,234 | **{{fig:assertions}}** |
| distinct assertions written | 5,903 | **{{fig:assertions_distinct}}** |
| unregistered patron slots | unmeasured | **0** |

\* *That number was wrong, and the error is the first thing this Part has to report.*

## The plan was wrong by 63% on its first day

The refactor was scoped against `_bandplan.py`, whose entrypoint filter read, in effect:

```python
re.match(r"^(A|AA|C|CC)_" + "|" + r"\|(A|AA|C|CC)_", n)      # the broken form
```

`re.match` anchors the **whole** pattern at position 0, so the second alternative could only ever
fire on a name that *starts* with a bar. Every Talos entrypoint — `ATS|A_KickStart`,
`DPTF|C_Issue`, all 482 of them — was invisible. The tool reported **302 done, 474 remaining**
against an actual **776**, and the programme was scoped, planned and reported against that number
for its entire first day.

> **Talos is the only supported client path in this system.** The blind spot was not a corner of
> the surface; it was the client surface.

What found it was a *second* tool, `_executorplan.py`, written specifically to re-derive the same
worklist by a different route. That is the reason it exists, and it is the first entry in this
Part's method: **when a number decides the scope of the work, compute it twice.**

## What this Part contains

| chapter | what it covers |
|---|---|
| {{ch:canon}} | The four shapes an entrypoint can have, and how to tell them apart |
| {{ch:sweepdefects}} | What the sweep found — three live defects, two wrong published prices, and an authorisation surface measured entrypoint by entrypoint |
| {{ch:sweepmethod}} | The instruments, and the eighteen lessons the round paid for |

## What the system gained

Four things, and only the first is what the round set out to do.

**1. The ledger can answer "who".** Every `A_`/`C_` names the acting account in a fixed position,
and that account's ownership is proven on every path. The `@event` a capability emits now carries
an actor that the transaction had to sign for, rather than one derived inside a capability and
never written down — or, in 322 entrypoints, never named at all.

**2. Sponsorship became possible where it had been silently forbidden.** Separating *pays* from
*acts* is not only an audit-trail question. Before the separation, several entrypoints enforced
`(= patron owner)` — forcing the **gas payer** to **be** the asset owner. No sponsor could pay for
a vault owner's operation, and the gasless patron was unusable across that whole surface. Those
enforces were the *symptom* of one parameter doing two jobs; the canon removes the need for them.

**3. Talos wrappers became mechanical.** With a fixed `(patron, executor, executee, …)` prefix,
what a Talos wrapper must do is determined by the canon rather than decided per function: a `C_`
passes the caller's patron through, an `A_` supplies `GASLESS-PATRON` itself. That is why a
call-site checker can be gate-fatal at all — there is now one correct shape to check against.

**4. The authorisation surface is written down.** For the first time, `AUTH-SURFACE.md` records
per entrypoint every ownership enforce reachable through its capability chain, and the gate
refuses any commit in which an entrypoint's set **shrinks**. "We did not weaken anything" stopped
being a claim and became a check — which is how the sixty newly-gated entrypoints in
{{ch:sweepdefects}} were counted rather than asserted.

## Why a renaming exercise found defects at all

It should not have. Renaming a parameter changes nothing a user can observe. The reason it found
three live defects, two wrong published prices and sixty entrypoints that gained an ownership gate
is that **the canon forces one question at every single entrypoint, including the ones nobody
suspected**:

> *Which account does this function's authority actually prove — and is it the one the signature
> names?*

Answering that 776 times is not a renaming exercise. It is an audit with a fixed question, applied
exhaustively, where the renaming is merely the artefact left behind. Three of those 776 answers
were *"neither — it proves nothing at all."*
