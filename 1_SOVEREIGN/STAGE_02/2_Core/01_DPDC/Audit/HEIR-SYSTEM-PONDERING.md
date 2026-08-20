# Heir System — pondering discussion (not a spec, not scheduled)

**Status:** early-stage design musing, captured verbatim-in-spirit from a 2026-08-20 conversation during
the DPDC audit (finding #4C, `DPDC-F · C1`). Not an accepted design, not scheduled work — a placeholder so
the reasoning isn't lost before the Heir System is actually taken up.

## Where this came from

Round I flagged `C_RepurposeCollectableFragments` as CRITICAL: it moves a fragment holder's balance with
no consent from that account, no freeze precondition, no `can-wipe` toggle — unlike the real `DPDC-MNG`
wipe functions, which require both before touching anything.

Owner clarified the actual design intent: repurpose is a **deliberate account-recovery tool**. Real flow —
Bob's Ouronet account is stolen (or Bob dies). Bob (or his heirs) tells the collection admin off-chain,
proves it convincingly enough, and the admin repurposes Bob's holdings to a new account Bob (or his heirs)
control. No freeze precondition is wanted — that would just add friction to a flow that's already
admin-gated and event-logged. **#4C's original "no consent check" framing was wrong; it's the feature
working as designed, not a gap.** (See `ROUND-01-OWNER-FEEDBACK.md` for the full verdict.)

## The tension the owner named, unprompted

This isn't unique to fragments — it's the shape of **every** token-owner power in this system: freeze,
wipe, unfreeze, remint, burn, repurpose. A collection/token owner has complete dominion over a token's
existence. Every holder of that token is implicitly trusting the issuer to be fair and not misuse that
dominion. Repurpose is just the sharpest edge of that same trust relationship, not a separate problem.

Owner's framing, close to verbatim:

> "This repurpose system exists everywhere for other tokens as well, so I'm thinking how can we make this
> not look like an abusive measure? ... anyone holding such a token basically trusts the token owner to be
> fair and not mess things up. However token owners may also be Ouronet accounts with complex autonomous
> guards, so such operations could also be protected in any conceivable way, in the end."

## Idea considered and its dead end

**Idea:** a platform where users can *request* a repurpose themselves, registered as an on-chain event —
and the admin can only act on a registered request, not at pure discretion. This would give holders some
say without removing the admin's ability to actually execute the move (which they still need to, since a
compromised account can't sign for itself).

**The paradox:** if the account is genuinely lost or compromised, its legitimate owner can't sign a
"request" from that account either — the same problem the recovery flow exists to solve in the first
place. A naive "must be requested by the account itself" model defeats its own purpose.

## Where the thinking landed: an Heir System

Owner's proposed resolution direction, explicitly flagged as "just an example," not a spec:

> "An Ouronet account designates an heir, and if no activity is happening on the registered account for a
> specific amount of time, such a repurpose would be given [a] green light..."

The shape of it, as best captured:
- An account **proactively** designates an heir *while still in control* — this is the trustless part,
  done in advance, signed by the account itself, before any compromise or death.
- A dead-man's-switch: if no activity is registered on the account for a specified duration, the
  designated heir becomes able to claim/repurpose the account's holdings themselves.
- This shifts the trust model from "trust the admin's fairness and discretion" to "trust the account
  owner's own advance designation, checked against an objective, on-chain-measurable inactivity timer" —
  removing the admin from the loop entirely for the succession case, while presumably leaving the
  admin-discretion path (today's `C_RepurposeCollectableFragments`) available for the theft-recovery case,
  where there's no advance designation to fall back on.

## Open questions (not answered, just visible)

- Does this live at the `DALOS` account layer (any account can designate an heir + inactivity window,
  benefiting every token type at once) or per-collection (each collection owner opts in separately)?
- What counts as "activity" for the inactivity timer — any signed tx from the account at all, or something
  narrower?
- Does an heir designation coexist with admin-discretionary repurpose, or does declaring an heir change
  what the admin can/can't do unilaterally?
- Smart-account guards (mentioned by the owner: "token owners may also be Ouronet accounts with complex
  autonomous guards") — could the heir mechanism itself be expressed as a guard, rather than bespoke
  DPDC-layer logic? Worth checking against however `OuronetDalosV1`'s guard system already works before
  assuming this needs new machinery.

## Non-decision

Nothing here is committed. This file exists so the next person picking up "should we build a Heir System"
doesn't start from zero — the trust-model problem it's meant to solve, and the dead-end considered first,
are both worth not re-deriving from scratch.
