# `E-ANK` is the empty-anchor OBJECT, used as the message label in 7 ANK enforces

**Date:** 2026-09-12 · **Status:** open, message-quality only · pinned as-behaves (`AQP-G35`)
**Site:** `1_SOVEREIGN/STAGE_02/2_Core/03_AQP/01_ANK.pact` — constant at :292, 7 uses

## What a caller sees

```
{"anchor-id": "|","ouronet-account": "|","promile": 0.0} BoostClass TfStakeBoost-98c486052a51 must be active
```

## Why

Every ANK rejection is built as `(format "{} BoostClass {} …" [E-ANK boost-class-id])`, and `E-ANK` is
**not a label**. `01_ANK.pact:292`:

```pact
(defconst E-ANK
    {"promile"         : 0.0
    ,"ouronet-account" : BAR
    ,"anchor-id"       : BAR}
)
```

It is the **blank-anchor row constructor**. So all 7 messages open with that object's JSON.

The intended shape exists elsewhere in the codebase — `06_DPOF.pact:522` has
`(defconst OF (at 0 ["Orto-Fungible"]))`, and DPOF's messages read *"Orto-Fungible MOCKO-… Nonce 1
must be in Circulation for exec"*. **ANK has no string label constant at all**, so whoever wrote these
reached for the nearest `E-`-prefixed name and got the blank row.

## Severity: message quality, not behaviour

The guard still blocks, and the *informative* half of the message ("BoostClass X must be active") is
intact — the object is noise in front of it. Same class as the missing `format` at `15_SWP.pact:466`
(fixed 2026-09-12 under the owner's ruling *"if an enforce is missing its string … you should just add
it"*): a one-token repair with no behavioural change.

**Not applied** — the `format` authorisation was specific to that site. Proposed: add a string label
constant (`(defconst ANK "Anchor")`, matching DPOF's `OF`) and use it at the 7 sites.

## Already has a test waiting

`AQP-G35` pins it two ways, so the repair is verified the moment it lands:

1. `E-ANK` equals the empty-anchor object (fails as soon as it becomes a string).
2. A live rejection's message literally opens with the object JSON.

Both flip to failing when the label is fixed, which is the intent — they name themselves.

## How it was found

Not by reading the source. It surfaced in the *expected-message* output while pinning the three
anchor-admission guards with `env-module-admin`: the refusal text came back with a JSON object glued
to the front. **Driving a guard to failure shows you its message, and the message is code too** —
three defects in this suite (this one, the missing `format`, `UEV_UpdateRewardBearingToken` omitting
its id) were all found by reading what a rejection actually says rather than what the source implies.
