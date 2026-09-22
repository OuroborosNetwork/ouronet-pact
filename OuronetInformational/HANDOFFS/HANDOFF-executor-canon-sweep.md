# HANDOFF — THE PATRON / EXECUTOR / EXECUTEE CANON SWEEP

> **Read this first after any compaction or context loss.** It is the complete plan: the canon,
> the tooling, the worklist, the protocol, and the reference implementation. Nothing else needs to
> be reconstructed from conversation.

**PROGRESS IS TRACKED IN §4's TABLE.** Tick `[ ]` → `[x]` as part of each module's commit. A cold
session must be able to see what is done by reading this file, without reconstructing it from
`git log`. If the table and `_executorplan.py` disagree, **the tool is right** — regenerate.

**Status:** preparation complete, sweep starting at `01_DALOS`.
**302 done · 474 remaining · 46 modules · 8 swept (01_DALOS, 02_IGNIS, 04_BRD, 05_DPTF, 06_DPOF, 08_ATS, 09_TFT, 10_ATSU) · 1 archived (00_DPMF).**
(Ground truth is `python3 REPL/tools/_executorplan.py`, never this line.)

---

## 0. WHAT A MODULE'S TURN IS — the four obligations (owner, 2026-09-21)

Stated by the owner so it never has to be asked again. **A module is not done until all four
are.** Steps 1-3 are enforced by `_modulecomplete.py` + the gate; step 4 is enforced by
`_auditdelta.py --check`.

| | obligation | how it is CHECKED |
|---|---|---|
| **1** | **Process the module** — signatures, interface, Talos wrappers, bindings | `_modulecomplete.py <MOD>` checks 1-2 |
| **2** | **Forward-refactor the WHOLE codebase, including every test** | `_modulecomplete.py` check 3: every call site of this module's entrypoints *and* its Talos wrappers, RESOLVED and correct. Unresolved is a FAILURE, not a shrug |
| **3** | **Verify nothing is broken** | `_modulecomplete.py` checks 4-6 (conformance, auth surface, `Deploy/`) **and then the full gate** |
| **4** | **Record what the v2 AUDIT must re-verify** | append the module's block to `Audit/AUDIT-V2-DELTA.md`; `_auditdelta.py --check` fails if a changed module has none |

**Why 4 exists.** This sweep changes the client surface of every module, so the published audit
is re-issued as **v2**. The signature delta is GENERATED from git against the pre-sweep baseline
(`21fa54f`) — 236 entrypoints changed so far — but what an auditor actually needs is the
*judgement*: which v1 assertions are invalidated, which findings were re-framed, which new gates
need an adversarial test that did not exist before. That cannot be derived, so it is written per
module as the turn is taken, while the reasoning is still in hand. Writing it afterwards, from
memory, across 46 modules, is how an audit becomes fiction.

**The single most important v2 fact:** every adversarial call site in v1's attack register has
MOVED, because the client surface is positional. An attack that still passes without being
re-pointed is passing on an arity error rather than on the guard it names — a failure this sweep
hit six times, twice inside an `expect-failure` that looked green for weeks.

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
| [x] 8 | `09_TFT.pact` | 0 | 0 | 5 | **5** | `TrueFungibleTransferV2` — done; +`DPTF\|C_ClearDispoForeign`. **Found a live security hole**, see §4d |
| [x] 9 | `10_ATSU.pact` | 2 | 1 | 12 | **15** | `AutostakeUsageV2` — done; 2 three-role functions the plan could not see, see §4g |
| [x] 10 | `11_VST.pact` | 0 | 5 | 24 | **29** | `VestingV2` |
| [x] 11 | `12_LIQUID.pact` | 0 | 0 | 5 | **5** | `StoaLiquidStakingV2` |
| [x] 12 | `13_OUROBOROS.pact` | 0 | 0 | 5 | **5** | `OuroborosV2` |
| [x] 13 | `15_SWP.pact` | 0 | 4 | 14 | **18** | `SwapperV4` |
| [x] 14 | `16_SWPI.pact` | 0 | 0 | 1 | **1** | — |
| [x] 15 | `18_SWPLC.pact` | 0 | 1 | 9 | **10** | `BrandingUsageSecondaryV2`, `SwapperLiquidityClientV2` |
| [x] 16 | `19_SWPU.pact` | 0 | 0 | 4 | **4** | `SwapperUsageV3` |
| [x] — | `20_MTX-SWP.pact` | — | — | — | — | *nothing to do* |
| [x] 17 | `21_CODEX.pact` | 0 | 0 | 5 | **5** | `CodexV2` |
| [x] 18 | `22_PYTHIA.pact` | 0 | 0 | 9 | **9** | `PythiaLedgerV3`, `PythiaV5` |
| [x] 19 | `01_TS01-A.pact` | 0 | 27 | 0 | **27** | `TalosStageOne_AdminV2` |
| [x] 20 | `02_TS01-C1.pact` | 10 | 49 | 2 | **61** | `TalosStageOne_ClientOneV2` |
| [x] 21 | `03_TS01-C2.pact` | 18 | 56 | 3 | **77** | `TalosStageOne_ClientTwoV2` |
| [x] 22 | `04_TS01-C3.pact` | 18 | 15 | 1 | **34** | `TalosStageOne_ClientThreeV4` |
| [x] 23 | `06_TS01-C4.pact` | 1 | 12 | 1 | **14** | `TalosStageOne_ClientFourV8` |
| [x] 24 | `05_TS01-P.pact` | 8 | 0 | 0 | **8** | `TalosStageOne_ClientPactsV4` |
| [x] 25 | `02_DPDC.pact` | 0 | 1 | 1 | **2** | `BrandingUsageTertiaryV2` |
| [x] 26 | `03_DPDC-C.pact` | 0 | 0 | 2 | **2** | `DpdcCreateV2` |
| [x] 27 | `04_DPDC-I.pact` | 0 | 1 | 0 | **1** | `DpdcIssueV2` |
| [x] 28 | `05_DPDC-R.pact` | 0 | 0 | 11 | **11** | `DpdcRolesV2` |
| [x] 29 | `06_DPDC-MNG.pact` | 0 | 0 | 12 | **12** | `DpdcManagementV2` |
| [x] 30 | `07_DPDC-T.pact` | 1 | 0 | 3 | **4** | `DpdcTransferV2` — done; +10 TS02-C1/C2 wrappers reordered. See §4i |
| [x] 31 | `08_DPDC-S.pact` | 0 | 0 | 10 | **10** | `DpdcSetsV2` — done; two authorities in one module, see §4j |
| [x] 32 | `09_DPDC-F.pact` | 0 | 0 | 4 | **4** | `DpdcFragmentsV2` — done; the third repurpose of the sweep, same shape |
| [x] 33 | `10_DPDC-N.pact` | 0 | 0 | 8 | **8** | `DpdcNonceV2` — done; the DPDC family's only ROLE-gated module |
| [x] 34 | `11_EQUITY+.pact` | 1 | 0 | 1 | **2** | `EquityV2` — done; **found a module with NO ownership check at all**, see §4m |
| [x] 35 | `00_Demipad.pact` | 2 | 2 | 6 | **10** | `DemiourgosLaunchpadV2` — done; 4 admin ops gained an enforced executor. See §4n |
| [x] 36 | `01_ANK.pact` | 0 | 0 | 2 | **2** | `AcquisitionAnchorsV1` — done; **found an unowned revoke**, and the binder had to go BELOW the liveness gate |
| [x] 37 | `02_SCORE.pact` | 6 | 0 | 8 | **14** | `AcquisitionScoresV1` — done; **eight dead bindings of the same 4g expression**. See §4p |
| [x] 38 | `03_AQP.pact` | 2 | 0 | 0 | **2** | `AcquisitionPoolsV1` — done; two EXECUTORLESS repairs, executee renamed. §4q |
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

### 4d. LESSON FROM MODULE 8 — THE CANON FINDS BUGS, AND A GREEN TEST CAN BE THE BUG

`TFT::C_ClearDispo` took `(patron account)` and its capability enforced ownership of **nobody**.
Anyone could clear anyone's dispo — which force-converts the subject's Elite-Auryn at **2.5x** the
debt and burns it. It had been that way since the function was written.

**A test was driving the attack and passing.** `modules/DPTF.repl` `<<DPTF-G10>>` called
`DPTF|C_ClearDispo KST.ANHD KST.EMMA` — one signature, two accounts — and asserted the refusal
`"Cannot Debit DPTF"`. That refusal is EMMA's empty Elite-Auryn balance, not a gate. Fund the
victim and the attack works. The assertion was true; its subject was a hole.

Three things to carry into every remaining module:

1. **The question "who is the executor?" is a BUG-FINDING question, not a naming question.** No
   static tool found this and none could: `_authsurface.py` reports what an entrypoint enforces,
   never what it *should*. The canon found it because assigning the role forces you to answer
   "whose ownership proves this?" — and here there was no answer.
2. **When the plan says RENAME and the capability disagrees, the capability wins.**
   `_executorplan.py` classified `account` as the executor; the caps proved it was the subject.
   **Read the capability chain for every entrypoint before trusting the classification.**
3. **A refusal that comes from a BALANCE is not a gate.** When an `expect-failure` passes, check
   *which layer* refused. "It failed" and "it was refused by the guard I am testing" are different
   claims, and only the second is worth an assertion.

**When you find one: surface it, do not fix it silently.** This one went to the owner and came back
with a design (the self/foreign pair, now canon in StoicSyntax §2.2) that is better than what I
would have shipped.

### 4e. PROVISIONAL PATRON SLOTS — the intermediate state, and how not to lose it

When a swept entrypoint gains `patron`, its callers must supply one — and some callers live in
modules whose own turn has not come, so they have no `patron` to pass. The rule:

- **Never invent a placeholder.** Pass the account that actually initiates the operation, which is
  a convention the codebase already used (`ORBR::C_Compress` passes `client` into `DPTF::C_Burn`'s
  patron slot).
- **Write every one of them down** — in the migration script's registry AND in the audit delta.
  A provisional slot is invisible in the diff once it parses; the only thing that stops it going
  stale is a list.
- **The migration script must FAIL CLOSED** on a call site whose enclosing function has no patron
  and no registry entry — report and refuse, never substitute a default. That is how TFT's 13 were
  *found* rather than guessed at: the script listed exactly the sites it could not resolve, and
  each got a decision. A script that silently picked something would have produced the same green
  gate and thirteen unreviewed choices.

TFT's 14 sites (13 functions, 5 modules — ATSU, OUROBOROS, SWPLC, AQP, VCT) are listed in the
`09_TFT` block of `Audit/AUDIT-V2-DELTA.md`. Each is re-pointed at that module's turn.

### 4f. THE ATTRIBUTION RULE — why the executor is unconditional (owner, 2026-09-21)

The owner stated the principle behind the whole canon, and it reframes what the sweep is *for*:

> every `C_` or `A_` function must have an executor no matter what — that is the Ouronet account
> doing the execution. Making every function have one, we can clearly see which account triggered
> the execution.

So the executor is not an authorisation device. It is an **attribution** device, and it is
**orthogonal to every other check**: an op may also need ownership of other accounts, a raw guard,
a keyset, a `GOV|*_ADMIN` — none of those removes the need to name an executor, because none of
them says *who*. A key says the act was permitted; several people may hold it.

Two consequences to carry into every remaining module:

1. **Admins are users.** `A_` and `C_` are named for Admin and Client. An admin must supply an
   Ouronet account like anyone else. The only door that needs no account is **direct module
   governance**, which is outside the canon and is meant to be the escape hatch.
2. **An unenforced executor is WORSE than none.** A parameter nobody checks is one the caller
   picks freely — so the emitted event names whoever they typed. A missing executor is visibly
   missing; a decorative one looks like attribution and is not.

(2) is now checked: **`_executorenforced.py`, wired as `_modulecomplete.py` check 7.** Every
executor must be proven directly, forwarded to a module that proves it, or reached by an indirect
route **named in the function's own `@doc`**. Its first run over the seven swept modules found
**three** decorative executors in DPTF's treasury admin ops and **one `@doc` that claimed a route
it did not state** — mine, written the same day. Do not trust a route you have not grepped for.

**Account creation is the BASE CASE, not an exception** (owner, same day). It looks like the one
place the rule must break — if the new account were the executee, who is the executor? It does not
break: **the account being created IS the executor and proves itself**, because the guard it will
be governed by is supplied in the call and enforced by `UEV_Any` (enforce-ONE) *before* every other
check in `DALOS|C>DEPLOY-*-OURONET-ACCOUNT`. Same proof `UEV_StandardAccOwn` performs on an
existing account, same key; the guard travels with the call because at creation there is nowhere
else it could come from. The list's second element, `(create-capability-guard (GOV))`, is the
governance door written into the capability — which is how genesis makes the first one.

That fact was **unpinned** until it was checked. It is now `<<DALOS-G4b>>`, which also proves the
guard check runs FIRST by pairing a held guard (format refusal) against an unheld one (guard
refusal). **Generalise the habit**: when a canon claim rests on a specific line of code, grep for
the test that holds that line still. Twice in this programme the line was right and the test did
not exist.

Full statement: `StoicSyntax-Prefixes.md` §2.2, *"WHY THE EXECUTOR IS UNCONDITIONAL"* and its
*"base case"* subsection.

### 4g. LESSON FROM MODULE 9 — "AUTHORITY PROVEN, ACTOR UNRECORDED" IS A RECURRING SHAPE

Third instance in three modules, so it is a shape and not a coincidence:

| module | entrypoint | what the capability proved | who was named |
|---|---|---|---|
| 05_DPTF | `A_WipeTreasuryDebt` + 2 | `GOV\|DPTF_ADMIN` | nobody — executor decorative |
| 09_TFT | `C_ClearDispo` | nothing at all | nobody |
| 10_ATSU | `C_WithdrawRoyalties`, `C_Syphon` | `CAP_Owner ats` — the POOL OWNER | the RECIPIENT |

**How to spot it fast.** Read the capability for an ownership call whose argument is *derived*
(`(UR_OwnerKonto ats)`, `(UR_Konto id)`) rather than a parameter the entrypoint took. If the
enforcement is on a derived account, the ACTING account is not in the signature — and the
parameter that looks like an actor is usually the recipient. The fix is the same every time:
name the executor, bind it with `UEV_ExecutorIs*`, demote the old parameter to `executee`.

**And it fools tools, not just readers.** `_executorenforced.py` PASSED `ATSU::C_KickStart`
because `CAP_Owner` appeared somewhere in a capability that also received `executor` — two
arguments away from anything that proved it. It is now position-aware: it finds which capability
PARAMETER the executor landed in and requires the enforcement to be on THAT name, re-mapping the
position at each `compose-capability` hop. Re-run after the change, it immediately found both
KickStart variants.

### 4l. LESSON FROM MODULE 33 — ROLE-GATED IS NOT OWNER-GATED, AND IT CHANGES THE ANSWER

Five DPDC modules in a row needed a binder because their authority was `DPDC::CAP_Owner id son` —
an enforce on a DERIVED account (§4g). `10_DPDC-N` needed none, and the distinction is worth
carrying forward because it is the first clean example of the *other* answer:

| gating | where the actor is | what the sweep does |
|---|---|---|
| **ownership** of a derived entity (`CAP_Owner`) | nowhere — it is read from a table | ADD an executor, BIND it |
| **a role held by an account** (`UEV_Role*ON account`) + `CAP_EnforceAccountOwnership account` | it is already a parameter | RENAME |

The tell is that a role can be **delegated**: an owner grants the update role and stops being the
actor, so the actor *has* to be named. Where authority is ownership of the entity, naming it is
redundant to the check and that is precisely why nobody wrote it down.

**And check the parameter SHAPE, not the name list.** Four Talos aliases — `C_Remove*NonceScore` —
delegate to a `C_Update*` sibling and were missed by a pass keyed on the names known to be
changing. Their delegation is arity-preserving, so `_callarity` (including the same-module pass
built one module earlier) could not object. Grepping for the OLD parameter shape
`(patron:string id:string account:string` found them in one line. *A signature change must reach
every place the name is written, and "the names I listed" is narrower than that.*

---

### 4q. LESSON FROM MODULE 38 — SOMETIMES THE ANSWER IS NO EXECUTOR

`03_AQP`'s two anchor-sync repairs got **no executor**, and that is the finding rather than a gap.
The test that settles it, in order:

1. **Is any account on the path ownership-checked?** If not, ask why before adding one.
2. **Is the op idempotent truth-restoration?** These recompute promile from actual balances — every
   outcome is the correct one.
3. **Who pays?** The patron. A caller can only make someone else's data correct at their own cost.
4. **Would a signature requirement remove a legitimate path?** Yes: the party who NOTICES stale
   anchors is usually whoever issued them, not the beneficiary.

All four → **EXECUTORLESS, and the account in the signature is an EXECUTEE.** Registered beside
`DALOS|C_UpdateEliteAccount`, which reached the same conclusion first.

**And a warning about the rename itself.** The first pass renamed `beneficiary-id` → `executee`
across the WHOLE of `04_TS02-C3.pact` — 80 occurrences, most in **stake** wrappers belonging to
module 45's turn. `beneficiary-id` means one thing in a repair and another in a stake; a file-wide
`re.sub` cannot tell them apart. Reverted (`git show HEAD:<path> > <path>`, never `checkout`) and
redone scoped: **15 edits, not 80.** A rename is only safe inside the extent you have actually
reasoned about.

---

### 4p. LESSON FROM MODULE 37 — DEAD BINDINGS ARE WHERE 4g LEFT ITS FINGERPRINTS

`02_SCORE` had **eight dead `let` bindings of the same expression** —
`(owner-konto (UR_SCR|ScoreOwnerKonto score-id))` — one in each of the eight entrypoints whose
capability enforces ownership of exactly that derived account.

**That is §4g seen from the inside.** The derived actor is so obviously the subject of the
operation that somebody bound it by reflex; the signature had nowhere to put it, so the binding
went nowhere. Worth treating as a *search heuristic* for the modules still to come: run
`_deadbind --all` on the module first, and a repeated dead read of an owner/authority is a strong
prior that the entrypoints above it are §4g and need a binder.

**Two further traps this module produced:**

* **Removing the last binding deletes the `let`.** Four of the eight bound nothing else, so the
  deletion left `(let ( ) …)` — a LOAD error (`Expected: ['(']`), 55 suites BROKEN, zero
  assertions. A dead-binding removal is a *restructure* when it is the last binding, and the
  difference only shows at load.
* **A proof the matcher cannot see is still a proof.** `SCR|C>ISSUE-TRIPLET` binds
  `(= executor owner-konto)` and enforces ownership of `owner-konto`. `_executorenforced` looks
  for the enforce applied to `executor` and reported UNPROVEN. Register it as INDIRECT — do NOT
  add a second enforce to satisfy a tool.

---

### 4o. LESSON FROM MODULE 36 — A BINDER IS A READ, AND A READ CAN PRE-EMPT A REFUSAL

`C_RevokeAnchor`'s binder resolves the anchored asset **out of the anchor row**. Placed in the
defun body, ahead of the capability, it turns a clean *"anchor must be alive"* refusal into a raw
`No value found in table …` on every non-existent anchor — replacing exactly the message
`[6.2.10] <<TX-AQP-NEG-OWNER2>>` was rewritten to pin.

So: **put the binder where the entity is already known to exist.** Inside the capability, after the
liveness/existence guard. The rules list has said *"never read an owner eagerly"* since module 9;
module 36 is the first time a named test would have caught the violation, and it is worth knowing
that the test existed only because an earlier round had already fixed the same class of problem in
`UR_ANK|State`.

**Second half, and it cost the gate run:** the first pass wrote `patron` into all 18 fixture
executor slots. The anchored asset there is `OURO`, owned by a `Σ.` SMART account — so every
positive revoke failed the binder and eleven suites went BROKEN. Fixtures must read the authority
with the **same expression the binder evaluates**; anything else is a second answer that can
disagree. `executor = patron` is not a safe default, and the rules list says so.

---

### 4n. LESSON FROM MODULE 35 — THE IMPLEMENTATION IS THE LAST MATCH, NEVER THE FIRST

Every sovereign module in this tree carries its **interface inline at the top of the same file**.
So a regex anchored on `(defun NAME` finds the STUB, and `re.search` returns it. This has now cost
edits in five separate modules, and module 35 produced two more in one pass.

The instance worth remembering is *why it was not obvious*: `C_TransmitSemiFungibles`'s stub ends
in a **trailing space** and `C_TransmitNonFungibles`'s does not. The same regex therefore matched
the BODY for one and the STUB for the other — two adjacent functions, one edit, opposite outcomes,
and nothing in the diff to show it.

**Rule: take `hits[-1]`.** `_ignis_price_sheet.defun_body` has always done this. Every scoped edit
from here on does too. And verify with `_modulecomplete` check 2 (interface declarations match
their module defuns), which catches the whole class in one line — `_callarity` only catches the
subset where the arity also changed.

**Corollary for the admin band.** When an admin op gains an enforced executor, the test must show
the two gates are DIFFERENT, not that one of them exists:

* admin signs, names someone else  → the **executor** gate refuses
* non-admin signs, names herself   → the executor gate passes and the **admin** gate refuses

Both produce "Keyset failure", so each assertion has to name the KEY it expects. Without that, one
assertion proves whichever gate happens to fire first and the other proves nothing.

---

### 4m. LESSON FROM MODULE 34 — RUN THE GUARD TEST WITHOUT THE GUARD

`11_EQUITY+` has **no ownership check of its own** — zero `CAP_EnforceAccountOwnership`, zero
`CAP_Owner` — so the turn added one and wrote a test for it. Both the `@doc` and the test comment
said the guard closed a hole.

**It does not, and only running the test with the guard disabled showed that.** The named creator
was already reached, three modules away and two writes later, by
`DPDC-C::C_CreateNewNonces`'s enforce on the derived `(UR_Verum5 id son)` — which on a freshly
issued collection *is* the creator. Of the two new assertions, one passed unchanged without the
guard and one failed; only the second discriminates.

Two rules, both already in this file, and this is what they look like when they bite:

* **"Where a guard is added, add a test that fails without it."** Not "a test that passes with it".
  The difference is one experiment and it is the whole point.
* **Install the fixture's funding signatures before measuring.** The first run without the guard
  died on `Managed capability not installed: (coin.TRANSFER …)` — a FUNDING signal that looked
  like the guard working. Only with the coin caps installed could the real answer surface.

Keep the non-discriminating assertion; relabel it. It pins a property worth pinning, and saying
which assertion depends on the guard is what stops the next reader assuming both do.

---

### 4k. THE REPURPOSE SHAPE, THIRD SIGHTING — AND WHAT A TEST COMMENT KNEW FIRST

Three modules have now produced the same shape: `11_VST`, `07_DPDC-T`, `09_DPDC-F`. Recognise it
by three things together —

1. an entrypoint whose leading account **loses** something (`repurpose-from`, `account`, `sender`);
2. an `@event` capability that validates shapes and **proves no account at all**;
3. an ownership enforce several hops downstream whose argument is **derived**, not a parameter.

When all three hold, the leading account is the **executee** and the executor has to be added and
bound. When only (1) and (3) hold but the derived account IS the leading one, it is a rename.

**`[6.1.2]_DPDC-FRAGMENTS.repl` had written this down before the canon had a name for it:**
*"`DPDC-F|C>REPURPOSE` only checks list-length; the real gate is `CAP_Owner`, downstream in the
wipe-mode debit leg."* That sentence is §4g exactly, sitting in a test banner for two weeks. Worth
remembering in both directions: the shape is findable by reading, and a comment that describes a
gap is not the same as a check that closes it.

---

### 4j. LESSON FROM MODULE 31 — ONE MODULE, TWO AUTHORITIES, AND THE LINE BETWEEN THEM

`08_DPDC-S` has ten entrypoints and **two different answers** to "who is the executor":

* **Four** — `C_MakeSemiFungibleSet`, `CC_BreakSemiFungibleSet`, `C_MakeNonFungibleSet`,
  `C_BreakNonFungibleSet` — are acts on a **holding**. The account assembling or dissolving a set
  signs for itself, and the proof is FORWARDED: the first leg hands it to `DPDC-T::C_Transfer`,
  whose capability opens on `CAP_EnforceAccountOwnership sender`. `DPDC-S|C>MAKE` and `C>BREAK`
  prove **no account at all** — they check shape and state only.
* **Six** — the three `C_Define*Set` variants, `C_EnableSetClassFragmentation`, `C_ToggleSet`,
  `C_RenameSet` — are acts on the **definition**. They reach `DPDC::CAP_Owner id son`, ownership
  of the DERIVED collection owner: §4g, needing a binder.

**The collection owner has no say in whether a holder assembles a set, and a holder has no say in
what a set IS.** That is the line, and it is not visible in the signatures: before this turn all
ten took an untyped leading `account` or `id` and neither shape told you which rule applied.

Two things follow for the remaining modules:

1. **"Which capability does it open?" is not the question — "what does that capability prove?"
   is.** `DPDC-S|C>MAKE` looks like an authorisation gate and is not one; it is a validator, and
   the authorisation happens a module away.
2. **A module-wide answer is a guess.** `05_DPDC-R` genuinely has one authority for all eleven
   entrypoints; `08_DPDC-S` has two for ten. Deciding per module rather than per entrypoint would
   have been right once and wrong once, with no local signal that anything was wrong.

The binder helper is now spelled `UEV_ExecutorIsCollectionOwner` in all three DPDC modules that
have one (`05_DPDC-R` was `UEV_ExecutorIsOwnerKontoLocal` and was renamed). Three names for one
check in one family is three greps.

---

### 4i. LESSON FROM MODULE 30 — A HAND-MAINTAINED LIST HID SIX SITES FOR A DAY

`_patronslots.py` exists to make the one invisible thing in this refactor visible: a caller whose
module has not had its turn, passing the initiating account where a `patron` will eventually go.
Arity is correct, the value is unused by every swept callee, and no assertion can reach it — the
registry is the only thing that remembers.

It kept a **hand-written `SWEPT` dict** of which callees already take a `patron`, and a callee not
in that dict was never even looked at. 06_DPDC-MNG's turn (2026-09-21) gave twelve entrypoints a
`patron` and did not add the module to the dict. Consequence: **four** provisional slots in
`11_EQUITY+` (`XI_ConvertPackageShares` and `XI_MakePackageShares` → `C_AddQuantity`,
`XI_BreakPackageShares` and `XI_ConvertPackageShares` → `C_BurnSFT`) were invisible to the one
tool whose entire purpose is to see them. They surfaced only because module 30 happened to touch
the same three functions.

`SWEPT` is now **derived from the source** — a function has been swept iff its first parameter is
literally `patron`, which is the canon and is written in the file. That derivation immediately
found **two more** the dict had never covered: `04_TS01-C3::SWP|C_Firestarter`'s two inner calls,
permanent rather than provisional because that entrypoint is PATRONLESS by design. Registered
count went 25 → 48.

**This is the FIFTH tool in this programme caught carrying a hardcoded list that could not report
its own incompleteness** (`_toolpaths`, `_bandplan`, `_executorplan`'s ACCT vocabulary,
`_executorenforced`'s `SWEPT`, now `_patronslots`'s `SWEPT`). The pattern is stable enough to
state as a rule: **if a tool's correctness depends on a list of things that changes as the work
proceeds, derive the list or the tool will quietly stop applying.**

---

### 4h. TWO THINGS THAT COST A GATE RUN EACH, AND THE CHECKS THAT NOW CATCH THEM

1. **A malformed `@doc` string continuation is a LOAD error.** Appending to an existing `@doc` by
   naive concatenation produces `… text.            \ \` on one line; `\ ` is not a valid escape,
   the module does not compile, and **86 suites report BROKEN with zero assertions** — which looks
   nothing like a test failure. It happened TWICE on 2026-09-21 (DALOS, then ATSU) and
   `_modulecomplete.py` reported **7/7 on a file that could not load**. Now:
   `REPL/tools/_docstrings.py`, wired FIRST in the gate because it is the cheapest check there and
   it guards the one failure that makes every other check meaningless. **When appending to a
   `@doc`, the join is `. \` + newline — never bare concatenation.**
2. **A rename that adds enforcement is invisible to an arity check.** `CC_RemoveSecondary` went
   `(patron remover …)` → `(patron executor …)`: same arity, same positions, so `_callarity.py`
   saw nothing and the call-site migration correctly skipped it. But position 1 went from an
   unread label to a bound executor, and one fixture had been passing a different account there
   for as long as it existed. Only the full suite caught it. **When a sweep turns a decorative
   parameter into an enforced one, review its call sites by hand.**

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
6. **`python3 REPL/tools/_modulecomplete.py <MOD>` — the turn is not finished until this is
   6/6.** It is the whole of 4.2 as a checklist, and it exists because "I believe it is done"
   is not a result anyone can audit. Six obligations: every entrypoint DONE in the plan; every
   interface declaration matching its module defun TEXT for text; every call site of this
   module's entrypoints AND its Talos wrappers resolved and correct; conformance; auth surface;
   `Deploy/` fresh.

   **Check 3 is the one that matters.** `_callarity` reporting *"no arity mismatches"* is NOT
   the same as *"everything was checked"* — a call site it could not RESOLVE is silence, not a
   pass. For the module under test, unresolved is a FAILURE. Writing this check found a stale
   3-arg call to a 5-arg DPTF entrypoint that had been sitting inside an `expect-failure`,
   green for the wrong reason, through two full gate runs.

   Writing it also reproduced **§3's own bug verbatim**: `ENTRY.match(r'...|\|(A|AA|C|CC)_')`
   anchors at position 0, so the `|`-alternative can only fire on a name starting with a bar —
   every `ENTITY|C_Fn` Talos wrapper invisible. The first version verified 55 call sites for
   ATS; with `.search` it verified 1,060. If a count looks small, it IS small.

7. `python3 REPL/tools/_callarity.py --module <MOD>` — **must report zero arity mismatches.**
   This is the step that proves the FORWARD REFACTOR actually reached every caller, and nothing
   else does. **Pact checks modref call arity at RUNTIME, not at module load**, so a caller
   passing the old argument count compiles, deploys, and stays silent until something executes
   it — which means the 25,000-assertion gate covers only the call sites a test happens to run.
   Worse, an `expect-failure` ABSORBS the error: a short call partially applies, yields a
   CLOSURE, the assertion is satisfied, and the suite goes green over a broken line.
   `Kursan/dsa-grand-tour.repl` carried one for weeks, written up as a *"native error, cause not
   yet isolated"* — the cause was the arity. Gate-fatal since 2026-09-21, but run it PER MODULE
   so the failure lands while the module is still in your head.
8. `python3 REPL/tools/_deploybundle.py --write`.
9. `python3 REPL/tools/_authsurface.py --check` — must report *no entrypoint weakened*.
   Note what 6 and 8 each cover and what neither does: 6 proves the SHAPE of every call (right
   number of arguments), 8 proves no entrypoint LOST an ownership enforce. **Neither proves
   semantics** — the right account in a correctly-sized slot. That is what the suite is for, and
   it is why a module's turn still ends in a full gate rather than two clean tool runs.
10. **Write the delta block and tick §4 BEFORE the gate, not after.** Both feed
    `_auditbook.py`, and the book is gate-checked, so doing them afterwards buys a second
    five-minute run for nothing. Order: delta → tick → `_auditdelta.py --check` →
    `_auditbook.py --docx` → gate → commit.
11. **IF THE MODULE ADDED ANY ASSERTION, SYNC THE FIGURES FIRST — there is a THREE-WAY CIRCULAR
    DEPENDENCY here and it cost three extra gate runs on 2026-09-21.** The gate fails when an
    audit document quotes a figure `REPL_SUITE_STATS.md` does not support; the stats file is
    refreshed by `_suite_stats.py --gate`; and **that tool REFUSES to generate from a failed gate
    run**. So a stale figure deadlocks: the gate will not pass until the stats move, and the
    stats will not move until the gate passes. Break it at the DOCUMENT, which is the only link
    in the cycle you can edit directly:

        1. edit the stale figure in Audit/records/REPL-ROUND-REPORT.md to match the CURRENT
           stats file (not to what you think the new number will be)
        2. cd REPL && python3 tools/_suite_stats.py --gate     # now permitted; writes the live count
        3. carry the new numbers back into the report -- there are FOUR coupled rows, and the
           gate reports them a batch at a time, so fix all four at once: distinct written,
           executed per run, positive, negative
        4. python3 REPL/tools/_figuresync.py                   # must say clean
        5. _auditbook.py --docx, then the gate

    Adding two assertions to one Kursan harness moved all four. The arithmetic is a useful
    check on yourself: executed went 25,629 -> 25,631, exactly the two added, which is the
    evidence that nothing else in the suite changed behaviour.
12. Full gate: `python3 REPL/tools/_gate.py`. **Never pipe it to `tail` without `pipefail`** —
    the pipeline's exit status is `tail`'s, so a run printing `GATE FAILED` exits 0 and reads as
    a pass. (`sys.exit("msg")` in the gate exits 1; the 0 was the pipe.)
13. **Commit per module**, with the delta block and the §4 tick in the SAME commit. The plan IS
    the progress tracker: a cold session must be able to see what is done without reading git log.
14. **Report to the owner**: *"processed module X, modified these functions, N in total, done,
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
