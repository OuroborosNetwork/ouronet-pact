# Registry: the execution axis — direct vs preflight-fed  (2026-09-26)

Owner's framing: a registry entry must say **how the function is executed**, not only what its
arguments are — because some arguments cannot be typed by a user. Three modes were asked for;
the tree forces a fourth.

## The four modes, as measured

| mode | n | meaning |
|---|---|---|
| `direct` | 406 | the provided inputs suffice |
| `indirect-parallel` | 9 | a preflight is cut into slices, one per tx, order-independent |
| `indirect-single` | 5 | ONE tx, but a preflight supplies an argument |
| `indirect-sequential` | 3 | a preflight reports progress; each call advances a stored cursor |

**The fourth mode is not a liberty taken with the brief.** `indirect-parallel` and
`indirect-sequential` both wear the `p` suffix, and `StoicSyntax-Prefixes.md` § *Recipe axes*
already separates them: a **fed slice** takes an explicit slice and is order-independent; a
**cursor pager** takes a size, computes its own window from stored progress, and is strictly
sequential. Collapsing them would tell a consumer it may fire a pager's pages at once, which
races the pager's own progress counter. The registry encodes the distinction per entrypoint so
the consumer does not have to know the rule.

## Why the fed set is DERIVED and not listed

A parameter is preflight-fed when **its type is the return type of a heavy read**
(`URH_`/`URHC_`/`URD_`). A heavy read is by definition a scan, so its return value is something
no caller can construct — that is the exact marker.

The first cut used a hand-picked tuple (`SmartSwapPathBundle`, `SwapRoute`, `CachedPathOrMiss`)
and **missed all three `C_WipePure` entrypoints**, which take the object `URHC_WipePure` returns.
That class of error is invisible: arity right, type right, and the call merely wipes the wrong
set of nonces. The derived rule found them; the hand list could not have, because the hand list
is exactly the thing being checked.

## Interface qualifiers are load-bearing here

`RemovableNonces` is **two different schemas** — `DpofUdcV2.RemovableNonces` and
`DpdcManagementV2.RemovableNonces` — returned by **two different readers that share the name**
`URHC_WipePure`, with different arities (the DPDC one takes `son`). Matching on the short name
cited *both* readers for *every* wipe entrypoint. Types are now matched with their qualifier.

Same shape as the 2026-09-2x table-name lesson: **a type qualifier is a wire format.**

## One list that cannot be derived, and how it is kept honest

`SmartSwapPathBundle` is returned by no on-chain read — the schema's own `@doc` says
*"Assembled entirely client-side per P3.7's orchestration sequence"* (`19_SWPU.pact:96`). So it
sits in a manual `CLIENT_ASSEMBLED` table, and `check_client_assembled()` **re-earns each entry
every run**: if any `UR`-family read starts returning the type, the manual entry is reported
stale. The first version of that check matched `U[A-Za-z]*_` and flagged `CachedPathOrMiss`
against `UC_FindStoaPath` — but a `UC_` is pure compute on arguments (prefix table: *"no table
reads"*), so it reshapes paths the client already holds and is not a source of chain data.
`UR` family only.

## Verified, not assumed

- **All 13 cited readers exist in DEPLOYED source**, checked via `describe-module` against
  AQP-FVT / AQP-VCT / DPDC-MNG / DPOF. A cited reader that were repo-only would be the worst
  possible entry: it reads as an instruction, the call fails as a **resolution** error, and a
  resolution error surfaces as a default — so the recipe would silently run on an empty slice.
  This is now folded into `--probe` (free: the sources are already fetched).
- **The parallel claim for the vacate family was checked, not inherited.** `XI_EnsureVacateBegun`
  short-circuits on `UR_VacateInProgress`; `XI_MaybeFinalizeVacate` fires only on
  `URC_PoolFullyVacated`, else returns `finalize-deferred-inventory-remains`. Both idempotent and
  state-guarded, so the auto-finalize tail is correct whichever slice lands last.
- **Both new gate checks were negative-tested**: a bogus citation (missing defun *and* missing
  module) fires the probe check; a stripped `execution` and a forced `preflightUnresolved` each
  fail `--check` with exit 1. Restoring returns surface `e941dd81bbe6ecbf` unchanged — which is
  the evidence that adding the verification changed no data.

## Gate

`_registry.py --check` was already fatal in `_gate.py` (line ~517). It now additionally refuses
an entry with no `execution`, and refuses any indirect entry shipping `preflightUnresolved` —
a named read or nothing, the same discipline the `ownership` field uses (`resolved: false` with
a reason, rather than a guess).

---

# Second finding: the auth-surface baseline had a 29-entrypoint blind spot

Building the execution axis surfaced 17 registry entries with **no `ownership` field at all**, and
they were not a random 17 — 12 were the multi-transaction recipes and 5 were two-segment names.
That pointed at `_authsurface.py`'s entrypoint filter, and it was the cause:

```
^(?:[A-Za-z0-9_-]+\|)?(?:AA|A|CC|C)_[A-Za-z0-9|_-]+$
```

Two independent gaps, verified by running the pattern against real names:

1. `(?:AA|A|CC|C)_` demands `_` straight after the band letters, so `C_`/`CC_` matched but
   **`Cp_`/`CCp_`/`Ap_`/`AAp_` did not** — every multi-transaction recipe.
2. `(?:…\|)?` allows at most **one** `name|` segment, so `ATS|HOT-RBT|C_*` and `MTX-AQP|2|CC_*`
   were missed.

Fixed to `^(?:[A-Za-z0-9_-]+\|)*(?:AA|A|CC|C)p?_[A-Za-z0-9|_-]+$`, tested against 9 must-match and
9 must-not-match names (`CAP_`, `CT_`, `UEV_`, `UCv_`, `P|UEV_IMC` … all still correctly rejected).
Regenerating: **1,196 → 1,225 entrypoints, 29 added, 0 removed.** Gate green at 26,081 assertions,
byte-identical to the run before the change — which is the evidence that seeing 29 more
entrypoints changed no behaviour.

**Why this mattered.** This tool's promise is *"no entrypoint ever stops enforcing something"*.
An entrypoint it cannot SEE is one it cannot report as WEAKENED — so for those 29 the promise was
vacuous, and a silently deleted ownership enforce would have passed the gate. Recipes are the
worst possible 29 to lose, because a recipe runs N times per logical operation. Same blind-spot
class CLAUDE.md already records for `_bandplan.py` (89 reported where there were 482); worth
treating as a recurring failure mode of hand-written entrypoint filters rather than a one-off.

**What the 29 turned out to enforce** — checked, because a new row is worthless unenread. 27 reach
an ownership enforce. Two do not: `FVT.CCp_InjectFixChunk` and `FVT.CCp_SweepRecomputeChunk`. That
is **intentional and coherent**, not a hole:

| function | gate | ownership? |
|---|---|---|
| `CCp_InjectFixChunk` | `FVT\|C>INJECT-FIX` | no — state only (not vacate-frozen, reward link enabled, chunk bounded) |
| `CCp_SweepRecomputeChunk` | `FVT\|C>SWEEP-DRAIN` | no — `UR_FVT\|SweepActive` |
| `CCp_UnstaleAll` | `FVT\|C>UNSTALE-ALL` | **yes** — `CAP_EnforceAccountOwnership (UR_FVT\|OwnerKonto fvt-id)` |

The two cranks are permissionless **because they can only advance a session the owner already
authorised**; `UnstaleAll` has no such prior session to ride on, so it carries the owner gate.
The baseline now records this instead of not looking.

## Next unit: the `ownership` field — root cause now pinned

Still `resolved: false` on all 406 (and now present, not absent, on the other 17). The blocker is
exactly one line, `_authsurface.py:130`:

```python
OWN = re.compile(r'(?:CAP_EnforceAccountOwnership|…)\s+\(?([A-Za-z0-9|_.:-]+)')
```

The `\(?` steps OVER an opening paren and then grabs the first identifier. So for
`(UR_OwnerKonto swpair)` it captures **`UR_OwnerKonto`** — the READER — and throws away `swpair`,
the subject. The artefact's cell therefore mixes account parameters with reader names, and no
amount of filtering downstream can separate them.

Surveying all **147** ownership enforces (comments stripped via the tool's own `strip_code`, since
a naive grep picks up `below`/`proves`/`on` from `@doc` prose — the exact trap its docstring
records) gives **35 distinct argument shapes** in just two families:

- **direct param** — the parameter IS the account: `executor` ×50, `owner-konto` ×20,
  `account` ×17, `fvt-owner` ×8, `sender` ×6, `receiver` ×4, `executee`, `culler`, `merger`, …
- **reader-derived** — the account is LOOKED UP from an entity id: `(UR_OwnerKonto swpair)`,
  `(URC_AqpOwnerKonto pool-id)`, `(ref-RPS::UR_FVT|OwnerKonto fvt-id)`,
  `(UR_SCR|ScoreOwnerKonto score-id)` ×8, `(UR_CreatorKonto id son)`, …

This is precisely the owner's `swpair` objection: the answer was never "`swpair`" (a pool id) —
it is *"the account `UR_OwnerKonto` returns for `swpair`"*.

**The fix is two steps, not one.** (a) `OWN` must capture the balanced FULL expression and a
resolver must split it into `{direct param}` or `{reader, subject}`. (b) The walk is TRANSITIVE
and deliberately so, so an expression found at depth N is written in terms of THAT function's
parameters — mapping it back to the entrypoint's own parameters needs argument threading through
the call, which `surface()` does not do today (it records `(file, defun, account)` but not depth
or the call's argument list). Step (a) alone resolves the enforces that sit in the entrypoint's
own defcap; step (b) is required for the rest. Emit a structured JSON artefact alongside the
markdown and have `_registry.py` consume that instead of re-parsing the table.

---

# Third finding: a FIFTH mode — `defpact` — and how a deleted doc caught it

`git status` showed two files deleted that I had not deleted:
`docs/CHAPTER-INTEGRATION/README.md` and `01-client-orchestration.md`, both added in the previous
commit. Restoring them mattered: `01-client-orchestration.md` (2026-09-24, 255 lines) is the PROSE
version of this exact axis, and it names **four** shapes where I had encoded three-plus-one.

Its shapes I/II/III map onto `indirect-single` / `indirect-parallel` / `indirect-sequential`
exactly — independent confirmation, since it was written from the tree and this was derived from
it. Its **shape IV is `defpact`**, which I had missed entirely: all 10 starters were `direct`.

**Why `direct` was wrong there.** The mode axis reads as being about dirty reads, and a defpact
starter takes ordinary literal arguments — so on the INPUT axis it genuinely is direct. But the
owner's definition is *"with the provided inputs, the function simply executes, **nothing else is
needed**"*, and a defpact needs a CONTINUATION: step 0 runs on submit, the rest advance with
`continue-pact`, a `cont` payload against the same pact id, not a fresh `exec`. A consumer told
"direct" submits once, sees success, and leaves liquidity committed with no LP minted. So the
record now carries `mode: "defpact"` with `steps`, `rollbackSteps`, the pact it starts, and an
`inputs` field preserving the input-axis answer.

**Detection needs two hops.** Talos does not call the defpact — the core module wraps each
`defpact MTX|C_Issue` in a plain `defun C_IssueStablePool`, and Talos calls the wrapper. Matching
defpact NAMES against Talos bodies returns **0 of 10**.

## The bug that this is really a lesson about

My first defpact pass reported **14** starters and `MTX-AQP|2|CC_SweepRevokeAnchor` as having
**0 steps** — while a direct measurement had just shown it has 2. Both came from one cause: I
wrote a fresh `balanced_at()` paren matcher that **does not skip strings**, so a `(` inside a
`@doc` unbalanced it and function bodies ran past their own end into the next function. That
produced four FALSE defpact starters in `TS01-C3` and a body too short to contain its own steps.

Fixed by importing `_authsurface.strip_code` rather than re-implementing it. That stripper exists
precisely because a naive scan once reported an account named `below`, matched out of `@doc`
prose. **Two tools, two independent re-derivations of the same parser, two versions of the same
bug.** Corrected count: **10**, which matches the hand-written doc's enumeration (8 `MTX-SWP` +
2 `MTX-AQP`) — a cross-check I would not have had if the doc had stayed deleted.

Note the shape of the near-miss: the buggy 14 looked MORE complete than the correct 10.

## Fourth finding: four names, two modules, two different modes

Falling out of the above — `TS01-C3` and `TS01-CP` both expose:

| name | `TS01-C3` | `TS01-CP` |
|---|---|---|
| `SWP\|C_AddFrozenLiquidity` | `direct` (via `SWPLC::STOA-PID\|C_AddFrozenLiquidity`) | `defpact`, 3 steps |
| `SWP\|C_AddGlacialLiquidity` | `direct` | `defpact`, 3 steps |
| `SWP\|C_AddIcedLiquidity` | `direct` | `defpact`, 3 steps |
| `SWP\|C_AddSleepingLiquidity` | `direct` | `defpact`, 3 steps |

**Identical signatures, different execution semantics.** The registry keys `MODULE.function` so it
is internally unambiguous, but resolving by BARE name — the precise habit that produced every drift
this registry was built to stop — is silent in both directions: address the defpact believing it
direct and the operation sits half-finished; address the direct one believing it a defpact and
there is no pact for the continuation to continue. Now emitted under a top-level
`nameCollisions` key and printed by `--probe`.

## Final state

`396 direct · 10 defpact · 9 indirect-parallel · 5 indirect-single · 3 indirect-sequential`
Surface `c4f0465e65d306d5`. Gate green at 26,081 assertions across three separate runs
(execution axis, auth-surface widening, defpact mode) — the count never moved, which is the
evidence that none of it changed behaviour.

Also hardened `rpc()` with a transport retry: a probe walks every module over minutes, and a
single DNS blip aborted the run while leaving the previous artefact committed — a failure that
looks loud but ships stale.

---

# Continuations: what a consumer needs, and the thing that surprises people

Owner asked whether the registry should say **how to continue a continuation**. Answer: yes, and
it now does — but the useful half turned out to be the part saying *you never need to*.

## The recipe (now on every `defpact` entry, under `execution.continuation`)

| field | value |
|---|---|
| payload | `cont`, not `exec` |
| `pactId` | from the step-0 result (`continuation.pactId`); **not derivable in advance** |
| `step` | 0-based index of the step to RUN next |
| `rollback` | `false` to advance; `true` only to unwind a `step-with-rollback` |
| `data` | **`{}` — empty** |

`data` is empty because **neither MTX module calls `read-msg` anywhere** — verified by scanning
both for every `read-msg`/`read-integer`/`read-decimal`/`read-string` form: zero hits. State moves
between steps by `yield`/`resume` inside the contract, so no step takes client input.

## The surprise: continuations are NOT gas-sponsored

Chainweb injects `exec-code` **only for `exec` payloads**. A `cont` payload is
`{pactId, step, rollback, data, proof}` and carries none. `DALOS.GAS_PAYER` binds
`(at "exec-code" (read-msg))` **eagerly** in its opening `let`, so on a continuation it raises
`Key "exec-code" not found` before a single one of its checks runs. **Step 0 is sponsored; every
later step is paid by the customer account.**

This matches the owner's 2026-09-15 ruling verbatim (*"the gas station does not pay continuations
in production — the CUSTOMER ACCOUNT does"*), and `tx-type` appears **nowhere** in the tree, so
nothing distinguishes the two cases anywhere in Ouronet.

**The registry was asserting the opposite.** All ten defpact entries carried
`sponsorship.sponsored: true`. Now `"step-0-only"` with the mechanism recorded.

## And the reason you never need any of it

Every one of the ten has a single-transaction twin with a **byte-identical parameter list** —
checked pair by pair, not assumed:

| defpact | twin |
|---|---|
| `TS01-CP.SWP\|C_AddFrozenLiquidity` … `AddGlacial`/`AddIced`/`AddSleeping` | same name on `TS01-C3` |
| `TS01-CP.SWP\|C_AddStandardLiquidity` | `TS01-C3.SWP\|C_AddLiquidity` |
| `TS01-CP.SWP\|C_IssueStablePool` / `Standard` / `Weighted` | `TS01-C3.SWP\|C_IssueStable` / `IssueStandard` / `IssueWeighted` |
| `TS02-C3.MTX-AQP\|2\|CC_Inject` / `CC_SweepRevokeAnchor` | `TS02-C3.AQP-FVT\|CC_Inject` / `CC_SweepRevokeAnchor` |

Emitted as `supported: false` + `preferInstead`, and `--check` now **fails** if a pointer's target
stops existing or its parameter list diverges — negative-tested both ways. A pointer that says
"call this instead" is an instruction; a stale one is worse than none.

---

# Fifth finding: 24 entrypoints silently had NO cost preview — including every launchpad purchase

Auditing "what else is missing" found **25 of 423 entrypoints unpaired**. For **24 of them the
preview EXISTED** and the pairing had silently failed. Among them: **every launchpad purchase**
(`SPARK|C_BuySparks`, `SNAKES|C_Acquire`, `CUSTODIANS|C_Acquire`, `KPAY|C_BuyStoicPay`,
`STOAICO|C_Collect`, both Spark redemptions) and **all four wrap/unwrap ops**. A UI cannot show a
price before signing for any of those — on money-taking flows.

Four distinct causes:

1. **Two-segment category.** `ATS|HOT-RBT|C_Repurpose` — the matcher assumed ONE `|` segment.
   **Same root cause as the `_authsurface` filter fixed hours earlier**, in an unrelated tool.
   Fixed structurally (greedy category on both sides), verified against the committed pairing:
   **0 changed, 0 lost, 3 gained**.
2. **Citizen sales put the preview on the sale module and drop the category segment** —
   `DEMIPAD-SPARK.INFO_BuySparks`, not `INFO_SPARK|BuySparks`. The module name IS the category.
3. **Category aliases** — `LQD|` vs `LIQUID|`; `KPAY` vs `STOICPAY`; `MTX-AQP` vs `AQP-MTX`.
4. **Spelling** — `C_Redem…` vs `INFO_Redeem…`.

Causes 2–4 are an explicit alias table, **not** a looser matcher, and deliberately so: loosening
risks pairing an entrypoint with the WRONG preview, and a wrong price shown before signing is
worse than no price. Every pairing was checked parameter by parameter (`max-cost` is absent from
the sale previews because it is a slippage bound the user sets, not a cost input; `executor` is
named `wrapper`/`unwrapper` in the LIQUID previews — same slot, same type).

**398 → 422 paired.** Stale entries in the table are reported, including a "redundant" warning if
one starts pairing automatically.

## Sixth finding: one operation is priced but has no preview reader at all

`TS01-C1.DPTF|C_ClearDispoForeign` is priced at **51.0 IGNIS** (`02_IGNIS.pact:887`) and has **no
`INFO_` reader anywhere**. That is a gap in the CONTRACT, not in the pairing — a consumer cannot
show its cost before signing, and no amount of registry work fixes it. Now emitted as an explicit
`previewMissing` reason rather than a silent blank, because silence cannot distinguish "free"
from "oversight". **Owner decision needed: add an `INFO_DPTF|ClearDispoForeign`, or rule it
exempt.**

## Seventh: return types were not captured at all

`params` told a consumer what to send and nothing told it what comes back. Now `returns`:

`303 undeclared · 102 string · 7 OutputCumulator · 6 list · 5 [string]`

The 303 are a real property of the code, not a scan failure — `TS01-CP` declares no return types
where `TS01-C3` declares `:string`. Emitted as `null` with a `returnsNote` saying the shape is not
pinned by the signature, which is the honest answer.

Final surface `d603869ec693d91d`. Gate green at 26,081 across four runs.

---

# Closing the preview gap: INFO_DPTF|ClearDispoForeign + PureV2/20

Owner: *"if we are missing INFO functions in the deployed pact code, you gotta write them, and
make me a deploy file next in the row."*

## CORRECTED — the owner caught the framing, and the correction is the useful part

Owner: *"how the hell was that client function missing its info function? and that was a function
we already had on OuronetUI so it had to have already had an info function."*

**Right on both counts, and my first write-up implied otherwise.** The UI function is
`DPTF|C_ClearDispo`, wired in `ClearDispoCFMModal.tsx` against `INFO_DPTF|ClearDispo`. That pair
has existed since the INFO unification and **has never been broken**. Nothing in the UI regressed
and nothing is broken today.

What actually happened: on **2026-09-21**, commit `8df60099` (the patron/executor canon sweep,
`09_TFT`) **SPLIT** the existing entrypoint in two —

```
- (defun DPTF|C_ClearDispo (patron:string account:string))
+ (defun DPTF|C_ClearDispo (patron:string executor:string))
+ (defun DPTF|C_ClearDispoForeign (patron:string executor:string executee:string))
```

The self variant kept its INFO. The **new** foreign variant is five days old, got its 51.0 price
entry **in that same commit**, and never got an INFO. It reaches OuronetUI only as a row in the
generated signature manifests — no component calls it.

So this was never "a live function lost its preview". It was **a new entrypoint born without
one**, and it reached mainnet priced and unpreviewable.

### Why nothing caught it, and why that is repeatable

The price table (`2_Core/02_IGNIS.pact`) and the INFO readers (`Z_Reads/02_INFO-ONE+.pact`) are
in **different files**. The sweep touched the first and not the second, and nothing compared them.
Every ingredient recurs: splitting an entrypoint is routine work, those two files are always
apart, and the symptom — a UI that cannot quote a price — only appears whenever someone finally
wires the new variant, which may be months later.

**Now gate-enforced.** `_registry.py --check` fails on any client entrypoint that has no cost
preview and no reasoned `PREVIEW_EXEMPT` entry. The single current exemption is **self-clearing**:
it names PureV2/20 as the reason, and the check ALSO fails once the entry starts pairing, telling
the next person to delete it. Negative-tested in all three directions — a new gap appearing, a
stale pointer, and the exemption outliving its cause.

### And it is the only one

Checked every one of the 423 client entrypoints against both the price table and the INFO
readers. **Exactly one** was priced without a preview. A 46-module sweep produced a single gap.

## The audit — the gap is ONE function, not many

Cross-referenced **all 483 IGNIS price keys** against **all 426 `INFO_` readers** in the tree.

- **87** price keys are unit COMPONENTS (`tier-small`, `r-l`, `issue-tf`), not operations — no
  preview is correct for these.
- **13** priced operations had no exactly-named reader.
- **12 of those 13 have one under a different name** — the alias cases already folded into the
  registry's `PREVIEW_ALIAS` table.
- **1 genuine gap: `DPTF|C_ClearDispoForeign`**, priced 51.0 at `02_IGNIS.pact:887`, with no
  `INFO_` reader anywhere.

So the answer to "write them" is "write one", and the audit is the evidence for that number.

## Module-only, and why that is not a shortcut

`InfoOneV2` is deployed and a deployed interface cannot be changed. Declaring the function there
means `InfoOneV3` plus the full cascade — for one read nothing on chain calls.

Module-only is legal (`implements` constrains module ⊇ interface, not equality), is **already
practice in this exact module** (`INFO_VST|HibernatedNonceDisplay` and `…NoncesDisplay`, 2 of
180), and costs nothing here: a tree-wide search for `::INFO_` returns **zero hits**. Every
`INFO_` reader in Ouronet is called off-chain over `/local`. Nothing reaches one by modref, so
the only thing module-only would forfeit is unused.

## The one way the function could have been wrong, and the test that pins it

`URCi_ClearDispo` takes ONE account. It must be the **executee** — whose dispo is cleared and
whose Elite-Auryn is force-spent at 2.5x. Passing the **executor** would price a different
account's debt, and since both are valid account ids it returns a **plausible number rather than
failing**. No shape check and no cost check can catch that.

`[6.2]_DPTF.repl`, inserted BEFORE "Dispo 2|x" (which clears the dispo — both readers enforce
`(< ouro-a 0.0)`, so a test placed after it would assert nothing while still passing):

| tag | asserts |
|---|---|
| `<<TX-DPTF-CDF-01>>` | foreign `ignis` block equals the self one exactly — shares the cost source rather than re-deriving |
| `<<TX-DPTF-CDF-02>>` | **swapping executor/executee is REFUSED** — if this ever passes, the reader reads the wrong account |
| `<<TX-DPTF-CDF-03>>` | the foreign narrative NAMES the executor and the self one does not — that audit trail is the only thing the variant adds |

Runs under `ZALL.repl`; `Z.repl` takes the issuance-only DPTF variant and does not reach it.

**Two mistakes while writing the test, both instructive.** First `INFO-ONE.OI|UC_ShortAccount` —
that helper is on **IGNIS**, which implements `OuronetInfoV2`. It surfaced loudly (`no such
member`) only because it was a direct qualified call at load; through a modref it would have been
a silent runtime default. Second, `(at "info" …)` — the field is `pre-text`. Neither would have
been caught by anything except running it.

## PureV2/20

Registered in `_purev2.py`'s MANIFEST as `module-only` — so the body is GENERATED from the source
and `--check` keeps them identical, rather than hand-copied and free to drift.

- **227,541 bytes / 4,095 lines** — inside the 320,000-byte conservative cap
- **366,551 gas — 18%** of the 2,000,000 budget

Both MEASURED, by loading the emitted file on top of a full Stage-01 so the load is a genuine
**upgrade**. That matters: a first deploy does not evaluate `GOV`, an upgrade does, and this one
needs **`ouronet-ns.dh_master-keyset`** (Demiurgoi) — the namespace admin key is refused at
`GOV|INFO|DPTF_ADMIN`. The first two measurement attempts failed exactly there, which is the
check working.

**The registry will not pair it until it is deployed** — `--probe` reads `describe-module`, and
deployed code is the authority. That is correct behaviour, not a lag to work around.

## Gate: three-pass convergence

Three new assertions moved the count 6,081 → 6,084, and three artefacts quote it in a chain:
`_suite_stats.py` → `Audit/records/REPL-ROUND-REPORT.md` → `OURONET-AUDIT-BOOK.md` (+PDF/DOCX).
Each pass surfaced exactly one stale consumer. Worth knowing the chain is three deep, not two.

## The two-artefact split, demonstrated

After writing the function, before deploying it:

| artefact | reads | previews | has the new one? |
|---|---|---|---|
| `Deploy/TALOS-ABI.json` | **sources** | 428 | yes |
| `Deploy/OURONET-REGISTRY.json` | **chain** (`describe-module`) | 427 | **no** |

Both are right. The ABI answers "what does this repo define"; the registry answers "what can a
consumer call today". `DPTF|C_ClearDispoForeign` therefore still shows `previewMissing` in the
registry, and will pair on the first `--probe` after PureV2/20 lands. A registry that advertised
it now would be advertising a function no node can resolve.

## Gate: the artefact chain is FIVE deep, not three

Adding one function to one sovereign source required, in order, each surfaced only by the
previous failing:

1. `_suite_stats.py` — assertion count 6,081 → 6,084
2. `Audit/records/REPL-ROUND-REPORT.md` — quotes that count
3. `_auditbook.py --docx` — assembles that report (MD + PDF + DOCX)
4. `_deploybundle.py --write` — `Deploy/1_Pure/11_deploy.pact` carries INFO-ONE (+62 lines, one
   new defun — verified the diff is ONLY the new function)
5. `_talosabi.py --write` — 427 → 428 previews

Final: **GATE GREEN at 26,120 assertions** (up 39 from 26,081 — the 3 new ones plus the
`RT-K PreviewParity` sweep, which iterates over previews and so grows when one is added).

Worth writing down because the natural assumption after step 2 is that you are done.
