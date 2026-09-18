# Chapter 5 — DEMIPAD, the launchpad

> **Source tree:** `1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/Audit/` (4 files, 792 lines)
> **Audited:** 2026-08-29 → 2026-08-30, on `main`, no worktree
> **Scope at the time:** 6 modules, 3,664 lines — the smallest core family in Ouronet
> **Findings:** 17 · **Fixed:** 15 · **WONTFIX:** 2
> **Verification pass for this chapter:** 2026-09-17.

---

## 1. What DEMIPAD is, and what breaks if it breaks

DEMIPAD is Ouronet's launchpad: the venue where Demiourgos.Holdings sells assets to the public. It is
**permissioned** — not anyone can list — which matters for several of the verdicts below, because the
seller is a trusted party by construction.

At the time of the audit it was six modules:

| module | lines | role |
|---|---|---|
| `00_Demipad.pact` | 1,298 | the launchpad **rules**: register an asset, toggle open-for-business, define a price, deposit, withdraw, transmit the four asset kinds, track dollars raised, retrieval |
| `05_STOAICO.pact` | 739 | the STOA ICO — a staking vault with RPS reward distribution (inject / stake / unstake / collect) |
| `01_Spark.pact` | 543 | the Spark token sale, bonding-curve priced, with redemption |
| `04_STOICPAY.pact` | 417 | the StoicPay (KPAY) sale, per-period buy cap |
| `03_Custodians.pact` | 351 | the Ouronet Custodians collection sale |
| `02_Snakes.pact` | 316 | the Demiourgos ShareHolder collection sale |

It handles **KDA payments** (native and wrapped), **token custody** (inventory sits in a shared
launchpad account until sold or retrieved), **bonding-curve pricing**, and **RPS reward
distribution**. For 3,664 lines that is a lot of money-touching surface.

The failure modes are concrete. A launchpad that lets a seller pull deposited inventory mid-sale is
not a launchpad, it is a rug-pull with extra steps. A custody ledger that can be credited without
tokens arriving lets one seller drain another's proceeds from the shared account. And a reward vault
whose "last claimant takes the dust" branch tests the wrong thing pays the entire remaining vault to
whoever asks first.

All three of those were found here. So was a sale module that had been copied from its twin and
half-wired.

### Where these modules live now

The audit's single most consequential outcome was **not a code fix**. Finding #15L asked why several
`C_` entrypoints lacked `UEV_IMC`, the sovereign inter-module gate. The answer was that they should
not have it: the per-asset sales are **citizen** modules that wire into the sovereign launchpad's
rules, and citizen client functions correctly carry no sovereign gate. The defect was **physical
filing** — they sat under `1_SOVEREIGN/…/2_Core/02_DEMIPAD/`, which made them look sovereign.

They were moved. Today [VERIFIED by command]:

```
1_SOVEREIGN/STAGE_02/2_Core/02_DEMIPAD/00_Demipad.pact     <- sovereign: the rules
1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact             <- sovereign launchpad Talos
2_CITIZEN/7_Launchpad/{1_Spark,2_Snakes,3_Custodians,
                       4_StoicPay,5_StoicIco}/             <- the five citizen sales
2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact                    <- citizen launchpad Talos, deployed last
```

**Five of the six modules this chapter covers are no longer in the directory whose audit tree this
is.** Anyone reading the audit documents without that fact will not find the code. The round-docs were
deliberately left as accurate-when-written rather than retro-edited, which is the right call for an
append-only record and a trap for a reader.

---

## 2. How it was audited, and what the tree does not contain

The DEMIPAD audit is **792 lines across four files**. The DPDC tree is 5,093 and the AQP tree is
4,233 across 14 files (it was 4,112 across 13 when this chapter was written — `RPS-SPLIT-SCOPING.md`
landed 2026-09-17). This chapter is shorter than its neighbours because its source is, and padding
it would misrepresent the coverage.

### What was run

`README.md` describes a five-step method, and steps 1–2 are the part that distinguishes this audit
from its siblings:

1. **Round-01 lens fan-out.** Six independent read-only auditors, each hunting **one dimension**
   across all relevant modules — rather than DPDC's and AQP's one-auditor-per-file. The roster:
   access-control/capability; arithmetic/precision/payment-math; economic/MEV/sale-accounting;
   a STOAICO reward-distribution deep dive; custody/state-lifecycle/asset-integrity; and
   StoicSyntax conformance plus cross-module boundary.
2. **Adversarial verification.** Every candidate was re-checked against the code by an independent
   validator and classified CONFIRMED / REFUTED / STYLISTIC **before** reaching the owner.
3. Owner verdicts → 4. Round-02 fixes with diffs and REPL proof → 5. ranked index and final report.

The lens structure is why `ROUND-01-FINDINGS.md` carries a **corroboration count** — "4 lenses",
"2 lenses", "1 lens" — that the other audits do not. It is a genuinely useful signal: the critical
finding was found by four independent lenses; most of the mediums by one.

The findings file also carries something the other trees lack: a **"Cleared by the lenses"** section
listing what was checked and found correct — Spark's bonding curves, the Snakes/Custodians cost
chains (floor-at-precision, favouring the protocol), Demipad royalty math, STOAICO's
settle-before-score ordering and `last-rps` snapshot-after (so a late staker cannot claim pre-stake
injects), the over-unstake block, and the `open-for-business` enforcement path. A negative result
recorded is worth more than a negative result assumed.

### What the tree does not contain

Being specific about this is the point of the section:

- **No `ROUND-01-OWNER-FEEDBACK.md`.** Steps 3 of the method produced no file. Owner verdicts are
  embedded in the fix entries instead — readable, but not separable, and not append-only.
- **No `FINAL-AUDIT-REPORT.md`.** The audit closes on `ROUND-02-FIXES.md`'s last line: *"Closes the
  DEMIPAD audit."* There is no consolidated sign-off document.
- **No re-verify round.** Same as DPDC.
- **`README.md`'s status checklist is still four unticked boxes** — *"Round-01 lens fan-out
  (in progress)"* — while `ISSUES-RANKED.md` shows all 17 closed. The tracker was never updated. That
  is a one-line clerical gap, and it is exactly the kind of gap that makes a reader distrust the rest,
  so it is named here rather than smoothed over.

What the tree **does** have, and has well, is proof discipline. **Eight fix entries record a
deliberate pre-fix reproduction** — the fix reverted or neutered and the original failure captured —
covering nine findings: #2H, #3H+#4H, #5M, #6M, #8M, #9M, #10M and #16L. [VERIFIED by reading —
`ROUND-02-FIXES.md`] #2H neutered the new capability body to `(enforce true …)` and
watched the non-admin block assertion fail. #4H reverted one identifier and captured the exact runtime
error (`Unbound free variable … DEMIPAD.GOV|LAUNCHPAD|SC_NAME`). #5M forced the flush branch on an
empty vault and captured `Arithmetic exception: div by zero` at the exact line. #6M removed the phase
gate and watched 1,568 urSTOA be minted twice.

That is a higher bidirectional-proof rate than either neighbouring audit, in a quarter of the
documentation. **The tree is thin; the work in it is not.**

### One live-vs-workspace check that changed a finding into a non-finding

Finding **#11M** deserves separate mention as method. The audit measured StoicPay's team-split
accounting against the **workspace** copy of `04_STOICPAY.pact` and derived a real inconsistency: the
module moves `2× amount` KPAY per buy while `UR_KpayLeft` derives `sold = 100M − 0.4·resident`, so the
per-period cap drifts from real inventory.

Pulling the **deployed** module through the Pythia dirty-read gateway (`describe-module` → `code`)
showed the on-chain contract is correct: a 5-recipient **1.5×** team split, not the workspace's
3-recipient **1.0×**. With the real split, `resident` drops 2.5× per buy and the formula tracks buyer
amount exactly. The "20 % under-count" existed only in a test simplification that had been left in the
workspace.

The fix was to re-sync the workspace to live. The general lesson recorded in the fix entry is the
transferable part: **for "does the workspace match live" questions, pull the deployed code and diff —
the workspace may carry deliberate test simplifications**, and an audit measuring the wrong artefact
produces a confident, wrong finding.

---

## 3. The findings

All 17, in the audit's own ranking. Severity as recorded; evidence as verified 2026-09-17.

| # | sev | module | summary | verdict | evidence today |
|---|---|---|---|---|---|
| **#1C** | CRITICAL | STOAICO | `C_Collect` is drainable — non-idempotent, and `unclaimed-count == 1` pays the whole vault | **FIXED** | `05_STOAICO.pact:153` `last-collected-round`, `:169` `distribution-round`, cap at `:243`, flush family at `:468` (`URH_UncollectedAccounts`), `:1046` (`Ap_FlushUncollectedSlice`) and `:1069` (`AA_FlushUncollected`). [VERIFIED by reading] |
| **#2H** | HIGH | Demipad | the `retrieval` toggle is dead state — the anti-rug lock is never enforced | **FIXED** | `00_Demipad.pact:412` `DEMIPAD|C>RETRIEVAL-GATE`, composed by all four `RETRIEVE-*` caps at `:477`, `:482`, `:487`, `:492`. [VERIFIED by reading] |
| **#3H** | HIGH | Custodians | `C_Acquire` never opens `CUSTODIANS|ACQUIRE` — supply cap and policy caps dropped | **FIXED** | `03_Custodians.pact:496-499` — `with-capability (CUSTODIANS|ACQUIRE …)` with the `#3H` note. [VERIFIED by reading] |
| **#4H** | HIGH | Custodians | calls a non-existent `GOV|LAUNCHPAD|SC_NAME` → runtime unbound variable | **FIXED** | `03_Custodians.pact:302-303` — `GOV|DEMIPAD|SC_NAME`, with the `#4H` note. [VERIFIED by reading] |
| **#5M** | MEDIUM | STOAICO | `A_Inject` divides by `vault-score` with no zero guard | **FIXED** | `05_STOAICO.pact:170` `zombie-rewards` + `:393` reader — escrow-on-empty, so the division only runs when the divisor is positive. [VERIFIED by reading] |
| **#6M** | MEDIUM | STOAICO | urSTOA double-credited across stake rounds — re-mints already-claimed urSTOA | **FIXED** | `05_STOAICO.pact:996-997` and `:1034-1035` — `(if (= (UR_Global11) 0) (XI_UpdateUrstoaEarned …) true)`. [VERIFIED by reading] |
| **#7M** | MEDIUM | Demipad | NF transmit guarded by the SF capability — NF assets cannot move, SF-as-NF type mismatch | **FIXED** | `00_Demipad.pact:1427-1439` — the 2×2 `son` branch wires `FUEL/RETRIEVE-NON-FUNGIBLE` (defined at `:470`, `:490`). [VERIFIED by reading] |
| **#8M** | MEDIUM | Demipad | `direct-injection` credits withdrawable funds with no tokens in — phantom funds | **FIXED** | `00_Demipad.pact:1208` `UEV_DirectInjection` — unconditional hard block — composed at `:580`. [VERIFIED by reading] |
| **#9M** | MEDIUM | Custodians | `UC_NonceQuintessence` is declared pure and enforces | **FIXED** | `03_Custodians.pact:271-274` — pure mapping, with the enforce relocated and documented. [VERIFIED by reading] |
| **#10M** | MEDIUM | Custodians | `UR_NonceSaleAvailability` enforces; the twin Snakes does not | **FIXED** | Enforce relocated to `03_Custodians.pact:245`, the first line of `CUSTODIANS|ACQUIRE`; reader at `:295-303` is now a pure read. [VERIFIED by reading] |
| **#11M** | MEDIUM | STOICPAY | workspace diverged from the deployed module (3 addr/1.0× vs 5 addr/1.5×) | **FIXED** | Workspace re-synced to live. See §2. |
| **#12M** | MEDIUM | all sales | no on-chain slippage or max-cost bound on any buy | **FIXED** | `00_Demipad.pact:1218` `UEV_SlippageCost` (composed at `:561`), `:776` `UC_SlippageFactor` (used at `:1036`); `URC_Acquire` gained `slippage` in all five modules. [VERIFIED by reading] |
| **#13L** | LOW | STOAICO | `unclaimed-count`/`nzs-count` have no lower bound | **WONTFIX** | Subsumed by #1C; declined to keep parity with the canonical AQP counter. See §5. |
| **#14L** | LOW | STOICPAY | fractional team-split for buys not divisible by 4 | **WONTFIX** | Precondition (`decimals < 2`) not met — KPAY has 24 decimals. See §5. |
| **#15L** | LOW | Snakes/Cust/STOAICO/Spark | missing `UEV_IMC` on several `C_` entrypoints | **FIXED by reclassification** | The sales are citizen modules and correctly carry no sovereign gate; they were relocated to `2_CITIZEN/7_Launchpad/`. [VERIFIED by command] |
| **#16L** | LOW | Demipad | `open-for-business` reject message has a `{}` placeholder and no argument | **FIXED** | `00_Demipad.pact:582` — `(format "{} is not open for business, to allow deposits" [asset-id])`. [VERIFIED by reading] |
| **#17L** | LOW | Demipad | interface omits `URC_Acquire`/`URCI_Acquire`; `URCI_` is a mis-prefix | **FIXED, then superseded** | `URC_Acquire` is now declared in all five interfaces. `URCcap_` lived one day. See §4.5. [VERIFIED by command] |

---

## 4. Five findings worth the retelling

### 4.1 #1C — the vault that paid the whole balance to whoever called last

Four of the six lenses found it independently, which is the strongest corroboration signal in the
tree.

`STOAICO|REDEEM-CONTRIBUTION` enforced two things: that the caller owns the account, and that a user
row exists. **No already-claimed flag. No `pending > 0` gate.** The `@doc` said *"Can only be done
once."* Nothing enforced it.

Meanwhile `URC_ClaimableRewards` implemented the dust sweep as: when `unclaimed-count == 1`, return
the **entire remaining `wstoa-supply`**, ignoring the account's own entitlement. And `C_Collect`
decremented `unclaimed-count` **unconditionally** after paying.

Compose those three and the attack is not clever, it is arithmetic. Any account holding a user row —
any past contributor, even one with zero score — calls `C_Collect` on itself repeatedly. The first
call pays its real share and sets `last-rps = current`. Every subsequent call pays approximately zero
**and still decrements the counter**. Drive the counter to 1, call once more, and the whole remaining
vault transfers out, stranding every other contributor and driving `wstoa-supply` negative.

It also broke in honest operation: an accidental double-collect desynchronised the counter and stole
the last-claimant dust branch from whoever should have had it.

The fix is not a flag. The owner-agreed design is a **distribution-round (generation) model**, which
preserves the vault's ability to run multiple inject rounds:

- `UserContributionSchema` gains `last-collected-round`; `GeneralContributionSchema` gains
  `distribution-round`, initialised to 0.
- The redeem capability enforces `(< last-collected-round distribution-round)`. A second collect in
  the same round is refused, so the counter cannot be walked.
- `A_Inject` enforces `unclaimed-count == 0` before opening a new round. A round cannot open until the
  previous one is fully collected.
- A new staker is initialised with `last-collected-round := current distribution-round` — **born
  already-collected for the round they joined**, so a mis-ordered post-inject stake is not eligible
  for the already-injected round.
- Because "fully collected" is now a precondition for the next inject, an **admin flush family** was
  added to push-collect stragglers: `URH_UncollectedAccounts` (a Hydra preflight, the one heavy scan)
  feeding `Ap_FlushUncollectedSlice` (parallel, retryable, idempotent per account) and
  `AA_FlushUncollected` (solo). The flush delivers each straggler **its own** wSTOA and urSTOA — to
  the rightful user, not to the admin and not to a burn address.

The proof is a conservation assertion, not a pass/fail: emma self-collects her exact share, the
double-collect is refused, `A_Inject` is blocked while lumy is outstanding, `URH_UncollectedAccounts`
lists exactly lumy, `AA_FlushUncollected` delivers to lumy sweeping the dust as the last, the counter
reaches 0, the vault reaches 0, and **emma + lumy wSTOA == 10,000,000 injected**.

**Verified 2026-09-17:** the schema fields, the reader, the capability enforce, and the whole flush
family are present in `2_CITIZEN/7_Launchpad/5_StoicIco/05_STOAICO.pact`. [VERIFIED by reading]

**And it was not the end of the story.** See §5.

### 4.2 #2H — a promise in a `@doc` that the code never made

`00_Demipad.pact`'s documentation promises buyers: *"if `retrieval = false` the only way to retrieve
Assets is a buy."* That is the launchpad's anti-rug guarantee. Deposited inventory is locked in;
it leaves through sales or not at all.

`UR_Retrieval` — the reader for that flag — was called in exactly **one** place in the whole module:
inside `TOGGLE-RETRIEVAL`, to detect a no-op flip. The four `RETRIEVE-*` capabilities that actually
gate withdrawal were byte-for-byte the shape of the `FUEL-*` capabilities: they enforced owner-or-admin
ownership and nothing else.

So the flag existed, had an admin toggle, emitted events, appeared in the UI — and gated nothing. The
asset owner could pull deposited inventory at any time, including mid-sale.

Three lenses found it. The fix is six lines: a shared `DEMIPAD|C>RETRIEVAL-GATE (asset-id)`, composed
by all four `RETRIEVE-*` capabilities and by none of the `FUEL-*` ones (deposits are always allowed).
The owner chose **Option A, admin override**: the gate is an `enforce-one` over `[admin guard,
(enforce (UR_Retrieval asset-id))]`, so admin may always retrieve, a non-admin owner may retrieve only
when `retrieval = true`, and everyone else is still stopped by ownership.

The bug direction was proved by neutering the new gate body to `(enforce true …)` and watching the
non-admin BLOCK assertion fail with *"expected failure, got result: ()"*.

One footnote a careful reader should have. Per `DEFECT-LEDGER.md` §1.2.3 `G-29`, **every `enforce`
nested inside an `enforce-one` is mute** — Pact discards the failed branch's message and raises the
outer one. So the inner `"retrieval disabled"` string is documentation, not a diagnostic. Here that
is harmless, because the outer message is the informative one and names the asset:
*"Asset {} retrieval is LOCKED (retrieval=false) — only the Launchpad admin may retrieve until a sale
or an admin re-enable."* It is worth knowing that the inner string will never be seen.

**Verified 2026-09-17:** `00_Demipad.pact:412-419`, composed at `:477`, `:482`, `:487`, `:492`.
[VERIFIED by reading]

### 4.3 #3H + #4H — the half-wired twin, and why fixing one alone would have crashed

Custodians is a copy of Snakes. It is not a finished copy, and the audit's cross-cutting note says so
plainly: *"Custodians is a half-wired copy of Snakes — the whole module needs a line-by-line reconcile
against its working twin."*

**#3H:** `C_Acquire` dropped straight into its `let`. Snakes wraps its body in
`(with-capability (SNAKES|ACQUIRE nonce amount) …)`. `CUSTODIANS|ACQUIRE` was defined and had **zero**
`with-capability` sites. Everything in it was skipped: the per-nonce supply cap
(`amount <= available-supply`), both policy capability composes that downstream `DPDC-T::C_Transfer`
relies on for caller authorisation, and the `@event`.

**#4H:** the capability's own reader called `(ref-DEMIPAD::GOV|LAUNCHPAD|SC_NAME)`. That member does
not exist. The module defines `GOV|DEMIPAD|SC_NAME`; Snakes reads the correct one. Because modref
`::` dispatch is dynamic, this is a **runtime** `Unbound free variable` the moment the function
executes — latent only because no test had ever exercised the Custodian availability read.

The two had to be fixed together, and this is the instructive bit: **adding the capability without
fixing the identifier would have made a previously-silent path crash on every Custodian purchase.**
The unguarded code path worked precisely because it never entered the broken capability. Wiring it
correctly wires in the runtime error.

Both directions proved. Post-fix: `UR_NonceSaleAvailability(-1)` resolves to `-1` (the pad holds none)
with no crash, and an over-supply acquire of `999999999` is rejected with *"Insufficient Assets for
Acquisiton"* — the capability's enforce firing for the first time. Pre-fix reproduced by reverting the
identifier and capturing `Unbound free variable … DEMIPAD.GOV|LAUNCHPAD|SC_NAME` at Custodians:193.

**Verified 2026-09-17:** `03_Custodians.pact:496-499` and `:302-303`. [VERIFIED by reading]

### 4.4 #8M — the stub had to be unreachable, not silent

`direct-injection` is an **unbuilt feature**. In `C_Deposit`, with the flag true, the inbound token
transfer became a no-op — no tokens entered the shared launchpad account — while the seller-ledger
credit `XI_DepositForAsset` still ran, raising that asset's withdrawable `funds-*` balance. A later
`C_Withdraw` would then pull those phantom funds out of **other sellers' proceeds** in the same
custody account.

Doubly latent: all four live callers hardcode `direct-injection = false`, and the old capability only
let `true` through when an admin flag was on. But the flag could be flipped. It was a landmine, not
dead code.

The design conversation is what makes this finding worth reading. Building the real path needs AQP
vaults live, an injection profile, a finalize-and-redeploy cycle — not something testable now. So the
decision was to leave a stub. And then the interesting part: **a silent no-op body was explicitly
rejected as the stub.** If a flipped flag made the deposit silently take no payment while the acquire
flow still delivered the asset, that is a free-asset hole — a worse bug than the one being stubbed
out. The stub had to make direct-injection **unreachable**, not quiet.

The result is `UEV_DirectInjection`, an **unconditional** hard block that ignores the admin flag
entirely, composed into `DEMIPAD|C>DEPOSIT` in place of the old flag-gated branch — plus
defence-in-depth: the seller credit is additionally wrapped in `(if (not direct-injection) … true)`,
so even if the capability is loosened during the future AQP build, the credit cannot fire before the
transfer is wired. The `UR_DirectInjection` state is kept, reserved, to gate the real path when it
exists.

Proved with the admin flag turned **ON**: `UEV_DirectInjection true` still fails. Bug direction proved
by restoring the flag-gated form, at which point with the flag on it returns `true` — *"expected
failure, got result: true"*.

**Verified 2026-09-17:** `00_Demipad.pact:1208-1216`, composed at `:580`. The `@doc` records the whole
reasoning, including what the reserved state is for. [VERIFIED by reading]

### 4.5 #17L — the fix that was correct and lasted one day

`URCI_Acquire` installs capabilities so a buyer can pay without pre-signing transfer caps. The finding
had two halves. The first — *the interface omits it, so cross-module calls "don't resolve"* — was
**REFUTED**: `::` dispatch is dynamic and the suite loads these calls green. What survived was a
convention gap (declare it for drift-catching) and a real contract violation: **`URCI_` was an
improvised prefix**, and worse, the whole `UR*`/`URC*` family is defined side-effect-free while this
function performs `install-capability` under a read-looking name.

The chosen fix was not an ad-hoc rename. `StoicSyntax-Prefixes.md` gained a formally registered `cap`
lowercase specialisation marker, a `URCcap_` prefix meaning *"a `URC_` that installs the caps it
derives"*, a distinct CAP-INSTALL colour family, an interface-membership corollary, and a flat
longest-first prefix index. `URCI_Acquire` was renamed `URCcap_Acquire` across five modules, and
`URC_Acquire` + `URCcap_Acquire` were declared in every relevant interface.

**One day later, `URCcap_` was removed.** `StoicSyntax-Prefixes.md:107` records it:

> **Removed 2026-08-31.** A cap-installing helper uses the **`CAP_`** prefix (Validate/ENFORCE) —
> installing a defcap is what `CAP_` denotes.

The function is `CAP_Acquire` today, in all five modules and all five interfaces [VERIFIED by command].
The half of the finding that survives — *declare it in the interface, and do not hide a state effect
behind a read-shaped name* — is fully honoured. The specific remedy did not survive its own week.

This is a small thing, and it is here because of what it does to the tree: **`URCcap_` appears in the
DEMIPAD audit documents and nowhere in the code**, and a reader checking that fix by grepping the name
the audit records will find nothing and reasonably conclude the fix was lost. It was not. It was
superseded. That distinction is only visible if you look for what replaced it, and it is the single
most likely place for a future reader of this tree to draw a wrong conclusion.

---

## 5. What later rounds found, including one thing this audit built and got wrong

### The #1C fix was correct, and the reader underneath it was not

The red-team round came back to STOAICO on 2026-09-14 and attacked the dust sweep from the other side.
`DEFECT-LEDGER.md` §1.1d records it as **GS-06**.

`URC_ClaimableRewards` still branched on one condition:

```pact
(if (= (UR_Global7) 1) (UR_Global4) (URC_AvailableRewards account))
```

`UR_Global7` is `unclaimed-count`, a property of the **vault**. `UR_Global4` is the whole remaining
`wstoa-supply`. The branch asks *"is exactly one claimant left?"* and never *"is **this** account that
claimant?"* — so whenever the count happened to be 1, **every** caller was told the entire vault was
theirs.

Measured at `RedTeam/[RT-E]_Sequencing.repl` `<<RT-E-001>>`, reached by a legitimate admin action
rather than an attack:

```
post-stake: unclaimed=1  nzs=3  newcomer-owed=0.000000  newcomer-OFFERED=690.525983
```

**No theft was possible, and that is precisely why it survived this audit.** The thing preventing it
is #1C's own repair — `A_Stake` stamps a newcomer's `last-collected-round` to the current round, and
the collect capability enforces `(< last-collected-round distribution-round)`, so a newcomer is born
already-collected. The money never moved.

But the same reader feeds `URCi_Collect` and `INFO_Collect`, so the **preview told such an account it
would receive the whole vault**. And the thing preventing the theft was a stamp written in a
*different function*, with nothing connecting the two. The owner's ruling, recorded in the ledger:
*a wrong reader is an error whether or not it is exploitable.*

Fixed by `URC_IzDustSweepClaimant`, which adds the two missing O(1) conditions — is this a real
staker, and has it already collected this round [VERIFIED by reading —
`05_STOAICO.pact:406-421`, all three conjuncts present, consumed at `:449`].

**What this means for #1C's verdict.** The fix was real, correct and load-bearing: it is what made the
defect un-exploitable. But **#1C's own description of the root cause named the reader** —
*"stop deriving 'final claimer gets everything' from a mutable global"* — and the reader was not
changed. The audit fixed the capability and the counter, which closed the attack, and left the
mis-derived number in place. Sixteen days later it was still lying to every preview.

### And the sibling it was ported from had the same shape, worse

The same session found **GS-08** in AQP: `AQP-RPS::URC_CollectClaimableRewards` had the identical
counter-only sweep branch — and there, no `last-collected-round` stamp exists. A fully-exited account
with zero weight collected the whole vault while the rightful sole claimant received `0.0`. Measured,
on the deployed stack. See {{ch:aqp}}, §5.

Both are ports of the Stoa `coin` UrStoa vault, whose comments the code still carries (*"coin step
1"*, *"coin step 2"*). `coin` is correct: its guard is `(and (= unclaimed-count 1) (> available 0.0))`,
and the repair is preserved in genesis with the pre-fix version commented out directly above it. **The
caller conjunct was dropped in both ports.**

### The verdict on #13L rests on a premise that a sibling counter later failed

**#13L** — *`unclaimed-count`/`nzs-count` have no lower bound* — was declined, and the reasoning was:
*use the canonical AQP implementation, verified bug-free — no clamp.* AQP's `WU_Score|NzsCount` updates
by a computed delta with no floor and no enforce, trusting the *guarded delta*: a decrement is only
ever reached on a genuine non-zero→zero transition, after a matching increment. Adding a clamp to
STOAICO would diverge from a settled pattern.

That premise **still holds as stated** [VERIFIED by reading — `02_SCORE.pact:3121-3132`,
`WU_Score|NzsCount` is still an unclamped `(+ old-nzs nz-delta)`].

But a different AQP counter, in a different file, failed exactly the way #13L worried about.
**GS-09**: `XI_1|BookCollectUnclaimed` in `04_RPS.pact` decremented on `deb == 0` alone, with no check
that the caller was ever counted — so a zero-weight account decremented the counter *for somebody
else*, once per call, for the price of gas. Walk it to 1 and GS-08 re-arms against honest stakers.

So the appeal-to-canonical-sibling argument was **correct about the counter it cited and not
transferable to the family**. "This pattern is proven elsewhere" is an argument about one instance of a
pattern. The general defence — *trust the guarded delta* — is only as good as the guard, and the
AQP-RPS guard was `deb == 0` with no membership test.

**#13L's disposition is not overturned by this**, because STOAICO's counter genuinely is protected —
by the round stamp #1C added, plus the flush's uncollected-only walk. But the **form** of the argument
should be read with care.

### Every citizen launchpad preview quoted a purchase it would refuse

**RT-K-006** found that Spark, Snakes, Custodians and StoicPay all price through
`DEMIPAD::URCi_Deposit`, and the amount check lived **inline in `DEMIPAD|C>DEPOSIT`**, where no reader
could share it. Buying **zero** was quoted as valid; buying **negative** was refused in a helper's
words rather than the operation's.

The repair is the one worth copying: the check was extracted to `UEV_DepositDollarAmount` — *one
definition, four sales* — and both the capability and the preview call it [VERIFIED by reading —
`00_Demipad.pact:518`, called at `:558` by the capability and `:1072` by `URCi_Deposit`, with a source
comment stating *"The op's own gate, not a copy of it"*]. The sale's own
`amount <= remaining-supply` gate was deliberately left alone, because remaining supply changes as
other buyers act and a preview should not validate what the caller cannot control.

**This is the direct descendant of #12M.** The audit added a slippage bound to the execution path in
August; the red team found in September that the *quote* the buyer reads before signing did not share
the execution path's arithmetic guards. A guard in one of two paths is half a guard.

### Two guard-reachability defects in the launchpad core

`DEFECT-LEDGER.md` §1.2.1 records `G-05`, and calls it *"the clearest instance"* of the eager-`let`
class in the codebase. The message *"Asset … is not registered to the Demiourgos Lauchpad"*
(`00_Demipad.pact:550`, inside `C>DEPOSIT` at `:527`) was unreachable: the caller got a raw Ledger
table key instead. The fix was
already in the module three lines up — `UR_CheckRegistration` deliberately wraps its read in
`(try false …)`, while its three **sibling** reads of the same row were bare. All three switched to
`with-default-read`. Pinned by `<<TX-DEP-02>>` and `<<DEMIPAD-G2>>`.

`G-32` is `DEMIPAD|C>WITHDRAW`'s type enforce (`00_Demipad.pact:588`), and it is **provably dead**:
`C_Withdraw` binds `(URv_Funds asset-id type)` before entering the capability, and that reader opens
with the identical predicate. It was **ruled KEPT** rather than fixed, because `<retrieval-amount>` is
a parameter of the `@event` capability and moving the read inside would change an event signature
indexers consume. That is a legitimate close, and the ledger records it as accepted-and-annotated
rather than repaired.

---

## 6. What remains open

**Two WONTFIX verdicts**, both argued rather than waved away:

- **#13L** — no clamp on the two counters. Declined to match the canonical AQP pattern. The root
  cause (#1C's ungated collect) is gone; the residual is defensive. See §5 for the one caveat on the
  form of the argument.
- **#14L** — fractional team splits for buys not divisible by 4. The precondition is `KPAY decimals
  < 2`; KPAY has **24**, confirmed in the test fixture and on-chain via the Pythia dirty-read
  (`DPTF.UR_Decimals "STOICPAY-64EvuR4kgZHd"` → `24`). Decimals are fixed at issuance, so the
  condition cannot arise. Guarding against it was declined as defending an impossible state. **This
  chapter did not re-run the live read** — the 24-decimal figure is quoted from the audit, not
  independently re-verified. *(not verified)*

**Two features deliberately stubbed, with the real work scheduled:**

- **Direct injection** (#8M). Hard-blocked. The real path routes the `cod` royalty portion into an AQP
  injection profile, or collects it locally for a daily drip automaton. Needs AQP vaults live and a
  redeploy cycle. Logged in `POST-AUDIT-MAIN-ROADMAP.md` under STAGE 3 / post-AQP.
- **NF transmit end-to-end** (#7M). The capability wiring is fixed and unit-proved via
  `UEV_AssetFungibility` in both directions, but a full non-fungible transmit needs a real DPNF
  collection and the `UEV_IMC`/"after-Upgrade" transmit path, which is separate Talos work. The SF
  direction is proved; **the NF direction is proved at the guard, not end-to-end.**

**One product decision, not a code question:** the StoicPay sale is **suspended**, and whether to
resume it — and on what tokenomics — is open. #11M only re-synced the workspace to what is deployed.

**One open question the audit raised and the owner answered by policy, not by code:** #12M's original
finding was that the launchpad is permissioned, so the admin is trusted, which tempers the
front-running risk. The slippage bound was built anyway. The 50 % tolerance ceiling, however, **is a
UI policy and not an on-chain bound** — `UEV_SlippageCost` enforces only the absolute `max-cost` the
buyer signs. The on-chain code holds no poll-time baseline to recover a percentage from, which the
`@doc` states explicitly. A buyer whose wallet signs a bad `max-cost` is not protected by the chain.

---

## 7. Verification result for this chapter

Every fix recorded as FIXED was searched for in current source on 2026-09-17.

**Nothing was found missing.** All 15 fixes are present, in the five files' new citizen locations
where applicable. One — #17L's `URCcap_` prefix — was **superseded within a day** by
`URCcap_` → `CAP_`, which a reader grepping the audit's own wording will misread as a deletion. It is
not. See §4.5.

**Three caveats a reader should hold against this chapter:**

1. **The tree is the thinnest in Part I and the chapter reflects that.** There is no owner-feedback
   file and no final report; the README's status boxes were never ticked. **Nine** of seventeen
   findings carry a bidirectional REPL proof — eight fix entries, one covering two findings — which
   is still a better rate than either neighbouring audit, but the *consolidation* step the sibling
   audits performed did not happen here.

   > **Corrected 2026-09-18.** This said *"Fifteen of seventeen"*, contradicting §2 of this same
   > chapter, which counts the eight `Bug reproduced` / `Bug direction` entries in
   > `ROUND-02-FIXES.md` and names the nine findings they cover. Fifteen is the **FIXED** count in
   > `ISSUES-RANKED.md`, not the proof count.

2. **Most of this audit's proofs are outside the default pipeline.** `[5.3]_Launchpad.repl` and
   `[6.3]_STOAICO.repl` are **both commented out in `Stage02_Tester.repl`** (lines 73 and 77), which
   is what `Z.repl` loads [VERIFIED by command]. They run under `ZALL.repl` (lines 92 and 94), which
   `REPL/tools/_gate.py` executes, so they are gated — but a developer running the fast path sees
   **none** of the #1C, #2H, #3H/#4H, #5M, #6M, #7M, #8M, #9M or #10M proofs go green. This is the
   exact hazard `CLAUDE.md` names about `Z.repl`: *the fast path, not the gate.* The fix entry for
   #1C flagged the wiring gap as a follow-up at the time; it is still the case, by design, and the
   suites have since been joined by `modules/DEMIPAD.repl` (37 assertions), `modules/LAUNCHPAD.repl`
   (39) and `modules/STOAICO.repl` (12), all globbed into the gate.

3. **The audit's scope no longer matches its directory.** Five of six audited modules are citizen
   modules under `2_CITIZEN/7_Launchpad/`. The audit tree that describes them sits under
   `1_SOVEREIGN/`. That is a consequence of the audit's own #15L reclassification and is correct; it
   is also the first thing that will confuse a future reader, so it is stated twice in this chapter
   on purpose.

---

*Next: {{ch:aqp}} — AQP, the acquisition-pool family, and the largest single body of design work in
Part I.*
