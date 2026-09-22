# Method: how the round was run, and what it cost to learn

## How the need was found

Not by a tool, and not by a threat model. By the owner reading one function.

`ATS|A_KickStart` takes an account called `kickstarter`. It is the account that funds and starts
an autostake pool — the account that *acts*. Elsewhere the same role is called `account`,
`owner-konto`, `client`, `injector`, `beneficiary-id`, `recoverer`, `owner-account`, `curler`,
`coiler`, `fueler`, `coiler-vester`, `curler-vester`. Thirteen bespoke names for one idea, and
because every name was locally sensible, nothing in the codebase looked wrong at any single site.

That is the shape of the whole finding. **A naming inconsistency is invisible from inside any one
module**, and it stops being cosmetic the moment you ask the system a question that spans modules:
*who performed this operation?* The system could not answer, because the answer was in a different
place, under a different name, in every module — and in some it was nowhere at all.

So the canon was written down first, as owner rulings, and only then applied. The reference
implementation was committed before the sweep began, to be copied rather than re-derived 776
times.

## The classification that could not be guessed

The first useful thing the worklist tool did was refuse to treat the 719 outstanding entrypoints
as one job. They split three ways, and the split is not visible from a signature's shape:

| class | count | what the second parameter is |
|---|---:|---|
| **RENAME** | 115 | an **account** under a bespoke name — `account` (53), `owner-konto` (13), `client` (10), `injector` (8), … |
| **ADD** | 322 | an **entity id** — `id`, `ats`, `swpair`, `pool-id`, `fvt-id`. There is no executor at all; it is derived inside a capability |
| **PATRON** | 282 | the *first* parameter is not `patron` |

> **Assuming "second parameter = executor" is wrong for 322 of them.**

The 322 are the interesting population, and they have a name: **"authority proven, actor
unrecorded."** The capability reads the entity, derives its owner, and enforces ownership of that
derived account. The authority is real. The *actor* is never a parameter, so it is never in the
event, never in the signature, and unavailable to anything asking who did this. Fixing one of
these is not a rename — it is adding a binder and proving the parameter equals the derived
account.

## Deploy order, and why the cascade is the point

The worklist ran in **deploy order** — first module of Stage 1 to the last of Stage 2 — not
smallest-first. A module's call sites live in the modules deployed *after* it, so sweeping forward
means every module is already fixed before anything that calls it is touched. Smallest-first would
revisit the same call sites repeatedly.

The effect compounds, and the last four modules measured it: of the 180 entrypoints across the
four Stage-2 Talos modules, **176 were already DONE when their turns arrived**. One module's row
reads *"64 of 65 arrived by cascade, 1 by its own turn."* The ordering did four fifths of the work
for free.

It also produces a rule that only becomes obvious in the middle: **the turn that clears a
provisional patron slot is the turn that gives its CALLER a patron.** A helper cannot thread an
account that does not yet exist upstream of it. Two such helpers sat provisional for nine modules
and cleared in a single edit when their caller's turn finally came.

## The instruments

Nine tools carried the round; five are gate-fatal.

| instrument | what it answers | gate |
|---|---|:---:|
| `_executorplan.py` | *What is left?* Classifies every entrypoint DONE / RENAME / ADD / PATRON. **Ground truth** — never a remembered number | — |
| `_executorenforced.py` | *Is every executor actually PROVEN?* DIRECT / FORWARDED / INDIRECT / SELF-PROVING, everything else a finding | **fatal** |
| `_authsurface.py` | *Did any entrypoint stop enforcing something it used to?* Per-entrypoint ownership sets, may only grow | **fatal** |
| `_patronslots.py` | *Is slot 0 the right KIND of value?* Registry of every non-`patron` patron | **fatal** |
| `_callarity.py` | *Does every call site pass the right NUMBER of arguments?* | **fatal** |
| `_docstrings.py` | *Will the module load at all?* Malformed `\` continuations | **fatal** |
| `_modulecomplete.py` | *Is this module's turn finished?* Seven obligations, the seventh being `_executorenforced` | — |
| `_deadbind.py` | *Where did somebody bind the actor and have nowhere to put it?* | — |
| `_auditdelta.py` | *Has every changed module written down what the audit must re-verify?* | **fatal** |

Two of these are worth a sentence each on **why they are fatal rather than reports**.

`_callarity.py`, because Pact checks modref call arity at **runtime**: a short call compiles,
deploys, and partially applies into a closure — and an `expect-failure` around it goes green for
the wrong reason. A caller that no test exercises is precisely the one that will not be found by
running anything.

`_patronslots.py`, because the thing it catches is **unreachable by assertion**. During the sweep a
caller in a not-yet-swept module threads whatever account initiates the call into slot 0. The arity
is right, the value is unused by every swept callee, and no test can observe it. The gate is fatal
only on an **unregistered** one — the registry is the artefact, and the gate's job is to refuse a
site nobody wrote down.

## Eighteen lessons, and the seven that transfer

The handoff carries eighteen lettered lessons, one per module that taught something. Most are
local. These seven are not.

**1. When a number decides the scope of the work, compute it twice.** The plan was wrong by 63% on
its first day because one regex was anchored wrongly, and Talos — the only client path — was
invisible to it. A second tool, written to re-derive the same list by another route, is what found
it.

**2. Derive the list — then check the derivation.** Four tools in this programme carried a
hand-maintained list that could not report its own incompleteness. Each was fixed by deriving the
list from an artefact that is already the single source of truth. Then a *derived* list silently
dropped a module because its index column held an em-dash instead of a number. Deriving is the
right answer and it is not the end of the answer.

**3. The implementation is the LAST match, never the first.** Interfaces are embedded inline at the
top of every file, so a regex for `(defun NAME` finds the **stub**. In one module the discriminator
between finding the stub and finding the body was a **trailing space** — one function's stub had
one and its sibling's did not, so the same pattern matched the body for one and the stub for the
other. The rule is mechanical: take `hits[-1]`.

**4. A grep window is not a read.** A sixty-line `sed` window showed only shape checks, and the
conclusion written from it — *"this entrypoint checks no account at all"* — was false; the
ownership enforce sat fourteen lines past the bottom of the window. A redundant guard and a wrong
`@doc` were added on the strength of it. What corrected it was the **existing test suite**, which
already pinned the refusal the new claim said was missing.

**5. Run the guard test without the guard.** Twice in this round a fix was credited with closing a
hole that was already closed somewhere else. The only thing that settles it is to **disable the new
guard and run the suite**: if the test still passes, the guard is not what it is passing on. One
such assertion survived — relabelled honestly as a property test rather than a discriminating one,
because a test that cannot fail is a green light wired to nothing.

**6. A rename is only safe inside the extent you have actually reasoned about.** A file-wide
substitution of `beneficiary-id` → `executee` changed 80 occurrences; the correct number was
**15**. The word means one thing in a repair and another in a stake, and no regex can tell them
apart. Reverted by writing back the committed blob, then redone scoped.

**7. A proof the matcher cannot see is still a proof.** The correct response to a false UNPROVEN is
to register the route and write it in the function's `@doc` — **never** to add a second enforce to
satisfy a tool. A guard added to make a report go green is a guard nobody chose, in a place nobody
reasoned about, and it will be read later as evidence that somebody did.

## Three ways the round broke itself

Recorded because they were all cheap to cause and expensive to find.

**An arity-preserving reorder is not idempotent.** Swapping two arguments of the same type is
invisible to every checker in the gate — the arity matches, the types match, the module loads, the
tests pass or fail for unrelated reasons. Running such a pass twice restores the original order and
looks like a no-op. The passes were therefore written to read arity **from the source** rather than
declare it, run exactly once, and then be parked with a `.DONE` suffix so they cannot be run again
by reflex.

**Removing the last binding deletes the `let`.** Four of eight dead-binding removals left
`(let ( ) …)`, which Pact rejects at load. Fifty-five suites reported BROKEN with **zero**
assertions — and a module-completeness check cheerfully reported 7/7 on a file that did not load,
which is why the cheapest check in the gate now runs first.

**An unescaped `"` inside an `@doc` closes the string, and the rest of the function parses as
code.** Three occurrences, all caught statically before any suite ran.

## What the round is worth

At the end: 776 of 776 entrypoints conforming, every executor proven, 60 entrypoints enforcing an
ownership gate they did not enforce before and none enforcing less, the authorisation surface
written down per entrypoint and gate-protected against shrinking, and a register of every place
where a value is knowingly provisional.

The three defects are the visible return. The durable one is smaller and harder to point at: the
system can now be **asked** who performed an operation, and the answer comes from the operation's
own arguments rather than from a capability three modules away. Every instrument above exists to
keep that true after the people who did this have forgotten the details.
