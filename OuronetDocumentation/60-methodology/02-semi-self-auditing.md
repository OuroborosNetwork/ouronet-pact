# How the naming made the code semi-self-auditing

The previous chapter described a naming discipline. This one is the claim that justifies it:

> Because every function's cost class and side effects are in its name, **a whole category of
> review became a mechanical check** — and the checks run on every commit rather than in a review
> someone schedules.

"Semi" is doing real work in that sentence. What follows says exactly which half is mechanical and
which is not, because a claim of self-auditing that does not draw that line is marketing.

---

## 1. What "auditable" has to mean at this size

122,969 lines. An auditor cannot read them, and neither can a maintainer. So the only questions
worth asking are the ones that can be asked of **all** of it at once.

Consider a single ordinary question: *does any function that claims to be pure actually read a
table?*

- **Without the naming**, that question has no addressable subject. There is no set of "functions
  that claim to be pure" — you would have to read every function, decide what it claims, then
  check it. For 8,848 `defun` forms that is not an audit, it is a career.
- **With the naming**, the subject is `^\(defun UC_`, and the check is whether any of them contains
  a table read. That is a script.

The naming does not make the code correct. It makes **correctness a question you can ask**.

## 2. What is actually checked

`REPL/tools/_conformance.py`, run 2026-09-29:

```
26 rules
VIOLATIONS: 0   (0 state-dependent, 0 argument-domain)
OBSERVATIONS: 106   (the doc is narrower than the code's correct practice)
```

Twenty-six structural rules over the whole tree, zero violations. A selection, to show what kind
of thing they are:

| rule | what it proves |
|---|---|
| `UC-no-read` | no "pure compute" function touches a table |
| `UR-no-enforce` / `UR-no-write` | a reader cannot abort a transaction or change state |
| `XI-no-enforce` | writers do not validate — every check lives in the capability |
| `XE-starts-UEV_IMC` | every cross-module entrypoint opens with its inter-module gate |
| `XI-no-trailing-true` | a write function ends on the write, so its return cannot be mistaken for a result |
| `self-C-call` | no billing client entrypoint is invoked from inside its own module |
| `citizen-calls-X` | no citizen module reaches a protected function directly |
| `table-never-created` | every declared table is actually created |
| `admin-gate-terminal` | an authorisation gate is never shadowed by a business rule (see §4) |
| `x-protection-declared` | every protected function states which class of protection it has |
| `v-role-justified` | the `v` suffix is re-earned every run, not inherited |

Every one of these is **impossible to express without the prefix system**. There is no way to ask
"do readers ever write" of a codebase where readers are not identifiable.

## 3. The 106 observations are the honest part

An observation is a place where the code does something the written rule does not describe, and
inspection found it legitimate. The tool's own closing line says so:

> *"the doc is narrower than the code's correct practice"*

That is a checker **printing its own incompleteness**, and it is the reason the zero above is worth
anything. Three examples of what lives in that bucket:

- **Six billing shapes where the documentation described one.** The rule says a client entrypoint
  returns a cumulator for Talos to collect. A trace of all of them found six legitimate patterns —
  billed in Talos, billed in the core, billed by a later `defpact` step, priced in native STOA
  instead. The rule was not wrong; it was partial.
- **Citizen minters inverted.** Their client functions call *into* Talos and return a string, which
  the self-call rule forbids for sovereign modules. It is sound there because no cumulator exists
  at that level to mishandle — and the tool bounds the exception to those two files rather than
  loosening the rule.
- **Cross-module scans**, nine of them, each bounded and deliberate.

A checker that classified all 106 as failures would have been switched off inside a week, and
then the 26 rules would protect nothing. **A rule that gets ignored weakens the rules that do not.**

## 4. The case that shows the difference between a check and an audit

Owner ruling, 2026-09-14. A capability both authorised and validated, in this order:

```pact
(enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")   ;; business rule
(compose-capability (GOV|DPTF_ADMIN))                                      ;; authorisation
```

A solvent treasury is the normal state. So **every** attempt — admin or stranger — was refused by
the business rule, and the admin gate was never reached.

A red-team test could report *"a non-admin was refused"*, be telling the truth, and prove nothing:
delete `GOV|DPTF_ADMIN` entirely and the test still passes. **A shadowed gate is indistinguishable
from an absent one from the outside.**

This is exactly the failure that survives ordinary review, and the reason it is worth dwelling on:
the fix was not to find the bug once. It was to make *"is any authorisation gate shadowed?"* a
question with a mechanical answer — `admin-gate-terminal`, now at zero — and then to find the
**other** seventeen sites the same question surfaced.

**The scope correction matters too.** The first sweep covered the admin band, fixed 18 sites and
reported them clean. Re-scanning **every capability in the tree** found **two more** that the
sweep's own definition had missed — both in the ruling's own module, one reproducing the treasury
shape exactly. The rule said "or equivalent" and the sweep had read it narrowly. (The tree holds
988 capabilities today; the sweep's own record says 989, which is the same tree one capability
ago — the kind of drift that makes a quoted total worth less than the command that produces it.)

That is the honest shape of this work: the check is mechanical, **deciding what the check should
cover is not**, and getting that wrong looks exactly like success.

## 5. What it made possible: the canon sweep

The strongest evidence is a refactor that would not otherwise have been attempted.

Every client entrypoint in the sovereign tree was re-signed to a fixed convention — `patron` first,
`executor` second, `executee` third. The sweep changed **694 entrypoint signatures across 58
files**. Today the conforming surface is larger, because it kept growing while the sweep ran:

```
A_/C_ entrypoints in 1_SOVEREIGN modules: 776
   DONE 776      remaining: 0
executor enforcement — whole tree: 766 proven, 0 UNPROVEN
```

A change of that size is only sane if you can *enumerate the subject* and *prove the result*. Both
come from the naming: `A_`/`C_` identifies the surface, and a tool can then check every one.

And the sweep's own history is the cautionary half. The first attempt was scoped by a tool whose
entrypoint filter was **blind to every Talos function** — it reported **89** entrypoints where the
scan it should have run found **482**, and Talos is the only client-facing path in the system. The
plan was wrong by a factor of five on its first day, and it looked complete.

> Trust the tool, and check the tool.

## 6. Where the mechanism stops

Stated plainly, because this is the "semi":

**It cannot check what a function means.** `UR_RewardTokenList` reads a table and returns a list.
Whether the *right* list for a given operation is that one or `UR_RewardBearingToken` is a
semantic question, and a wrong choice there is a well-formed call that returns a confident wrong
answer. That class has bitten this project repeatedly and no naming discipline addresses it.

**It cannot check a boundary decision.** Whether a rule should cover the admin band or every
ownership gate is a judgement; the checker only runs the scope it is given.

**It cannot check arithmetic, economics or intent.** Those are what the Audit Book is for.

**And a green check is evidence about the checker as much as the code.** Several checks in this
project passed while proving nothing — a guard whose regex matched its own explanatory comment, a
sentinel test that passed with the fix removed, a coverage guard that read one file while claiming
a rule about a class. `04-what-went-wrong.md` is the catalogue, and it exists because the
credibility of §2's zero depends on it.

## 6b. What the structural checks sit on top of

The 26 rules answer questions about *shape*. They are not the only thing that runs, and they
would not be worth much alone — a codebase can be perfectly well-named and wrong.

Underneath them is the behavioural suite, and it was measured while writing this chapter rather
than quoted from memory:

```
wall 312.8s   executed 26128 assertions (20952 positive, 5176 negative)
GATE GREEN
```

**26,128 assertions**, of which **5,176 are negative** — checks that something is correctly
*refused*. That ratio is worth pausing on. Roughly one assertion in five exists to prove a door is
shut, which is the half of testing that is easy to skip because nothing visibly breaks when it is
missing.

The runner also proves something about itself. Beyond executing the suite, it verifies that **no
asserting file is orphaned** — every file containing assertions must be reachable from a named
entry point, or explicitly excluded with a reason. That check exists because it was once absent:
four test drivers were archived on the reasoning that they contained no assertions themselves,
which was true of the drivers and false of what they loaded. About 125 assertions left the suite
silently, and the inventory never noticed, **because it counted files rather than execution**.

An assertion nothing runs is not coverage. It is decoration that reads as coverage — to a ledger,
and to a human.

## 7. The claim, stated precisely

What the naming buys:

- a **decidable subject** for structural questions — 26 of them, over the whole tree
- **enumeration** for large refactors, and proof afterwards
- a review that can concentrate on meaning, because shape is already settled
- exceptions that are **bounded and counted** rather than argued case by case

What it does not buy: correctness, economic soundness, or freedom from the class of bug where
every argument is well-formed and one of them names the wrong entity.

The name of this chapter is the honest version. Not self-auditing — **semi**.

---

## Where to go next

- `01-stoicsyntax.md` — the system this chapter is about
- `03-the-gate.md` — everything else that runs on every commit
- `04-what-went-wrong.md` — the failures, including the checks that failed silently

## Sources

- `python3 REPL/tools/_conformance.py` — 26 rules, 0 violations, 106 observations, run 2026-09-29.
- `python3 REPL/tools/_executorplan.py` / `_executorenforced.py` — 776 / 776 / 0 remaining,
  766 proven, 0 unproven, same date.
- The shadowed-gate ruling and its scope correction: `CLAUDE.md`, *"Authorisation precedes
  validation inside a `defcap`"*; `OuronetInformational/DEFECT-LEDGER` §7.2h.
- The six billing shapes and the citizen inversion: `CLAUDE.md`, *"Two billing shapes, and where
  the no-self-`C_` rule actually applies"*.
- The 89-vs-776 scoping error: `CLAUDE.md`, *"ACTIVE LONG-RUN WORK"*.
