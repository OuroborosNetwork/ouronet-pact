# Red Team — running report

*Audit-paper source material. One section per stage, written as each stage closes.*

Everything in the constructive suite asserts that **documented behaviour holds** and that
**documented refusals fire**. This programme asks the opposite question: *what can someone do that
nobody documented?* The suite lives in `REPL/RedTeam/`, is gated like any other entrypoint, and its
method is fixed in `REPL/RedTeam/README.md`.

**The register is the honest summary.** An adversarial suite is uniquely bad at self-reporting: an
attack that was never written and an attack that was refused both show up as a green gate. So every
block carries a machine-read `FAMILY` / `STATUS` header, `REPL/tools/_redteam.py` builds the register from
those, and the gate **fails** on a malformed header — a shrinking register looks exactly like a
clean one.

    python3 REPL/tools/_redteam.py          # attempts by family and outcome
    python3 REPL/tools/_redteam.py --md     # the table for this document

## Method, and why it is shaped this way

**Pin the exploit before fixing it.** Fix on discovery and you are left holding only the
"attack refused" half; a reader has to take your word it was ever exploitable. Pin first and one
block shows both states — the measured exploit in its comment, the measured refusal in its
assertions. This earned its place on the first finding: `RT-A-001`'s pre-fix measurement
(53.0 against 557.03) exists only because it was taken before the repair.

**Probe before pinning.** Run the attack as an open experiment, observe, *then* write the
assertion. Writing the assertion first biases the experiment toward the expected answer — and an
attack you expect to fail is an attack you will accidentally arrange to fail. This also earned its
place immediately: the first draft of `RT-A-001` targeted a pool id that does not exist in the
fixture. Had the assertion been written first, the attack would have "failed" for a reason with
nothing to do with the defence.

**A red-team `expect-failure` must check the message.** "The attack was refused" is worthless if
the code refused for an unrelated reason. That is the shadowed-guard trap, which accounts for 36 of
this project's recorded defects.

**Fix policy.** Findings are pinned as-observed and fixed in a pass at the end of their stage, so
the whole class is visible before a fix is chosen. The exception is anything exploitable now with
value at risk, fixed immediately — a live exploit must not sit in a backlog, and leaving it live
corrupts the state later attacks run against.

---

## Stage 0 — verify the backlog before attacking

Red-teaming over an unknown backlog produces findings nobody can act on, so the 28 entries marked
**open** in `DEFECT-LEDGER.md` were first re-verified against source as it exists today. Three
agents worked in parallel, split by class.

**Outcome: all 28 confirmed open — none had been silently fixed — plus eight factual corrections to
the ledger, one refuted escalation, and one live finding that was not in the ledger at all.**

### The refuted claim, and why it matters more than the confirmed ones

One agent escalated **P-13** to *"every `STOA|C_Collect` in the codebase is currently a no-op"*,
reasoning from the genesis seed line `native-gas-toggle: false`. The mechanism it described is
real — `STOA|C_CollectWTEx` wraps its four transfers in `(if (not trigger) …)` and `trigger` is
`(URC_IsNativeGasZero)`, so a false toggle would indeed disable all STOA collection.

Measured directly on the live fixture: **`native-toggle=true`, `IsNativeGasZero=false`.** Collection
is active, which is consistent with an independent measurement taken the same day
(`modules/VST.repl <<VST-I1>>`, 76.5 STOA observed moving). The agent read the seed and missed the
flip.

The base P-13 defect stands, and inverts the escalation: seven branding sites pass a hardcoded
`trigger=false`, so they collect **regardless** of the global toggle — an administrator disabling
native gas would find branding still charging.

This is recorded prominently because it is the second time in this project that a plausible,
mechanically-correct chain of reasoning produced a false conclusion about coverage (the first being
a "78 unreached guards" worklist that was an artefact of one tool answering a question it does not
ask). **The correction in both cases came from measuring, not from re-reading.**

### Ledger corrections

| entry | correction |
|---|---|
| M-08 | 6 message sites, not 7 — the count included the `defconst` line |
| M-11 | over-classed; a duplicate of G-33 |
| R-02 | understates `DPL-UR` (12 hardcoded ids across two deployment hashes), miscounts EXPLORER's derived ids, and attributes a header to a file that does not carry it |
| R-04 | names the wrong file (`URC_PoolValueFromGraph` is in `16_SWPI.pact`) |
| G-29 | wider than recorded — the three outer messages are mute too |
| G-30 | narrower than recorded — the annotation overstates the call sites |
| G-33 | the framing is a misread; the rule *is* enforced one line lower |
| GS-01 | **mechanism misread**, with a larger defect underneath — see below |
| P-14 | count correct; two citation errors |

### GS-01 — the misread that concealed a bigger defect

The row attributed a `$1.00` published floor for five add-liquidity ops to the known
"literal-counted-as-a-price" generator bug. It is not that: the `literal 100` is a faithful reading
of real code. The actual defect is in `_ignis_price_sheet.py:38`, where the `CLIENT` pattern is
anchored `^` with no optional `ENTITY|` prefix — so **nine real client entrypoints are silently
skipped**, including `SWP|C_AddLiquidity` and all three `ATS|HOT-RBT|*`, and never counted in the
sheet's own "420 priced, 0 unresolved" claim. The sibling generator already carries the fix and its
docstring names this exact bug class.

Both generated artefacts are additionally **stale**: the price sheet differs in 15 rows from a fresh
regeneration with 5 rows regressed to `?`, contradicting the "0 unresolved" claim these documents
feed into the published Chapter-2 material.

### Fixed during Stage 0

Two actively-misleading messages — the class where a reader can *act* on the message and be sent
the wrong way, as distinct from a message that is merely terse:

- **DEMIPAD type-3 deposit** enforced `iz-ouro` and reported *"SSTOA Deposits must be turned on"*.
  SSTOA is a real, separately-togglable admin flag, so an operator could perform the suggested
  remedy, observe nothing change, and retry forever. Its pin now demands **different** text per
  branch — with identical wording, a test that swapped the two branches would still pass.
- **Snakes acquisition** had no nonce guard, so an unsellable nonce was refused by the *supply* cap
  with text identical to a genuine over-buy. Its Custodians twin had `UEV_AcquisitionNonce` from the
  start; Snakes now carries it.

### Targets this stage produced

| target | why it is first-rank |
|---|---|
| **G-34 / V-03** | `UEV_SwapData` runs **only on the slippage branch**. With `slippage = -1.0` the real gate is `SWPU\|X>SWAP` — no uniqueness, no count bound, no "output ∉ inputs". Attacker-drivable through `C_Swap`. |
| **V-01** | slippage unbounded in *both* directions; the `@doc`'s "≤ 50" is UI policy the chain never runs, and the on-chain ceiling is opt-in and disabled by a negative sentinel. |
| **`GAS_PAYER` Case 3** | validates exec-code forms 0, 1 and 2 only; forms at index ≥ 3 are unconstrained and form 2 need only *start with* `(let`. The only bound is economic. |

---

## Stage 1 — Family A, arithmetic & value

### RT-A-001 — the LP-churn deterrent could be declined *(FIXED)*

**Hypothesis.** Adding standard liquidity is reachable through two live Talos client paths, and one
does not charge the `lp-churn` deterrent. If so the deterrent is optional: a provider pays it only
by choosing the more expensive door.

**Confirmed, measured before the fix:**

| route | charged |
|---|---:|
| `TS01-C3 → SWP\|C_AddLiquidity → SWPLC` | **557.03** (1051.0 raw at a 0.53 discount) |
| `TS01-CP → SWP\|C_AddStandardLiquidity → MTX-SWP` | **53.00** (a flat literal 100.0) |

Same operation, same pool, **10.5×**. Both routes are `P|UEV_IMC`-gated Talos clients, so this is
not a matter of calling core directly — and the cheaper door is the one the gas station subsidises.
`lp-churn` appeared **zero times** in `20_MTX-SWP.pact`.

**Why it survived, and this is the transferable part.** An earlier repair moved every add-liquidity
op onto `UC_IgnisPrice`; it landed in `18_SWPLC.pact` only. Nothing compared the two modules
afterwards, and nothing could have: the suite measured each route against **its own** preview, and
both routes agreed with themselves. Preview-versus-charge testing — however rigorous, and this
project has 397 such measurements — cannot see this class. It asks *"does this route quote what it
charges"*. The unasked question is *"do two routes to the same operation charge the same"*: a
**cross-route** invariant, not a per-route one.

**Fix.** Step 0 of all three add-liquidity defpacts now bills `UC_IgnisPrice … "lp-churn"`, with
`UC_AddLiquidityChurnKey` selecting Standard/Iced/Glacial from the same two collection flags that
already decide which variant is running. The Frozen and Sleeping twins carried the identical gap and
were repaired with it.

**Deliberately not changed.** The three `step-with-rollback` branches still charge the flat 100 — a
rolled-back step did not perform the operation, so charging the full deterrent is a design choice,
not a defect. `MTX|C_Issue`'s flat 100 is a *different* operation with a different deterrent and was
left for a ruling rather than guessed at.

**Verification.** The block measured 557.03 = 557.03, and the two assertions that encoded the
exploit went red at the moment of repair — evidence a fix-first approach cannot produce.

**Re-verified end to end, 2026-09-14, and the assertion is now exact.** The original pin compared
**step 0 alone** against a whole-operation figure, which was the best available before a defpact
could be bracketed. After the `RT-F-001` ruling split the fee across steps, that comparison stopped
describing the op at all — step 0 is now small *by design*. Re-pointed at the TOTAL, where a bypass
would now have to hide, and stated as an equality rather than an inequality:

| | measured |
|---|---:|
| defpact door, all three steps (`TS01-CP → MTX-SWP`) | **1318.83** |
| single-tx door, same pool, same inputs (`TS01-C3 → SWPLC`) | **1318.83** |
| `ignis-need` quoted + declared asymmetry tax (1118.83 + 200.00) | **1318.83** |

Two doors, one price — the cross-route invariant this finding is about, now measured rather than
inferred from a single leg. The identity `total == quoted + declared principal` is the same one
`modules/SWP.repl` `<<SWP-I14>>` pins for the single-tx door; `<<DPB-01>>` states it for the
multistep door for the first time.

*A caution recorded against myself: the 200.00 term initially looked like a fresh under-quote and was
very nearly written up as one. It is the Asymmetric-Liquidity TAX — principal, not gas — and this
codebase's own `UC_LiquidityTaxDeclaration` `@doc` already records the identical pair of figures,
1118.83 quoted against 1318.83 leaving the account. Arithmetic that looks like a discovery should be
checked against the source before it becomes a finding.*

*Footnote worth keeping: the exploit assertion itself first failed on a three-argument `(* a b c)`.
Pact's `*` is binary — the same arity trap this project's ledger already records for a
three-argument `or`.*


### RT-E-001 — the STOAICO dust sweep, and who counts as "last" *(REFUSED — the reader FIXED)*

**Hypothesis.** STOAICO pays the last unclaimed staker the **whole remaining vault** rather than
their computed share — a dust sweep, so nothing is stranded. "Last" is decided by
`unclaimed-count`, which is set to `nzs-count` **only at inject**. A contribution recorded mid-round
moves `nzs-count` without moving `unclaimed-count`, so an account owed nothing should be able to
collect while the counter still reads 1 and take the vault out from under its rightful claimant.

**Half of it is true, and that half is pinned.** After a legitimate admin action — recording a late
1.0 v-USD contribution — the counters diverge exactly as predicted, and the reader offers the entire
vault to an account owed nothing:

    unclaimed-count = 1        nzs-count = 2 -> 3          <- diverged
    URC_AvailableRewards(newcomer) = 0.000000000000        <- owed nothing
    URC_ClaimableRewards(newcomer) = 690.525983513596      <- offered the ENTIRE vault

**What stops it is one stamp, and it is deliberate.** `A_Stake`'s insert for a new contributor sets
`last-collected-round` to the *current* distribution-round, and the collect cap enforces
`(< last-collected-round distribution-round)`. A newcomer is born already-collected for the round
they joined. The source comment says so outright: *"a (mis-ordered) post-inject stake is not
eligible for the already-injected round."* Someone modelled this attack and closed it at the
eligibility layer.

**FIXED 2026-09-14, on the owner's ruling that a wrong reader is an error whether or not it is
exploitable.** The branch was

```pact
(if (= (UR_Global7) 1) (UR_Global4) (URC_AvailableRewards account))
```

`UR_Global7` is `unclaimed-count` — a property of the **vault**. The condition asks *"is exactly one
claimant left?"* and never *"is **this** account that claimant?"*, so it **tested a global and
returned a per-account answer**. `URC_IzDustSweepClaimant` now adds the two missing O(1) conditions:
this account is a real staker, and it has not already collected this round.

The measured line inverts, and the counters still diverge — the fix is to the reader, not to the
accounting quirk that exposed it:

    before   post-stake: unclaimed=1 nzs=3  newcomer-owed=0.000000  newcomer-OFFERED=690.525983
    after    post-stake: unclaimed=1 nzs=3  newcomer-owed=0.000000  newcomer-OFFERED=0.000000

**The non-vacuity arm is essential here and is now pinned.** Returning `0.0` to everyone would
satisfy the repair while destroying the dust sweep, whose entire purpose is that the LAST claimant
receives the remainder so rounding residue is never stranded. `<<RT-E-001>>` therefore also asserts
that the rightful claimant still collects the whole vault, and that the newcomer is correctly *not*
the sweep claimant.

**Why the block existed even while the theft was impossible.** The theft is prevented by a single
stamp, written in a different function from the one computing the dangerous number, with no
assertion previously connecting them.
`URC_ClaimableRewards` also feeds presentation paths, where it will state a figure the account
cannot have. If that stamp ever changes — a newcomer starting at round 0 reads like harmless
initialisation — this becomes a live theft primitive with nothing else in the way. The block pins
**both halves**, so the day the stamp moves the finding assertion goes red and names what broke.

**The method caught an error inside the red-team suite itself.** The first run recorded the attack
as refused — by `Keyset failure (keys-all): [PK_Byta...]`. The attacker's key had not been signed,
so the collect died at ownership, nowhere near the defence under test. **A bare `expect-failure`
would have recorded a defence that does not exist.** That is the shadowed-guard trap reproduced
inside the adversarial suite, on its second attack, and it is the clearest possible argument for the
message-checking rule.


---

## Stage 2 — Family F, griefing and denial of service

### RT-F-001 — one ordinary swap destroys a stranger's add-liquidity fee *(SUCCEEDED — FIXED)*

**Hypothesis.** `MTX|C_AddLiquidity` collects its entire deterrent in **step 0**, then validates in
**step 1** that the pool has not moved since it quoted. `PoolState` includes the pool's **token
supplies**, which every swap changes. So any stranger's ordinary trade should permanently invalidate
an in-flight add — *after* its fee is paid, with no refund.

**Confirmed, measured:**

    step 0   victim pays                                       557.03 IGNIS
             pool supplies unchanged (step 0 only quotes)
    attack   one SWP|C_SingleSwapNoSlippage by another account
             supplies move  [798.4087…, 901.5915…, 850.0]
                         -> [798.3981…, 903.5915…, 848.0213…]
    step 1   "Execution Step of Adding Liquidity cannot execute on altered pool state!"
             victim's 557.03 is NOT returned

**The guard is correct and must stay.** Executing a quote against a moved pool is how a liquidity
provider silently gets a worse ratio than they agreed to; `modules/SWP.repl <<SWPX-10>>` already
pins that it fires. **What nothing pinned is what it costs the victim when it does.**

**The defect is the ORDER of fee and validation, not the validation.** Money moves in step 0; the
condition deciding whether the operation can happen at all is checked in step 1. On a pool with any
trading activity the defpact add is not merely grief-able — it is **unreliable by construction**,
because `PoolState` equality is exact and includes supplies. The attacker's cost is a normal trade;
they need no knowledge of the victim beyond the fact that adds are in flight, which on a public
chain is visible.

**RESOLVED 2026-09-14 (owner ruling).** Step 0 now takes only `LQ|INITIATION-FEE` (100.0 raw), and
the lp-churn **remainder** is collected in the execution step, after the pool-state check has passed.
The total across the pact is unchanged — so neither Talos door is cheaper than the other and
`RT-A-001`'s repair still holds — but what one stranger's swap can destroy falls from **557.03 to
53.00 net**, a factor of 10.5. Measured end to end at `modules/DEFPACT-BILLING.repl` `<<DPB-01>>` and
re-pinned at `<<RT-A-001>>` as an exact identity: `total == quoted + declared tax`.

The fee is still **not refunded** on the failed step, and this report does not claim otherwise. The
ruling was to split the fee, not to refund it; the residual exposure is now one initiation slice, and
the multi-step add-liquidity path is in any case retained only for historical continuity now that
StoaChain's ~2M gas limit lets the single-tx door do the whole job in one transaction.

**This finding is a direct consequence of `RT-A-001`'s repair, and that must be stated plainly.**
Closing the churn-deterrent bypass raised this step-0 fee from a flat 100.0 to the real 1051.0
deterrent — correctly, since the cheap door let providers decline the deterrent entirely. But the
same change **multiplied the griefing payoff by ten**: what one swap destroys went from 53.0 to
557.03 net. The trade is still worth making — an optional deterrent is worse than an expensive one —
but a fix with a second-order cost should be recorded at the moment it is made, not discovered
later by someone else. This is the argument for red-teaming *after* a repair pass rather than
before.

**Recommended, not applied:** collect the deterrent in the step that **succeeds**, or refund it on
the rollback path. Both change when money moves inside a defpact — a design decision, not a
transcription fix — so it is left for an owner ruling. The block pins present behaviour meanwhile,
and will go red the day the ordering changes.


### Hydra slice replay — investigated, no attack block written *(and why that is the right outcome)*

**Hypothesis.** The architecture documents `Cp_`/`CCp_`/`Ap_`/`AAp_` as *"fed one slice of a `URH_*`
dirty-read plan, order-independent, retryable, fired **in parallel**"*. If a slice can be **replayed**
or applied **out of order**, work is double-applied or skipped. Nothing in the suite tested that
claim.

**What the investigation found instead — a documentation defect, not an attack.** There are exactly
**three** Hydra functions in the tree, and they do not agree with each other:

| function | argument | actual shape |
|---|---|---|
| `DPTF::Cp_WipeSlice`, `DPOF::Cp_WipeSlice` | an explicit `removable-nonces-obj` **slice** | fed-slice — order-independent, parallel-safe, exactly as documented |
| `AQP-FVT::CCp_SweepRecomputeChunk` | a chunk **size** | **cursor pager** — reads `FVT\|SweepProgress`, computes its own window `[offset, min(offset+chunk, total))`, advances the cursor |

The sweep chunk is **strictly sequential**. It is not fed a slice, and two cannot be fired as
independent units — the second reads the cursor the first advanced. Its own `@doc` is honest
("PAGE a paginated re-score sweep … advancing the cursor"); the *prefix contract* overstated.

**No exploit.** The obvious attacks are closed by construction: `FVT|C>SWEEP-DRAIN` enforces
`(and (> chunk 0) (<= chunk SWEEP-CHUNK-MAX))`, so the cursor cannot be driven backwards by a
negative chunk; and because the window derives from stored progress rather than an argument, a
replay simply pages forward rather than re-applying. Completion is enforced by `offset` reaching
`total` before any pool unfreezes.

**Why no block was written, and this is a deliberate methodological point.** The chunk bound is
**already pinned twice** (`Kursan/AQP-scale-sweep.repl:215`/`:219`). Writing a red-team block that
re-asserts an existing guard would inflate the attack register with a test that discovers nothing —
and the register's only value is that its numbers mean something. **Not every investigation yields
an attack; recording that honestly is what keeps the count trustworthy.**

**Fixed:** the prefix contract in `CLAUDE.md` and `StoicSyntax-Prefixes.md` now describes both
shapes and tells a reader to check which one they have before firing N at once. The prefix is the
only thing a client author consults before deciding whether they may submit concurrently — for a
fed-slice they may, for a pager the concurrency buys nothing and the mental model is wrong. The
correction closes with the rule that caused the drift: *if a third shape appears, give it its own
letter; overloading `p` to mean "multi-transaction" rather than "parallel" is how this happened.*


---

## Stage 3 — Family G, the hostile citizen module

This is the family the architecture **invites**. `2_CITIZEN/` is documented as extension modules
*"anyone can write"*, calling only into sovereign public APIs. That is a deliberate and valuable
design choice, and it is also the largest attack surface in the system: every other family assumes
an attacker with an account; this one assumes an attacker with **code deployed beside yours**.

So this stage does not simulate an adversary. It **deploys one**, in a namespace anyone can write
to, and attacks the sovereign core the way a real one would.

### Establishing the attacker's position honestly

- **`ouronet-ns` is closed.** A module load into it fails with `Keyset failure (keys-any)` —
  verified, not assumed. `init-phase-01-ns.repl:56` defines it with `(keyset-ref-guard
  "ns-operate-keyset")` for both the user and admin guard. A hostile module cannot sit *inside* the
  sovereign namespace.
- **`user` is open by construction** — `(define-namespace "user" ns.GUARD_SUCCESS ns.GUARD_FAILURE)`,
  exactly as the equivalent namespaces are on a live chain. The real adversary deploys *beside* the
  system and calls across, needing no privilege at all.

### RT-G-001 — calling sovereign clients directly, cumulator discarded *(REFUSED)*

**Hypothesis.** A module in an open namespace can call a sovereign `C_` directly, discard the
returned `OutputCumulator`, and perform a real state change nobody was billed for — because IGNIS is
collected in **Talos**, and this path never enters it.

**Result.** `TFT::C_Transfer` and `DPTF::C_Mint` both refused by `P|UEV_IMC` →
`"None of the guards passed"`, message-checked so the refusal is provably the intended guard.

**The mechanism is sound, not lucky.** `P|UEV_IMC` passes only on capability guards over
capabilities that **only the owning module's own code can bring into scope**, and a foreign module
cannot acquire another module's capability in Pact. Registration is closed as well:
`DALOS::P|A_AddIMP` requires `GOV|DALOS_ADMIN`.

**Whole-surface scan, not two samples.** Of the **290** `C_`/`CC_` implementations across the
sovereign core, **289 carry `P|UEV_IMC`**. The single exception is `IGNIS::C_TransferDalosFuel`,
attacked separately below rather than taken on trust.

The block carries a non-vacuity assertion that matters more than usual here: the hostile module
**can** read the sovereign core. Without it the refusals would only prove that cross-namespace calls
fail, not that the gate works.

### RT-G-002 — draining the gas station through the one ungated entrypoint *(REFUSED)*

**Hypothesis.** `C_TransferDalosFuel` has no `P|UEV_IMC` and its body is a bare `coin::transfer`
with the sender taken straight from the argument. If the coin layer can be satisfied, a foreign
module moves native STOA out of any account it names — including the **Ouronet gas station**, which
would stop the chain paying for anything.

**Three escalating attempts, each pushing one layer further:**

| # | attempt | refusal |
|---|---|---|
| 1 | call it cold | `Managed capability not installed` |
| 2 | **sign and install** `coin.TRANSFER` naming the station as sender | `Capability not acquired: CapabilityGuard {name: ouronet-ns.DALOS.DALOS\|NATIVE-AUTOMATIC}` |
| 3 | confirm the refusal names DALOS's own capability | same, and the balance is untouched |

**Attempt 1's refusal is not the defence, and saying so is the point.** It sounds like one, but an
attacker removes it themselves — signing a capability for an account you do not control is *allowed*
and installs the managed cap. Attempt 2 does exactly that.

**What actually holds is attempt 2's failure.** The gas station's STOA account is a **`c:` principal**
whose guard is `(create-capability-guard (DALOS|NATIVE-AUTOMATIC))`, so `coin.pact:144`'s
`(enforce-guard (UR_Guard sender))` demands a **capability in scope, not a signature**.

> **An attacker holding every private key in the system still cannot move the gas station's funds.**

That is a stronger property than "the entrypoint is gated" — it is not gated. Its authorisation is
*delegated* to a guard that is unsatisfiable from outside the owning module. Why the entrypoint has
no gate is also defensible: it is a **primitive** through which every `STOA|C_Collect*` path funnels,
so gating it with `P|UEV_IMC` would gate the collector against itself.

The signed account literals are pinned against the derived accounts, so if the fixture ever moves,
the attack fails loudly at the assertion rather than silently aiming somewhere harmless.

### Family G assessment

The inter-module boundary is the **best-defended surface tested so far**:

| property | status |
|---|---|
| `ouronet-ns` closed to deployment | verified |
| core client entrypoints gated | **289 / 290** |
| the 290th | safe by delegation to an unsatisfiable guard |
| policy registration | `GOV|DALOS_ADMIN` only |
| a real deployed adversary | refused by the intended guard, message checked |

**The one documented hole is `X-01`**, and it is not closed by anything above: the genesis sequence
registers the **master keyset itself** as a DALOS inter-module policy, so a master-key holder
satisfies `P|UEV_IMC` **without being a module**, and anything done on that path is **unbilled**
because it never enters Talos. It is probably deliberate — the bootstrap must reach DALOS core ops
before Talos exists — but it is the single exception to an otherwise complete boundary and it is
undocumented at every call site. Pending an owner ruling.


---

## Stage 4 — Families B, C, D: the authorisation surfaces

### A correction to method, made before any of these results

Families B and C were first approached with two whole-surface scans, which reported
*"102 `XI_`/`XB_` implementations without `require-capability`"* and *"31 of 42 `A_`/`AA_` with no
admin guard"*. **Both numbers are wrong and neither was reported.** Authorisation in this codebase
is **compositional** — `A_ToggleGAP` acquires `GOV|GAP`, which `compose-capability
(GOV|DALOS_ADMIN)` — and the scans looked one level deep.

That is the **third** time in this programme that a naive static scan produced a misleading safety
number, after the "78 unreached guards" worklist and the "every `STOA|C_Collect` is a no-op" claim.
The pattern is consistent enough to state as a finding in its own right:

> **In a codebase with compositional authorisation, one-level static scans systematically
> under-report safety.** The only instrument that cannot make this error is execution: the chain
> either refuses you or it does not.

Families B, C and D were therefore driven entirely by attack rather than by scan.

### RT-B-001 — the master key reaches core without Talos, and pays nothing *(SUCCEEDED)*

This settles **X-01**, which had been carried as an unresolved owner question.

    ordinary key  ->  "None of the guards passed"        the gate holds for users
    master key    ->  OURO source price  0.0 -> 0.5
                      IGNIS charged      0.0000

`P|UEV_IMC` is described as an **inter-module** gate. Genesis registers the **master keyset itself**
as a DALOS policy, so a key holder satisfies it without being a module, reaches DALOS core directly,
and pays nothing because Talos — the only place IGNIS is collected — is never entered.

**Bounding the severity precisely:** this is not theft. The same key cannot operate the collector
against a third party; `IGNIS::C_Collect` enforces the payer's own account ownership. *Skipping your
own toll needs nobody else's signature; charging someone else's does.* The reachable damage is
**unbilled admin activity**, not drained users.

**Why it is pinned anyway:** the op reached is a **price input** feeding gas economics; the exception
is invisible at every call site; and it is the single way through a boundary that `RT-G-001` measured
at 289/290. It is probably deliberate — the bootstrap must reach DALOS before Talos exists — and that
is exactly the argument for pinning it. **An intended exception that no document mentions is
indistinguishable from an unintended one at review time.** Owner ruling pending.

### RT-C-001 — eight admin wrappers driven as a stranger *(REFUSED, one shadowed gate — now FIXED)*

`TS01-A`'s 30 admin wrappers do **not** gate uniformly:

| gate | count | is it authorisation? |
|---|---:|---|
| `P|ADMINISTRATIVE-SUMMONER` (composes `GOV|TS01-A_ADMIN`) | 11 | yes |
| `P|TS` — and `(defcap P|TS () true)` | **15** | **no: it grants itself** |
| `GOV|TS` | 2 | yes |

For those fifteen the Talos layer contributes no authorisation at all; only the core function stands
between a stranger and the operation. That is the shape that made `ORBR|A_Fuel` exploitable, so it
was driven rather than reasoned about. Eight were attacked, chosen for blast radius. All refused.

**Seven refused for the right reason; one did not, and that is the useful result.**
`DPTF|A_WipeTreasuryDebt` answered `"Cannot Wipe Positive Treasury Balance"` — a business guard:

    (enforce (< treasury-supply 0.0) "Cannot Wipe Positive Treasury Balance")   ;; 402
    (compose-capability (GOV|DPTF_ADMIN))                                       ;; 403

The admin gate exists one line below and is **unreachable while the treasury is solvent**, its normal
state. So the suite can report "a non-admin was refused" without ever exercising the admin check —
**had `GOV|DPTF_ADMIN` been missing from that cap, the test would still be green.** The assertion is
therefore worded as the business guard, and the honest score is *seven admin refusals and one
shadowed gate*, logged as a follow-up rather than counted as a pass.

**The first pass used `(try "REFUSED" ...)` and reported 8/8 refused — true, and useless.** The
distinction above is invisible without the message. That is the third time the message-checking rule
has changed a result in this programme.

### RT-D-001 — paying the gas does not prove ownership *(REFUSED)*

Nearly every client entrypoint takes both a `patron` and an account: the patron **pays**, the account
**owns**. Where two identity-like arguments sit side by side, the question is whether proving one is
ever mistaken for proving the other.

Attacker as patron *and* receiver, victim as sender, only the attacker signing, against a victim
holding 1,567,573 OURO: refused at `CAP_EnforceAccountOwnership` on the **sender**, naming the
victim's key, with neither balance moved.

**The half that makes it evidence** is the second transaction. The identical call with the **owner**
signing and the **attacker still the patron** must succeed — and does:

    owner OURO    1567573.1176 -> 1567473.1176      the transfer happened
    sponsor IGNIS spent 1.0                          the patron paid
    owner   IGNIS spent 0.0000                       the owner paid nothing

Gas sponsorship is a real, working feature, so the refusal above is specific to ownership rather than
an artefact of a broken path. One role proves identity, the other pays, and neither substitutes for
the other.

### Where the defects are, and where they are not

Eight attacks across seven families now show a consistent shape:

| surface | families | result |
|---|---|---|
| **authorisation** | C, D, G | 5 refusals, every one message-checked against the intended guard |
| **economics & sequencing** | A, F | 2 defects, one fixed and one open |
| **architectural exception** | B | 1 confirmed bypass, owner ruling pending |

This mirrors the constructive round exactly: of its 131 compiled defects, the two largest classes
were pricing/billing (30) and guard *reachability* — not guard *absence*. **The guards in this
system are present and they hold; what fails is the arithmetic around them and the order in which
things happen.**


---

## Stage 5 — Family H, input domain

Deliberately **not** a fuzzing campaign. A full gate run is ~7 minutes, so random search is an
expensive way to find what reading the guards gives for free. The attacks were targeted at a gap
identified by reading `SWPU|X>SWAP`, the capability guarding the no-slippage swap path — the one a
caller reaches by passing the `-1.0` sentinel.

### RT-H-001 — the validator cannot see properties of the SET *(REFUSED incidentally — now FIXED)*

`SWPU|X>SWAP` checks the output is on the pool, that swapping is enabled, that `input-ids` and
`input-amounts` are the same LENGTH, and then loops over the inputs checking each is on the pool
with a valid amount. **Every one of those is a per-ITEM property.** Nothing checks a property of the
set — so two malformed sets should be constructible.

Both were refused. **Neither by a guard that is about the set:**

| attack | refused by | what that actually is |
|---|---|---|
| `output-id` also in `input-ids` (swap a token for itself) | `"is not a Valid Transaction amount"` | a **zero-amount transfer rule**, three modules away |
| the same id twice in `input-ids` | `"Only a single Input can be used in Stable Swap"` | a **pool-type rule**, not uniqueness |

**The self-swap is the result that matters.** `output-id` in `input-ids` passes every check in the
capability, proceeds **into the curve math**, which computes an output of exactly **zero** — adding
and removing the same token on a constant-function curve nets to nothing — and only then is the zero
transfer refused by `DPTF::UEV_Amount`.

> The system is not protected from self-swaps by a rule forbidding them. It is protected by the
> curve returning zero. Any change that makes a self-swap return a non-zero positive amount — a
> different curve, an amplifier, a fee rebate, a rounding direction — becomes value creation with
> nothing in the way. There is no `output-id NOT IN input-ids` check anywhere on that path.

**Scope stated honestly:** the duplicate result is pinned only for the **stable** shape. Weighted
pools accept several inputs by design, so the pool-type rule does not apply to them; that case is an
open follow-up, not a result claimed here.

**A correction made during this block.** The first draft asserted "neither attempt moved anything".
Both assertions failed: the caller was debited by exactly the 100.0 self-swap input and the pool's
OURO reserve rose 0.53. That is **RULE 9** — `expect-failure` catches the abort mid-transaction and
does **not** roll back preceding writes. On chain the transaction reverts entirely, so no value is
lost. "The refusal is total" is therefore guaranteed by Pact's transaction semantics and is **not
something this suite can demonstrate**, so the claim was removed rather than reworded into something
weaker but still unearned. What the partial write does show was kept: the self-swap is refused
**late**, after the input is debited and the curve evaluated — the caller pays for the full
computation of a swap that could never have succeeded.

---

## Stage 6 — Family I, the gas station's payable surface *(2026-09-15)*

The last first-rank target Stage 0 produced, and the only one that had never been attacked. Stage 0's
own words: *"`GAS_PAYER` Case 3 validates exec-code forms 0, 1 and 2 only; forms at index ≥ 3 are
unconstrained and form 2 need only start with `(let`. The only bound is economic."*

### RT-I-001 — the custom-code door, and the deterrent that can be declined *(SUCCEEDED)*

**The defect is not the unvalidated tail.** That is the custom-code door working as designed, with
the fee as its bound. **The defect is that the fee can be declined.**

Every link measured at `RedTeam/[RT-I]_GasStation.repl`:

| # | fact | block |
|---|---|---|
| 1 | Case 3 inspects forms 0, 1, 2 only; `(>= n 3)` bounds nothing above | `RT-I-001c` |
| 2 | the **count** of appended forms is unbounded | `RT-I-001d` |
| 3 | form 2 need only **start with** `(let` — its body is unread | `RT-I-001e` |
| 4 | the door is priced at a **flat** `(* 5.0 tier-biggest)` — 25 raw, **13.25** after a top-tier discount, *independent of what the tail does* | `RT-I-001f` |
| 5 | **a gassless (smart) account pays 0.0** — `C_Collect` collects only `(if (and (!= ignis-sum 0.0) (not iz-gassles-patron)) …)` | `RT-I-001g` |
| 6 | smart accounts are **permissionless**: `DALOS\|C_DeploySmartAccount` is a **client** wrapper (`TS01-C1:311`), STOA-priced at `acct-smart` 1000 deter = 100 STOA — *and that fee is itself conditional on `UR_AccountCreationStoa`, so it is **zero** when the account-creation toggle is off* | read off the Talos surface |

**Composed:** pay once, or nothing, then submit unlimited transactions shaped
`namespace + IGNIS.C_Collect(CustomCodeCumulator) + (let …) + <arbitrary code>`, paying **no IGNIS**,
with the gas station funding up to `DALOS|GAS-BUDGET` = **2,000,000 gas units** of **native STOA** each time. *(Corrected: there is no gas station for IGNIS — only for native STOA. IGNIS is the virtual-chain fee, and it is the IGNIS side that the exemption waived.)*

> **This is `RT-A-001`'s shape in the gas station.** There a second door skipped the `lp-churn`
> deterrent; here the gassless exemption skips the custom-code fee. A deterrent that can be declined
> is not one.

It is **not theft** — the appended code still satisfies its own guards. It is **free execution**,
which is the one thing a gas station exists to ration.

### What is proven, and what is inference

Links 1–5 are **measured**. Link 6 is read off the Talos surface. The **composition is not executed
end to end**, because no REPL can simulate chainweb's buy-gas phase — `test-capability` acquires
`GAS_PAYER` exactly as buy-gas does, which is what makes 1–3 real, but nothing here can show KDA
leaving the station. That last step is an on-chain smoke test and is the only part of this finding
that is inference rather than measurement.

### The method correction this attack forced

The first draft put all five cases in **one** `begin-tx` and reported a clean success. **It was
vacuous.** `test-capability` grants the capability for the remainder of the transaction, so cases
2–5 never re-evaluated the defcap body — they read a cap already in scope from case 1. The **control**
exposed it: a single foreign form, which `DALOS-G2c` proves is refused, came back as *"expected
failure, got result: ()"*. Without that control this file would have claimed a gas-station hole it
had not demonstrated. *A control is not a formality; it is the only assertion that can tell you your
attack did not run.*

### The register could not see this family at all

`_redteam.py` hard-coded `RT-([A-H])` in **both** its header regex and its malformed-header scan, so
adding family I produced **nothing** — not a row, not an error. The register said 9 attacks and was
silent about the 10th. Widened to `A-Z`, family I registered, and an unknown family is now an error.
*Third instance this round of a checker silently narrowing to the region it was told about, after the
price sheet's write-only `skipped` counter and `canon_check`'s `diff[:8]`.*

### The owner named the design, and it turned the finding into a plain violation

Presented with RT-I-001, the owner stated the intent (2026-09-15):

> *"An IGNIS gas payer account can only be a **standard** account. A smart account can never be a
> gassless payer, **except one single account hardcoded into the code**, to allow admin-based gassless
> IGNIS transactions — the Ouroboros daily minter uses such a gassless patron. No other smart account
> should have this property."*

**The code implements no such hardcoding.** `iz-gassles-patron` is `(DALOS::UR_AccountType patron)`,
which is `(at 0 (UR_AccountProperties …))` — the **`smart-contract` flag** — and
`XI_DeploySmartAccount` sets it `true` **unconditionally**. The string `gassles` appears **exactly
twice in all of `1_SOVEREIGN/`**, and both are those two lines in `IGNIS::C_Collect`.

So the exemption's population is not one account:

| holder | how it gets the flag |
|---|---|
| **7 system smart accounts** — DALOS, ATS, VST, LIQUID, OUROBOROS, SWP, … | `[4.0]_Sovereign-Executor` deploys them via `DALOS\|A_DeploySmartAccount` |
| **every user smart account** | `DALOS\|C_DeploySmartAccount` is a **client** wrapper (`TS01-C1:311`), permissionless, STOA-priced — and that fee is conditional on `UR_AccountCreationStoa`, so it can be **zero** |

Measured at `<<RT-I-001h>>` on `KC.BJ` — an ordinary user account on a user keyset
(`us-0008_bnjr-keyset`), hardcoded nowhere: **`gassless = true`**, while a standard account
(`KST.ANHD`) is `false`. The flag is *"is smart"*, not *"is the designated payer"*.

**This is no longer an economics question.** The intended rule exists and the code does not implement
it. The fix shape is one line — `iz-gassles-patron` should compare the patron against the **one**
designated account rather than read the smart flag — and the only open item is **which account**,
which is the owner's to name. The Ouroboros daily minter is the cited consumer; the seven candidates
are the system smart accounts above.

#### FIXED — and the rule was already there, shadowed by the exemption

*Two corrections to my own analysis are recorded here, because both were wrong in the owner's
favour and both were caught by asking him.*

**The guard already existed.** `IGNIS::UEV_Patron` is the owner's sentence in code:

```pact
(if (ref-DALOS::UR_AccountType patron)
    (do (enforce (= patron DALOS|SC_NAME) "Only the DALOS Account can be a Smart Patron")
        (ref-DALOS::CAP_EnforceAccountOwnership DALOS|SC_NAME))
    (ref-DALOS::CAP_EnforceAccountOwnership patron))
```

**It was unreachable for exactly the accounts it is about.** `UEV_Patron` runs inside
`IGNIS|C>COLLECT`, and `C_Collect` acquires that capability only when it actually collects:

```pact
(if (and (!= ignis-sum 0.0) (not iz-gassles-patron)) (with-capability (IGNIS|C>DC patron) …))
```

and `iz-gassles-patron` was `(UR_AccountType patron)` — **true for every smart account**. So a smart
patron took the branch that *skips collection*, and skipping collection skipped the guard that says
only one smart account may be a patron.

> **The exemption jumped over the rule written to constrain it.** That is `RT-C-001`'s shadowed admin
> gate, in the billing path: a guard present, correct, and never consulted for the inputs it was
> written about.

**The fix** (`02_IGNIS.pact`): `iz-gassles-patron` now compares the patron against
`GOV|DALOS|SC_NAME` instead of reading the flag. The designated account stays exempt — the DSP daily
minters are untouched and the gate is green — and every other smart patron now **reaches
`UEV_Patron` and is refused by name**. Pinned at `<<RT-I-001g>>` as an `expect-failure` on the exact
message, so the guard that refuses is identified rather than assumed.

##### Two things I got wrong, and how

1. **"No hardcoded check exists anywhere."** It does — `UEV_Patron`. I searched for the string
   `gassles`, found two hits, and concluded from their absence elsewhere. *The rule was not named
   after the exemption, so a search for the exemption could not find it.*
2. **"The one-line fix is unsafe — SWP/AQP depend on the exemption."** A **name-collision error**:
   my sweep matched callees by bare name, so `VST::C_Freeze` matched a *different* module's
   `C_Freeze` whose first parameter is `patron`. VST's is `freezer`; `C_Sleep` takes `sleeper`,
   `C_Hibernate` `hibernator`, `SWPLC::C_Fuel` `account`. Resolving every call site to its **actual
   callee signature** gives **37 genuine `patron` slots, all 37 in `03_DSP+.pact`**, none elsewhere —
   which is what the owner said from memory before any of it was measured.

*This is the third false positive this round from matching Pact members by bare name, after the
twin-divergence sweep and the canon diff. A bare name is not an identity in a module system.*

#### The earlier analysis, retained for the reasoning *(its conclusion was wrong)*

The owner remembered correctly. `2_CITIZEN/Stage_Z/03_DSP+.pact`:

```pact
(defconst GASLESS-PATRON (URC_Gassless))
(defun URC_Gassless () … (ref-DALOS::GOV|DALOS|SC_NAME))
```

Every daily-emission call in `A_OuroMinterStageOne` and the Koson minter passes exactly that — the
**DALOS smart account**. So the intended account is named, and the intended consumer is real.

**But it is a caller-side convention, not an enforcement.** DSP *chooses* to pass one account;
`IGNIS::C_Collect` still exempts **any** smart patron. That is `RT-C-001`'s lesson in a new place —
*a convention that is honoured is indistinguishable from a rule that is enforced, until someone does
not honour it* — and the Case 3 door lets an attacker write the patron into their **own transaction
text**, where DSP's discipline has no reach at all.

**And narrowing the exemption to that one account would break live flows.** Measured at
`<<RT-I-001i>>`: `SWP|SC_NAME` is gassless **and is passed as a patron by live liquidity code** —
`VST::C_Freeze` / `C_Sleep` at `20_MTX-SWP:684,830,983` and `18_SWPLC:1168,1229,1299,1381` — as is
`AQP|SC_NAME` to `SWPLC::C_Fuel` (`04_RPS:5317`). Those accounts hold no IGNIS; charging them would
fail the flows, not the attacker.

**So the fix does not belong in the exemption. It belongs in the gas station**, which is where "gas
payer" actually means something. Two shapes, both implementing the owner's own sentence — *"an IGNIS
gas payer account can only be a standard account"* — at the point it is about:

| option | change | risk |
|---|---|---|
| **A** | Case 3 enforces `(= n 3)` — no appended forms at all | may break a legitimate client flow that appends; unknown from inside the repo |
| **B** | Case 3 additionally enforces that the patron named in **form 1** is **not** a smart account | implements the stated rule literally; needs string extraction of the account from the form, and leaves the SWP/AQP exemption untouched |

**B is the recommendation.** It closes RT-I-001 at the door rather than at the till, and it does not
disturb the internal flows that depend on the exemption.

**Not applied unilaterally**, because naming the wrong account would silently break whichever
automaton actually depends on the exemption — and that automaton is exactly the kind of thing that
fails quietly, once a day, in production.

### Owner ruling needed *(superseded by the section above — retained for the reasoning)*

The gassless exemption is presumably deliberate — smart accounts are contract-controlled and meant to
operate without holding IGNIS. The question is whether that exemption should extend to the
**custom-code door specifically**. Two contained options: charge `UDC_CustomCodeCumulator` even for
gassless patrons, or refuse Case 3 for gassless patrons. Both are economics, so neither was applied
unilaterally.

---

## Stage 7 — V-01, the last Stage-0 target *(2026-09-15)*

### RT-H-002 — the slippage ceiling lived in the constructor, not the consumer *(SUCCEEDED — FIXED)*

Stage 0's third and final first-rank target, and with it every target that stage produced is closed.
Its words: *"slippage unbounded in **both** directions; the `@doc`'s '≤ 50' is UI policy the chain
never runs, and the on-chain ceiling is opt-in and disabled by a negative sentinel."*

**The rule existed — in the wrong place.** `UDC_SpawnSmartSwapSlippageBounds` enforces
`(or (= slippage -1.0) (and (> slippage 0.0) (<= slippage 50.0)))`, and its own `@doc` says it is
*"Called by the UI to generate the slippage-bounds object before submitting the Smart Swap
transaction."* But the **client surface takes the built object**:
`SWP|CC_SmartSwapWithSlippage (patron account input-id input-amount output-id slippage-bounds)`,
and `TS01-C3` then reads the number **back out of it**:

```pact
(slippage:decimal (at "slippage-percent" slippage-bounds))
```

So the value the chain acts on is whatever the caller put in the object. An integrator who
hand-builds it never calls the constructor — and **nothing downstream re-checked it.**
`UEV_SwapData` validates token sets, lengths and output-∉-inputs and says nothing about slippage;
a search for `enforce` beside `slippage` in `19_SWPU.pact` returned **one hit, and it was a comment.**

**Measured**, on a hand-built object the constructor would refuse:

| object | derived floor | derived ceiling |
|---|---:|---:|
| forged `slippage-percent = 9999.0` | **−98,990.0** | 100,990.0 |
| conforming `10.0` | 900.0 | 1,100.0 |

`UC_SlippageMinMax` computes `min = expected − (sp/100 × expected)`. Above 100% the floor goes
**negative**, so no output can ever breach it — the bound is not loose, it is **inoperative**. That
is exactly what the ≤ 50 ceiling exists to prevent.

> **A bound enforced in a constructor is a bound the caller may decline by not calling it.** The
> constructor refused `9999.0`; the consumer accepted the same value handed to it in an object.

**Fixed** by putting the rule where the value is used: a module-only `UEV_Slippage` carrying the
constructor's exact rule (`-1.0` included, so the no-slippage sentinel is unaffected), called from
**all four** `*-WITH-SLIPPAGE` defcaps — which previously took `slippage` as a parameter and
validated nothing about it. Module-only deliberately: declaring it in `SwapperUsageV3` would bump
the interface and cascade to every consumer, the same reasoning `04_BRD.pact` records for
`UDC_BrandingGenesis`.

Pinned at `<<RT-H-002>>` with both arms and both directions: `9999.0` and `0.0` refused **by
message**, `10.0` and `-1.0` still accepted. Nothing in the tree passed an out-of-range slippage, so
tightening all four caps left the gate green at 21,588 assertions.

**Severity, stated honestly:** this is **self-harm** — a caller weakening their own execution
guarantee, which the `-1.0` sentinel already offers openly. What was broken is the **invariant**: a
documented, constructed rule that the chain did not keep on the path that uses it. An integrator
building against Talos directly would reasonably assume the `≤ 50` in the error message applies to
them. Now it does.

---

## Stage 8 — Family E reopened: defpact continuation authority *(2026-09-15)*

### RT-E-002 — continue a defpact you did not start *(REFUSED — and the manner is the finding)*

A defpact's steps are separate transactions, so **the signer set can change between them**. And
`20_MTX-SWP.pact` contains **zero** occurrences of `CAP_EnforceAccountOwnership` or `CAP_Owner` —
no step asks who is driving it.

That matters because `RT-F-001` established what step 1 does when the pool has moved: it takes the
rollback branch and the starter loses the initiation fee. **An attacker who could time the
continuation could swap against the pool first, then continue the victim's pact into its own
failure branch** — turning RT-F-001's accident into a directed grief.

**Attempted**, on two pact families, by starting as `ANHD` and replacing the signer set with
`EMMA`'s alone before continuing:

| pact | result |
|---|---|
| `MTX\|C_AddLiquidity` step 1 | **refused** — `Keyset failure (keys-all): [PK_Ancie…]` |
| `MTX\|C_Issue` step 1 | **refused** — same |
| the same pact, continued by its **starter** | **proceeds** *(non-vacuity, `RT-E-002b`)* |

**The manner is the result.** The refusal is a plain keyset failure naming the **starter's** key —
it comes from a **downstream core op that happens to touch the starter's account**, not from
anything in the defpact layer. *The protection is a property of what the step does, not of the
pact.*

> Safe today, structurally thin. Every MTX step currently moves the starter's tokens, so every one
> demands their key. **A future step that touched only protocol state — a sweep, a recompute, a flag
> flip — would have nothing to demand it**, and this attack would succeed against that step without
> anything else changing.

This is the fourth refusal in the programme that came **from the wrong guard**, joining `RT-E-001`,
`RT-H-001` and `RT-C-001`. The attack is kept precisely because it does not test a guard — **it
tests an absence, and the absence is still there.**

**Not fixed**, deliberately: adding a continuation-authority check to the defpact layer is a design
decision about who may drive a multi-step operation (the starter only? the account? an authorised
relayer?), and it would touch every `MTX|` pact. Recorded as a standing constraint on any new
defpact step instead: *if a step does not move the starter's own assets, it has no caller
authentication at all.*

---

## Stage 9 — Family A reopened: the three add-liquidity doors *(2026-09-15)*

### RT-A-002 — the door that *requires* asymmetry is the one that does not tax it *(REFUSED)*

This was chased because from the outside it is `RT-A-001` exactly. `MTX|C_AddLiquidity` takes
`asymmetric-collection` and `gaseous-collection`, and **the core picks them per door** — the client
only picks the door:

| door | flags | asymmetry tax |
|---|---|---|
| `C_AddStandardLiquidity` | `true  true` | **charged** |
| `C_AddIcedLiquidity` | `false true` | **not charged** |
| `C_AddGlacialLiquidity` | `false false` | **not charged** |

All three branches then call the **identical** function with **identical** arguments —
`ref-SWPL::XE_STOA-PID|AddLiquidity account swpair asymmetric-collection gaseous-collection
stoa-pid ld clad` — differing only in which capability is acquired. Inside SWPL the flag gates
nothing but tax collection. Same operation, two prices, caller picks.

And it gets sharper: `UEV_AddChilledLiquidity` enforces *"Chilled Liquidity can only be added when
asymtric liquidity exists"*. **The two doors that require asymmetry are exactly the two that do not
tax it.**

**REFUSED.** The tax is not skipped, it is **exchanged for a lock**. Step 2 of the pact:

```pact
(if (not asymmetric-collection)
    (ref-VST::C_Freeze SWP|SC_NAME account lp-id secondary) …)
```

The doors that skip the asymmetry tax hand back **frozen** LP, locked in VST; the Standard door
hands back free LP. The provider pays in liquidity instead of IGNIS. A coherent product trade-off,
not a bypass.

**Why the block exists anyway.** The two consequences of one flag — *"no tax"* and *"LP is frozen"* —
live **forty lines and one defpact step apart**, in different capabilities. The price and the thing
paid for it are not visible together anywhere in the source. If a future change ever removed or
conditioned that freeze, the bypass would become real and **nothing would notice**, because no test
asserted the two were coupled. `<<RT-A-002>>` now does, from the side that cannot be faked: the
untaxed door is **refused outright** on a pool without frozen-LP enabled, so *untaxed* and *locked*
cannot come apart by pool configuration.

**One incidental measurement worth keeping:** step 0 of the Iced door **succeeds and charges the
100 initiation fee**, and only **step 1** refuses with *"Frozen LP Functionality is not enabled"*.
The caller pays before learning the door is unavailable — `RT-F-001`'s shape, now the documented
design after the owner's ruling (100 at step 0, the rest at the succeeding step).

---

## Stage 10 — Family J, ledger conservation *(2026-09-15)*

Every family before this one attacks a **guard**. This one attacks the **books**.

A DPTF's `supply` and the sum of its account balances are written by two different code paths.
`XBv_UpdateSupply` writes the supply column of `DPTF|PropertiesTable`; balances go through
`XI_UpdateBalance`, which for the two **core** tokens — OUROBOROS and IGNIS — dispatches into a
table owned by a **different module**, `DALOS|AccountTable`. Nothing in 103,000 lines of REPL had
ever compared the two. Every conservation assertion in the suite was **local and hand-named**:
`op+emma+lumy = 5000`, three accounts, one scenario.

### RT-J-001 — SUCCEEDED, then FIXED

The sweep enumerates every token (`UR_P-KEYS`) and every balance row (`UR_KEYS`), attributes rows
to tokens, and compares. After `[6.2]_DPTF` + `[6.3]_SWP`: **296 tokens, 739 balance rows.**
295 conserved to the last decimal. One did not.

```
OURO   supply = 2,235,687.961486…   held = 2,235,695.961486…   delta = -8.0
```

OURO is the protocol's own money, and its recorded supply was **8 below** the tokens actually held.

Bisected to a single transaction (`"Dispo 2|x Clear Dispo Test"`), then to a single call,
`DPTF|C_ClearDispo`. Its step 6:

```pact
;;6] Finally clears dispo setting OURO <acount> amount to zero
    (ref-DALOS::XB_UpdateBalance account true 0.0)
```

A **dispo is a negative OURO balance** — the defcap refuses anything else
(`"Dispo Clear requires Negative OURO"`) — and supply counts it as negative, because the
sublimation that opened the dispo decremented supply by the very amount it drove the balance below
zero. Zeroing that balance therefore *returns* tokens to the ledger. Supply was never told.

The consequence is that `ico5`'s burn is the only supply movement in the function and it is counted
**twice**: once against ATS's real OURO, once against the phantom OURO the dispo represented. The
drift is permanent and cumulative — the gap widens by the size of **every dispo ever cleared**.

**Fixed** by pairing the write with its supply half:

```pact
    (ref-DALOS::XB_UpdateBalance account true 0.0)
    (ref-DPTF::XBv_UpdateSupply ouro-id ouro-amount true)
```

This is the **only one-sided call to `DALOS::XB_UpdateBalance` in the tree**. Of its five call
sites, two are the debit and credit halves of an IGNIS transfer, two the same for DPDC-T, and one
is DPTF's own dispatch, which its callers pair with a supply update at the `C_` level.

### The two non-vacuity guards, which both fired for real

A sweep is an argument of the form *"I looked everywhere and found nothing"* — worthless unless
"everywhere" is proven. Both guards caught a genuine error during construction:

- **Partition completeness.** Two token ids *contain the key separator* (`F|VST-…`, `R|OURO-…`),
  so splitting a balance key on the first bar misattributes them. Rows are matched on the **full
  id** prefix and counted per token, so a row matching two ids is counted twice and the guard goes
  red.
- **Account-set completeness.** The first run reported OURO conserved and **GAS off by 9302.0225**.
  *Both were wrong.* Core-token balances live in DALOS, and **DALOS exposes no key enumerator** —
  only `URH_AccountCounter`, a count. The sweep was summing DALOS balances over the 6 accounts that
  happened to own a DPTF placeholder row, out of 24. The guard asserts the swept set **is** every
  account that exists, by comparing against that count. It fired again when `[6.3]_SWP` raised the
  count from 24 to 26.

> **Without the second guard this sweep would have reported a different wrong number with equal
> confidence.** It is the difference between a measurement and a coincidence.

### RT-J-002 — REFUSED: the ortofungible's cached aggregate matches its ledger

RT-J-001 swept DPTF only. **DPOF** — the ortofungible — keeps the same quantity in *three* places:

| level | table | role |
|---|---|---|
| `Properties.supply` | `DPOF\|T\|Properties` | the headline total |
| `total-account-supply` | `DPOF\|T\|AccountRoles` | a **cached aggregate**, per account |
| `supply` + `holder` | `DPOF\|T\|Nonces` | the **ledger** — every nonce records its own holder |

A cached aggregate sitting beside its own source of truth is the classic place for drift, and
nothing had ever compared them. **16 ortofungibles, 34 account rows, 80 nonce rows: every level
agrees exactly**, including the aggregate-vs-ledger check.

**The first run looked like four defects and was four misreadings of one convention.** Summing nonce
supplies naively left `Z|VST` short by 31.0, `DDKOSON` by 4.0, `V|OURO` by 1.0, and gave `Z|OURO` a
*negative* total of −1.0 against a supply of 0.0. Every delta turned out to equal that token's
`UR_NoncesExcluded` **exactly**: an excluded nonce is **tombstoned, not deleted** —

```
supply = -1.0    and    holder = BAR
```

`−1.0` is a marker, not a balance. The assertions therefore do not merely *skip* tombstones, which
would hide the convention rather than test it. They **pin** it: the tombstone count must equal
`UR_NoncesExcluded`, no nonce may carry any other negative value, and `supply = −1.0` must hold
**if and only if** `holder = BAR`.

### Two controls were needed, and that is the finding about the test

An all-green sweep is exactly the shape a vacuous one has, so the block was mutation-tested.

1. Sentinel `−1.0 → −2.0`: **`002b`, `002c`, `002d` go red.**
2. That control left **`002e` — the aggregate-vs-ledger check — GREEN.** The reason matters: `002e`
   selects a nonce by its **holder**, and a tombstone's holder is `BAR`, which is not an account, so
   no account picks a tombstone up whatever the sentinel is. It needed its own control: flipping the
   holder match to `!=` reddens **`002e` and nothing else**.

> **One perturbation reddening four assertions would have proven *less*, not more** — it would have
> meant the four were one assertion wearing four labels.

The suite was also made heavier for this: without `[6.6]_ATS` and `[6.7]_VST`, **11 of 12
ortofungibles sit at zero supply** and the sweep is a sweep over zeros. Loading them raised DPOF to
16 tokens with real balances — and raised RT-J-001's own coverage from 296 tokens / 739 rows to
**297 / 745**, still exact.

### What the instrument could not do, and it is worth recording

`DALOS|AccountTable` has **no on-chain key enumerator**. `AU_OuronetAccounts`'s own `@doc` says
*"Get Accounts with `(keys DALOS|AccountTable)`"* — i.e. the caller is expected to supply the list
from **off-chain**. So the conservation of OURO and IGNIS, the two tokens the whole economy is
denominated in, **cannot be verified on-chain by anything**. The sweep works only because a test
harness may hold the account list that the chain will not give it.

## Stage 11 — Family D reopened: an abbreviation is not an identity *(2026-09-15)*

Found while extending family J into **DPDC** (collectables). The conservation sweep kept reporting
DPNF nonces whose `supply` was 1 but which nobody held; the schema explains that
(`nonce-supply` is *"Always 1 for NFT, even when burned or wiped"*, and `nonce-holder = BAR` means
inactivated). What the schema does **not** say is what `nonce-holder` actually contains.

### RT-D-002 — SUCCEEDED, then FIXED

`DPDC|NonceElement.nonce-holder` is documented as *"Stores the `<OuronetAccount>` holding the
Nonce"*. It stores this instead — `XE_U|NonceHolder`, `02_DPDC.pact:1482`:

```pact
(sh:string (if iz-bar BAR (ref-I|OURONET::OI|UC_ShortAccount new-holder-account)))
```

and `OI|UC_ShortAccount` is

```pact
(concat [(take 5 account) "..." (take -3 account)])
```

**Eleven characters**, two of which are the fixed `Ѻ.` prefix — **six characters of entropy.**

`UEV_NonceQuantityInclusion` is the possession gate inside `DPDC-C|C>SINGLE-DEBIT`, which guards
every NFT debit, burn and transfer. Its shape:

```pact
(let ((nonce-supply (UR_AccountNonceSupply account id son nonce)))   ;; keyed by the FULL account
    (if (or son (< nonce 0))
        (enforce (<= amount nonce-supply) …)     ;; SFT branch: spends it
        (… (enforce (= sa nft-holder) …))))       ;; NFT branch: binds it and never uses it
```

**On the NFT branch the only ownership test was the abbreviation compare.**

### Measured, all three arms in one run

| account passed to the gate | result |
|---|---|
| the true holder (`ANHD`) | **PASSES** |
| an unrelated account (`EMMA`) | **REFUSED** |
| **a collider** — distinct, glyph-valid, 162 chars | **PASSES** |

The middle row matters as much as the last: it proves the gate is neither always-true nor
always-false, so the third row is a real discrimination failure rather than a broken test.

### No grinding is required, and that is the point

`GLYPH|UEV_DalosAccount` enforces **length 162**, the `Ѻ`/`Σ` prefix, the `.` separator and
membership of `DALOS|CHARSET` — **and nothing else**. There is no checksum and **no binding between
the account string and the guard**. So the collider is not searched for, it is *written down*: the
victim's first three body characters, 154 characters lifted from any other real account, the
victim's last three.

Nor does the `patron`/`account` split help. `DPDC-C|C>SINGLE-DEBIT` gates with
`CAP_EnforceAccountOwnership account` — an attacker naming their **own** colliding account satisfies
that completely. And `DALOS|C_DeployStandardAccount` is a permissionless **client** wrapper on
`TS01-C1` whose STOA fee is itself toggle-conditional, so the colliding account can cost nothing.

### The fix was already in the function

`nonce-supply` is read from `AccountSupplies`, whose key carries the **complete 162-character
account string** — the only value in scope that can tell two accounts apart. The NFT branch now
spends it:

```pact
(enforce (<= amount nonce-supply) "Account {} doesnt hold NFT {} Nonce {}")
(enforce (= sa nft-holder)        "NFT {} Nonce {} is not active on Account {}")
```

The abbreviation compare is **kept, with its own message**, because it carries a second meaning the
quantity check does not: an inactivated NFT stores `BAR` there. Two checks, two messages — so a
future refusal says *which* thing was wrong, the lesson from RT-C-001.

Safety was established before the change rather than assumed: across every DPNF nonce in the
harness, **each of the 6 active nonces has exactly one full-account holder with supply 1 whose short
form equals the stored abbreviation, and all 7 inactive nonces are held by nobody.** So
`AccountSupplies` is reliably maintained for NFTs and the added check refuses nothing legitimate.

> **A lossy display value had become a security predicate.** `OI|UC_ShortAccount` lives in the INFO
> module and its 20-odd other uses are all what it was built for — putting a readable account into a
> Talos result string. One caller stored it and then compared it.

## Stage 12 — Family B reopened: the bar in a ticker is a capability *(2026-09-15)*

RT-D-002 ended on a generalisable rule — *grep for a display helper appearing inside an `enforce`,
a `defcap`, or a table write*. Running that produced one more class, and it is not a display helper:
**a token-id PREFIX used as a privilege marker.**

At least three places read the first two characters of an id and change behaviour:

| where | test | effect |
|---|---|---|
| `05_DPTF.pact` `DPTF\|C>X_TOGGLE-TRANSFER-ROLE` | `ft ∈ ["F\|" "R\|"]` | **skips two validations** |
| `03_DPDC-C.pact` `URCi_RegisterCollectablesPrice` | `ft = "E\|"` | **price ÷ 1000** |
| `07_DPDC-T.pact` `URC_TotalTransferPrice` | `ft = "E\|"` | **per-nonce price ÷ 1000** |

An id is `UDC_Makeid(ticker)` = `ticker + "-" + block-hash`, so the prefix is the first two characters
of a **caller-supplied ticker**. `CT_SPECIAL` is `["|" "-" "^"]`, and `UEV_NameOrTicker` enforces
**length and charset only — no positional rule**, so a special character is legal at index 0.

And the `E|` discount is not incidental: `EQUITY+`'s own `@doc` spells out that
`UC_EquityID` *"forces an 'E|' ticker … so take-2 of the id is 'E|'"*, which is what makes the
`/1000` branch fire — while the legitimate route, `C_IssueShareholderCollection`, charges a **$100
equity premium** for the privilege.

### RT-B-002 — REFUSED, by one hardcoded boolean, written out four times

Every issuance family gates the special charset behind an `iz-special` flag, and **every
client-reachable wrapper passes it `false`**:

- `TS02-C1::DPSF|C_Issue` and `TS02-C2::DPNF|C_Issue` pass a literal `false` as the last argument;
- `DPTF::C_Issue` and `DPOF::C_Issue` build `(make-list l1 false)` internally and **take no such
  argument at all**, so Talos cannot pass one even by mistake.

Measured through the only supported client path:

| ticker | outcome |
|---|---|
| `F\|FRZ` | refused — *"Designation does not conform character-wise"* |
| `E\|EQT` | refused — same guard, same message |
| `V\|VST` via **DPOF** | refused — same, in a different issuance family |
| `PLN` *(non-vacuity)* | **passes the charset guard**, dies later at STOA — *"Managed capability not installed"* |

The last row is what makes the first three mean anything: an otherwise identical call with an
unbarred ticker gets **past** the guard and fails somewhere else, later, paying.

> The prefixes are load-bearing in three modules, and the only thing between a user and one of them
> is a literal `false` written out four times, with nothing central enforcing it.

A future wrapper that plumbed `iz-special` through to its caller — the obvious move if user-defined
LP-style names are ever wanted — would open all three privileges at once, in three modules **none of
which mention `iz-special`**. The refusal is pinned by message so that wrapper cannot land quietly.

## Stage 13 — Family J completed: all three asset families *(2026-09-15)*

### RT-J-003 — REFUSED: the collectable ledgers

DPDC is the last asset family, and the only one whose two halves are **not the same kind of thing**:

| | `nonce-supply` | possession |
|---|---|---|
| **DPSF** (semi-fungible) | a real quantity | sum of `AccountSupplies` over holders |
| **DPNF** (non-fungible) | *"Always 1 … even when burned or wiped"* | `AccountSupplies` + `nonce-holder = BAR` means **inactivated** |

Swept: **82 DPSF + 26 DPNF holdings rows, 72 DPSF nonces, 13 DPNF nonces.** DPSF conserves exactly.
DPNF is consistent under its own rule — 6 active nonces each with exactly one full-account holder,
7 inactive held by nobody, and `nonce-supply` the constant 1 throughout.

**Summed naively, DPNF looks broken**: seven nonces report supply 1 against zero holdings. They are
not leaks, and `<<RT-J-003e>>` pins the constant itself so that if `nonce-supply` ever *becomes* a
quantity for NFTs, the sweep goes red and tells whoever changed it that its meaning moved.

`<<RT-J-003c>>` is also **RT-D-002's safety premise**. That fix rested on a single measurement — that
`AccountSupplies` is reliably maintained for NFTs. It is now a standing assertion rather than a
memory.

**Mutation-tested one control per assertion**, because RT-J-002 showed that a single perturbation
reddening several lines proves they are one assertion wearing several labels. Each of the five
reddens exactly its own line and nothing else.

> **All three asset families are now proven to conserve**: DPTF (incl. the two core tokens), DPOF
> (three levels, including the cached aggregate), DPDC (both sons, under the correct rule for each).

## Stage 14 — Family A reopened: the share price has a singularity *(2026-09-15)*

Entered looking for the **classic vault-inflation attack**: seed a pool with a tiny share supply,
donate to inflate the share price, and let later depositors round to nothing. The pieces are all
present — `URC_Index` is `floor(resident-sum / rbt-supply, p)`, `URC_RBT` inverts it as
`floor(rt-amount / index, p-rbt)`, and `C_Fuel` raises the numerator **without minting shares** and
is permissionless.

### The inflation attack itself — REFUSED, on arithmetic

Three things bound it, and only one was designed to:

1. **Audit finding #11M** already bounds the KickStart **ratio** to `[0.1, 100.0]`.
2. **RBT precision is 24 decimals**, so the per-coil rounding loss is `index × 10⁻²⁴`. Moving a real
   pool's index far enough to hurt a depositor takes on the order of **10²⁴ times the pool's own
   supply** in donated tokens.
3. A coil that would mint **zero** shares aborts — not by any share check, but because `C_Mint`
   reaches `UEV_Amount`, which enforces `amount > 0`.

Worth noting what #11M's bound does and does not do: it bounds the **ratio**, not the **scale**.
`rbt-request-amount` is floored only at `> 0.0`, so a one-ulp genesis supply is legal. It is the
**precision**, not the bound, that makes the attack uneconomic.

### RT-A-003 — SUCCEEDED, then FIXED: `index = 0`

The bound does not cover the singularity, and zero is **a reachable live state** — not a contrived
input. Any pair whose reward-bearing token carries supply minted **outside** the pool reads
resident-sum 0 against a positive rbt-supply. **Five such pools exist at deploy** (the AOZ primal
assets), measured:

```
Bisthanium-98c486052a51   index = 0.0   rbt-supply = 10,000,000.0   resident-sum = 0.0
```

Driving the real client entrypoint into it:

| op | result |
|---|---|
| `ATS\|C_Fuel` *(sibling)* | refused — *"Fueling requires an ATS-Pair Index of at least 0.1"* |
| **`ATS\|C_Coil`** | **`Arithmetic exception: div by zero, decimal`** |
| the shared pricing reader (used by INFO previews) | same raw exception |
| the same reader on a healthy pool | prices normally *(non-vacuity)* |

> **The guard was not missing because the state was unknown.** `ATSU|C>FUEL` enforces
> `index >= 0.1`, and its comment block was reworded on 2026-09-13 *specifically* so that a caller
> whose index is 0.05 is not told something untrue about their own pair. That much care went into
> one guard's wording, while the door an ordinary user actually reaches had no index check at all.

**Fixed** by enforcing `(> index 0.0)` inside `URC_RBT` — the function that actually divides, and
the one the INFO previews share, so a **quote** for an impossible coil now refuses in the same words
instead of throwing. Pact's `try` cannot catch an arithmetic exception, so the old failure was not
merely ugly: it was uncatchable by any caller.

# Closing assessment

## The register

<!-- REGISTER:BEGIN (generated by REPL/tools/_redteam.py --sync; do not hand-edit) -->
| family | attempted | succeeded | fixed | refused |
|---|---:|---:|---:|---:|
| A — Arithmetic & value | 3 |  | 2 | 1 |
| B — Permissionless reach | 2 |  | 1 | 1 |
| C — Admin impersonation | 1 |  |  | 1 |
| D — Ownership bypass | 2 |  | 1 | 1 |
| E — Sequencing & state | 2 |  |  | 2 |
| F — Griefing / denial of service | 1 |  | 1 |  |
| G — Hostile citizen module | 2 |  |  | 2 |
| H — Input domain | 2 |  | 2 |  |
| I — Gas station payable surface | 1 |  | 1 |  |
| J — Ledger conservation | 3 |  | 1 | 2 |
| **total** | **19** | **0** | **9** | **10** |
<!-- REGISTER:END -->

**Seven of fourteen attacks found a defect, and all seven are fixed and measured.** The table above
is generated by `_redteam.py --sync` and diffed by `--check` inside the gate — it was hand-typed
until 2026-09-15, by which point it had silently drifted to *"9 attacks"* while the tool said 14.
`_figuresync.py` guards every other figure in this directory against `REPL_SUITE_STATS.md`; it has
no opinion about the attack register, so nothing compared the two.

Two further defects were found while implementing owner rulings, by reading the lines either side
of the ones being changed: **GS-05** (reclassified — see below) and the confirmation of **GS-04**
against a live measurement.

## Where the defects are, and where they are not

Fourteen attacks across ten families produced a consistent shape, and it matches the constructive
round exactly:

| surface | families | outcome |
|---|---|---|
| **authorisation** | C, D, G | 5 refusals, every one message-checked against the intended guard |
| **economics & sequencing** | A, F | 2 defects — one fixed, one open |
| **architectural exception** | B | 1 confirmed bypass, owner ruling pending |
| **input domain** | E, H | 2 defects fixed (RT-H-001/002) + 2 refusals, both **by the wrong guard** |
| **gas station** | I | 1 defect — a fee that a whole class of account could decline |
| **ledger conservation** | J | 1 defect — supply and balances drifting apart, permanently |
| **ownership, Stage 2** | D | 1 defect — an 11-char abbreviation used as a possession gate |
| **prefix-as-privilege** | B | refused — but by one hardcoded flag, repeated in four places |
| **share-price math** | A | 1 defect — a live `index = 0` state divided by zero on the coil path |

> **The guards in this system are present and they hold. What fails is the arithmetic around them,
> and the order in which things happen.**

Of the constructive round's 131 compiled defects, the two largest classes were pricing/billing (30)
and guard *reachability* — not guard *absence*. Red teaming reproduced that distribution
independently, from the opposite direction.

## The finding that a green test cannot show

**Three of the six refusals were by the wrong guard**, and each is a latent defect wearing a passing
test:

| attack | the guard that ought to refuse | the guard that actually did | status |
|---|---|---|---|
| `RT-E-001` dust sweep | a claimant-set check | a `last-collected-round` **stamp in a different function** | **FIXED** |
| `RT-H-001` self-swap | `output-id NOT IN input-ids` | the **curve returning exactly zero** | **FIXED** |
| `RT-H-001` duplicate input | a uniqueness check | a **stable-pool single-input rule** | **FIXED** |
| `RT-C-001` treasury wipe | `GOV|DPTF_ADMIN` | a **solvency check one line above it** | **FIXED** |

Every one of those was green and would have stayed green through the change that breaks it. Three
were closed by the owner rulings below, and `RT-E-001` was closed on 2026-09-14 by a later
ruling — *a wrong reader is an error whether or not it is exploitable*. **All four are now fixed.**

**One of the three did not move where it was expected to**, and the reason is worth more than the
fix. Adding `UEV_IzUnique` to `SWPU|X>SWAP` did **not** change what refuses a duplicated input on a
stable pool: the pool-type rule still answers first, because `TS01-C3::SWP|C_MultiSwapNoSlippage`
binds its slippage bounds in a `let` **before** calling `SWPU::C_Swap`, a Pact `let` is **eager**, and
the curve inside it raises. *The validator is downstream of the math it guards.* The new rule is real
and now demonstrated on a **weighted** pool — the case that previously had no guard at all — and
`<<RT-H-001>>` pins the eager-`let` mechanism directly by raising the same message out of
`UDC_SpawnSlippageBounds` with no client call and no capability in scope. This is the
single most valuable output of the programme, and it is only visible because the method requires a
red-team `expect-failure` to **name the message it expects**. An earlier pass over `RT-C-001` used
`(try "REFUSED" ...)` and reported 8 of 8 refused — true, and useless.

## What the method cost, and what it caught

The two rules in `RedTeam/README.md` each changed a result on first contact:

- **Message-checking** caught a false defence in `RT-E-001` (the attack was "refused" by
  `Keyset failure` because the attacker's key was not signed — the defence under test was never
  reached), and the shadowed admin gate in `RT-C-001`.
- **Probe-before-pinning** caught `RT-A-001`'s first draft aiming at a pool id absent from the
  fixture; assertion-first, the attack would have "failed" for a reason unrelated to the defence.

**A third rule earned its place during the programme and is now recorded:** in a codebase with
**compositional** authorisation, one-level static scans systematically under-report safety. Three
separate scans produced misleading numbers — "78 unreached guards", "every `STOA|C_Collect` is a
no-op", "31 of 42 `A_` with no admin guard" — and all three were refuted by measurement. Families B,
C and D were consequently driven entirely by execution.

## Owner rulings, 2026-09-14 — and what they changed

All four items below were put to the owner as decisions rather than fixes, because each one trades
off something the red team has no standing to choose. All four were ruled on the same day and are
now implemented and measured. **Three of the four were "the wrong guard refused" findings from the
table above — the ones a green test could never have surfaced.**

| id | ruling | what shipped | how it is pinned |
|---|---|---|---|
| `RT-C-001` | authorisation precedes business validation | swept **18 defcaps** across 11 files; convention recorded in CLAUDE.md | the refusal **message** changed from `"Cannot Wipe Positive Treasury Balance"` to `"DPTF Ownership not verified"` — nothing else about the call changed |
| `RT-F-001` | split the fee: initiation slice in step 0, remainder in the step that succeeds | `LQ|INITIATION-FEE` (100.0) + `URCi_AddLiquidityChurnRemainder` across all three add-liquidity defpacts | `<<RT-F-001>>` — griefing exposure 557.03 → **53.00 net**, total unchanged |
| `RT-H-001` | state the set rules directly | `output-id NOT IN input-ids` + `UEV_IzUnique` in `SWPU|X>SWAP` | `<<RT-H-001>>`, including the **weighted-pool** arm that was previously an open follow-up |
| `RT-B-001` / X-01 | the master key passing as a module is correct; `RotateStoa` must pass through Talos | the harness registration deleted; the five assertions it propped up re-homed on the Talos path | `<<RT-B-001>>` and `<<CONF-01>>` now assert the **refusal**, each with a non-vacuity arm proving the Talos route still works |

### A correction to `RT-B-001`, and it narrows the finding — now fixed

This report originally presented X-01 as a live exception to *"Talos is the only supported client
path"*. **That overstated it.** The registration that creates the exception —

```pact
(DALOS.P|A_AddIMP (keyset-ref-guard "ouronet-ns.dh_master-keyset"))
```

— appears in exactly one place in the repository: `REPL/Stage_01/[2.1]_Dalos.repl:221`. It is **not
in the genesis payloads**. So on chain the master key does *not* satisfy `P|UEV_IMC`, and
`DALOS::C_RotateStoa` is already Talos-only. What the red team measured was real, reproducible, and
**a property of the test harness rather than of the deployed system.**

The finding does not vanish, it changes category: the harness is *weaker than production*, and it
was that weakness which let `[2.1]_Dalos.repl`'s rotation tests call core directly — under labels
that name the **Talos** entrypoints (`<(DALOS|C_RotateGuard EMMA user-guard)>`) while the code
beneath calls `ref-DALOS::C_RotateGuard`. The registration exists because that file runs **before
Talos is deployed**, which is also why removing the line is not a one-line change.

*An audit harness that grants itself a privilege the real system withholds will certify behaviour
nobody can reach* — and will, as here, quietly turn a mislabelled test green.

**FIXED 2026-09-14, and the blast radius was measured before anything moved.** Deleting the
registration and re-running the full gate produced **exactly 10 failures — 5 assertions, counted
twice — and not one other failure in the 21,732 the suite executed at that moment.** That is what established that nothing downstream
depended on the state those rotations set, which is the fact the move needed and the only one that
could not be established by reading.

| | |
|---|---|
| `[2.1]_Dalos.repl` | registration removed; the rationale written where the line was |
| `[6.12]_DALOS-ADMIN.repl` `<<TX-DA-004>>` | the five guard-type assertions, re-homed on the Talos path — where they now cross the IGNIS billing leg the core-direct form never touched |
| `<<CONF-01>>`, `<<RT-B-001>>` | inverted: both assert the **refusal**, both message-checked |

**Both inverted blocks carry a non-vacuity arm, deliberately.** A gate that refuses *everyone* is an
outage, not a boundary, and "the master key is refused" would pass just as happily against a broken
`P|UEV_IMC`. So each block also proves the same operation, by the same signer, **through Talos**,
still succeeds — and `<<CONF-01>>` additionally proves it is now *billed*, which is precisely what
the old core-direct route escaped.

*One assertion was deliberately left as a `print`.* The admin IGNIS delta across the `TS01-A` route
measures **0.0000**: admin wrappers are not IGNIS-billed client ops, so "it now costs something"
would have been a false claim about the admin lane. What the repair closed is the **reach**, not the
price of admin work.

**A latent roughness this surfaced, recorded not fixed.** With the registration gone, the pre-Talos
failures read `No value found in table ouronet-ns.DALOS_P|MT for key: InterModulePolicies` —
`P|UR_IMP` does a bare `read` with no default, so before *any* module has registered, `P|UEV_IMC`
raises a table error rather than refusing cleanly. On chain the first module's deploy-time
`P|A_AddIMP` creates the row, so the window is real but narrow.

## What the fixes cost, and one that nearly cost more

**The `RT-C-001` sweep was first attempted mechanically and introduced a real authorisation hole.**
A script located each defcap's first `enforce` and the `compose-capability` of its admin cap, and
moved the latter above the former. Two of the eighteen sites were not flat sequences:

- `SWPI|C>ISSUE` — the admin compose sat inside `(if p ... true)`, because only a **primordial**
  issuance needs the admin key. The script hoisted it out, turning a conditional gate unconditional.
- `SWP|C>PRINCIPAL` — the admin compose sat unconditionally at the end of the `let`. The script moved
  it **into** `(if add-or-remove (and ...))`. **Removing a principal would no longer have required
  admin at all.**

Both were caught by the Pact loader on argument arity — `if` takes three, `and` takes two — which is
luck, not method. **The diff was reviewed and both were missed**: 5 of 18 hunks were read, and both
bad sites were outside the 5. Sampling a mechanical edit confirms the mechanism ran; it cannot
confirm the mechanism was right, because the failures are precisely in the sites that differ from the
ones sampled.

The whole sweep was reverted and redone as 18 hand-written `(old, new)` text pairs, each asserting
`count == 1`, with the `SWPI` conditional hoisted as a **whole `if` form**.

> **A refactor that moves security-relevant code is not verified by the code still loading. It is
> verified by knowing, per site, what the code was nested inside.**


## The instrument was the blind spot

The programme's last finding is about the tools rather than the code, and it generalises past this
project.

`_info_measured.py` reports **397 of 412** INFO previews as MEASURED. Its rule: a preview counts when
its name appears, uncommented, inside a `begin-tx` that also extracts `ignis-need` or `stoa-need`.
The tool's own docstring is careful to call that a **proxy** and an upper bound, and lists the ways it
is generous.

It does not list the way it is **blind**. A defpact's billing is spread across transactions, so a
`begin-tx` can only ever contain **one step** of it. A preview of a multi-step operation could satisfy
every condition the tool checks while the number it was compared against was a single step's charge.
Three previews sat in exactly that position — `INFO_SWP|Issue*Pool`, quoting a single-tx reader for a
defpact exec, **652 raw IGNIS** apart — through every green gate this project has run.

The fix was not "measure more". It was a harness that can bracket a defpact at all
(`REPL/modules/DEFPACT-BILLING.repl`), and the blocking idiom turned out to be one line:
`(continue-pact N)` resolves against the pact started in the **same** transaction.

> **A coverage proxy inherits the shape of the thing it samples.** `_info_measured.py` samples
> transactions, so it can only see operations that fit inside one. Asking it about defpacts was asking
> a question it had no vocabulary for — and it answered "measured", because its vocabulary had no way
> to say "not applicable".

The same sentence covers the earlier one-level static scans. Both failures are the instrument
reporting confidently about a region it cannot see, and in both cases the number it produced was
**reassuring** rather than alarming. An audit should treat a tool's silence as unexamined, not clean.
