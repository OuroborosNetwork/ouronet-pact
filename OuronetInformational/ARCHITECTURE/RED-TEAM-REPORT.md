# Red Team — running report

*Audit-paper source material. One section per stage, written as each stage closes.*

Everything in the constructive suite asserts that **documented behaviour holds** and that
**documented refusals fire**. This programme asks the opposite question: *what can someone do that
nobody documented?* The suite lives in `REPL/RedTeam/`, is gated like any other entrypoint, and its
method is fixed in `REPL/RedTeam/README.md`.

**The register is the honest summary.** An adversarial suite is uniquely bad at self-reporting: an
attack that was never written and an attack that was refused both show up as a green gate. So every
block carries a machine-read `FAMILY` / `STATUS` header, `REPL/_redteam.py` builds the register from
those, and the gate **fails** on a malformed header — a shrinking register looks exactly like a
clean one.

    python3 REPL/_redteam.py          # attempts by family and outcome
    python3 REPL/_redteam.py --md     # the table for this document

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

**Verification.** The block now measures 557.03 = 557.03, and the two assertions that encoded the
exploit went red at the moment of repair — evidence a fix-first approach cannot produce.

*Footnote worth keeping: the exploit assertion itself first failed on a three-argument `(* a b c)`.
Pact's `*` is binary — the same arity trap this project's ledger already records for a
three-argument `or`.*


### RT-E-001 — the STOAICO dust sweep, and who counts as "last" *(REFUSED)*

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

**Why the block exists anyway.** The theft is prevented by a single stamp, written in a different
function from the one computing the dangerous number, with no assertion previously connecting them.
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

### RT-F-001 — one ordinary swap destroys a stranger's add-liquidity fee *(SUCCEEDED — open)*

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

### RT-C-001 — eight admin wrappers driven as a stranger *(REFUSED, with one shadowed gate)*

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

### RT-H-001 — the validator cannot see properties of the SET *(REFUSED, incidentally)*

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

# Closing assessment

## The register

| family | attempted | succeeded | fixed | refused |
|---|---:|---:|---:|---:|
| A — Arithmetic & value | 1 | | 1 | |
| B — Permissionless reach | 1 | 1 | | |
| C — Admin impersonation | 1 | | | 1 |
| D — Ownership bypass | 1 | | | 1 |
| E — Sequencing & state | 1 | | | 1 |
| F — Griefing / DoS | 1 | 1 | | |
| G — Hostile citizen module | 2 | | | 2 |
| H — Input domain | 1 | | | 1 |
| **total** | **9** | **2** | **1** | **6** |

Three attacks found a defect. One was fixed immediately (`RT-A-001`); two are open pending an owner
ruling (`RT-B-001`, `RT-F-001`).

## Where the defects are, and where they are not

Nine attacks across all eight families produced a consistent shape, and it matches the constructive
round exactly:

| surface | families | outcome |
|---|---|---|
| **authorisation** | C, D, G | 5 refusals, every one message-checked against the intended guard |
| **economics & sequencing** | A, F | 2 defects — one fixed, one open |
| **architectural exception** | B | 1 confirmed bypass, owner ruling pending |
| **input domain** | E, H | 2 refusals, both **by the wrong guard** |

> **The guards in this system are present and they hold. What fails is the arithmetic around them,
> and the order in which things happen.**

Of the constructive round's 131 compiled defects, the two largest classes were pricing/billing (30)
and guard *reachability* — not guard *absence*. Red teaming reproduced that distribution
independently, from the opposite direction.

## The finding that a green test cannot show

**Three of the six refusals were by the wrong guard**, and each is a latent defect wearing a passing
test:

| attack | the guard that ought to refuse | the guard that actually did |
|---|---|---|
| `RT-E-001` dust sweep | a claimant-set check | a `last-collected-round` **stamp in a different function** |
| `RT-H-001` self-swap | `output-id NOT IN input-ids` | the **curve returning exactly zero** |
| `RT-H-001` duplicate input | a uniqueness check | a **stable-pool single-input rule** |
| `RT-C-001` treasury wipe | `GOV|DPTF_ADMIN` | a **solvency check one line above it** |

Every one of those is green today and would stay green through the change that breaks it. This is the
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

## Open items for the owner

| id | item | why it needs a ruling rather than a fix |
|---|---|---|
| `RT-B-001` / X-01 | the master keyset satisfies `P|UEV_IMC`, reaching DALOS core outside Talos, unbilled | probably deliberate (bootstrap precedes Talos). If intended it belongs beside the "only supported client path" sentence; if not, the registration is what to remove. |
| `RT-F-001` | the add-liquidity deterrent is collected in step 0 and validated in step 1, so any swap destroys it | the fix — collect in the step that succeeds, or refund on rollback — changes **when money moves inside a defpact**, a design decision |
| `RT-H-001` | no `output-id NOT IN input-ids` check on the swap path | adding one is cheap; whether self-swaps should be *forbidden* or merely *unprofitable* is a design call |
| `RT-C-001` | `GOV|DPTF_ADMIN` on the treasury wipe is unreachable while the treasury is solvent | reordering the cap is trivial; whether the solvency check should precede authorisation is a convention question |
