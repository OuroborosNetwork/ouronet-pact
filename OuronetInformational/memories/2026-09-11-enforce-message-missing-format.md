# A written `enforce` message that no caller can ever read

**Date:** 2026-09-11 · **FIXED 2026-09-12** · pinned (`SWP-G21`) · detector added
**Site:** `1_SOVEREIGN/STAGE_01/2_Core/15_SWP.pact:466`, capability `SWP|S>RT_OWN`

## Resolution (2026-09-12)

Owner ruling: *"if an enforce is missing its string (format outputs a string), you should just add
it."* Applied — the site now reads `(format "Insufficient Major Elite Tier for NewOwner to support
CurrentOwner \ \existing SpecialFeeTargets of {}" [current-special-targets])`, using the repo's
`\`-continuation style to stay inside the line budget.

`SWP-G21` flipped with it: the `expect-failure` that used to pin `"Cannot apply value to
non-closure"` now pins `"Insufficient Major Elite Tier for NewOwner"`, so it is a **regression guard
on the fix** rather than a record of the bug. Drop the `format` again and that assertion fails.
`_conformance.py --rule enforce-msg-not-format` is at **0 codebase-wide and must stay there**.

This is a useful precedent for the rest of the open list: a repair with **no behavioural change**
(the guard blocked before and blocks now — only the message differs) does not need a decision, just
doing. The items that still wait on the owner are the ones that change what code *does*.

## The defect (as found)

```pact
(enforce (>= max-new-owner current-special-targets)
    ("Insufficient Major Elite Tier for NewOwner to support CurrentOwner existing
      SpecialFeeTargets of {}" [current-special-targets]))
```

**`format` is missing.** Pact therefore tries to APPLY the string literal to the argument list and
raises `Cannot apply value to non-closure` — an internal evaluation error in place of the
explanation somebody deliberately wrote.

## Why it survived, and the severity

**`enforce` is LAZY in its message.** Verified directly, not assumed:

```
(enforce (= 1 1) ("m {}" [1]))   =>  true      ;; malformed message never evaluated
```

So the defect is **invisible on every call where the condition passes**, and appears only when the
condition FAILS — the one moment the message exists to serve.

**It fails safe.** The transfer is still blocked; the guard works. What is lost is the *diagnosis*,
and the sentence is dead text no caller can reach. So: a real defect, low severity, trivially fixed
by wrapping the message in `format`.

Reproduced with the precondition asserted so the test cannot pass for the wrong reason: the
`S|DLK|OURO|DWK` pair carries **7** special-fee-targets while EMMA's major Elite tier caps her at
**4**, so `(>= 4 7)` is false and the malformed message is reached.

## The detector, and a trap inside it

`python3 _conformance.py --rule enforce-msg-not-format`. **One occurrence codebase-wide.**

**The rule first shipped reporting a clean 0 against a defect I had already reproduced.** Cause:
`_conformance.py`'s `strip()` blanks *string bodies* to preserve line numbers, so by the time the
rule runs, `("msg {}" [x])` has become `(        [x])` — an application with an empty head. A regex
keyed on the quote (which is what the standalone version of the scan used, and which worked) finds
nothing there. The rule now matches `(\s+\[` instead.

Worth remembering generally: **a rule written against raw source can silently find nothing when
dropped into a pipeline that pre-processes that source.** A clean 0 from a new rule should be
distrusted until it has been shown to fire on a known instance.

## Found by accident

This came out of trying to pin `SWP::UEV_CanChangeOwnerON`, an unpinned guard from
`_cheapseam.py`. The guard sits at line 472 of the same capability, *after* the malformed enforce at
466 — so probing it surfaced the defect first. The guard itself is still unpinned: reaching it needs
a prospective owner whose tier clears the special-fee-target count.
