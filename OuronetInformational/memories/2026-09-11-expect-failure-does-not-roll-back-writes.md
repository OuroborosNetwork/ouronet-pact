# `expect-failure` does not roll back DB writes (and `try` forbids them)

*2026-09-11 — found while trying to pin `SCR|XE>CREATE-FVT-LINK`.*

## The two rules, verified empirically

| harness form | DB writes inside it | can reach a guard that sits AFTER a write |
|---|---|---|
| `(try fallback expr)` | **forbidden** — `Operation disallowed in read-only or sys-only mode` | no |
| `(expect-failure doc msg expr)` | **allowed, and they PERSIST** | yes |

Proof for the second row: `REPL_BootstrapVault` does four writes (`WI_Fvt`,
`XE_WI_FvtRewardAggregate`, `XE_WI_ScoreEntityLink`, `XE_WI_RpsGlobal`) and only then calls
`XE_CreateFvtLink`, whose cap holds the guard. Inside `expect-failure` the guard fires
correctly — and afterwards `URC_FvtExists` on the new id returns **true**, both in the same
transaction and after the following `commit-tx`. The row is permanent.

`expect-failure` catches the Pact error; it does not open a nested transaction.

## Why this matters for guard pinning

Any negative test whose target enforce sits downstream of a write **silently mutates the
shared fixture** for every later block in the file. The error is invisible: the assertion goes
green, and the damage shows up as an unrelated suite failing later, or worse, not failing.

The mirror-image trap is `try`: wrap the same call in `try` to "probe safely" and the write
errors out first, so the probe reports the *write* failing and the guard looks unreachable.
That is how this pair was found — the `try` probe said "unreachable", the `expect-failure`
probe said "guard fires". Both were telling the truth about different things.

## Audit of the existing pins: clean, checked two ways

1. **Intra-function** (`/tmp/_leak.py`): for every pinned guard, is there a persisting write
   earlier in the same `defun`? → **0 of the pins**. Control: the detector does find the 7
   post-write enforce sites that exist, including the two `REPL_Bootstrap*` post-condition
   self-checks already annotated unreachable — so the zero is real, not vacuous.
2. **Cross-module** (`/tmp/_leak2.py`): is a pinned guard reached via a caller that writes
   first? → 2 candidates, both **false positives**. `DPOF-G3b` and `DPDC-G5b` acquire their
   cap directly with `test-capability`, so no caller and no write is involved.

A zero from a detector is a claim about the detector first. Both were proven against a known
instance before being believed — same discipline as the `admin-gate-terminal` rule.

## Rules going forward

- Probe with `expect-failure`, never `try`, when the target guard may sit after a write.
- Before pinning such a guard, ask **what row does the failed call leave behind**, and either
  place the block where residue cannot be observed, or don't take the pin.
- `AQP-G27` is the one block that deliberately accepts residue. It is the **final transaction
  of a leaf tester** (`modules/AQP.repl` is loaded by nothing — not `Z.repl`, not `ZALL.repl`),
  carries a banner saying so, and asserts the surviving link is unchanged. Appending below it
  makes the orphan visible.

## Related: defensively-shadowed guards in AQP-SCORE

The three `SCR|XE>*-LINK` caps each re-check what their callers already checked:

| SCORE cap | production caller | caller's own check |
|---|---|---|
| `CREATE-AQPOOL-LINK` | `AQP\|C>ADD-SCORE` | `UEV_AddScorePoolAndScore`: aqpool-link = BAR |
| `REVOKE-AQPOOL-LINK` | `AQP\|C>REVOKE-SCORE` | `UEV_RevokeScorePoolAndScore`: aqpool-link = pool-id |
| `CREATE-FVT-LINK` | FVT `C_AddScoreEntity`, RPS triplet admit | fvt-link = BAR (both) |

This is correct defence-in-depth — SCORE owns the row and should not trust callers — but it
means **no deployed path can reach these enforces**. `CREATE-FVT-LINK` is pinned anyway via the
REPL-only bootstrap helper (the only unshadowed caller). The two aqpool twins have no
unshadowed caller at all and stay on the worklist *unpinned rather than marked UNREACHABLE*:
they are reachable in principle, just not from anything that exists today. Marking them dead
would be the convenient answer, not the true one.

## Standing checks

Both detectors are now committed as `REPL/_leakaudit.py` (intra-function) and
`REPL/_leakaudit_xmod.py` (cross-module). Run them after adding negative tests.

`_leakaudit_xmod.py` **is expected to flag `AQP-G27`** — that is the one deliberate,
contained instance described above, and the flag is the detector working rather than a
regression. The other two names it raises (`DPOF-G3b`, `DPDC-G5b`) are false positives:
both acquire their cap with `test-capability`, so the writing caller it found is never on
their path. The detector answers "could this guard be reached after a write", not "does the
actual test reach it that way" — so every hit still needs the test read before it is believed.

---

# Addendum: driving CONFIGURATION guards in the deploy-chain window

Modules that refuse to operate until the canonical token ids are set (`LIQUID`,
`OUROBOROS`, `DALOS|UEV_IgnisCollectionRequirements`) carry guards no test suite could ever
reach: every suite runs on a fully-configured chain, so the guards always pass.

**The window is inside the deploy chain itself.** `REPL/Stage_01/[4.0]_Sovereign-Executor.repl`
inserts `DALOS|INFO` with every id = BAR, then ~290 lines later `update`s them to real values.
Between those two points every module is deployed and the configuration is empty — exactly the
state the guards describe. Negative tests placed there are read-only apart from three *staged*
`update`s, each overwritten by the real update in the same transaction, so nothing else ever
observes the intermediate state.

The staging is necessary because these are conjunctions checked one id at a time: with
everything BAR only the first enforce of each function can speak. Setting one id per stage walks
the chain forward so each guard answers in turn (`<<TX4.0-CONFIG>>`).

Because the deploy chain is loaded by ~57 suites, the block runs everywhere: total assertions
went 10,225 → 10,624 for seven written assertions. That is fine (they are cheap reads) but it
means **a mistake there breaks every suite** — run the full gate, not one suite, after editing it.

## A sixth instance of the eager-binding defect

`OUROBOROS.UEV_Exchange` carries `"Ouroboros is not set"` and `"Ignis is not set"`. **Neither can
ever fire.** Its `let` binds `(UR_AccountRoleMint ouro-id orb-sc)` in the same binding group as
`ouro-id`, and Pact evaluates eagerly — so a BAR id aborts in the DPTF properties read with
`DPTF ID | does not exist` before any enforce runs. Setting OURO alone does not help; the
`gas-id` role read aborts next.

Running list of this shape: PYTHIA `UEV_DualPairForLink`, FVT `UEV_AddScoreEntityScoreContext`,
DALOS `GAS_PAYER`, SCORE triplet admission, FVT `UEV_AddScoreEntityTripletContext` (already
fixed in place), and now OUROBOROS `UEV_Exchange`. **The fix is always the same**: hoist the BAR
check above the `let`, or bind the dependent reads lazily inside the branch.

Both annotated `;;UNREACHABLE` and pinned AS THEY BEHAVE.

## Recorded, not taken

`UEV_Exchange`'s third guard ("Permission invalid for Ignis Exchange") needs one of four
mint/burn roles absent from the ORBR smart contract. `DPTF|C_ToggleMintRole` refuses a smart
account outright (`UEV_NotSmartOuronetAccount`), which is correct — a contract's roles are not
user-revocable. It needs the admin grant path plus a restore, not a client toggle.

---

# Addendum 2: CADUCEUS had two uncreated tables — the whole bridge was non-functional

*Found by writing the module's first-ever REPL suite.*

`2_CITIZEN/6_OuronetBridge/03_CADUCEUS.pact` declared `CADUCEUS|ConfigTable` and
`CADUCEUS|SignalTable` and **created neither**. A `deftable` is only a declaration: the module
compiles, loads and deploys cleanly without the matching `create-table`. At runtime every path
died on `Table ouronet-ns.CADUCEUS_CADUCEUS|ConfigTable not found` — and since every function in
the module reads or writes the config row, nothing in the bridge worked at all.

**Why it survived:** CADUCEUS had ZERO REPL coverage. The only thing that had ever touched it was
`archive/_scratch_n2_caduceus_compile_check.repl`, a load-only structural check whose own header
admits it is not a functional proof. A load is exactly what this defect survives.

The lesson worth keeping: **"it compiles and deploys" does not imply "a table exists."** A compile
check cannot substitute for one live call.

Fixed by adding the two `create-table` calls after the module body, matching every other
table-owning module (AOZ+ 8/8, `99_TS02-CPAD` 2/2, `03_DSP+` 2/2).

## `[table-never-created]` conformance rule

Added to `_conformance.py`. Verified the only way that counts: **reverted the fix, watched it
fire on both tables at the right lines, restored.**

It also needed a fix of its own first. The initial version did not strip comments — and the very
comment documenting the CADUCEUS fix contains the literal text `(deftable ...)`, which the rule
read as a table named `...` and reported as a permanent phantom violation. A lint rule that fires
on prose about itself is worse than no rule.

`00_DPMF.pact` is exempt: it is the superseded MetaFungible module, deployed for provenance and
never called, and its tables are uncreated consistently with that. Narrow carve-out — if DPMF is
ever revived the rule should fire on it.

## `REPL/modules/CADUCEUS.repl` — the module's first coverage

Light by design: CADUCEUS references only `OuronetConstantsV2`, `OuronetDalosV2`,
`TalosStageOne_AdminV2`, `TalosStageOne_ClientOneV2`, so `deploy-stage01` suffices. (The archived
compile check loaded all of Stage 2 unnecessarily.)

**Two different keysets are in play and the error messages do not say which:**
- DEFINING a module inside `ouronet-ns` needs the **namespace** user keyset (raw hex keys).
- CALLING its `A_` functions needs `GOV|CADUCEUS_ADMIN` → DALOS's **Demiurgoi** set
  (`PK_AncientHodler` / `PK_Florex`).

Signing only one yields a bare `Keyset failure (keys-any)` whose key list is the only clue.

Pinned: `UEV_Ready` (only reachable on a freshly deployed module — the config row is never
deleted) and `UEV_Active` (only reachable configured-but-paused, because `UR_BridgeActive` is a
hard `read`, so before configuration it aborts in the read rather than the enforce).
`A_SetBridgeConfig` takes `active` as a parameter, so the bridge can be brought up paused
directly — no toggle needed.

**Not pinned:** `UEV_FreshSignal`'s replay rejection needs a row in `SignalTable`, and the only
writers run a real mint/transfer or burn through TS01-C1 first. That means a full bridge
bring-up (Σ account deployed, DPTF roles provisioned under TS01-A's admin keyset, funded relayer).
It is the obvious next step for that file, because the replay guard is what stops the same inbound
transfer being redeemed twice.

---

# Addendum 3: the CADUCEUS bridge, stood up end-to-end

The replay guard (`UEV_FreshSignal`) needs a row in `CADUCEUS|SignalTable`, and the only writers
are the two bridge flows — each of which runs a live mint/transfer or burn BEFORE the write. So
there is no shortcut: reaching it means standing the bridge up for real. Done, in
`REPL/modules/CADUCEUS.repl` (`CAD-04`, `CAD-G4`, `CAD-G5`).

## The four prerequisites, each of which failed differently

1. **The relayer keyset did not exist.** `BRIDGE|RELAYER` enforces
   `(keyset-ref-guard "ouronet-ns.dh_bridge_caduceus-keyset")` — a namespace keyset defined
   nowhere in the repo, so the cap was unacquirable. Defined the way `[5.2]_Dispenser+` defines
   its smart-contract keysets.
2. **A real Σ bridge account.** `DALOS|C_DeploySmartAccount` runs `UEV_Glyph` on the name, so a
   readable placeholder is rejected — it needs a genuine 200-glyph Σ name. Reused the one from
   `_scratch_dalos_m2_deploysmart_capsplit.repl`.
3. **A patron-owned DPTF.** `deploy-stage01` leaves NONE — every token it creates belongs to a
   smart contract. `fixtures/mock-tf.repl` supplies MOCKA/MOCKB owned by KST.ANHD.
4. **Mint/burn/transfer roles** for the bridge account on that DPTF, via
   `A_ProvisionBridgeDptfRoles` (needs TS01-A's admin keyset *and* `GOV|CADUCEUS_ADMIN`).

## Two keysets, easy to confuse

- DEFINING a module in `ouronet-ns` → the **namespace** user keyset (raw hex keys).
- CALLING its `A_` functions → `GOV|CADUCEUS_ADMIN` → DALOS's **Demiurgoi** set
  (`PK_AncientHodler` / `PK_Florex`).

Signing only one gives a bare `Keyset failure (keys-any)` whose key list is the only clue.

## The outbound direction needs the bridge funded, and the inbound flow cannot do it

My first attempt at the burn block failed with `Cannot Debit DPTF ... into the negatives`. The
inbound flow forwards everything it mints straight to the user, so it leaves the bridge at zero.
The bridge is funded by a direct owner mint instead, which is what a real outbound transfer would
do. Both directions are driven with a FRESH signal first, then replayed — a replay rejection proves
nothing if the flow rejects every signal — and each replay asserts the balance is **unchanged**,
so the test is about the invariant rather than the error string.

Both flows are driven because they are separate entrypoints with separate writers; the inbound one
is the one that MINTS, so a missing check there costs real supply.

## `REPL/_prerun.sh`

Two pre-gate checks, both learned the hard way:
1. **Leftover `PROBE` blocks in live suites.** Twice the restore-after-probe was missed — once a
   throwaway assertion I had already seen fail for the wrong reason got committed as if it passed
   (the gate caught it), once a harmless diagnostic was left in `modules/LIQUID.repl`. `Kursan/`
   and `archive/` are excluded: they hold finding-verification files that legitimately say PROBE.
2. **Lost assertions**, by comparing per-file `expect` COUNTS against HEAD — raw diff lines are
   the wrong instrument, since a modified line reads as a deletion.

Run it before every gate run instead of remembering to.

---

# Addendum 4: uncredited coverage — expected strings that straddle a `{}` hole

`_enforce_coverage.py --orphans` lists every `expect-failure` whose expected text matches no
source guard. 75 of 644. Most are legitimately not guards (`Keyset failure`, `No value found in
table` — raw Pact errors). But some are **real guard tests that get no credit**.

The cause: the tool splits a guard's `format` template on `{}` holes and needs ONE WHOLE run to
match. An expected string written from the RENDERED message — `"...for making a Tier 2 Share
Packge"` — straddles a hole, so it matches the rendered text (the test passes) but matches no run
of the template (the tool reports the guard untested).

Five fixed, all by naming a complete fixed run instead of a rendered fragment:

| test | was | now |
|---|---|---|
| `DPDC-G6` | `"doesnt hold SFT"` | `"in sufficient quantity for Operation"` |
| `DSU-05` | `"Nonce 7 in sufficient quantity…"` | `"in sufficient quantity for Operation"` |
| `DPTF-09` | `"Frozen for MOCKA-98c486052a51"` | `"on Account"` |
| `EQUITY-G1` ×2 | `"…a Tier 2 Share Packge"` | `"Shares is an invalid amount for making a Tier"` |

**+4 pinned with no new tests written** (477 → 481). The tests already drove those guards; only the
attribution was broken. This is the opposite of inflating the metric — the fix is on the TEST side
(name an unambiguous fragment), never on the matcher.

## A real test defect found the same way

`[6.2+3]` had two assertions both expecting `"…principal — cannot be"`. But removal and rotation
have DIFFERENT messages — `"cannot be removed"` (15_SWP.pact:691) and `"cannot be rotated"` (:719).
A shared prefix matches both, so **neither assertion could tell them apart**: a bug making rotation
emit the removal message would have passed. Each now names its own verb.

Generalised rule: an expected string must name a fragment that is unique to the guard under test,
and must not contain an interpolated value.

## `REPL/_orphanmatch.py`

Pairs each orphan with the guard it probably meant, by longest run of consecutive shared words.
It took **four** bugs to get right, and three are recurring traps worth naming:

1. Matched string literals inside **comments** (a `"` in prose opens a bogus literal) → three
   confident false positives pointing at a comment I had written myself. Third tool this session.
2. Required the **longest** template run to appear — the one thing an interpolated string is least
   likely to contain. Any-run is the right test.
3. Its own `strip_comments` tracked quote state **per line**, but Pact `@doc` strings span lines,
   so a `;` inside one deleted a closing `"` and misaligned every literal after it.
4. **`re.S` missing.** Pact's `@doc "text \` + newline + `\ more"` continuation means a literal
   contains `\`+newline, and without DOTALL the `\\.` alternative cannot step over it — the regex
   stops at the first continued doc string and every literal below is invisible. This is what hid
   the EQUITY guard 500 lines further down.

Copy `strip_comments` from `_enforce_coverage.py` verbatim rather than re-deriving it (importing
is not an option — that module runs `main()` on import).

---

# Addendum 5: `_prerun.sh --snapshot` — catching regressions WITHIN a session

The HEAD comparison in `_prerun.sh` cannot see work lost during a session. I restored
`modules/AQP.repl` from a backup taken BEFORE a finished block (`AQP-G30`) and silently dropped it;
the HEAD diff still read "+1760 insertions", so nothing complained.

Fixed: `./_prerun.sh --snapshot` records per-file `expect` counts after a green gate, and every
later run compares against that as well as against HEAD. Verified by **replaying the exact
accident** — restoring from the stale backup — and watching it report
`REGRESSION vs last green gate: REPL/modules/AQP.repl 136 -> 133`.

Routine is now: `./_prerun.sh` → gate → `./_prerun.sh --snapshot`.

The deeper lesson: a `/tmp` backup taken at the start of a probe goes stale the moment the next
block lands. Prefer re-deriving the file from git plus the known-good blocks, or take the backup
immediately before the edit that needs it — never reuse an older one by name.

# Addendum 6: the class-0 pool fixture is NOT "one more pool"

Several guards have been blocked on a class-0 (LP) acquisition pool: the class conjunct of
`UEV_AddScorePoolAndScore`, its class-0 lp-denominator rule, and the FVT farm-score guards.

`UEV_IssuePoolClassAndAsset` requires a class-0 pool's asset to be a genuine SWP **LP token**:
prefix in `S|`/`W|`/`P|` AND `asset-id = (UR_TokenLP (UR_GetLpSwpair asset-id))`. And
`CAP_AqpAssetOwner` requires the tx sender to own that LP token's canonical owner.

`modules/AQP.repl` runs the **issuance-only** Stage-1 path, which creates no swap pairs at all —
probed: `SWP|Pairs` has no row even for the Stage-1 stable pool id. So the fixture is not an extra
`C_Issue`; it needs the full SWP path loaded into the AQP tester first, which changes that suite's
loader. Recorded rather than attempted.

---

# Addendum 7: `(fold (and) true [...])` is NOT short-circuiting

This matters because CLAUDE.md **mandates** that idiom for 3+ boolean conditions.

`fold` receives an already-built list, so every conjunct is evaluated before `and` ever runs.
Verified directly:

    (enforce (fold (and) true [false (enforce false "LATER-CONJUNCT-EVALUATED")]) "FOLD-MSG")
    => got 'LATER-CONJUNCT-EVALUATED'

Usually harmless — the conjuncts are independent predicates. It is a **defect** when a later
conjunct hard-reads a table using the very value an earlier conjunct is checking for BAR or
existence: the read raises first and the earlier conjunct can never protect anything.

## `REPL/_foldeager.py`

Scans every `(fold (and) true [...])` site (121 of them) for that shape. Crucially it classifies
each `UR_*` reader as **hard** (bottoms out in a bare `read`) or **soft** (`with-default-read`), and
only flags hard ones — without that the rule is noise: 3 of its first 4 hits passed the guarded
value to `UR_FVT-SEL|Enabled`, which resolves through a `with-default-read` whose `@doc` says
"absent rows read as disabled", so eager evaluation there is harmless. Reader kinds propagate
through delegation.

**121 sites scanned → 2 real.** Reported as observations, since the fix is per-site.

## The three instances

| site | kind | consequence |
|---|---|---|
| `04_RPS.pact:2957` `UEV_AddRewardLinkContext` | `enforce` | `UR_FVT-MF|Active` is a bare read; a BAR family id — the case conjunct 1 exists to reject — aborts in the read, so the written message is mute |
| `04_RPS.pact:2992` `UEV_QualitySplitContext` | `enforce` | same, via the link's stored family id |
| `04_RPS.pact:3876` `XE_XI_SettleScoreRps` | **`if`** | worse in kind: a plan with a BAR `fvt-id` aborts the WHOLE batch settle instead of being skipped — the opposite of what `(!= fvt-id BAR)` was written to do. Latent (the plan builder does not emit BAR today) |

The first two are pinned AS THEY BEHAVE in `<<AQP-G31>>`, so a fix must update those lines
deliberately. All three annotated at source.

**Fix for all three:** hoist the BAR check into its own `enforce` above the fold, or read through a
`with-default-read` — the pattern `UR_FVT-SEL|ScoreEntityLink` already uses.

This is now the seventh distinct instance of "a guard's own subject is unavailable when the guard
runs" (PYTHIA, FVT score, DALOS GAS_PAYER, SCORE triplet, OUROBOROS, AQP score-assignment, and this
family). The first six were eager `let` bindings; these are eager fold operands. Same root cause,
different syntax — **Pact evaluates everything in a binding group or a list literal before the form
that consumes it.**

# Addendum 8: SWP liquidity-kind guards need a constructed object, not a scalar

`UEV_AddChilledLiquidity` / `UEV_AddLiquidity` take an `object{LiquidityData}`, which is why they sat
unpinned. SWPL publishes constructors for every part (`UDC_LiquiditySplit`,
`UDC_LiquiditySplitType`, `UDC_LiquidityData`), so the fixture is three calls rather than a real
liquidity addition. Use the module's own constructors, not an object literal: a schema change then
breaks the block loudly instead of silently mis-typing a field.

`LiquiditySplitType` is `{iz-balanced, iz-asymmetric}` and is the whole lever — one object asserts
"this deposit is proportional", the other "this deposit is lopsided", and the guards branch on
exactly that. Driving the same function on the same pool with one field changed is what makes each
refusal attributable (`SWP-G15`).

The global asymmetric switch is a protocol-wide kill switch, toggled off/asserted/back on with the
restoration asserted (`SWP-G16`). Still blocked: the empty-pool rule needs `URC_LpCapacity = 0.0`,
i.e. a freshly issued and never-funded pool.

---

# Addendum 9: `_pactlex.py` — one copy of the lexing helpers

Three scanners shipped with bugs in re-derived copies of the same logic:

1. a `strip_comments` tracking quote state PER LINE — Pact `@doc` strings span lines via the
   `\`-newline continuation, so a `;` inside one deleted a closing `"` and misaligned every string
   literal after it;
2. a string-literal regex without `re.S`, which cannot step over that same `\`+newline and goes
   blind from the first continued `@doc` onward;
3. a conformance rule that read `(deftable ...)` out of its own explanatory comment.

`REPL/_pactlex.py` now holds `strip_comments`, `balanced`, `split_top`, `STRLIT`, `UR_CALL` and
`reader_kinds`. `_foldeager.py` and `_eagerlet.py` both import it. **Import it; do not re-derive it.**

`reader_kinds` is the part that makes these rules usable rather than noise: it classifies each `UR_*`
as HARD (bottoms out in a bare `read`, can abort) or SOFT (`with-default-read`, answers for a
missing row), propagating through delegation. Verified against two hand-checked cases —
`UR_FVT-MF|Active` hard, `UR_FVT-SEL|Enabled` soft.

# Addendum 10: `_eagerlet.py` — the let-binding half of the eager-evaluation family

Narrow rule: an `(enforce (!= var BAR) …)` in a `let` body where a HARD reader in the binding group
above consumes `var`. **3905 binding groups scanned → the 2 known OUROBOROS instances, 0 new.**

It reported 0/0 at first, which was a detector bug, not a clean result: it took the binding's value
expression as `b[b.index(')'):]` — but the first `)` in
`(o-rm:bool (ref-DPTF::UR_AccountRoleMint ouro-id orb-sc))` closes the inner CALL, so the slice was
`'))'` and no variable was ever found. **A zero from a detector is a claim about the detector first** —
this is the fourth time that has held this session.

**The narrow rule reading clean does NOT mean the family is clean.** Of the seven instances found by
hand, only the two OUROBOROS ones have that exact shape; the others hide in a fold operand (covered
by `_foldeager.py`), test a bool (`(enforce iz-single …)`), or call an existence function
(`URC_TripletExists`). Hence `--wide`, which flags any enforce merely MENTIONING the variable:
**31 candidates, labelled a REVIEW AID because it is noisy** — the ones I hand-checked were false
positives (e.g. `05_DPTF.pact:378`, where the enforce tests `type` and `ouro` only appears inside
the match window).

# Addendum 11: a bridge fixture unlocked a Stage-1 guard

`TFT UEV_MoveRoleCheck` only engages when a token has a non-empty transfer-role list — with no roles
granted, transfers are open and the check short-circuits. **No suite granted one** until `CAD-04`
gave the CADUCEUS bridge account mint/burn/TRANSFER on MOCKA. So the fixture built to test the
bridge made a Stage-1 guard reachable for the first time (`CAD-G6`).

Both sides are driven, because the rule is an `enforce-one` over (sender-has-role OR
receiver-has-role). Without the positive case the rejection would be satisfied by a check that
blocked EVERY transfer once any role existed — which would silently freeze a token the moment its
first role was granted.

General lesson: when a guard needs state no suite has, check whether a fixture built for an
unrelated purpose already produces it. That has now paid off three times (`ResumeVacPool` for the
SCORE/LP decision, `mock-of` cross-loaded into VST, and this).

---

# Addendum 12: structural re-classification found a 45-site bucket I thought was spent

At ~3 pins/pass the right move was not more grinding but asking afresh WHAT KIND of thing stands in
front of each remaining guard. Classifying all 230 by enclosing form:

| count | bucket | lever |
|---|---|---|
| 67 | `defcap @event` | Talos client call |
| 42 | `defcap @event` + ownership | Talos call + right signer |
| 30 | **`defcap plain`** | **`test-capability`, directly** |
| 23 | `defun UEV_` | direct call |
| 15 | `defcap plain` + ownership | `test-capability` + signer |

I had believed the `test-capability` seam was exhausted — it was not: **45 plain defcaps remained.**
Re-characterising the remainder was worth more than another pass of hand-picking.

## The single highest-leverage fixture in the whole effort: GAP

**Ten** of those sites were the SAME guard in ten different modules. Every Talos module carries its
own copy of `P|TS`, the cap every client function composes first, and each copy independently refuses
while the Global Administrative Pause is on. One toggle reaches all of them.

That duplication is the point, and it is why all eleven are driven separately rather than sampled:
GAP is the protocol emergency stop, and it only works if NO module has an unpaused path. A Talos
module added later without the check would leave a live entrypoint open during a freeze and nothing
else in the suite would notice. `TS02-CPAD` — the CITIZEN launchpad Talos, authored alongside the
citizen sales rather than with the sovereign Talos set — is exactly the one most likely to be missed.

Split across two suites by load scope: `DALOS-G6` (five Stage-1, `deploy-stage01`) and `AQP-G32`
(five Stage-2 + CPAD). GAP restored to the value found, restoration asserted, and the same cap
re-acquired afterwards to prove the refusals were about GAP rather than about `P|TS` being
unacquirable in a REPL.

Plus `DALOS-G7` / `AQP-G33`: four more `GOV|*_ADMIN` caps (SWPL, SWPLC, MTX-SWP, MTX-AQP), completing
that family — the caps governing whether each module can be REPLACED.

**Two traps worth keeping:**
- The module inside `05_TS01-P.pact` is named **`TS01-CP`**, not `TS01-P`. Addressing it by filename
  gives `Module TS01-P has no such member: P|TS`.
- `GOV|MTX-AQP_ADMIN` is an `enforce-one` over [Demiurgoi keyset, the MASTER account's guard] and the
  master **is KST.ANHD**. Folded into the GAP block — which must sign ANHD to work the toggle — the
  cap SUCCEEDS and the suite reports `expected failure, got result: ()`. It needs its own transaction
  signed by EMMA, who is legitimate but neither Demiurgos nor master.

Result: 489 → 503 (+14) in one pass, against ~3/pass before. Remaining plain defcaps: 45 → 31.

---

# Addendum 13: the plain-defcap bucket, mostly drained

Continuing the structural classification from Addendum 12. The `defcap plain` (non-`@event`, no
ownership check) bucket went **30 → 8** across two passes, and the whole plain-defcap bucket
(with and without ownership) **45 → 23**. I first wrote "45 → 0" here; re-running the classifier
showed 8 + 15 left, so the claim is corrected rather than left standing. `test-capability` reaches these directly:
no client call, no account, no signing beyond whatever the fixture itself needs.

| block | what it pins |
|---|---|
| `DALOS-G6` / `AQP-G32` | `P|TS` under GAP in all **11** Talos modules (one toggle) |
| `DALOS-G7` / `AQP-G33` | `GOV|*_ADMIN` for SWPL, SWPLC, MTX-SWP, MTX-AQP |
| `ATS-G10` | `GOV|*_ADMIN` for the two CITIZEN modules, AOZ and DSP |
| `AQP-G34` | the three VCT vacate-batch admission caps, 2 conjuncts each |
| `SWP-G17` | explicit-route endpoint checks + the pool-supply floor |

## Notes worth keeping

**`AQP-G34` — why two cases per cap.** A vacate batch is the operator force-unstaking *other
people's* positions. Each cap opens with a fold over the batch's structural predicates (arrays
aligned, asset belongs to the pool, every leg actually staked) and the ownership check sits AFTER —
so the fold answers and no pool ownership is needed to reach it. Each is driven on array
misalignment AND on a wrong asset with well-formed arrays; the second is the shape an attacker would
actually send, and one input only ever proves one conjunct.

**`SWP-G17` — the reversed route.** `SMART-SWAP-EXPLICIT-ROUTE` is where the CLIENT supplies the
route instead of the chain searching, so every property the search used to guarantee must be
re-checked. Its own `@doc` names the danger: *"a structurally-valid but wrong-pair route must never
be silently accepted."* The test uses `nodes [b a]` — a genuine one-hop path through that very pool,
structurally valid and active, simply running the wrong way. That is what makes the case test the
ENDPOINT check rather than the path validator three lines below it.

SWPU publishes no UDC for `SmartSwapPathBundle` (unlike SWPL's `LiquidityData`), so the bundle is an
object literal there — noted in the block so the difference is not read as carelessness.

**Citizen admin caps are the easier thing to get wrong**, because they are authored outside the
sovereign review path yet still govern their own upgrade. `ATS-G10` lives in `modules/ATS.repl` for a
load reason only: it is the one tester that loads both AOZ and DSP.

## Where the remainder now sits

208 live unpinned: **109 are `@event` defcaps** (67 plain + 42 with ownership), reachable only through
a real Talos client call — volume, not a blocker, since that route is proven. Then 38 directly
callable `UEV_`s (23 + 15 with ownership) and 23 plain defcaps (8 + 15 with ownership).

---

# Addendum 14: two SWP guards worth the write-up

## `SWP-G19` — `UEV_CheckTwo`, and why it checks BOTH token orderings

The pool id is **order-sensitive**: `UC_PoolID [A B]` and `[B A]` hash to different strings
(verified — `P|OURO|BUSD` vs `P|BUSD|OURO`). So a "pair already exists" check looking only at the
order it was handed would let the same pair be issued a second time with the tokens swapped: two
pools for one market, splitting liquidity and giving the router two different prices for one trade.

`UEV_CheckTwo` therefore computes both orderings with a separate `enforce` for each, and both are
driven, because the SECOND one covers the case the first misses:

    [OURO BUSD] -> swp1 = P|OURO|BUSD  EXISTS  -> first enforce fires
    [BUSD OURO] -> swp1 = P|BUSD|OURO  absent  -> first enforce PASSES
                   swp2 = P|OURO|BUSD  EXISTS  -> second enforce fires

The weights/amp passed are the ones that actually reproduce the live id (`[1.0 1.0]`, `-1.0`,
asserted as a precondition). A wrong pair of those would hash to an id that does not exist and BOTH
enforces would pass for the wrong reason — the test would be green and vacuous.

Finding the right pair took a probe: the two-token pools in `[6.3]_SWP.repl` carry the `P|` prefix,
and `UtilitySwp` is at interface **V2**, not V3.

## `SWP-G18` — a guard whose RETURN VALUE is its own positive control

`UEV_Liquidity` returns `[dev max-dev]` instead of merely passing. That makes the positive half free
and exact: the dust-sized asymmetric deposit is asserted to sit strictly under the ceiling **the
function itself reports**, and the ceiling asserted positive. Without those, the rejection would be
satisfied equally well by a bound of zero — which would forbid every asymmetric deposit rather than
only the extreme ones.

Both cases use the same SHAPE (everything into token 0, nothing into the rest) and differ only in
magnitude — 0.000001 vs 1,000,000 — so magnitude is provably the only variable, which is what the
guard measures. The ceiling is `0.4 * (n-1)/n`, derived from the pool's own token count, so it
tightens automatically on smaller pools.

**General point:** when a validator returns data rather than just succeeding, read it. It is usually
the cheapest possible positive control, and it is exact rather than approximate.

---

# Addendum 15: starting the `@event` tier — the Talos-path bulk

109 of the 205 remaining sites are `@event` defcaps, reachable only through a real Talos client call.
First batch: `DPDC-S|C>MAKE` (both guards) and `C>RENAME` (`DPDC-S-G2`, `DPDC-S-G3`).

## Three things that cost time and are worth knowing

**1] SFT and NFT set wrappers live in DIFFERENT Talos modules with different arities.**
`DPSF|C_Make` is in **TS02-C1** and passes `how-many-sets` through. The NFT twin `DPNF|C_Make` is in
**TS02-C2** and DERIVES it. My first attempt used the `DPNF|` names against TS02-C2 and got
unbound-variable errors for all three calls. TS02-C1 has 122 `DPSF|C_*` wrappers; TS02-C2 has none.

**2] The inactive-class case needs a TOGGLE, not a bad argument.** `UR_IzSetActive` hard-reads
`DPSF|SetsTable`, so a set-class that does not exist aborts with
`No value found in table ... for key: TSFS-...|99` before the guard is consulted — the eager-read
shape again. The only way to see the written message is an EXISTING class switched off.
`DPSF|C_ToggleSet` does that; `[6.1.3]_DPDC-S.repl` already uses it at `TX-SET-007`, so the recipe
was sitting in the suite.

**3] Each case is built so the sibling guard cannot answer.** `C>MAKE` has activity and positivity
checks one line apart: the zero-sets case asserts SC1 is ACTIVE first, and the inactive-class case
passes `how-many-sets = 1`. Without both, either case could be passing for the other's reason.

Semantics worth stating, since it is what makes the guard more than a shape check: a deactivated
set-class is the issuer saying "stop minting these". Composition must stop while BREAK keeps
working, so holders are never trapped in a retired set — which is why `C>BREAK` deliberately has no
activity check and its own comment says so.

## `DPDC-F-G1` — fragments, and why the merge rules are two guards

Fragments are sub-units of a class-0 nonce addressed by **negative** nonce numbers: nonce 1 is the
whole item, nonce −1 is its fragment lane. That convention is what the two `C>MERGE` guards police,
and each is driven with the other's precondition satisfied:

- positive nonce + a clean multiple of 1000 → only the SIGN is wrong
- negative nonce + 1500 → only the AMOUNT is wrong (1500 would merge one item plus half of another)

`C>ENABLE-FRAGMENTATION`'s class guard is driven with a class-2 SET nonce. The semantics are the
point: a set nonce already represents a composition of other items, so fragmenting it would create
two independent claims on the same underlying items.

Nonce classes were READ out of the live collection rather than assumed — n1..n10 class 0, n11 class 1
and already fragmented, n12 class 2, n13 class 3. That survey is what identified n12 as the right
input, and also what proved the remaining guard unreachable here.

**Not pinned, with the reason:** the second `ENABLE-FRAGMENTATION` guard needs a nonce that is BOTH
class 0 AND already fragmented. The collection has neither combination — the one fragmented nonce is
class 1, so the class guard answers first. Reaching it means enabling fragmentation on a class-0
nonce first, which needs a `fragmentation-ind` that passes `UEV_NonceDataForCreation` (the zero
object works for the cases above only because it is reached AFTER both guards), and there is no
disable-fragmentation operation to restore with.

## `CODEX-G1` / `CODEX-G2` — the StoicTag registry as a bijection

A StoicTag is a human-readable name bound to an Ouronet account, so the registry must be a
BIJECTION, and two guards enforce the two directions:

- one name cannot be held by two accounts → *"StoicTag name is already active"*
- one account cannot hold two names → *"Account already has an active StoicTag"*

Without the second, an account could accumulate names and the reverse lookup (`UR_STBA`,
address → tag) would silently return only one of them. The account case uses a DIFFERENT, unused
name so the name guard provably passes and only the account side can answer.

The release pair is separate because **a released tag's row is KEPT** (the suite's own TX006
re-activates one), so "absent" and "present but released" are genuinely different states and one
check would conflate them. `CODEX-G2` releases the fixture tag, drives the refusal, and re-registers
it to the same account.

**Two costs learned:** release is IGNIS-only, but REGISTER charges 1 STOA per glyph — so the restore
needed the four-way fee split signed, and my first attempt failed with
`Managed capability not installed: (coin.TRANSFER ...)`. Split amounts derived from
`URC_SplitSTOAPrices`, not hardcoded. And the Talos client interfaces are at DIFFERENT version
numbers from one another — TS01-C4 is `TalosStageOne_ClientFourV8`, not V2; guessing costs a
"Cannot find module" round trip every time.

## `DEMIPAD-G2` — an ordered admission chain, plus two findings

`DEMIPAD|C>DEPOSIT` is a chain, and each case must be built so only its own link can answer:

    registered -> dollar amount -> slippage -> type -> SSTOA/OURO branch -> open-for-business

So the dollar-amount case passes a valid type, the type case a valid amount, and the
open-for-business case valid everything. TSFS happens to be registered with the sale CLOSED, which
makes the final gate reachable without touching any flag.

**FINDING 1 — the "Asset is not registered" guard can never fire.** `UR_CheckRegistration`
hard-reads `DEMIPAD|T|Ledger`, so an UNREGISTERED asset — the only case the guard exists for —
aborts in that read first. A caller who fat-fingers an asset id gets a raw table error instead of
the written message. Eighth instance of the eager-read shape. Pinned as it behaves.

**FINDING 2 (message only) — the OURO branch says SSTOA.**

    (if (= type 2) (enforce iz-sstoa "SSTOA Deposits must be turned on for exec")
                   (enforce iz-ouro  "SSTOA Deposits must be turned on for exec"))

The else-branch checks `iz-OURO` and names SSTOA, so a type-3 depositor is told to enable the wrong
switch. Both sites are driven (both flags are off on TSFS), but they share wording inside one module,
so the coverage tool can only credit them nominally. One word to fix.

**Already documented, now marked:** `C>WITHDRAW`'s "Invalid Withdrawal type" is unreachable and the
source already says so at length — an identical predicate under "Invalid Read Type" runs first. The
comment explains why it is kept (the read must precede it because `retrieval-amount` is an @event
parameter that indexers consume) and references its existing pin.

## A tag collision, caught by reading the output

My block was named `DEMIPAD-G1` — and `modules/DEMIPAD.repl` ALREADY had a `DEMIPAD-G1`. I noticed
because the run printed two different `--- [DEMIPAD-G1 · 01 · ...] ---` banners with different
slugs. Renamed to `DEMIPAD-G2`.

This is the same hazard that destroyed `AQP-G30`: **reusing a tag that already exists in the file.**
`_prerun.sh` would not have caught it (no assertion count drops). The cheap habit that does:
`grep -c '<<TAG>>' <file>` before appending, or simply read the banner lines in the run output —
duplicated slugs under one tag are the tell.

---

## Re-audit at a larger pin set (same day, later)

The audit above covered the pin set as it stood when this was written. Many pins were added after
it, so it was re-run against the current set:

| | |
|---|---|
| enforce sites downstream of a write in the same member | **2** |
| ...of those currently PINNED (the leak risk) | **0** |

The 2 are `DPMF::XI_UpdateSupply` (dead module) and `DPTF::XBv_UpdateSupply` — both protected write
bodies, both unpinned. So the zero is real, not vacuous: the detector does find post-write enforces
and none of them is pinned. (The earlier count of 7 included the two `REPL_Bootstrap*`
post-condition self-checks, since annotated `;;UNREACHABLE` and therefore no longer counted as
sites at all.)

## A parsing trap for any future Pact analysis tool

The first version of the re-audit walked parentheses to find member boundaries and reported
**20 false leaks**, every one attributed to `DALOS::GAS_PAYER`. The paren walk claimed GAS_PAYER
spans lines **351-1867**; it actually ends near 400.

Cause: Pact's backslash-continued strings.

```pact
@doc "first part of the doc \
    \ second part"
```

A C-style escape parser (`\` escapes the next character) desyncs on that pattern, so the tool
stops tracking string boundaries correctly, sees stray parens inside string literals, and the
depth counter never returns to zero.

`strip_comments` in `_enforce_coverage.py` and `_conformance.py` carries the same escape logic —
they are unaffected only because neither relies on paren matching. `_conformance.py` uses a
line-based `MEMBER` regex and members run to the next member line.

**CORRECTION, added on discovering the existing tooling.** This was not a new lesson. `REPL/_pactlex.py`
already exists and its own docstring says it was extracted *"after THREE separate scanners shipped
with bugs in re-derived copies of this logic"* — including precisely the `\`-continuation bug hit
here. The re-audit was also a re-derivation of `REPL/_leakaudit.py`, which already answers the same
question and independently confirms the same result (0 pinned guards after a write).

**The real rule is therefore blunter: `ls REPL/_*.py` BEFORE writing an analysis script.** There are
34 of them. Re-deriving `strip_comments` is the specific mistake `_pactlex.py` was built to stop,
and it has now caused at least four incidents. Import `from _pactlex import strip_comments,
balanced, split_top, reader_kinds` instead.
