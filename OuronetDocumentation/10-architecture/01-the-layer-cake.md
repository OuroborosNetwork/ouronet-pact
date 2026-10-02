# The layer cake

`../00-orientation/03-the-shape-in-one-diagram.md` gave four rules. This page makes them precise,
and — more importantly — shows that they are **mechanically checked rather than aspired to**.

```
   UTILITIES  →  CORE  →  TALOS          and, beside it:   READS        CITIZEN
   pure          state    orchestration                     no writes    a client
```

---

## 1. Why a layer cake at all

Ouronet is 123,501 lines of Pact across 105 files. At that size the question is not "is each
function correct" but "can anyone tell?" — and the answer depends almost entirely on whether a
reader can know what a function is *allowed* to do without reading it.

That is what the layering buys. Each layer's constraints are strict enough that a function's
position in the cake tells you most of what you need:

| layer | may read tables | may write | may `enforce` | may be called by a client |
|---|---|---|---|---|
| **Utilities** | no | no | only on its own arguments | no |
| **Core** | yes | yes | yes | **no** — never directly |
| **Talos** | yes | via Core | yes | **yes — the only layer that may** |
| **Reads** | yes | **never** | rarely | yes, freely and for free |

Combined with the prefix system (`../60-methodology/01-stoicsyntax.md`), this means a reviewer
reading `UC_ComputeSplit` in a utility module knows *before reading the body* that it touches no
table, holds no authority, and cannot abort a transaction for business reasons. That is not a
documentation convention. It is checked.

## 2. The four rules, precisely

### Rule 1 — calls go down, never up

A Utility may not call Core. Core may not call Talos. The dependency graph is acyclic and the
deploy order is its topological sort, which is why deploy order is forced
(`04-deploy-order.md`).

Cross-module calls use **module references** with `::` rather than `module.function`:

```pact
(ref-U|CT::CT_NS_USE)          ;; a modref call — couples only to the interface member used
```

The distinction is load-bearing and the owner explains why:

> "using it with dot instead of double dot, I learned would load the whole module … That's the
> reason I use `::` to call functions from different modules"

`.` couples a module to the *whole* of another module; `::` couples it to one interface member.
At this scale that difference decides whether the deploy graph is tractable.

### Rule 2 — every write enters through Talos

A Core `C_` — the client entrypoint prefix — **cannot be invoked from inside its own module**. A
client cannot call it either. The only path is a Talos wrapper.

The reason is the money, not tidiness. A Core `C_` builds an **OutputCumulator**, the object that
records what an operation cost, and only Talos may hand that to the collector. A self-call could
drop it or double it, and either way the user is billed wrongly and silently.

**The checked statement is sharper than the documented rule**, which is worth knowing because the
sharper one is the true one. `REPL/tools/_conformance.py` reports:

```
[self-C-call] 0 violation(s)
```

and cross-checks *why*: the hits it finds all target `C_DeployAccount`, which is **cumulator-free**
— it carries the `C_` prefix without the `C_` contract. So the rule that actually holds is:

> **No billing client `C_` is ever invoked from inside its own module.**

In the **citizen** minters the direction inverts and is sound: their `C_Spawn` / `C_Fix` call *into*
Talos and return a string after Talos has already collected. There is no cumulator at that level to
mishandle. The tool records these separately — `[self-C-call-citizen] 64 observation(s)` — bounded
to those files, which is the point: an unbounded exception is indistinguishable from a hole.

### Rule 3 — every read is free, and bypasses Talos entirely

Reads take no signature, collect no IGNIS, and cannot change anything. They do not go through
Talos because there is nothing for Talos to do: no gas to sponsor, no fee to collect, no capability
to compose.

A `/local` read does report a `gas` figure. **That is not IGNIS** and costs the user nothing — it
is the node's meter for a simulated execution, billed to nobody. Surfacing it as a fee is a real
mistake clients have made. `08-the-read-layer.md` and
`docs/CHAPTER-INTEGRATION/05-reading-data.md` cover the surface.

### Rule 4 — citizen code is a client, not a layer

A citizen module sits *beside* the cake. It calls Talos exactly as a browser does, pays the same
IGNIS, and gets no privileged access — `[citizen-calls-X] 0 violation(s)` confirms no citizen
module reaches a protected `X*` function directly. `02-sovereign-and-citizen.md` is the boundary.

## 3. Inside a Core operation

The decomposition every Core client operation follows. Deviations exist and are deliberate.

```
  C_Something            wiring + billing
    │
    ├── UEV_IMC                      inter-module gate: am I allowed to be called?
    ├── with-capability (ClientCap)   ← ALL authorisation and validation lives here
    │     ├── CAP_EnforceAccountOwnership
    │     ├── UEV_* checks
    │     └── one combined boolean enforce
    │
    ├── XI_ / XB_ / XE_              the writes. no enforce, no validation
    │
    └── UDC_ConstructOutputCumulator  what it cost → returned to Talos
```

The rule that makes this reviewable: **all checking in the capability, all writing in the `X`
function, all billing in the `C_`.** A reviewer auditing authorisation reads only `defcap`s; one
auditing persistence reads only `X` functions. The conformance tool enforces the separation —
`[XI-no-enforce] 0`, `[XE-starts-UEV_IMC] 0`, `[XI-no-trailing-true] 0`.

### Authorisation comes before validation

Owner ruling, 2026-09-14, and it is about testability rather than style. When a `defcap` both
authorises and validates, the authorisation goes first — because whichever check runs first is the
one a failing test sees.

The case that produced the ruling:

```pact
(enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")   ;; business
(compose-capability (GOV|DPTF_ADMIN))                                      ;; authorisation
```

A solvent treasury is the normal state, so **every** attempt — admin or stranger — was refused by
the business rule and the admin gate was never reached. A red-team test could report "a non-admin
was refused", be telling the truth, and prove nothing: delete `GOV|DPTF_ADMIN` and the test still
passes. **A shadowed gate is indistinguishable from an absent one from the outside.**

Swept across 18 admin-band sites. `[admin-gate-terminal] 0 violation(s)` holds it.

## 4. Billing is not one shape, and that is correct

A full trace of the non-cumulator `C_`s — **38** of them when the trace was done on 2026-09-13 —
found **six** legitimate billing shapes:

| | where billing happens | example |
|---|---|---|
| **A** | Core `C_` returns the cumulator; Talos collects | most operations |
| **B** | Talos builds the cumulator from a cost reader and collects | `DALOS::C_RotateGuard` |
| **C** | STOA-priced — no IGNIS at all | `DALOS::C_DeploySmartAccount` |
| **D** | billed in the Core itself | `SWPLC::C_UpgradeBrandingLPs` |
| **E** | a `defpact` step — the `C_` starts, a later step bills | the swap pool/liquidity ops |
| **F** | nested Talos — the Core calls another Talos client that collects | `DEMIPAD::C_Transmit*` |

Today the tool reports `[C-without-cumulator] 32 observation(s)`, not 38, and the difference is not
drift: the IGNIS restructure of 2026-09-20 reclassified the collector primitives — `C_TransferDalosFuel`
and the `STOA|C_Collect*` family — as protected `XB_`/`XE_` functions. They were never client
functions; they *are* the collectors and cannot collect from themselves, which made them a standing
exception to every rule in this section. **The exception disappeared because the prefix was wrong,
not because the rule was.** Six shapes remain six.

These are reported as **observations, not violations**, because the choice belongs to the
operation. The rule is still worth reading: it is the only thing that
would surface a genuinely *unbilled* operation.

One operation is deliberately free: `PYTHIA|C_Link` charges nothing while its three siblings do.
Safe because it is **bounded**, not because it is cheap — linking needs two deployed halves at 500
native STOA each and counterparts are never cleared, so it is one-shot per pair forever. If
counterparts ever become clearable, it stops being safe. Pinned by a test that says so.

## 5. How much of this is actually checked

This is the claim worth verifying, so here is the command and its output:

```bash
python3 REPL/tools/_conformance.py
# 26 rules
# VIOLATIONS: 0   (0 state-dependent, 0 argument-domain)
# OBSERVATIONS: 106   (the doc is narrower than the code's correct practice)
```

Twenty-six structural rules, zero violations across 123,501 lines. The rules include: `UC_`
functions read no tables, `UR_` functions neither `enforce` nor write, `XI_` functions never
validate, `XE_` functions start with the inter-module gate, no module-reference parameters, no dead
modref bindings, every table is created, every `X*` declares its protection.

**Read the last line carefully**, because it is the honest part: *"the doc is narrower than the
code's correct practice."* 106 observations are places where the code does something the written
rule does not describe, and inspection found them legitimate — six billing shapes where the
documentation described one, citizen inversions that are sound, cross-module scans that are
bounded. The tool reports them rather than either failing or hiding them.

That distinction — **violation** versus **observation** — is what makes 0 violations meaningful. A
checker that classified all 106 as failures would have been switched off within a week.

---

## Where to go next

- `02-sovereign-and-citizen.md` — the boundary Rule 4 draws
- `06-ignis-and-the-gas-station.md` — what Talos does with the cumulator
- `../60-methodology/01-stoicsyntax.md` — the prefix system these rules are written against
- `../60-methodology/02-semi-self-auditing.md` — why naming made these checks possible at all

## Sources

- Conformance output: `python3 REPL/tools/_conformance.py`, run 2026-09-27 — 26 rules, 0
  violations, 106 observations.
- The six billing shapes, the `self-C-call` narrowing, and the `PYTHIA|C_Link` bound: `CLAUDE.md`,
  *"Two billing shapes, and where the no-self-`C_` rule actually applies"*.
- The authorisation-before-validation ruling: owner, 2026-09-14; `CLAUDE.md` and
  `OuronetInformational/DEFECT-LEDGER` §7.2h.
- The `::` versus `.` modref reasoning: owner, 2026-08-28, session transcripts.
- Layer membership and per-layer figures: `../00-orientation/03-the-shape-in-one-diagram.md`.
