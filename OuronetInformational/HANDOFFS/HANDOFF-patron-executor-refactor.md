# The patron / executor refactor — plan

**Status:** planned, not started. Owner-settled canon, 2026-09-20.

## The canon being established

1. **Every `C_` and `A_` names TWO accounts: a `patron` and an `executor`.**
   The patron pays IGNIS. The executor is the account whose tokens move, or whose ownership
   authorises the action. They are different roles and must be different parameters even when a
   caller passes the same value for both.
2. **The executor must be enforced — directly, or provably indirectly.**
   "It is checked deeper down" is only acceptable if a tool can DEMONSTRATE the path. Otherwise the
   enforce is added at the entrypoint.
3. **`A_` functions are ADMINISTRATIVE and GASLESS. `C_` functions collect gas.**
   That is the difference between the two prefixes in a sovereign module. An `A_` still HAS a
   patron — the hardcoded gasless one (`DALOS|SC_NAME`, the single account `IGNIS::C_Collect`
   exempts) — so gasless is a *patron choice*, not an absence. Where the answer is always gasless,
   it need not be a parameter; it is an internal constant with a comment saying so.

`A_OuroMinterStageOne` is the worked example of (3): the daily emission is administrative, and it
is already gasless.

## NOT an executor: counterparty consent

A transfer into a SMART account with `method = true` additionally requires the RECEIVER's
ownership. That is consent, not execution — the sender is still the sole executor. It lives in the
shared engines (`09_TFT.pact:414`, plus `06_DPOF`, `00_DPMF`, `07_DPDC-T`), so every transfer path
inherits it. Consequence already load-bearing in the design: a BULK transfer cannot include a smart
account in its receiver list, because consent cannot be expressed per-receiver in a list. A MULTI
transfer (many tokens, one receiver) can, because the receiver is unique.

Do not rename consent into an executor.

## Measured scope (2026-09-20)

    C_/A_ entrypoints in sovereign modules            357
    ... taking `patron` today                          89
        executor DERIVED from the entity, never named  72   <- band 1
        executor ALREADY a named parameter             16   <- band 2
        patron IS the executor (conflated)              1   + the inject/collect family
    A_ functions with NO patron                        78   <- band 3
    P|A_ policy wiring (deploy-time, separate class)  156
    call sites across REPL + citizen                ~7,500 in 218 files

## STEP 0 — DONE (2026-09-20). `REPL/tools/_authsurface.py`

Built, wired into `_gate.py` as fatal, baseline committed as
`OuronetInformational/ARCHITECTURE/AUTH-SURFACE.md` — **1,104 entrypoints, 714 reaching an
ownership enforce**. As far as anyone can tell this is the first time the system's authorisation
surface has been written down.

**It was validated against its own failure modes before being trusted**, and three of its first
three answers were wrong:

1. *Bare-name resolution* followed `C_Transfer` into all six modules that define it and unioned
   everything they reach — **342 of 841 entrypoints came out with an IDENTICAL 7-target set**. An
   analyser saying everything touches everything cannot tell you when something stops. Fixed by
   resolving calls through the let-bound modrefs to a specific file.
2. *Rows keyed by name alone* collapsed **1,104 entrypoints into 841** — only the last
   `C_Transfer` survived, so a regression in any of the other five would have been invisible to
   `--check`. Now keyed `module::entrypoint`.
3. *Comment blindness* — an early pass reported an account called `below`, which was the words
   "real CAP_EnforceAccountOwnership below" inside a `@doc`.

And the test that matters: removing ONE enforce from `09_TFT.pact` correctly reported four
dependent entrypoints as WEAKENED. A baseline tool that cannot fail is decoration.

**A useful property for Band 3:** `UEV_InjectContext` only checks that the patron EXISTS. The real
ownership check is TFT enforcing `CAP_EnforceAccountOwnership sender` on the custody transfer. So
renaming that account to `injector` keeps ownership enforced on the right account, and the auth
surface should come out UNCHANGED — which is itself a strong assertion about the change.

## STEP 0 (original plan text follows)

**`REPL/tools/_authsurface.py`.** For every `C_`/`A_`, emit the set of accounts whose ownership is
enforced anywhere in its call tree, TRANSITIVELY. Commit that as a baseline artefact and diff it in
`_gate.py`, exactly like `_pricesync` and `_figuresync`.

The invariant the refactor must satisfy:

> For every entrypoint, the set of enforced ownership targets after the change is a SUPERSET of the
> baseline. The refactor may ADD the executor check. It may never REMOVE a derived one.

This is not optional tooling. The refactor's failure mode is adding `executor`, enforcing it, and
dropping the derived check — a diff that reads as a tidy improvement and is an authorisation hole.
Across 72 functions that is 72 chances, and the tests would stay green because the caller passing
the right account is the normal case.

**The analyser MUST be transitive.** A first scan for this plan stopped at each entrypoint's own
defcap and reported "2 of 357 transfers require receiver consent". The true answer is "all of
them" — the check lives in the shared TFT engine one level further down. A non-transitive analyser
would bless the removal of every check it cannot see.

## Bands, in order

### Band 3 — the exact surface (mapped 2026-09-20, script staged)

    RPS   XI_FvtInjectCore              +injector   custody transfer IN   (04_RPS.pact:4395)
    RPS   XE_XI_FvtInjectCore           +injector   x2 (interface decl + impl)
    RPS   XIv_FvtAddStream              +injector   stream custody        (:4444)
    RPS   XE_XI_FvtAddStream            +injector   x2
    RPS   XI_TransferRewardDptfFromVault +collector payout transfer OUT   (:3422)
    RPS   XE_XI_TransferRewardDptfFromVault +collector x2
    FVT   XB_FvtInject / CC_Inject / CC_InjectStream / CC_InjectFinalize  +injector
    FVT   CC_Collect                                                     +collector
    TALOS 4 AQP-FVT| wrappers                                            pass-through
    CALL SITES  142 across REPL + 2_CITIZEN

**Every edit is FUNCTION-SCOPED with an expected count.** The first draft replaced the two
signatures globally. Counting first showed the collect signature appears TEN times in 04_RPS.pact
and the inject signature FOUR -- the others being read-only cost readers
(`URC_CollectClaimableRewards`, `URCi_InjectFull`, `URC_CollectTransferLegIgnis`) and bookkeeping
(`*BookCollectUnclaimed`). A blanket replace would have handed eight extra functions a parameter
they have no use for, AND THE TREE WOULD STILL HAVE COMPILED. The script aborts if any function
changes a different number of definitions than expected.

**Band 3 first — inject / collect.** The only band that is a BEHAVIOURAL defect rather than
legibility: `XI_FvtInjectCore` does `C_Transfer token patron AQP|SC_NAME`, so the gas payer IS the
injector, and collect pays rewards TO the patron. Nobody can sponsor anyone's stake or collect.
~5 entrypoints (`CC_Inject`, `CC_InjectStream`, `CCp_InjectFixChunk`, `CC_InjectFinalize`,
`CC_Collect`), ~27 definitions, ~40 REPL files. Unblocks `A_OuroMinterStageTwo` into its intended
shape — dispenser as executor, gasless patron paying.

### Band 1 batching order — smallest module first (measured 2026-09-20)

    02_IGNIS        1      05_TS02-DPAD     1      07_MTX-AQP      2
    05_DPTF         1      15_SWP           3      02_SCORE        3
    08_ATS          1      00_Demipad       4      01_ANK          4
    11_VST          5      03_AQP           5      08_DSA          9
    05_FVT         16
                                                   TOTAL          55

Gate after EVERY module, never batch two. Smallest first is deliberate: the first three modules
carry one function each, so the very first gate run exercises the whole pipeline -- edit, auth
surface, assertion count, deploy bundle -- against a change small enough to read in full. If
anything about the method is wrong, it is wrong on a one-function diff rather than on 05_FVT's
sixteen.

Revised band sizes after following the capability chain properly: **B1 = 55, B2 = 33, B3 = 1**
(plus the inject/collect family, which is B3 in substance -- the patron IS the money account there,
it just does not show up as a `CAP_EnforceAccountOwnership patron`, because the enforce happens
indirectly inside TFT).

**Band 2 — the 16 already compliant.** Rename their account parameter to `executor`. No behaviour
change; the auth surface must be byte-identical. Cheap, and it establishes the vocabulary.

**Band 1 — the 72, ONE MODULE AT A TIME.** Add `executor`, enforce its ownership, AND enforce that
it equals the derived owner. Gate after each module. Never batch modules.

**Band 4 — the 78 patronless `A_`.** Give each the gasless patron. Decide per function whether it
is a parameter or an internal constant; `A_DeploySmartAccount` and `A_ToggleGAP` are not obviously
the same kind of thing, so a uniform sweep is the wrong instinct here.

## Band 3 — the tests that PROVE the separation (not just that it compiles)

The 142-site migration passes each call's patron into the executor slot, so afterwards every test
still runs with patron == executor. That proves nothing broke; it does NOT prove the separation
works, and a parameter that is never varied is exactly the defect
`CC_Step14_OpenCustodiansAgency` shipped with (an `operator-konto` that could only ever equal
`patron`, passing because both were `KST.ANHD`).

So Band 3 is not done until at least one test per direction passes DIFFERENT accounts. The
fixtures for this already exist -- collects run today under four distinct accounts
(`anhd` 21 sites, `emma` 14, `lumy` 7), and `Kursan/dsa-fee-tests.repl` has two delegators
collecting from one agency:

    SPONSORED COLLECT   (AQP-FVT|CC_Collect  anhd emma  fvt ...)
        ANHD pays the IGNIS, EMMA receives the rewards. Must succeed, and EMMA's balance --
        not ANHD's -- must rise. Today this is impossible to express at all.

    SPONSORED INJECT    (AQP-FVT|CC_Inject   anhd emma  fvt ouro amt)
        ANHD pays the IGNIS, the tokens leave EMMA. EMMA's balance must fall, ANHD's must not.

    NEGATIVE            the executor must still be the one who signs. With EMMA as executor and
        only ANHD signed, the call must fail INSIDE TFT on `CAP_EnforceAccountOwnership`, naming
        EMMA -- not fail earlier for an unrelated reason. Per <<TX-BOOT-OG7>>, assert on the
        message, and confirm the probe reaches the intended enforce rather than dying en route.

## How we prove nothing broke

1. **Auth-surface baseline** (above) — the only check that speaks to authorisation directly.
2. **Assertion-count invariance.** A pure refactor must leave the executed count unchanged. The
   AQP schema hoist moved 980 lines and held at 25,196 exactly; that number IS the evidence.
3. **Gate after every band**, never at the end.
4. **Fixtures must pass DIFFERENT accounts for patron and executor** in at least one test per
   refactored function. Otherwise the parameter is untested: `CC_Step14_OpenCustodiansAgency`
   shipped with an `operator-konto` that could only ever equal `patron`, and the test passed
   because both were `KST.ANHD`. Two identical arguments hide every distinction between them.
5. **Red-team probes must fail at the RIGHT enforce.** `<<TX-BOOT-OG7>>` needed three attempts:
   it first died in `coin.TRANSFER` before reaching any guard, then SUCCEEDED because the admin key
   was in `env-sigs`. Only the third failed with the intended keyset named in the message.

## Audit

Yes — this is a new edition. It changes the authorisation model of every client entrypoint in the
system, which is the single thing an audit book exists to describe. Expect **v2.0**, not v1.2: the
"what was verified" statement changes shape, not just content. Bands land as separate chapters or a
single dated round depending on how they fall.


## Incidental findings while building Step 0

* `_heavy.py` rejected `A_OuroMinterStageTwo`: it reaches
  `RPS.URH_FvtEnabledScoreEntityIdsForFvt` through its four `CC_Inject` legs. Renamed
  `AA_OuroMinterStageTwo`. This is the structural confirmation of the gas concern that started the
  whole thread — Stage One is a flat `A_` at ~135k gas; Stage Two is not the same kind of thing.
* `OuronetInformational/tools/gen-module-index.mjs` matched `C_|A_|XI_|XE_|XB_` and silently
  dropped the DOUBLED prefixes `CC_` and `AA_`. MODULE-INDEX.md was therefore under-reporting the
  public surface by **38 entrypoints** (2,195 -> 2,233), including every heavy one. Nothing
  cross-checks that file, which is why it went unnoticed.


## Deploy-order lesson from the DSP move (2026-09-20)

Moving `03_DSP+.pact` from Stage 1 to Stage 2 broke `ZALL.repl`, which loaded
`Stage_01/[6.8]_Dispenser.repl` at line 53 -- BEFORE `deploy-stage02.repl` at line 60. The test ran
against a module that no longer existed at that point. It cost two ~20-minute gate runs to find.

**Moving a module's deploy position means moving its test position too, and nothing enforces that
coupling.** Worth a gate check of its own if this recurs.


## Band 3 post-mortem (2026-09-20) — three defects I introduced, and what each teaches

**1. The half-migration.** The collect function's transfer TARGET was renamed to `collector` while
the payout stayed COMPUTED from `patron`:

    (payout ... (URC_CollectClaimableRewards patron ...))       ;; whose rewards
    (C_Transfer reward-dptf-id AQP|SC_NAME collector payout)    ;; who receives them

Compute one account's rewards, credit another's. SEVEN call sites had to move, not one -- the
payout, the triplet lanes, the heterogeneous route, two bronze/silver transfers and the Coil/Curl
legs. Harmless only because every call site still passes the same value twice, i.e. harmless until
someone uses the feature the refactor exists to enable.

**Neither mechanical invariant could see it.** AUTH-SURFACE was clean because no ownership enforce
disappeared -- it asks "did authorisation WEAKEN?", not "is the rename COMPLETE?". The assertion
count was unchanged because no test varies patron from executor. A mechanical invariant proves a
PROPERTY, not correctness, and it is dangerously easy to let a green check stand in for the rest.
What found it was asking a different question before writing the proof test: *does anything
validate that the collector is entitled to those rewards?*

**2. Two scripts, two function lists.** The call-site transformer and the core-signature script
each carried their own list of "functions in this band". They disagreed on
`CCp_InjectFixChunk`: the transformer added an argument at 7 call sites, the core script never
added the parameter -- because that function fixes stale debs and moves no tokens, so it correctly
has NO executor. Result: call sites passing an argument the function does not take.

> For Bands 1/2/4: ONE source of truth for band membership, consumed by both scripts. Two lists
> that must agree, with nothing enforcing it, is the same defect class as every other one found
> this session.

**3. Two call FORMS.** The transformer matched only the Talos-qualified `AQP-FVT|CC_Inject` and
missed direct core calls written `ref-FVT::CC_Inject` (`[6.2.10]_AQP-NEGATIVES.repl`) and
`ref-FVT::XB_FvtInject` (`07_MTX-AQP.pact` x2). A migration regex must cover every way the
codebase spells a call, and this codebase spells it three ways: bare, `ref-X::`, and `Module.`.

**What actually caught 2 and 3:** the suite, via arity errors. What caught 1: stopping to think
about the test. The order matters -- the proof tests must come BEFORE the band commit, because they
are the only thing that can detect a half-migration.

**Follow-up left open:** `07_MTX-AQP.pact` passes `patron patron` into `XB_FvtInject`. MTX's own
defpact signature has no executor yet; threading it is Band 3b, deliberately not folded in here.


## Call-graph tooling on this codebase: the FOUR ways a check hides

Building `_authsurface.py` and `_bandplan.py` produced the same bug four times, and every instance
UNDER-reported -- the tool said "this function enforces nothing" about code that is enforced. That
is the dangerous direction: it invites adding an executor with nothing to validate it against, or
removing a derived check the tool could not see.

A call-graph tool here MUST follow all four, or it is lying:

    1. BARE NAME, resolved per FILE.      `(UEV_x ...)`
       Resolving by name alone across modules is worse than useless: `C_Transfer` is defined in six
       modules, and unioning them gave 342 of 841 entrypoints an IDENTICAL 7-target set.
    2. A UEV_/CAP_ HELPER the defcap calls. C_SetMosaic -> UEV_SetMosaicContext -> CAP_Owner.
    3. A COMPOSED CAPABILITY.             VST|C>VESTING-LINK -> VST|C>LINK -> DPTF::CAP_Owner.
    4. A CROSS-MODULE HELPER.             `(ref-RPS::UEV_AddRewardLinkContext ...)` -- a regex
       anchored on `(UEV_` misses it entirely. C_AddRewardLink DOES enforce ownership, at
       04_RPS.pact:2800.

And ownership is not one idiom but EIGHT. `CAP_Owner` (150 uses) is more common than
`CAP_EnforceAccountOwnership` (108), with six module-local variants besides: CAP_StakeOwner,
CAP_PoolOwner, CAP_VctVacatePoolOwner, CAP_TF|Owner, CAP_AqpAssetOwner, CAP_Creator. The first
version of AUTH-SURFACE.md knew only one of the eight and therefore covered under half the
enforcement in the tree -- 714 entrypoints reported as enforcing, against 811 in truth.

Measured effect of fixing these, on "Band 1 functions whose executor cannot be determined
mechanically": 30 -> 25 -> 14 -> 12. The first three numbers were tool artefacts.

**I wrote the first tool BECAUSE non-transitive scans under-report, and then made the same mistake
three more times in its sibling.** Knowing a failure mode does not prevent repeating it; only
testing each specific shape does.

### Genuine residue (12), not tooling gaps

`C_IssueSingleScoreModel` and `C_CombineTripletScoreModel` have NO ownership check at all -- their
defcap does `UEV_EnforceAccountExists patron` and stops. Anyone may define a score model. Probably
harmless alone, but it pairs badly with the open finding that `DSA|Template.model-id` is written
and never read: if a vault's declared model were ever enforced, an unowned model factory would
start to matter. Two half-open doors that only matter together.

## Band 3 verified authorisation-neutral (2026-09-20)

Not asserted -- MEASURED, differentially, with the corrected tool across the commit boundary:
check out Step 0 (d333fc9) into a worktree, run the 8-idiom transitive analyser against both trees,
diff per `module::entrypoint`.

    pre-Band-3: 1104 entrypoints        post: 1104
    LOST an enforce:   0        GAINED: 0        disappeared: 0

This comparison was only possible because Step 0 was committed SEPARATELY. Folding the instrument
into the same commit as the change it validates would have left no boundary to measure across.

---

## BAND 2 — DONE for the 13 that could be licensed (2026-09-20)

**Band 2 turned out to be three different things wearing one label**, and the label was the
dangerous part: its prescribed action is a *no-op rename*, so anything misfiled into it gets marked
done without ever gaining an executor.

### The classifier was wrong twice before any code was touched

**(a) It read the BODY, not the signature.** Membership was decided by matching an account-name
regex against `b[:400]` — the first 400 characters of the function body. Seven functions qualified
on the strength of a **let binding**:

```pact
(defun C_UpgradeBranding (patron:string entity-id:string months:integer)   ;; no account param
  (let ((parent-owner:string (UR_Konto parent)))                            ;; <-- this matched
```

`C_UpgradeBranding` × 6 (`DPMF`/`DPTF`/`DPOF`/`ATS`/`SWP`/`DPDC`) + `C_UpgradeBrandingLPs`
(`SWPLC`). Their owner is **derived from the entity** — they are Band 1. Fixed by reading the
paren-balanced parameter list and nothing else. Totals held at 89 (no function entered or left the
refactor); `band 1: 51 → 58`, `band 2: 37 → 30`.

**(b) It could not tell "already compliant" from "unverifiable".** Band 2's licence to rename rests
on the account parameter *being* the enforced ownership target. For 21 of 30 rows it is not, for
**three unrelated reasons that produce one identical symptom** (`targets = []`):

| row | why the walker sees nothing | real status |
|---|---|---|
| `DPTF`/`DPMF`/`DPOF`/`ATS`/`SWPI` `C_Issue` | the core enforces nothing; **Talos does** (`AUTH-SURFACE` line 382 shows `TS01-C1::DPTF\|C_Issue` reaching `account`) | correct by architecture — Talos is the auth boundary |
| `MTX-SWP` × 8 | delegates into the `MTX\|C_AddLiquidity` **defpact**; auth is in the steps | fine |
| `FVT::CC_Inject` / `CC_Collect` family | ownership is enforced one layer **down**, in `ref-TFT::C_Transfer` → `CAP_EnforceAccountOwnership sender` | already done in Band 3 |

The walker follows capability chains, not defun bodies or defpact steps, so it cannot see any of
the three. It now reports them as `??` instead of picking a band. **A classifier that cannot tell
these apart must not pretend to.**

### The one that would have been an active mistake

```pact
(defun C_RotateOwnership (patron:string fvt-id:string new-owner-konto:string))
```

Band 2 says "rename the account parameter to `executor`". The account parameter here is
`new-owner-konto` — the **recipient**. The executor is `owner-now`, derived inside the defcap via
`ref-RPS::UR_FVT|OwnerKonto`. Renaming would have named the *incoming* owner as the actor, under a
banner that reads "no behaviour change". **It is Band 1.**

(Noted in passing: `FVT|C>ROTATE-OWNERSHIP-FVT` also has the 2026-09-14 ordering problem — the
`can-change-owner` business `enforce` runs *before* `CAP_EnforceAccountOwnership owner-now`.)

### What was actually renamed, and the principle used

**Rename only where the existing name is silent about the axis.** `account` says nothing about who
pays versus who acts, so `account → executor` **loses no information and gains the axis**. By the
same test `owner-konto`, `sender`, `injector` and `collector` all already name a real role — the
user's own acceptance of `injector`/`collector` in Band 3 establishes that a domain-specific
executor name is canon. Renaming those would *remove* meaning to buy uniformity.

**13 renamed** — `C_Issue` in `00_DPMF`, `05_DPTF`, `06_DPOF`, `08_ATS`, `16_SWPI`; and all 8
`20_MTX-SWP` pool/liquidity entrypoints. 2 forms each (interface declaration + module defun),
3–4 occurrences, **zero call sites — Pact has no named arguments**, which is what makes Band 2
cheap in a way Band 1 will not be.

**Left alone, deliberately:** the 6 `02_SCORE` + `FVT::C_Issue` (`owner-konto` — meaningful),
`DPDC-T::C_IgnisRoyaltyCollector` (`sender` — matches the transfer idiom), the 4 inject/collect
(done in Band 3).

### Still open out of Band 2

- `05_FVT::C_RotateOwnership` → move to Band 1.
- `11_EQUITY+::C_IssueShareholderCollection` — `creator-account`, no reachable enforce; unreviewed.
- `03_AQP::C_SyncTrueFungibleAnchors` / `C_SyncCollectableAnchors` — `beneficiary-id` is an account
  and no ownership enforce is reachable. These are **repair** functions, so permissionless may well
  be intended (a stranger paying to fix your anchors harms nobody) — but that is a ruling, not a
  reading, and it has not been made.
