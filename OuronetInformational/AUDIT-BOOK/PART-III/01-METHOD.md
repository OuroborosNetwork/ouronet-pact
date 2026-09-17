# Part III · Chapter 1 — Method: how an attack is built, and the four ways one can be worthless

A red-team assertion in this codebase looks trivial:

```pact
(expect-failure "a non-owner cannot move someone else's tokens"
    "Keyset failure (keys-all): [PK_Emma...]"
    (ref-TS01-C1::DPOF|C_Transfer attacker token [1] victim attacker false))
```

It passes. It is green in the gate. And on its own it may prove **nothing at all**. This chapter is
about the difference, because that difference is where almost all of this round's effort went, and
every rule below was learned by producing the worthless version first.

---

## Failure 1 — Vacuity: the refusal came from somewhere else

The dominant failure mode. A capability is written like this:

```pact
(defcap DPDC-S|C>RENAME (...)
    (enforce (< (length new-name) 32) "Name too long")   ;; business rule
    (CAP_Owner set-id)                                    ;; the ownership gate
    ...)
```

An attacker who hands it a bad name is refused **by the length rule**. The test is green. The
attacker was stopped. And **if you deleted `CAP_Owner` entirely, the test would still pass.**

A gate in that position is called *shadowed*. From outside, a shadowed gate is **indistinguishable
from an absent one** — which is the entire problem, because the outside is where tests live.

The remedy is not to reorder the capability. Reordering only moves which check is hidden, and a
scripted reorder during this programme silently converted an unconditional admin gate into a
conditional one by hoisting a `compose-capability` out of the `if` that guarded it. **The remedy is a
fixture that satisfies the earlier checks**, so the gate is the only thing left that can refuse.

### The differential pair

The house form, adopted after `DPOF|C>DEBIT`. Hold everything constant except the one input that
clears the shadow, and pin **both** messages:

| call | amount | refused by | message |
|---|---|---|---|
| shadow | `999999.0` | the amount-vs-supply fold | `Cannot Debit into the Negatives …` |
| gate | `10.0` | `CAP_EnforceAccountOwnership` | `Keyset failure (keys-all): [PK_Ancie...]` |

Same signer, same sender, same nonce. The pair proves **two things at once**: that the shadow is
real, and that the fixture escaped it. A lone `expect-failure` on the ownership message proves only
that *something* refused.

---

## Failure 2 — Unattributability: the refusal is real but anonymous

`ATS|C>ADD-REWARD-TOKEN` carries **two** ownership checks in sequence — the reward token's, then the
pool's. Every token and every pool in the fixtures is owned by the same account, so both checks fail
with the *identical* message. An assertion on that message is green, and **survives deleting the
second gate**.

No static analysis can see this: both checks are present, both are reached, the test is green. The
only remedy is a fixture that **separates** them — here, giving the attacker a token she genuinely
owns, so the first gate passes by construction and the message can only be the second.

> This is a third distinct way a gate goes dark, after ordering and after gaps in the reachability
> map: **two guards that refuse with the same words.**

---

## Failure 3 — No non-vacuity control: you proved a refusal, not a rule

`expect-failure` proves a call was refused. It does not prove the operation *works* when it should.
A wrapper that returned an error unconditionally would satisfy every attack in this round.

So every attack carries a control: **the identical call, with the rightful party signing, must
succeed** — and the success is asserted on *state*, not on the returned string. `VST-G1b` does not
check that a message says "succeeded"; it checks that 999,250.0 tokens left one account and arrived
at another.

Sometimes a full success is out of reach and the control has to be a **message differential**
instead: add exactly one signature and show the refusal moves to a *downstream* check. That proves
the gate was satisfied, which is the claim that matters. `ATSU-G1` uses three calls that land short
of the gate, on it, and past it.

---

## Failure 4 — The wrong attacker

In these fixtures the account `ANHD` is simultaneously an ordinary user key, a member of the
Demiurgoi master keyset, and the owner of most assets under test. An attack signed by ANHD therefore
proves nothing: a refusal might be ownership or might be something else, and a *success* might mean
"the gate is broken" or "they legitimately own it".

The default rule is to pick an attacker who demonstrably owns nothing relevant, and to **assert that
in the test** rather than assume it.

But the rule is a default, not a law, and `ATSU|C>COLD_RECOVERY` inverts it. There, an ordinary
stranger never reaches the gate at all — a broader permission check over five guards turns them away
first. The only caller who can reach it is one who passes that broader check while not being the
target, and the Demiurgoi master key is exactly that caller. The attack is *"the most privileged key
in the system still cannot act on somebody else's behalf"*, and no lesser key gets far enough to ask.

> **Which account should attack is a property of the gate, not a house rule.**

---

## A fifth rule, about what you are allowed to pin

When an operation is refused by something **wrong** — an index fault where a written guard should
have spoken — the temptation is to pin the fault text, because it is what happens.

Do not. Pinning a defect makes it the expected behaviour and turns its eventual **repair** red. The
correct move is to pin only what is legitimately true (*the call is refused and nothing moves*),
record the fault as a defect, and leave the message unpinned until it is right.

This is not hypothetical: `RT-A-004` was written that way, the defect it flagged was root-caused and
fixed the same week, and the assertion was then rewritten to pin the guard's own words — at which
point it also had to start *measuring* that nothing moved, because the fixed call **commits** instead
of reverting and transaction rollback no longer guaranteed it.

---

## What this costs

Roughly: for every line of attack, three or four lines of fixture and control, and a comment
explaining why that attacker and that input. The attacks in `REPL/RedTeam/` are mostly comment.

That ratio is the finding. A red-team suite that is mostly assertions is probably mostly vacuous.
