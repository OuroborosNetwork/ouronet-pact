# The canon, and the four shapes a proof can take

## Three roles, one transfer

The rule is easiest to see on the operation that needs all three:

```pact
(C_Transfer patron sender receiver id amount method)
;;           ^      ^      ^
;;           |      |      executee -- acted upon
;;           |      executor -- acts
;;           patron -- pays
```

| role | what it is | what must be true of it |
|---|---|---|
| **patron** | the account that PAYS | ownership enforced **always, directly**, via the gas-collection path |
| **executor** | the account that ACTS | ownership enforced **always** — directly, or indirectly by a route the function's own `@doc` names |
| **executee** | the account acted UPON | enforced **conditionally**, and the conditions must be named in the `@doc` |

The executee's conditionality is not a weakening. A receiver needs an ownership check only when
the transfer is *method*-style and the receiver is a smart Ouronet account; for an ordinary
credit, demanding the receiver's signature would make it impossible to pay anyone who is not
online. The canon's demand is that whichever rule applies is **written down in the function**,
not inferred from the capability three modules away.

## Position is canon, not just presence

Pact arguments are positional. An `executor` sitting fourth is non-conforming even though every
check on it passes, because the next caller — reading the signature rather than the body — will
put the wrong account in the slot. The practical consequence dominated the whole round:

> **Correcting a signature rewrites every call site that reaches it.**

Not only the direct ones. A core module's `C_` is reached through a Talos wrapper, that wrapper is
reached from citizen modules and from REPL fixtures, and a single reorder in Stage 1 propagated
into 172 call sites in one turn, 86 in another, 31 in a third.

And there is a specific hazard in that: **Pact checks modref call arity at RUNTIME, not at
load.** A call left one argument short compiles, deploys, and partially applies into a *closure*.
Worse, an `expect-failure` **absorbs** it: the test fails as expected, green, for the wrong
reason. This round found six such call sites, two of them inside `expect-failure`s that had looked
green for weeks. That is why `_callarity.py` is gate-fatal rather than a report.

## Why the executor is unconditional — the attribution rule

Stated by the owner mid-round, after it was asked once too often:

> **An unenforced executor is WORSE than none.**

A parameter nobody checks is one the caller chooses freely. An entrypoint that takes an `executor`
and never proves it does not record who acted; it records *whoever the caller felt like naming* —
and the `@event` it emits can implicate an account that was nowhere near the transaction. A
missing executor is visibly missing. A decorative one **looks like attribution**, which is the
property that makes it worse than the gap it appears to fill.

Admin operations are where this goes wrong, and for an understandable reason: the `GOV|*_ADMIN`
keyset already opened the door, so the executor *feels* like a label — and a label is what it
becomes. Found in exactly that shape on the second day, in three DPTF treasury admin ops that took
an `executor` and never mentioned it again.

## The four shapes of proof

`_executorenforced.py` accepts exactly four, and refuses everything else:

| verdict | what it means |
|---|---|
| **DIRECT** | `CAP_EnforceAccountOwnership` / `UEV_Executor*` / `CAP_Owner` runs on the executor, in the function or in a capability it acquires (two levels of `compose-capability` are followed) |
| **FORWARDED** | the executor is handed to another module's entrypoint **in the executor position** — the Talos-wrapper and cross-core shape |
| **INDIRECT** | registered in the tool **with the route**, which must *also* appear in the function's own `@doc` |
| **SELF-PROVING** | account creation, where the executor is the account being created and proves itself with the guard it supplies |

Two of these deserve their reasoning spelled out.

**FORWARDED is position-aware on purpose.** It matches
`(ref-TFT::C_Transfer patron executor receiver …)` and deliberately does **not** match
`(ref-TFT::C_Transfer patron sender executor …)` — in the second, `executor` is sitting in the
executee slot, and a callee proving its *own* executor proves nothing about this one. The check
passed one function for a day on the strength of a `CAP_Owner` two arguments away, which is
exactly the conflation the position rule exists to stop.

**INDIRECT is not a waiver.** Registering a route in the tool does not silence it: the function
must still *say* the route in its `@doc`, and the tool re-reads the `@doc` on every run. So the
justification lives beside the code, and deleting the sentence breaks the build. This is the
canon's *"the path MUST be named"* clause, made mechanical.

**SELF-PROVING is the base case of the attribution rule**, resolved by the owner after being
raised as an open question. In the four deploy entrypoints the executor is the account *being
created*, so its ownership cannot be read from a table — there is no row yet. It does not need to
be: the **guard** the account will be governed by is enforced in the same transaction, which is
the same proof and the same key, arriving as an argument because there is nowhere else it could
come from. The claim is load-bearing and is pinned by a negative test: a deploy whose guard the
caller does not hold is refused, and refused *before* the format checks — so if that list element
were ever dropped, account creation would become unauthenticated and the registry entry would
silently become false.

## Four reasons a real proof is invisible

The round's most repeated surprise: a function reports UNPROVEN, and the proof is *right there*.
Four distinct shapes produce that, and the correct response to every one of them is to **register
the route and write it in the `@doc`** — never to add a second enforce to satisfy a tool.

1. **Proven in place.** The capability binds `(= executor owner-konto)` and then enforces
   ownership of `owner-konto`. The matcher looks for the enforce applied to `executor`; here it is
   applied to the name `executor` was just proven equal to. Correct code, invisible shape. Eight
   AQP score entrypoints and six DSA entrypoints are this.
2. **A same-module hop.** The executor is forwarded into an `XI_` in the *same* file. FORWARDED
   scans for a cross-module `ref-X::` call by design — a foreign module is what does the proving —
   so an internal hop has to be traced by a human and written down.
3. **A defpact step.** The entrypoint acquires its capability and then starts a `defpact`; the
   call carrying the executor lives in a *step*, so the entrypoint's own body contains no
   forwarding call at all.
4. **An intra-Talos sibling.** A thin alias delegating to another wrapper in the same Talos file
   — the same internal-hop shape, one layer further out.

## Sometimes the answer is no executor

Not every entrypoint has an actor. Two anchor-sync repairs were given **none**, and that is the
finding rather than a gap. The test that settles it, in order:

1. Is any account on the path ownership-checked? If not, ask **why** before adding one.
2. Is the op idempotent truth-restoration? These recompute a ratio from actual balances — every
   outcome is the correct one.
3. Who pays? The patron. A caller can only make someone else's data correct **at their own cost**.
4. Would a signature requirement remove a legitimate path? Yes — the party who *notices* a stale
   anchor is usually whoever issued it, not the beneficiary.

All four, and the verdict is **EXECUTORLESS: the account in the signature is an executee.** Six
entrypoints ended there, registered with their reasoning attached, and the two *different*
rationales kept visibly separate — permissionless repair in one case, authority-is-a-guard in the
other. A shared register with one blurred justification would have been the easier artefact and a
worse one.

## Where Talos diverges

| | core module signature | Talos wrapper signature |
|---|---|---|
| `C_` | `(patron executor …)` | passes the **caller's** patron — sponsorship preserved |
| `A_` | `(patron executor …)` | **no patron** — the wrapper supplies `GASLESS-PATRON` itself |

An `A_` is gasless **because its ordinary collection is served by the one account the IGNIS
collector exempts**, not because collection is skipped. The path is preserved, which matters: a
skipped path cannot be regression-tested, and an exempted account can.

## The intermediate state nobody can see

One consequence of sweeping a dependency graph module by module has no clean solution, only an
honest one. While module *N* is being swept, a caller in module *N+5* has no `patron` to thread,
so slot 0 carries whatever account initiates the call — `client`, `culler`, a service-account
constant. That is **correct today and wrong after the caller's turn**, and it is invisible: the
arity is right, the value is unused by every swept callee, and no assertion can reach it.

So it is written down. `_patronslots.py` carries every such site with its evidence, distinguishing
**permanent** (the patronless OUROBOROS family, where `patron = executor` is the truth) from
**provisional** (re-point at that module's turn), and the gate is fatal on an **unregistered**
one. The register ended the round at nineteen: fifteen permanent, four provisional, all four in
one module, and those four *measured* inert — both callees use `patron` zero times in their
bodies once the signature and doc string are stripped. An inert wrong value is the most patient
kind, and the only thing that keeps it from becoming a live one is that somebody wrote it down.
