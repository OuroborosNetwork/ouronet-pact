# A balance is not a gate — and a green test can be the bug

**2026-09-21, during module 8 (`09_TFT`) of the patron/executor/executee sweep.**

## What was found

`TFT::C_ClearDispo` took `(patron account)`. Its capability `DPTF|C>CLEAR-DISPO` enforced ownership
of **nobody** — it checked that the target was a STANDARD account holding a NEGATIVE OURO balance,
then composed `P|DALOS|REMOTE-GOV`, `P|ATS|REMOTE-GOV` and `P|SECURE-CALLER`, all of which are
module-policy grants and none of which say anything about the caller's relationship to the account.

Clearing a dispo is not a favour. It force-converts the subject's Elite-Auryn at **2.5×** the debt
and burns it. So **any caller could liquidate any qualifying account's Elite-Auryn.**

## The part worth remembering

**A test was driving the attack and reporting a PASS.** `REPL/modules/DPTF.repl` `<<DPTF-G10>>`:

```pact
(expect-failure "<<DPTF-G10>> ...so her debt cannot be cleared, on cost rather than on type"
    "Cannot Debit DPTF"
    (ref-TS01-C1::DPTF|C_ClearDispo KST.ANHD KST.EMMA))
```

One signature, two accounts. The assertion was **true**: it did fail, with that message. But the
message comes from EMMA's empty Elite-Auryn balance, not from a guard. **Fund the victim and the
attack works.** The test's own comment even explains this — *"standard account + negative OURO is
NOT sufficient for a clear to succeed"* — it just never asked why ANHD was allowed to try.

Generalised: **when an `expect-failure` passes, ask WHICH LAYER refused.** "It failed" and "it was
refused by the guard I am testing" are different claims and only the second is worth an assertion.
A refusal produced by a balance, a length, an empty list or an arity error is not a security
property. This is the same family as:

- `2026-09-16-a-guard-present-is-not-a-guard-reachable.md` — a guard shadowed by an earlier one.
- The `expect-failure`-swallows-a-closure trap: a short modref call partially applies, so the test
  fails-as-expected and the wrongness is invisible.

Three failure modes, one root: **the test asserts that something went wrong, not that the right
thing went wrong.**

## Why nothing static could have caught it

`_authsurface.py` reports what each entrypoint *enforces*. It cannot know what an entrypoint
*should* enforce. `_conformance.py` had zero violations here. The v1 attack register never reached
it because the operation does not look like an asset move — its parameters were `(patron account)`
and its name says "clear", not "spend".

**What found it was assigning the `executor` role.** The canon forces the question *"whose
ownership proves this?"* for every entrypoint, and here there was no answer. That is a value of the
canon distinct from readability, and it argues for finishing the sweep on modules that "look fine".

## The resolution (owner ruling)

`account` is BOTH executor and executee — the subject requests the clear for themselves. The core
became `(patron executor executee)` enforcing both ownerships, and Talos got two doors:

| | | |
|---|---|---|
| `DPTF\|C_ClearDispo` | `(patron executor)` | self — arity unchanged, no client breakage |
| `DPTF\|C_ClearDispoForeign` | `(patron executor executee)` | delegated, both signatures |

Canonised as the **self/foreign pair** in `StoicSyntax-Prefixes.md` §2.2, along with the owner's
companion ruling that **pure admin ops take an executor too** — not for authority (the governing
key still decides) but for the **audit trail**: "the dispo was cleared" becomes "account X cleared
it".

Pinned in both directions by `<<DPTF-G10c>>`. One direction alone would also pass if the operation
were broken for everybody, so the refusal is asserted with the victim's business guards
deliberately SATISFIED, and then the identical call is driven through with her signature added.
