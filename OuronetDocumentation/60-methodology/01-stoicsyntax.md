# StoicSyntax — the naming discipline

Every function in Ouronet is named so that its **cost class and its side effects are legible from
the name alone**, before you read a line of its body.

That is the whole idea. What follows is the system, and the next chapter
(`02-semi-self-auditing.md`) is what it bought.

---

## 1. Why a codebase needs this

123,005 lines of Pact. At that size the question stops being *"is this function correct"* and
becomes *"can anyone tell?"* — and the answer depends almost entirely on whether a reader can know
what a function is **allowed** to do without reading it.

Three concrete problems this solves:

**You cannot see a table read.** In Pact a read looks like any other call. A "pure helper" that
quietly scans a table is indistinguishable from one that does arithmetic, until it is on the
critical path of an operation someone is paying for.

**You cannot see an abort.** An `enforce` anywhere in a call tree can fail the whole transaction.
Whether a function may do that is a fact about the *contract* it offers, not about its body.

**You cannot see authority.** A function that writes to a guarded table and one that computes a
number look the same from the call site.

StoicSyntax makes all three visible in the identifier. It was designed before the bulk of the code
was written, which is why it is consistent enough to be checkable — retrofitting a naming
discipline across 8,848 function forms is not a thing anyone does.

## 2. The composition rule

A name is `PREFIX_Name`, or `PREFIX_Scope|Name`. The prefix is read left to right.

**UPPERCASE letters are the operation class** — what the function *does* and what it costs:

| letter | meaning |
|---|---|
| `U` | utility |
| `C` | compute |
| `R` | read |
| `H` | **heavy** — a scan |
| `D` | data construction |
| `E` / `V` | enforce / validate |
| `W` | write |

They compose. `URC_` is read-then-compute. `URH_` is a *heavy* read. `UDC_` constructs data.

**lowercase letters are a specialisation role** appended to the class:

| letter | meaning |
|---|---|
| `k` | the compute produces a composite table **k**ey |
| `x` | an au**x**iliary — a private helper of the function directly above it |
| `v` | **v**alidating — see §4, this one is earned |
| `i` | emits an **I**GNIS cost — a `URCi_` cost reader |

**`|` is a scope** inside the *name* part, not the prefix. `UR_SCR|ScoreOwnerKonto` is a reader
scoped to the `SCR` tables; `DPNF|C_Create` is a client entrypoint scoped under the `DPNF` module.

## 3. The families, and what each one promises

The promise is the point. A prefix is a **contract with the reader**.

### Unprotected — callable without a capability, safe by construction

| prefix | promises | count |
|---|---|---|
| `UC_` | pure compute on its arguments. **No table reads, no `enforce`.** | 430 |
| `UR_` | table reads, and nothing else. No `enforce`, no writes. | 1,406 |
| `URC_` | read and derive. **No `enforce`** — validation lives elsewhere. | 755 |
| `UEV_` | read and `enforce`. May abort the transaction. | 523 |
| `UDC_` | named constructors for objects, in place of ad-hoc literals. | 310 |
| `URH_` | a **heavy** read — a scan. Announced, because it is expensive. | 128 |
| `URCi_` | a cost reader. Returns what an operation will charge. | 597 |
| `CAP_` | account-ownership enforcement. | 33 |
| `INFO_` | a client-facing cost preview. | 625 |

### Protected — locked inside the module, not the integrator surface

| prefix | meaning | count |
|---|---|---|
| `A_` | admin-key mutations. `AA_` doubled = **heavy** somewhere in its whole call tree. | 190 |
| `C_` | client entrypoint. Builds the IGNIS cumulator. `CC_` doubled = heavy. | 604 |
| `XI_` | internal to this module | 388 |
| `XE_` | for external modules only | 328 |
| `XB_` | both | 62 |
| `WI_` / `WU_` / `WW_` | raw persistence: insert / update / upsert | 117 |
| `P\|` | policy functions — the inter-module authorisation layer | 538 |

> The `W` family is real canon and worth knowing about: 117 functions, each one a single write site
> gated on a `SECURE` capability. `CLAUDE.md`'s own prefix tables omit it, which is a gap in that
> file rather than in the system — `StoicSyntax-Prefixes.md` §2 documents it fully.

### What these counts do and do not include

**Exact `PREFIX_` matches only**, in `1_SOVEREIGN` + `2_CITIZEN`, measured 2026-09-28:

```bash
grep -rhoE "^\s*\(defun <PREFIX>_" --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l
```

So a **role variant** counts separately — `UCv_` and `UCx_` are not in the `UC_` row — and a
**scoped** form is not counted at all: `DPTF|C_Transfer` is a `C_` client entrypoint, but it does
not match `^\(defun C_`. That is why the `C_` row reads 604 while the family including scoped
forms is roughly twice that, and why these rows do **not** sum to the 8,848 `defun` forms on the
front page.

This is stated rather than smoothed over because the first draft of this table did smooth it over
— it used a census that collapsed `UCv_` into `UC_` and `DPTF|C_` into `C_`, and published eleven
figures that were each somewhere between 1 and 300 too high. A count is only meaningful with its
matching rule attached, and the rule is the part that gets lost when a number is quoted onward.

## 4. The `v` role must be EARNED — and re-earned

`UCv_`, `URv_`, `URCv_` mark a function whose `enforce` is **intrinsic to its own computation** — a
shape guard on the thing it is computing — rather than business validation, which belongs in a
separate `UEV_` or a capability.

This is the one part of the system that is a *judgement*, so it is given a test:

> **Relocating the check to a `UEV_`/defcap is "complicated" exactly when it results in MORE CODE.**
> More code → it stays inline and the `v` is justified. Same or less → it moves, and the `v` is not
> warranted.

In practice that is a **call-site count**. One real caller means relocating costs one check and
removes one, so the `v` is unjustified. Many callers mean relocating duplicates the identical check
N times, so it stays.

Three further rules, each from a real mistake:

- **REPL suites count as call sites.** A test that calls a function directly and asserts its failure
  message depends on the check being inline. `UCv_Percent` had zero `.pact` callers and was nearly
  deleted, while `REPL/modules/UTILITIES.repl` asserts both its value and its failure message.
- **A check every caller already guarantees is tautological** — delete it, do not rename it.
- **A check the defcap also performs is a duplicate, and the inline copy SHADOWS the defcap's.**
  Measured: `DEMIPAD::UR_Funds` made `C>WITHDRAW`'s type `enforce` provably dead.

Enforced by `REPL/tools/_conformance.py` `[v-role-justified]`, re-checked every run — because a `v`
that was justified when written stops being justified when its call graph changes.

## 5. The honesty rule

> A prefix reflects the function's **own** nature and its **heaviest reachable branch** — never its
> caller's class.

A pure helper used by a `URC_` is still `UC_` (as `UCx_`), because it does no reads. And a function
that can reach a scan takes the heavy prefix even if the common path does not — which is why `CC_`
and `AA_` are *transitive*: doubled means a heavy read is reachable **anywhere in the whole
execution tree, at any depth**.

That transitivity is what makes the marker useful. A caller can see the worst case without
traversing the tree, which is the only way a worst case is ever actually checked.

## 6. "Protected" means locked out — not validated

Owner ruling, 2026-09-20, and it corrected a vocabulary rather than a codebase.

| form | what it does | protection? |
|---|---|---|
| `(require-capability (C))` | refuses unless a caller already granted `C` | **YES** |
| `(P\|UEV_IMC)` | enforces a registered inter-module guard | **YES** |
| `(with-capability (C) …)` | *acquires* `C`, running its body as validation | **no** — nobody is turned away |
| `(with-capability (SECURE) …)` | acquires a capability whose body is literally `true` | **no, and not even validation** |

Applying that definition precisely **reclassified 50 functions** from "IMC + custom lock" to "IMC
is the whole lock". **None of them lost protection** — they never had the second lock the
annotation claimed.

The measurement that settles it: 141 `X_`/`W_` functions use `require-capability (SECURE)`, a
genuine lock. 40 use the `with-capability` form, and **every one of those also carries an IMC gate
or another `require-capability`**. The number relying solely on the no-op form is **zero**.

> **The codebase was sound; the vocabulary was not.**

That sentence is the honest summary of this whole section, and it is why a naming discipline is
worth arguing about. A word that describes two different things lets a reviewer believe a check
exists where none does — and the belief is the dangerous part, not the code.

## 7. The one reader allowed to write

`UM_` — *utility migrate*. A migrate-on-read helper, and the sole exception to "`UR_` never
writes". It exists because a schema change would otherwise require rewriting every historical row
in one transaction, which does not fit in the gas budget.

It is marked precisely so the exception is greppable. An unmarked reader that writes is a defect;
a `UM_` is a decision.

## 8. Where this stops being style

Three things follow mechanically from the naming, and they are the reason it earns a chapter:

1. **A reviewer can read a call site.** `(UC_Split a b)` cannot touch a table. `(URH_Holdings acct)`
   scans. You know before you look.
2. **A machine can check it.** `_conformance.py` runs 26 structural rules across 123,005 lines and
   reports **0 violations** — `UC_` never reads, `UR_` never enforces, `XI_` never validates, `XE_`
   always starts with its inter-module gate. None of those checks is possible without the naming.
3. **The exceptions are bounded.** Where the code legitimately does something the rule does not
   describe, it is reported as an **observation** with a count — 106 of them — rather than hidden
   or renamed away.

That third point is the subtle one. The tool's own closing line is:

> *"the doc is narrower than the code's correct practice"*

which is an admission, printed by the checker, that the written rules do not cover everything the
codebase legitimately does. A system that reports its own incompleteness is one you can trust the
zeros from.

---

## Where to go next

- `02-semi-self-auditing.md` — what this bought, and how the audits used it
- `03-the-gate.md` — the 26 rules, and everything else the gate enforces
- `../10-architecture/01-the-layer-cake.md` — the layering these prefixes describe

## Sources

- **The canon**: `OuronetInformational/StoicSyntax-Prefixes.md` (1,568 lines) — §1 composition,
  §2 the registry, §2.15 protection classes, §7.19 `UM_`.
- **Counts**: `grep -rhoE "^\s*\(defun <PREFIX>" --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l`,
  2026-09-27. Full method in `../90-reference/03-how-these-figures-were-obtained.md`.
- **Conformance**: `python3 REPL/tools/_conformance.py` — 26 rules, 0 violations, 106 observations.
- **The protection-class measurement and the 50 reclassifications**: `StoicSyntax-Prefixes.md`
  §2.15, owner ruling 2026-09-20.
