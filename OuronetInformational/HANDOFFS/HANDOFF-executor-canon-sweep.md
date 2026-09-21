# HANDOFF — THE PATRON / EXECUTOR / EXECUTEE CANON SWEEP

> **Read this first after any compaction or context loss.** It is the complete plan: the canon,
> the tooling, the worklist, the protocol, and the reference implementation. Nothing else needs to
> be reconstructed from conversation.

**PROGRESS IS TRACKED IN §4's TABLE.** Tick `[ ]` → `[x]` as part of each module's commit. A cold
session must be able to see what is done by reading this file, without reconstructing it from
`git log`. If the table and `_executorplan.py` disagree, **the tool is right** — regenerate.

**Status:** preparation complete, sweep starting at `01_DALOS`.
**255 done · 520 remaining · 46 modules · 6 swept (01_DALOS, 02_IGNIS, 04_BRD, 05_DPTF, 06_DPOF, 08_ATS) · 1 archived (00_DPMF).**

---

## 1. THE CANON (owner rulings, 2026-09-20)

Authoritative copy: `OuronetInformational/StoicSyntax-Prefixes.md` §2.2. Summary:

Every `A_`, `AA_`, `C_`, `CC_` function takes these parameters, **in these positions**:

```
1st   patron      ALWAYS      the account that PAYS
2nd   executor    ALWAYS      the account that ACTS
3rd   executee    when it exists   the account the execution is BESTOWED UPON
```

**Position is canon, not just presence.** An executor sitting fourth is non-conforming. Pact
arguments are positional, so reordering a signature **rewrites every call site**.

### Ownership obligations

| role | enforcement |
|---|---|
| `patron` | **always, directly** — via the gas-collection path. For the gasless patron this is proven by a capability on the function, and *that same capability proves the admin gating* |
| `executor` | **always** — directly or indirectly. If indirect, **the path MUST be named in the `@doc`** |
| `executee` | **conditionally** — the conditions MUST be named in the `@doc` |

A transfer is the canonical three-role case:
`(C_Transfer patron sender receiver ...)` → patron / executor / executee, where the receiver needs
an ownership check **only when `method` is true AND it is a smart Ouronet account**.

### Talos is where the two paths diverge

| | module signature | Talos wrapper signature |
|---|---|---|
| `C_` | `(patron executor ...)` | passes the **caller's** patron — customness preserved |
| `A_` | `(patron executor ...)` | **no patron** — supplies `GASLESS-PATRON` itself |

An `A_` is gasless **because its ordinary collection is served by the one account
`IGNIS::C_Collect` exempts** — not because collection is skipped. The path is preserved.
**Consequence:** the permissions the gasless patron needs must be granted **in Talos**.

### `P|` IS EXEMPT

`P|A_Define`, `P|A_Add`, `P|A_AddIMP`, … — **126 functions, leave exactly as they are.** They are
deploy-time setup and inter-module-guard registration with admin characteristics, not client
functions. The `P|` denomination exists to signal precisely this.

---

## 2. REFERENCE IMPLEMENTATION (already committed — copy this shape)

`ATS|A_KickStart`, the owner's own example. `kickstarter` was the executor under a bespoke name.

```pact
;; CORE — 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
(defun A_KickStart (patron:string executor:string ats:string rt-amounts:[decimal] ...))

;; TALOS — 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
(defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] ...)
    (ref-IGNIS::C_Collect GASLESS-PATRON
        (ref-ATSU::A_KickStart GASLESS-PATRON executor ats rt-amounts ...)))
```

`GASLESS-PATRON` is already `(defconst GASLESS-PATRON (URC_Gassless))` in `01_TS01-A.pact:260`,
and `IGNIS::C_Collect` already exempts it (`iz-gassles-patron`, `02_IGNIS.pact:1868`).

---

## 3. TOOLING

| tool | job |
|---|---|
| `REPL/tools/_executorplan.py` | **the worklist.** Classifies every entrypoint DONE / RENAME / ADD / PATRON. `--module F.pact`, `--state RENAME` |
| `REPL/tools/_executormigrate.py` | **call-site migration.** PARSES rather than regexes; rule table per function; `--apply` required |
| `REPL/tools/_authsurface.py` | **the safety net.** Gate-fatal; fails if any entrypoint's ownership set shrinks |
| `REPL/tools/_bandplan.py` | superseded for scoping — **its filter was blind to all Talos** (see below) |

### Classification, and why RENAME vs ADD cannot be guessed

- **RENAME (115)** — 2nd param is an ACCOUNT under a bespoke name: `account` 53, `owner-konto` 13,
  `client` 10, `injector` 8, `beneficiary-id` 5, `recoverer` 4, `owner-account` 3, and singles
  including `kickstarter`, `curler`, `coiler`, `fueler`, `coiler-vester`, `curler-vester`.
- **ADD (322)** — 2nd param is an ENTITY id (`id`, `ats`, `swpair`, `pool-id`, `fvt-id`). There is
  **no executor at all**; it is derived inside a capability. **Assuming "2nd param = executor"
  is wrong for these 322.**
- **PATRON (282)** — first parameter is not `patron`.

### The bug that made the first attempt wrong

`_bandplan.py` used `re.match(r'^(A|AA|C|CC)_|\|(A|AA|C|CC)_', n)`. `re.match` anchors the WHOLE
pattern at position 0, so the second alternative could only fire on a name starting with a bar.
**Every Talos entrypoint was invisible.** It reported **89** entrypoints against an actual **482**
— and Talos is the only client-facing path in the system. The first day of this refactor was
scoped, sequenced and reported against that number. Found by the owner reading `TS01-C1`, not by
the tooling.

---

## 4. THE WORKLIST — DEPLOY ORDER, 46 modules, 719 functions

**Order is deploy order, first module of Stage 1 to the last of Stage 2 — NOT smallest-first.**
That is the owner's instruction and it is also the correct dependency order: a module's call sites
live in the modules deployed *after* it, so sweeping forward means every module is already fixed
before anything that calls it is touched. Working smallest-first would revisit the same call sites
repeatedly.

A module already conforming is **not skipped silently** — report *"looked it up, this module was
done in previous runs, nothing to do here"* and move on.

### 4a. LESSON FROM MODULE 2 — PROTECTING A FUNCTION HAS A CALL-SITE TAIL

Recorded 2026-09-20, because it cost most of the IGNIS module's time and it will recur in every
module where this sweep promotes a `C_` to an `X_`.

Turning `IGNIS::C_Collect` / `STOA|C_Collect*` into `XE_CollectIgnis` / `XE_CollectStoa` /
`XB_Collect*` behind `P|UEV_IMC` is a one-line change *in IGNIS* and a three-part change
everywhere else. Do all three or the tree loads and then dies at the first fee:

1. **Registration.** Every module that bills must add `(ref-P|IGNIS::P|A_AddIMP mg)` to its own
   `P|A_Define`. Grep for callers and check each one — four were missed on the first pass
   (`MTX-AQP`, `TS02-C2`, `TS02-C3`, `TS02-DPAD`) and four more matched only in `@doc` prose
   (`DALOS`, `CODEX`, `PYTHIA`, `DSP+`), so a grep count is not an answer.

2. **Acquisition — and this is the part that is easy to miss.** `P|UEV_IMC` passes when one of
   the registered capability guards is IN SCOPE. On the ordinary path that is free: Talos
   acquires `P|TALOS-SUMMONER` at the top, the gate is **depth-invariant**, and every nested
   core call inherits it. **A defpact step inherits nothing** — it arrives in its own
   transaction through `continue-pact` with an empty capability scope. Every billing site inside
   a defpact step needs an explicit `(with-capability (P|MOD|CALLER) …)`. `MTX-SWP` alone had
   fourteen. The modules with defpacts that bill: `MTX-SWP`, `MTX-AQP`, `FVT`, `SWPI`, `ANK`,
   `TS02-C3`, `DSP+`.

3. **The deploy pipeline.** `P|A_Define` is a *function*. Upgrading a module does not re-run it,
   so on an upgrade round the new IMP entry never lands — no deploy error, then "None of the
   guards passed" at the first collection. The fix is not a hand-written file in `Deploy/`
   (`Deploy/` is generated and the gate diffs it): add the init block's label to the round's
   `"init"` list in `REPL/tools/_deploybundle.py` so the step is *emitted* from the REPL chain.

Tooling: `/tmp/wrapbill.py` (paren-aware wrapper for part 2) — regenerate it from this note if
lost; a line-oriented regex silently skips the multi-line call forms, which is the same failure
`_executormigrate.py` already records.

R = rename · A = add executor · P = add patron

### 4b. LESSON FROM MODULE 4 — DEPLOY ORDER PUTS A MODULE *BEFORE* ITS CALLERS

Recorded 2026-09-21. §4 justifies deploy order as *"a module's call sites live in the modules
deployed after it, so sweeping forward means every module is already fixed before anything that
calls it is touched."* **That sentence is backwards** and `05_DPTF` is where it showed.

DPTF is module 4. Its callers — ATSU, VST, SWP, OUROBOROS, LIQUID, TFT, SWPL, SWPLC, SWPU, SWPI,
MTX-SWP, RPS — are modules 7–16 and Stage 2. So when DPTF's entrypoints gained `patron`, **69
nested call sites in twelve not-yet-swept modules had no patron in scope to pass.**

Deploy order is still right (it is the dependency order, and a callee must be correct before its
callers are touched), but the consequence has to be planned for: **a module's turn includes adding
`patron` to whatever downstream functions reach it.** That is incremental, not rework — those
functions gain their `executor` at their own turn, and `_executorplan.py` reads source, so it
re-reports the truth either way.

**Measure before despairing.** The first estimate for DPTF was "12 modules, unbounded"; the actual
number was **38 enclosing functions and 76 call sites**, because a core `C_` is typically called
once, from its own Talos wrapper, which already has a patron. Two hops, not many.

**The nested calls are legitimate and must stay `C_`.** They are not the IGNIS case. ATSU binds
DPTF's return as `ico2` and concatenates it into its own cumulator, so the nested call is
**billing composition** — CLAUDE.md's shape F. Reclassifying them to `X_` would silently drop
those legs from the bill. Check the *return value* before concluding a nested `C_` is misprefixed:
IGNIS's collectors discarded it, these consume it, and that is the whole difference.

**Use the compiler as the worklist.** Threading is a transitive cascade (`XI_Issue` ← `XI_FoldedIssue`
← `C_Issue`) and a grep cannot see it — multi-line call forms defeat line-oriented matching, which
is the same failure `_executormigrate.py` already records. A loop of *compile → read the one
unbound-`patron` error → thread that function → repeat* terminates and is exhaustive.
### 4c. THE 2026-09-21 TOOL INCIDENT — AND WHY THE FIX WAS A REVERT, NOT A REPAIR

The DPTF pass was **written, compiled, and then thrown away**. What happened, because the shape
recurs:

To thread `patron` transitively I wrote a compile-read-error-edit-repeat loop. Its error parser
used `awk`'s **GNU-only** three-argument `match($0, re, arr)`. The system `awk` is mawk, which does
not have it, so `fn` was **empty from round one** — and the loop then called the call-site editor
with an empty function name, in the background, 37 files deep, for twenty minutes.

An empty name matches everywhere. The editor inserted the bare token `patron`:
into every `()` (860 sites), at the head of every multi-line `let` binding list, and before
individual bindings. Three shapes, all of them *plausible-looking text*.

**Three things went wrong, and only the third one matters.**

1. A portability bug in a throwaway script. Unavoidable-ish, cheap on its own.
2. It ran unattended, writing, in the background. **`--apply` guards the tools in `REPL/tools/`;
   a `/tmp` script has no such rule and I gave it none.**
3. **I tried to repair it by pattern.** Two reversal passes worked. The third shape was
   `patron (binding ...)`, and the discriminator I reached for — *"a line beginning with
   `patron (`"* — **also matches legitimate multi-line call arguments, which exist in HEAD in
   eight files.** A fourth pass would have corrupted real code while reporting success.

The fix was `git checkout` of every source file and a redo. That is the right call whenever the
damage class is *"parses fine, means something else"* — CLAUDE.md §formatter already records the
same conclusion for `_subdivide_repl.py`, which was fixed by a **depth guard**, not by a cleverer
regex. **A pattern that cannot distinguish damage from intent is not a repair tool.**

What survived the revert, deliberately: the two real tool fixes found along the way —
`_executormigrate.py`'s missing **name-boundary check** (`DPTF|C_SetFee` is a prefix of
`DPTF|C_SetFeeTarget`, so both rules fired and 31 call sites got two executors) and the
`_deploybundle.py` header work. Tool fixes are not source edits; they were kept on purpose.

**Rule going in: any script that rewrites sources must (a) require `--apply`, (b) refuse an empty
or unresolved target, and (c) run in the foreground where its output is read.** The redo uses the
same tools with those three properties.

| done · # | module | R | A | P | total | interface(s) to update |
|---|---|---:|---:|---:|---:|---|
| [x] 1 | `01_DALOS.pact` | 0 | 0 | 18 | **18** | `OuronetDalosV2`, `OuronetPolicyV2` |
| [x] 2 | `02_IGNIS.pact` | 0 | 1 | 5 | **6** | `IgnisCollectorV3` |
| [x] 3 | `04_BRD.pact` | 0 | 0 | 2 | **2** | `BrandingV2` |
| [x] 4 | `05_DPTF.pact` | 0 | 2 | 22 | **24** | `BrandingUsagePrimaryV2`, `DemiourgosPactTrueFungibleV2` |
| [—] 5 | `00_DPMF.pact` | — | — | — | — | **ARCHIVED**, not swept — read-only retirement, StoicSyntax 7.21 |
| [x] 6 | `06_DPOF.pact` | 0 | 1 | 20 | **21** | `DemiourgosPactOrtoFungibleV2`, `DpofUdcV2` — done, incl. `XBv_DeployAccount` |
| [x] 7 | `08_ATS.pact` | 0 | 3 | 21 | **24** | `AutostakeV3` |
| [ ] 8 | `09_TFT.pact` | 0 | 0 | 5 | **5** | `TrueFungibleTransferV2` |
| [ ] 9 | `10_ATSU.pact` | 0 | 0 | 14 | **14** | `AutostakeUsageV2` |
| [ ] 10 | `11_VST.pact` | 0 | 5 | 24 | **29** | `VestingV2` |
| [ ] 11 | `12_LIQUID.pact` | 0 | 0 | 5 | **5** | `StoaLiquidStakingV2` |
| [ ] 12 | `13_OUROBOROS.pact` | 0 | 0 | 5 | **5** | `OuroborosV2` |
| [ ] 13 | `15_SWP.pact` | 0 | 4 | 14 | **18** | `SwapperV4` |
| [ ] 14 | `16_SWPI.pact` | 0 | 0 | 1 | **1** | — |
| [ ] 15 | `18_SWPLC.pact` | 0 | 1 | 9 | **10** | `BrandingUsageSecondaryV2`, `SwapperLiquidityClientV2` |
| [ ] 16 | `19_SWPU.pact` | 0 | 0 | 4 | **4** | `SwapperUsageV3` |
| [x] — | `20_MTX-SWP.pact` | — | — | — | — | *nothing to do* |
| [ ] 17 | `21_CODEX.pact` | 0 | 0 | 5 | **5** | `CodexV2` |
| [ ] 18 | `22_PYTHIA.pact` | 0 | 0 | 9 | **9** | `PythiaLedgerV3`, `PythiaV5` |
| [ ] 19 | `01_TS01-A.pact` | 0 | 27 | 0 | **27** | `TalosStageOne_AdminV2` |
| [ ] 20 | `02_TS01-C1.pact` | 10 | 49 | 2 | **61** | `TalosStageOne_ClientOneV2` |
| [ ] 21 | `03_TS01-C2.pact` | 18 | 56 | 3 | **77** | `TalosStageOne_ClientTwoV2` |
| [ ] 22 | `04_TS01-C3.pact` | 18 | 15 | 1 | **34** | `TalosStageOne_ClientThreeV4` |
| [ ] 23 | `06_TS01-C4.pact` | 1 | 12 | 1 | **14** | `TalosStageOne_ClientFourV8` |
| [ ] 24 | `05_TS01-P.pact` | 8 | 0 | 0 | **8** | `TalosStageOne_ClientPactsV4` |
| [ ] 25 | `02_DPDC.pact` | 0 | 1 | 1 | **2** | `BrandingUsageTertiaryV2` |
| [ ] 26 | `03_DPDC-C.pact` | 0 | 0 | 2 | **2** | `DpdcCreateV2` |
| [ ] 27 | `04_DPDC-I.pact` | 0 | 1 | 0 | **1** | `DpdcIssueV2` |
| [ ] 28 | `05_DPDC-R.pact` | 0 | 0 | 11 | **11** | `DpdcRolesV2` |
| [ ] 29 | `06_DPDC-MNG.pact` | 0 | 0 | 12 | **12** | `DpdcManagementV2` |
| [ ] 30 | `07_DPDC-T.pact` | 1 | 0 | 3 | **4** | `DpdcTransferV2` |
| [ ] 31 | `08_DPDC-S.pact` | 0 | 0 | 10 | **10** | `DpdcSetsV2` |
| [ ] 32 | `09_DPDC-F.pact` | 0 | 0 | 4 | **4** | `DpdcFragmentsV2` |
| [ ] 33 | `10_DPDC-N.pact` | 0 | 0 | 8 | **8** | `DpdcNonceV2` |
| [ ] 34 | `11_EQUITY+.pact` | 1 | 0 | 1 | **2** | `EquityV2` |
| [ ] 35 | `00_Demipad.pact` | 2 | 2 | 6 | **10** | `DemiourgosLaunchpadV2` |
| [ ] 36 | `01_ANK.pact` | 0 | 0 | 2 | **2** | `AcquisitionAnchorsV1` |
| [ ] 37 | `02_SCORE.pact` | 6 | 0 | 8 | **14** | `AcquisitionScoresV1` |
| [ ] 38 | `03_AQP.pact` | 2 | 0 | 0 | **2** | `AcquisitionPoolsV1` |
| [ ] 39 | `05_FVT.pact` | 4 | 2 | 3 | **9** | `AcquisitionFarmsVaultsTreasuriesV1` |
| [ ] 40 | `06_VCT.pact` | 0 | 0 | 3 | **3** | `AcquisitionVacateV1` |
| [ ] 41 | `07_MTX-AQP.pact` | 1 | 0 | 0 | **1** | `AqpMtxV1` |
| [ ] 42 | `08_DSA.pact` | 0 | 2 | 2 | **4** | `DsaV1` |
| [ ] 43 | `01_TS02-C1.pact` | 11 | 54 | 0 | **65** | `TalosStageTwo_ClientOneV2` |
| [ ] 44 | `02_TS02-C2.pact` | 9 | 50 | 0 | **59** | `TalosStageTwo_ClientTwoV2` |
| [ ] 45 | `04_TS02-C3.pact` | 15 | 27 | 0 | **42** | `TalosStageTwo_ClientThreeV1` |
| [ ] 46 | `05_TS02-DPAD.pact` | 8 | 6 | 0 | **14** | `TalosStageTwo_DemiPadV1` |

**THE TWO CHARGING ADMIN WRAPPERS — a decision deferred so the twins move together.**
Measured 2026-09-21: of **120** Talos `A_` wrappers, exactly **two** charge a caller-supplied
patron — `DPTF|A_DeployAccount` and `DPOF|A_DeployAccount`. The other 118 are gasless, the canon
says a Talos `A_` takes no patron and supplies `GASLESS-PATRON`, and the generated price sheet
already *labels both of these* "admin entrypoint — IGNIS + STOA free by owner rule". So the
artefact and the code disagree today, and the code is the outlier 2/120.

Applying the canon makes them free. That is a PRICE GOING TO ZERO, not a refactor, and the owner
has not ruled on it — so both were left charging. **Do not fix only the DPTF one.** They are
twins; changing one mid-sweep replaces a consistent anomaly with an inconsistent one, which is
strictly worse to reason about. Raise it when module 6 comes up and move both, or neither.

**`06_DPOF` CARRIES AN UNFIXED TWIN.** DPTF's `C_DeployAccount` was reclassified to
`XB_DeployAccount` on 2026-09-21 (owner): it builds no OutputCumulator and was called by
`XIv_Issue` and `XB_DeployAccountWNE` — an `X_` reaching into a `C_`, which inverts the layering.
`06_DPOF.pact` has the **identical** pair (`C_DeployAccount` + `XB_DeployAccountWNE` calling it),
and it was deliberately NOT fixed in DPTF's pass: doing it there would leave DPOF half-swept, and
half-swept is the state that wrecked the first attempt at this refactor. Do it as part of module
6's own turn. ~16 references.

The shape to copy, and the two Talos doors that must keep their DIFFERENT policies:

```
DPOF|C_DeployAccount   self-service. Caller must own <account>, and PAYS.
DPOF|A_DeployAccount   admin only. Deploys for SOMEONE ELSE, no ownership check on the target.
```

Only the admin may deploy for another account (owner, 2026-09-21); the missing ownership check
IS that door's reason to exist, and `P|ADMINISTRATIVE-SUMMONER` is what confines it.

**Interfaces get CONTENT updates, not necessarily VERSION bumps** — most are already ahead of
mainnet. This is what dissolved the "48-interface cascade" that blocked the first attempt.

## 4.1 PATRONLESS BY DESIGN — the correction that changes what "conforming" means

**Owner correction, 2026-09-20, mid-sweep.** `patronless` and `gasless` are different things:

- **gasless** — a patron exists and is supplied as `GASLESS-PATRON`; collection runs, collects zero.
- **patronless** — **no patron is needed at all.** Adding one is wrong.

**Account deployment is patronless**: the payer is the thing being created. There, *the account
being deployed IS the executor*:

```pact
(defun C_DeploySmartAccount (executor:string guard:guard stoa:string sovereign:string public:string))
```

**The IGNIS source/collector primitives are the same** — they make virtual gas or compress it back
to its source, so they are what a patron would be paid *from*. `CLAUDE.md` already records them as
"the collectors [that] cannot collect from themselves": `C_Collect`, `C_TransferDalosFuel`, and the
`STOA|C_Collect*` family.

`_executorplan.py` now carries a `PATRONLESS` registry. **It is a set of discovered design facts,
recorded per function — never a fallback for "I could not find a patron".** When a module's turn
comes, ask whether each entrypoint *can* have a patron before assuming it must.

**EXECUTEE IS RARE.** Observably it appears only in transfer functions. Do not hunt for a third
role; if one seems to appear, read the body before promoting a parameter to third position.

## 4.2 SCOPE OF ONE MODULE'S TURN

Processing a module is **not** editing one file. It is:

1. the core module, 2. its interface, 3. its Talos wrapper(s), 4. **every downstream module that
calls it**, 5. **every REPL test that exercises it**, 6. the deploy bundle, 7. the gate.

Steps 4 and 5 are the bulk. DALOS alone reached `RedTeam`, `CONFORMANCE`, `ATS`, `LIQUID` and the
Stage-1 bootstrap. **Do it in ONE pass per module**, with intermediate commits inside that pass as
needed — not repeated partial sweeps, which is how the same call sites get revisited.

**At the end of all 46:** Audit Book 2.0 must prove the whole refactor works, is tested and is
deploy-ready, and the **deploy pipeline is rewritten**.

## 5. PROTOCOL — one module at a time

Per module, in order:

1. `python3 REPL/tools/_executorplan.py --module <F>.pact` — the list.
2. Edit the **core module**: signatures (interface declaration **and** module defun), capability
   signatures, and bodies. `patron` 1st, `executor` 2nd, `executee` 3rd.
3. Edit the **interface** content to match. No version bump unless the owner says so.
4. Edit the **Talos wrapper(s)**: `C_` passes the caller's patron; `A_` drops patron and supplies
   `GASLESS-PATRON`.
5. Add a rule to `_executormigrate.py`, run `--apply` for the call sites.
6. `python3 REPL/tools/_callarity.py --module <MOD>` — **must report zero arity mismatches.**
   This is the step that proves the FORWARD REFACTOR actually reached every caller, and nothing
   else does. **Pact checks modref call arity at RUNTIME, not at module load**, so a caller
   passing the old argument count compiles, deploys, and stays silent until something executes
   it — which means the 25,000-assertion gate covers only the call sites a test happens to run.
   Worse, an `expect-failure` ABSORBS the error: a short call partially applies, yields a
   CLOSURE, the assertion is satisfied, and the suite goes green over a broken line.
   `Kursan/dsa-grand-tour.repl` carried one for weeks, written up as a *"native error, cause not
   yet isolated"* — the cause was the arity. Gate-fatal since 2026-09-21, but run it PER MODULE
   so the failure lands while the module is still in your head.
7. `python3 REPL/tools/_deploybundle.py --write`.
8. `python3 REPL/tools/_authsurface.py --check` — must report *no entrypoint weakened*.
   Note what 6 and 8 each cover and what neither does: 6 proves the SHAPE of every call (right
   number of arguments), 8 proves no entrypoint LOST an ownership enforce. **Neither proves
   semantics** — the right account in a correctly-sized slot. That is what the suite is for, and
   it is why a module's turn still ends in a full gate rather than two clean tool runs.
9. Full gate: `python3 REPL/tools/_gate.py`. Artefact chain if it complains:
   `_suite_stats.py` → `_figuresync.py --write` → `_auditbook.py --docx`.
10. **Commit per module.**
11. **Tick the module in §4's table** — `[ ]` → `[x]`, in the same commit. The plan IS the
    progress tracker: a cold session must be able to see what is done without reading git log.
12. **Report to the owner**: *"processed module X, modified these functions, N in total, done,
    moving to next."*

### Rules that cost time when ignored
- **Never replace a derived ownership gate** — add the executor check *beside* it.
- **`executor = patron` is not a safe default.** Sovereign assets are owned by **smart accounts**
  (`Σ.` prefix); the human patron is usually the wrong answer.
- **Never read an owner eagerly in a `let`** — the entity may not exist yet, and in negative
  probes the read raises and replaces the refusal being asserted.
- **Negative probes keep plain accounts** — they must fail on the guard under test, not on arity.
- Where a guard is added, add a test that **fails without it**. A guard nothing ever fails on is
  indistinguishable from an absent one.
- **A RULE WITH THE WRONG ARITY MATCHES NOTHING.** Added 2026-09-21. `_executormigrate.scan`
  fires on `len(vals) == arity - 1`, so an off-by-one entry in `RULES` skips every call site
  while the tool reports success -- `ATS|C_Control` was entered as 7 against a real 6 and
  silently missed 16 sites. Same shape as an incomplete registry: not an error, just a rule that
  quietly does not apply. The tool now validates every rule's arity against the real signature
  and REFUSES to run if any cannot fire. Verified by corrupting one and watching it refuse.
- **An arity-PRESERVING reorder is not idempotent. Run it exactly ONCE.** Added 2026-09-21 after
  it cost most of `06_DPOF`. A pass that MOVES arguments without changing their count is a
  permutation, so applying it twice composes the permutation with itself. For a simple swap
  (`C_Mint`, `C_Burn`, `C_Transfer`) that is the IDENTITY: the second run reports *"rewrote 98
  call sites"* and silently restores the original order. It looks exactly like success.
  Arity-CHANGING passes are self-protecting — the executee group went 4 args to 5, so a second
  pass could not match it, and it survived three runs untouched.
- **When a reorder goes wrong, restore from `HEAD` — do not compose more permutations.** The
  repair "it ran twice, so run it once more" is right only if the permutation is an INVOLUTION.
  `C_Transmit`'s is a **5-cycle**, so three applications is not one, and the third run moved it
  somewhere new. Two further traps in the restore itself: match by CONTENT, not by line index
  (the file had shifted by two lines), and beware MULTI-LINE calls — a line-indexed restore
  replaced only the first line of one and truncated the form.
- **Never run a source-rewriting script unattended.** Added 2026-09-21 after the incident in §4c.
  Three properties, not one: it must (a) require `--apply`, (b) **refuse an empty or unresolved
  target** — an empty function name matches everywhere — and (c) run in the FOREGROUND where its
  output is read. The tools in `REPL/tools/` have (a) by rule; a script in `/tmp` has none of
  them unless you give them to it.
- **Do not repair a broad mechanical corruption by pattern.** If the damage is of the form
  *"parses fine, means something else"*, `git checkout` and redo. The discriminator you reach for
  will match legitimate code somewhere in 370 files, and the second pass looks like success.

---

## 6. SURFACE TO THE OWNER, DO NOT DECIDE ALONE

- **Gasless-patron permissions in Talos.** If `P|ADMINISTRATIVE-SUMMONER` does not satisfy a
  collection path, show what is missing rather than invent a capability.
- **Where `executee` exists.** Clear for transfers. Elsewhere, check the body before promoting a
  parameter to 3rd — the RENAME/ADD split already proved position alone is wrong 322 times.
- **Functions that are permissionless by design** (`C_RecomputeCapture`, `C_Sync*Anchors`) or
  guard-based (`C_OracleWrite`) — a decorative executor is worse than none; it reads as a check.

---

## 7. RESUMING COLD

```bash
python3 REPL/tools/_executorplan.py          # what is left, by module
git log --oneline | head -20                 # what was done, one commit per module
```
The worklist table above is the plan; the tool is the ground truth. If they disagree, **the tool
is right and this table is stale** — regenerate it.
