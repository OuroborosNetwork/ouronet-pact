# Message-construction defects — THREE variants of one family, all fixed

**Date:** 2026-09-12 · **ALL FIVE FIXED**, owner-authorised (same class as the missing `format` at
`15_SWP.pact:466`) · detector added: `_conformance.py --rule format-no-arglist`, must stay at **0**

## The defect

Pact's `format` takes a template **and** an argument list. Given one argument it is an arity error
that resolves to a **closure**, and the caller dies with:

```
Expected Pact Value, got closure or table reference
```

— a message that says nothing about what went wrong.

## The mirror of `enforce-msg-not-format`, and strictly worse

That rule catches a *missing* `format`, which `enforce`'s **lazy** message hides until the guard
fires. This one also appears on **success paths**, where there is no laziness to hide behind: the
function does not merely lose its message, **it aborts**.

| site | context | severity |
|---|---|---|
| `08_ATS.pact:883` | `ATS\|C>ADD-HOT-RBT` enforce message | rejection path — guard fired, then died on its own message |
| `12_LIQUID.pact:125` | migration pause-gate message | rejection path |
| `Stage_Z/03_DSP+.pact:360` | **return value** for "nothing to mint or distribute" | **success path** |
| `Stage_Z/01_DPL-UR.pact:2430` | **UI stage text** once the KPay sale has concluded | **success path** |
| `Z_Reads/02_INFO-ONE+.pact:2465` | `INFO_ATS\|Cull`'s description | **success path — broken for every input** |

`INFO_ATS|Cull` was therefore **unpriceable by any client**, always.

## The repair

None of the five templates contained a `{}`, so the fix is to **drop `format`** — a plain string
literal is what every one of them wanted. A previous session had proposed adding `[]` instead
(matching `DALOS.pact:489`); dropping the call removes the hazard rather than patching it.

## A second defect that the first one hid

`12_LIQUID.pact:125` read:

```pact
(enforce gap (format "Migration can only be executed when Global Administrative Pause is offline"))
```

`enforce gap` requires the pause to be **ON**, and the sentence said **"offline"** — the exact
opposite of its own condition. Five sites elsewhere (`TS01-C2:197`, `C3:158`, `C4:145`, `TS01-P:111`,
`TS02-CPAD:110`) all use *"online"* to mean the pause is on, so the convention was unambiguous and
this line was the odd one out. Corrected to "online".

**Defect 1 hid defect 2: a message that never renders cannot be noticed to be wrong.** That is the
general hazard with message-construction bugs, and the reason `<<LQD-03pre>>` now pins the exact
sentence rather than just "it was refused".

## The detector found two sites a grep missed

`grep -rn '(format "[^"]*")'` found five. The rule found **seven** — two more in `00_DPMF.pact`
(`:641`, `:645`), whose templates wrap across lines with `\`-continuation. **Structure beats regex
whenever the thing you are matching can wrap.**

The scan is simple because `_conformance.py`'s `strip` blanks string literals by overwriting them with
**spaces**, preserving offsets: after stripping, a one-argument `(format "…")` has *nothing* left
inside it, while `(format "…" [x])` still shows its `[x]`. The literal is then recovered from the raw
source at the same offsets for the report.

**The two DPMF hits are deliberately NOT fixed.** They are a worse shape — a `{}` placeholder *and* no
argument list — so dropping `format` would print the brace. The repair needs the argument somebody
forgot, and guessing it in a module that is never called is churn with a chance of being wrong. DPMF
is superseded by DPOF and deployed for provenance only; the rule's dead-module bucket is where these
belong.

## Pinned

`modules/ATS.repl <<ATS-G15>>` (the repaired Hot-RBT message, as a regression guard),
`<<ATS-BRD>>` (`INFO_ATS|Cull` now returns its description), and
`modules/LIQUID.repl <<LQD-03pre>>` (both LIQUID defects).

---

## 2026-09-12, later — the THIRD variant, and the quietest one

`11_VST.pact:659`, `ATSU|C>BRUMATE`:

```pact
(enforce (and (not h1) h2) "Brumate requires hibernation for {} set to off andfor {} set to ON")
```

A **bare string** carrying two `{}` placeholders and **no `format` call at all**, so the caller saw the
braces verbatim and the two pair ids never appeared. One instance codebase-wide.

### The family, ordered by how loudly each fails

| shape | what the caller gets | sites | detector |
|---|---|---|---|
| `("…{}" [args])` — `format` missing | `Cannot apply value to non-closure` | 1, fixed | `enforce-msg-not-format` |
| `(format "…")` — arg list missing | `Expected Pact Value, got closure` | 5, fixed | `format-no-arglist` |
| `"…{}…"` — bare template, no call | the braces, printed literally | 1, fixed | `enforce-msg-bare-template` |

The first two **abort**. The third fails **safe and silent** — the guard works, the message arrives, it is
merely incomplete — which is exactly why it survived longest. All three are now regression detectors that
must stay at 0, and all three are false-positive-free: a `{}` in a string that is never formatted is never
intentional, and a one-argument `format` is never correct.

Fixed with the `format` call plus the `andfor` run-together; the sibling at `:646` had *"Hibernation turned
of"*, corrected to *"turned off"* in the same pass. Both are spelling, not meaning — the semantically wrong
message found the same day (the fuel-index *"negative Index"* for a bound of `0.1`) was left for the owner
precisely because it is a different kind of change.

### The scan took two tries, and the first returned a confident 0

`_pactlex.split_top` splits on top-level **forms** and discards bare string tokens — so the message was
never in the argument list being searched. The rule now uses a depth-aware literal scan.

**A scan that returns 0 on a class you have already reproduced is wrong, not reassuring.** That is the
second time this exact trap has been hit (`enforce-msg-not-format` fell into it for a different reason:
`strip` blanking string bodies). Both times the instance had already been found by hand, which is the only
reason the 0 was recognised as a bug rather than good news. **Reproduce first, then scan.**

Pinned by `modules/ATS.repl <<ATS-G18>>`, which asserts the repaired sentence with both ids substituted.
