# Chapter 2 — ATS, the Autostake family

> Source tree: `1_SOVEREIGN/STAGE_01/2_Core/Audit/ATS/` (3,296 lines across 7 files, plus a `.docx`
> rendering of the report).
> Audit ran 2026-08-16 → 2026-08-19. This chapter was written 2026-09-17 and re-checks every
> recorded fix against the tree as it stands today.

Evidence labels are the same as Chapter 1: **[V-cmd]** (established by running a read-only command),
**[V-read]** (established by reading the cited source), **[INFERRED]**, **[REPORTED]** (quoted from
the audit trail or the ledger, not re-established here). **No test was executed for this chapter.**

---

## 2.1 What the module does

ATS is Ouronet's staking engine. A user deposits *reward tokens* (RT) into a pool — an **ATS-pair** —
and receives a *reward-bearing token* (RBT) that represents their claim on the pool. The RBT is not a
receipt for a fixed amount; it is a share. As the pool owner **fuels** the pool with more reward
tokens, the pool's *index* (reserves ÷ RBT supply) rises, and every existing RBT becomes redeemable
for more RT than it was minted against. That is the yield.

Getting value back out has three doors, and they are the reason the module is large:

- **Cold recovery** — the ordinary unbonding path. You burn RBT, your claim is recorded into a
  numbered *position* (P0 through P7) on a per-account ledger row, a `cull-time` is stamped on it,
  and after the wait you **cull** it and receive the tokens. The wait length is a table indexed by
  your Elite tier, built so higher tiers wait less.
- **Hot recovery** — you receive an NFT-like DPOF nonce instead of a timer. It can be traded,
  branded, repurposed, or **redeemed** early for a decaying fee.
- **Direct recovery** — instant exit at an owner-configurable fee.

Around this sit the pool owner's levers: royalty rate, syphon floor, hibernation fees, cold-recovery
duration curves, fee-threshold ladders, an elite-mode toggle, a parameter lock, and `KickStart` —
the genesis operation that sets a virgin pool's initial index by declaring how much RT backs how
much RBT.

**What breaks if ATS breaks.** Two things, and they are different in kind. The first is direct:
positions are stored as a *positional array* of per-reward-token amounts, aligned by index against
the pool's live reward-token list. If that alignment ever drifts, a staker's claim is paid in the
wrong token — not lost, *misattributed*, which is worse because the ledger still balances. The second
is indirect: `KickStart` sets the index a virgin pool starts at, and every later depositor's mint is
`floor(rt_amount / index, precision)`. An unbounded genesis index is the classic vault
inflation-attack setup, where a later depositor's real tokens are credited in full to the pool while
their own RBT rounds down to a negligible fraction of fair value.

Both of those are in this chapter. The first is C2. The second is M2.

---

## 2.2 How it was audited

**Round I — four parallel lenses, read-only, plus a hand-run lead pass on the priority target.**
The scope was split by role rather than by file: admin/lifecycle, usage/token-custody, utility maths,
and Talos wiring + interfaces. Each lens was briefed with the same contract as the sibling AQP audit
— load `StoicSyntax.md` first, work read-only, **assume nothing is correct despite being live on
mainnet**. [REPORTED — `ATS/README.md` § Method]

One thing was done differently here and it is the methodological high point of the tree. **C2, the
reward-token remove/re-add mechanic, was the audit's declared priority target going in**, and the
lead verified it end-to-end by hand across `08_ATS.pact` + `10_ATSU.pact` + `09_U_ATS.pact` **before
reading any lens result**. Two lenses then independently converged on the same defect from different
directions — ATSU's `X_RemoveSecondary` precondition gap, and U_ATS's `UC_ReshapeUnstakeObject`
gating bug — giving three independent derivations of one root cause. [REPORTED]

`VST` was declared an explicit **boundary**, not an audited module: `ATS|C_VestedCoil`/`VestedCurl`
call into it, but its internal correctness was out of scope. The tree says so up front, which is the
right way to scope an audit.

**Round I — the C1 correction, and what it taught.** The Talos lens reported, as CRITICAL, that
`ATS|GOV` — a `(defcap () true)` wired as the Autostake vault's governor guard — was forgeable by any
caller, allowing a full drain. It claimed an *empirical reproduction* in an isolated two-module
Pact 5.4 REPL.

The owner refuted it: Pact requires a foreign caller to already hold the target module's own admin
before `with-capability` will grant that module's capabilities. The lens's repro had not isolated
the claimed threat model — it ran without error, but it did not test the thing it said it tested.
The audit re-verified the refutation independently with a fresh two-module repro using a foreign
module holding zero admin, and recorded the conclusion in its own method section:

> *"This is a reminder that even an 'empirically reproduced' finding needs its repro checked for
> whether it actually isolates the claimed threat model, not just whether it runs without error."*
> [REPORTED — `ATS/README.md` § Method, "Correction, 2026-08-16"]

The correction also *narrowed* the rest of the audit usefully. `ATS|GOV` is the documented "Simple
vault" pattern (`StoicSyntax.md §14.5`) and four sibling modules use it identically. The residual
question — *does any of this module's own public functions compose its `GOV` cap without an
ownership check first?* — is a per-module reading task, and it is exactly what C5 turned out to be.

**Round II — 18 sequential fixes.** Each owner-green-lit, each with a diff and a proof. The
discipline is visible in the fix entries and is worth naming because it repeatedly changed the
answer:

- **Verify under correct preconditions before touching code.** For C3, the owner suspected the dead
  REPL call might be a benign "nothing to redeem" state. Three escalating checks followed; the
  second one *failed for a different reason* (a fixture whose `block-time` was set two years before
  the nonce's mint time), which would have been reported as confirmation by a less careful pass. The
  third, under honestly forward-moving time, hit the real defect at the predicted line. [REPORTED]
- **Own the process failures in the record.** Fix #12's entry opens: *"a first pass at this fix was
  applied **without owner authorization** — the owner had only said 'let's do next'… Reverted
  immediately in full once caught."* [REPORTED]
- **Two fixes had no write-up until the audit audited itself.** Fixes #13, #14 and #17 were applied
  to code during the session but never logged; they were caught while re-auditing the tally in a
  fresh worktree and back-filled, each with a note saying so and a re-verification that the code fix
  was genuinely present before the entry was written. [REPORTED]

**Round III was never created.** The cycle table lists `ROUND-03-REVERIFY.md` as *"not yet
created"*; it does not exist. [V-cmd] Unlike the SWP tree, no later systematic re-verify pass covered
ATS either. This chapter is, as far as can be determined, the first.

**Was the audit thin anywhere?** The Round-I coverage of the Hot-RBT surface and ~12 configuration
functions was zero — the audit says so as finding L4/`#22L`, and Fix #15 closed it by writing nine
new transaction groups. That is the correct response. But note what that implies about Round I
itself: for a dozen owner-facing functions, the Round-I verdict rested entirely on reading, because
there was nothing to run. Two real bugs (N2 and N3) fell out the moment tests were actually written
— see §2.4.

---

## 2.3 The findings

35 findings: `#1C`–`#31L` from Round I, plus `#32N`–`#35N` appended after the original list was
published (deliberately appended rather than renumbered, so the original numbering never shifts).
Severity is as recorded. The audit uses two ID schemes in parallel — a ranked `#nnX` and a
per-severity `C1`/`H2`/`M6`/`L9`/`N1` — and this chapter gives both, because the tree's own
cross-references use whichever was to hand.

### CRITICAL

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| `#1C` / C1 | `ATS\|GOV` is `(defcap () true)` and is the vault's governor guard — claimed forgeable, full drain | CRIT | **REFUTED** | Pact requires foreign module-admin first. The pattern is intact and still used: `08_ATS.pact` `ATS\|GOV`, plus `VST\|GOV`, `LIQUID\|GOV`, `ORBR\|GOV`, `SWP\|GOV`. [REPORTED + V-cmd] |
| `#2C` / C2 | Reward-token remove-then-re-add corrupts every pre-existing position's token attribution — **three** sub-mechanisms: (a) cull pays the wrong token, (b) royalty permanently stranded, (c) cold recovery permanently unusable for existing accounts | CRIT | **FIXED** | (a)+(c): `1_Utilities/09_U_ATS.pact:394-404` — `UC_ReshapeUnstakeObject` now calls `UCv_SolidifyUnstakeObject` unconditionally, comment names `#1C / C2c`. (b): `2_Core/10_ATSU.pact:1530-1596` — `XI_RemoveSecondary` derives the account list on-chain via `URH_ExistingAutostakePairs` and migrates RUR bucket 3 (royalty) alongside 1 and 2. [V-read] **No witness in the running suite** — see §2.5. |
| `#3C` / C3 | `ATSU::C_Redeem` passes a `:decimal` where Pact's `if` requires `:bool` — **every** call reverts; the only exit from hot recovery is permanently dead | CRIT | **FIXED** | `10_ATSU.pact:2117` — `(have-fee-rts:bool (!= are-fee-rts 0.0))`, with a comment naming `#3C / C3`; used at `:2131`. A second instance exists correctly at `:1162`. [V-read] **Witnessed**: `REPL/Stage_01/[6.6]_ATS.repl:483-484` (early redeem withheld a real fee — paid *strictly less* than full value) and `:565` (matured redeem paid *exactly* full value). [V-read] |
| `#4C` / C4 | `syphon` floor has no monotonicity, lock or timelock — the owner can re-lower it and extract ~95%+ of pool backing in one call | CRIT | **NOT A BUG** | Owner: full at-will discretionary control (bounded `>= 0.1`) is intended; stakers trust the pool owner with this lever. Proposed ratchet explicitly rejected. [REPORTED] |
| `#5C` / C5 | `C_HOT-RBT\|UpdatePendingBranding`/`UpgradeBranding` have **no** owner or entity-linkage check at all | CRIT | **FIXED** | `08_ATS.pact:736` — new unevented core `ATS\|C>HOT-RBT-BRD` resolves the owning pair from the hot-rbt id, `CAP_Owner`, then composes `ATS\|GOV`; `:746` and `:750` are the two `@event` leaves; used at `:2993` and `:3004`. [V-read] |

### HIGH

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| `#6H` / H1 | Parameter-lock protects fee-schedule config but not royalty, syphon, hibernation fees, ownership rotation or the recovery switches | HIGH | **FIXED / CLOSED** (2 of 8 fields; 6 confirmed intentionally exempt) | `08_ATS.pact:638` and `:660` — `(UEV_ParameterLockState atspair false)` is now the first statement of `ATS\|S>SET-HIBERNATION-FEES` and `ATS\|S>ROYALTY`, each with a comment naming `#6H / H1`. [V-read] **No witness** — see §2.5. |
| `#7H` / H2 | Royalty ceiling is 99.9%, applies instantly, no lock or delta cap | HIGH | **FIXED** | `08_ATS.pact:662` — `(enforce (<= royalty 500.0) "Royalty cannot exceed 500.0 promile (50%)")`, layered over the shared `UEV_Fee`. [V-read] **Witnessed**: `[6.6]_ATS.repl:3689` (999.0 rejected), `:3693` (500.0001 rejected), `:3702` (500.0 accepted), `:3711`/`:3717` (both off-sentinels still work). [V-read] |
| `#8H` / H3 | `URC_RBT`'s `abs()` masks the `-1.0` "uninitialised index" sentinel — Coil/Curl bypass KickStart, genesis inflation / zero-mint donation | HIGH | **NOT A BUG** (both scenarios) | Scenario 1: bare-Coil bootstrap is the intended alternative to KickStart. Scenario 2: refuted on tracing — `DPTF\|C>CREDIT`'s `UEV_Amount` reverts a `0.0` mint atomically, so no silent-donation window exists. [REPORTED] |
| `#9H` / H4 | `UEV_ColdDurationParameters`' soft branch calls `enforce` with 3 arguments — soft cold-recovery duration can never be set post-genesis | HIGH | **FIXED** | `1_Utilities/09_U_ATS.pact:730-758` — one correctly-formed 2-arg enforce per branch; the `@doc` names both `#9H / H4` and `#16M / M7`. [V-read] **Witnessed**: `REPL/modules/UTILITIES.repl:119` `<<UTIL-03>>` — soft branch accepted with valid params, and refused with a message that *names the values*, asserted as a pair against the hard branch's anonymous message. [V-read] |

### MEDIUM

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| `#10M` / M1 | `UEV_HibernationFees` has a malformed `(= () 0.0)` term — `C_SetHibernationFees` **always** fails | MED | **FIXED** | `09_U_ATS.pact:699-705` — the stray term is gone; the `@doc` records what it was (`()` is Pact's unit value; the comparison is always false, dragging the whole `(fold (and) …)` to false). [V-read] Indirectly witnessed: `modules/ATS.repl:2246 ATS-I5` executes `C_SetHibernationFees` through the real Talos path. [V-cmd] |
| `#11M` / M2 | `C_KickStart` has no bound on the `rt-amounts : rbt-request-amount` ratio — vault inflation-attack setup | MED | **FIXED** | Layered per `StoicSyntax §14.7`: `10_ATSU.pact:370 ATSU\|C>X_KICKSTART` (shared core, `>= 0.1` floor), `:340 ATSU\|C>KICKSTART` (`@event` leaf, `CAP_Owner` + `<= 100.0` ceiling), `:359 ATSU\|C>ADMINISTRATIVE-KICKSTART` (`@event` leaf, `GOV\|ATSU_ADMIN`, floor only). New helper `09_U_ATS.pact:303 UC_KickStartIndex` returns `-1.0` on a non-positive divisor rather than crashing in a `let`. [V-read] **Witnessed**: `modules/ATS.repl:850` `<<ATS-G9>>` — *"an owner-path KickStart above index 100.0 is refused"*; `:602` `<<ATS-G5>>` covers the core's four sequential guards. [V-read] |
| `#12M` / M3 | `XE_UpdateRUR` has no floor-at-zero on any of its three buckets | MED | **NOT A BUG** | `UDC_RT`'s constructor `enforce` fires during the `let`-binding phase, before any write — a complete atomic backstop, not partial defence. [REPORTED] |
| `#13M` / M4 | `C_Fuel` doesn't gate on the lock-state flags `RemoveSecondary` requires | MED | **NOT A BUG** | Coil/Curl skip all four locks too; the locks exist to protect the RT-list reshape specifically. [REPORTED] |
| `#14M` / M5 | Elite toggle switches the position-selection algorithm on already-populated ledger rows | MED | **NOT A BUG** | The toggle changes only the *search window* for new deposits; stored P1–P7 rows are always read literally. [REPORTED] |
| `#15M` / M6 | `UEV_CRF\|FeeThresholds` never validates threshold *values* despite its `@doc` promising `[1,100]` | MED | **FIXED (doc-only)** | `09_U_ATS.pact:601-606` — `@doc` now says the bound is on the **count**, and says why values have no ceiling. [V-read] **Witnessed** for the count bound: `modules/UTILITIES.repl:350-355`. [V-read] |
| `#16M` / M7 | Hard-branch cold-duration params never enforce `growth > 0` — a negative, evenly-dividing growth inverts the whole wait curve | MED | **FIXED** | `09_U_ATS.pact:745` and `:754` — `(> growth 0)` on both branches (soft had the identical gap). [V-read] **Witnessed**: `modules/UTILITIES.repl:142-144` — *"a zero growth is refused before it can divide by zero"*. [V-read] |
| `#17M` / M8 | `UC_SplitByIndexedRBT` has no zero-guard on `resident-sum` — reachable div-by-zero | MED | **NOT A BUG** | Proven from `URC_Index`'s own formula: `resident-sum = 0.0` is the *only* way `index` reads exactly `0.0`, so a strictly-positive index guarantees a nonzero divisor by construction. [REPORTED] |
| `#18M` / M9 | `UC_SplitByIndexedRBT` trusts positional alignment of two arrays with no length-parity guard | MED | **NOT A BUG** | Both arrays are a 1:1 map over the same `reward-tokens` list; they cannot desync. [REPORTED] |

### LOW

| id | summary | verdict | evidence today |
|---|---|---|---|
| `#19L` / L1 | `ATS\|F>OWNER` — dead capability, never composed | **FIXED** | Gone. Zero `F>OWNER` occurrences in `08_ATS.pact`; the sibling `DALOS\|F>OWNER` survives at `01_DALOS.pact:873` and is composed twice, confirming the pattern itself was fine. [V-cmd] |
| `#20L` / L2 | `UR_P-KEYS`/`UR_KEYS` perform raw `keys` scans under a `UR_` prefix | **NOT A BUG (deferred)** | Repo-wide convention; folded into the post-audit sweep. [REPORTED] |
| `#21L` / L3 | `can-upgrade` is permanently `true` with no setter — a V1→V2 vestige gating `C_Control` | **FIXED** | New setter: `08_ATS.pact:255` (interface), `:3202` (impl), plus cap and `XI_`; Talos wrapper `3_Talos/03_TS01-C2.pact:70`/`:614`. [V-read] **Witnessed**: `[6.6]_ATS.repl:2653` (*"can-upgrade is now false"*), `:2654` (`C_Control` then refused), `:2698` (restored). [V-read] |
| `#22L` / L4 | Hot-RBT surface + ~12 config `C_*` functions have **zero** REPL coverage; the suite that exists isn't in the default pipeline | **FIXED** | `[6.6]_ATS.repl` now carries 45 `expect`/`expect-failure` forms across the twelve functions. [V-cmd] **But the pipeline half regressed** — see §2.5. |
| `#23L` / L5 | Hibernation fee computed but never separately tracked, asymmetric vs royalty | **NOT A BUG** | Traced in `C_Brumate`: the full pre-fee amount is credited to resident while the coiler receives less RBT — the fee stays in the pool, raising the index for existing holders. [REPORTED] |
| `#24L` / L6 | `URC_RewardBearingTokenAmounts` hardcodes `dayz=1` | **NOT A BUG** | `dayz` only matters when hibernation is on, and every caller of the plain variant is gated to hibernation-off by its own cap. [REPORTED] |
| `#25L` / L7 | `XI_Normalize`'s 16-branch position reshuffle not hand-verified | **VERIFIED CORRECT** | Full trace of all 9 top-level branches + the `take`/`drop` slicing; occupied slots are never dropped or duplicated. No defect. [REPORTED] |
| `#26L` / L8 | `C_KickStart`'s `rt-amounts` array is caller-order-trusted | **NOT A BUG** | Owner-only function; a wrong order misconfigures only the caller's own pool. [REPORTED] |
| `#27L` / L9 | `U_DPTF::UC_UnlockPrice`'s `@doc` says "ATS" (copy-paste) | **FIXED → since deleted** | **The fixed function no longer exists.** `02_IGNIS.pact:1501-1509` records that the escalating unlock ladder (`U\|DEC`/`U\|ATS`/`U\|DPTF` `UC_UnlockPrice`) *"had been dead code since the flattening and was DELETED 2026-09-10"*; the flat replacement is `UC_FeeUnlockPrice`. [V-read] |
| `#28L` / L10 | `UC_IzStoicTagIndexChar`/`UC_IzStoicTagIndex`/`UEV_StoicTagIndex` are dead and collide by name with the live CODEX StoicTag feature | **ONGOING (kept)** | **Still present, still dead.** `09_U_ATS.pact:57-58` and `:63` declare all three. [V-cmd] Owner: *"leave them."* |
| `#29L` / L11 | `defcap P\|ATS` in `05_TS01-P.pact` — dead code shadowing the real `P\|ATS\|CALLER` machinery | **FIXED** | Gone; zero `defcap P\|ATS` in that file. [V-cmd] |
| `#30L` / L12 | Several ATSU master defcaps put a bare-ref validation call before local `enforce`s | **ONGOING (kept)** | Deferred to the StoicSyntax sweep; confirmed harmless (affects only which message fires first). [REPORTED] |
| `#31L` / L13 | Talos wrapper `ATS\|C_SetHotRecoveryFee` (singular) vs core `C_SetHotRecoveryFees` (plural) | **NOT A BUG (left as-is)** | Renaming would cascade into a new interface version plus two citizen-module consumers plus a coordinated redeploy. [REPORTED] |

### Appended after the original list

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| `#32N` / N1 | `URC_MultiCull` returns a raw `[decimal]` on its "nothing cullable" branch but an object on the other — `XI_MultiCull`'s `:object` binding makes it a hard crash; reachable by **any** account with nothing currently ripe | — | **FIXED** | `10_ATSU.pact:641-681` — the empty branch now returns the same 4-key object shape (`after-cull` unchanged, two empty lists, `summed-culled-values: zr-output`). Talos reports it distinctly: `3_Talos/03_TS01-C2.pact:1030` *"Nothing to Cull just yet for ATS-Pair {} - no positions have reached their cull-time"*. [V-read] **No witness** — see §2.5. |
| `#33N` / N2 | `C_WithdrawRoyalties` hands its full per-RT royalty vector to `TFT::C_MultiTransfer`, which debits every leg unconditionally — any `0.0` leg crashes the whole withdrawal | HIGH | **FIXED** | `10_ATSU.pact:1651` — `nonzero-idx` filters both lists before the multi-transfer; the RUR-reset loop still iterates every RT, so no accounting is skipped. The same filter is mirrored in the preview at `:766-777`. [V-read] **Witnessed**: `[6.6]_ATS.repl:3557` (royalty accrued, nonzero) and `:3563` (all buckets reset after withdrawal). [V-read] |
| `#34N` / N3 | `P\|A_Define` in `01_TS01-A.pact` never registered `ATS` or `ATSU` as permitted Talos-admin callers — `ATS\|A_RemoveSecondary` and `ATS\|A_KickStart` were **unreachable, unconditionally, for any signer** | HIGH | **FIXED** | `3_Talos/01_TS01-A.pact:249-250` — `(ref-P\|ATS::P\|A_AddIMP mg)` and `(ref-P\|ATSU::P\|A_AddIMP mg)`, in the list alongside the eight that were already there; the missing `ref-P\|ATSU` binding is at `:234`. The in-source comment at `:219` records the history. [V-read] |
| `#35N` / N4 | The audit added 5 new public functions across 5 interfaces with no version bump — 3 of them already live on mainnet under those exact names | — | **ONGOING (deployment prerequisite)** | **Resolved by the later redeploy phase.** All three required bumps are present: `UtilityAtsV2 → UtilityAtsV3` (`09_U_ATS.pact:2`), `AutostakeUsageV1 → AutostakeUsageV2` (`10_ATSU.pact:6`), `AutostakeV2 → AutostakeV3` (`08_ATS.pact:6`). [V-cmd] |

### A note on this tree's own counting

The audit's two summary documents disagree with each other and with the list they summarise. This is
worth stating precisely, because Rule 3 of this book exists for it.

- `ISSUES-RANKED.md`'s Tally says **"FIXED: 19"** and then enumerates **18** ids.
- `AUDIT-REPORT.md` §1 says **"19 fixed… 13 closed as not-a-bug… 3 deferred"**, summing to 35.
- Counting the verdict tag on every entry gives **18 FIXED, 14 NOT A BUG, 3 ONGOING = 35**. [V-cmd]

So the report's total is right only because two errors cancel: fixed is overstated by one and
not-a-bug understated by one. The correct figures are 18 / 14 / 3. None of this changes a verdict;
it changes the headline number an outside reader would quote.

---

## 2.4 Six findings worth the telling

### (a) C2 — one bug, three symptoms, and the sentinel that made it invisible

This was the audit's declared priority target, and it is the best-diagnosed finding in the tree.

A staker's cold-recovery claim lives in an `Awo` object: a `[decimal]` array of per-reward-token
amounts, positionally aligned against the pool's live `reward-tokens` list, plus a `cull-time`. When
the pool owner removes a secondary reward token, every stored `Awo` on every account has to be
reshaped — fold the removed index's value into slot 0 (the primal RT) and shrink the array by one.

`UC_ReshapeUnstakeObject` did that *conditionally*, gated behind `UC_IzUnstakeObjectValid` — which
is true only when the object already has a nonzero claim. The overwhelming majority of ledger rows
are untouched, all-zero P0–P7 slots. Those were silently skipped. Every one kept its pre-removal
array length forever.

Now the three symptoms:

- **(c) cold recovery becomes permanently unusable.** `URCX_PosObjSt` and `XI_StoreUnstakeObject`
  answer "is this slot open?" by **structural equality** against a freshly length-derived zero
  sentinel. Once the live reward-token list shrank, a stale longer array no longer equals the
  sentinel — so every empty slot on every pre-existing account reads as permanently *occupied*.
- **(a) a cull pays the wrong token.** A stale, longer-than-current array read positionally against
  the shorter live list attributes each amount to the wrong token.
- **(b) royalty is stranded.** Separately, `X_RemoveSecondary` migrated the removed token's
  *resident* (RUR 1) and *unbonding* (RUR 2) buckets into the primal token but not *royalty*
  (RUR 3). The tokens stayed custodied in `ATS|SC_NAME` with no reward-token entry left to
  reference them; `C_WithdrawRoyalties` could never reach them again.

**The fix is two diffs and a deletion of trust.** `UC_ReshapeUnstakeObject` now calls
`UCv_SolidifyUnstakeObject` unconditionally — merging a `0.0` removee into slot 0 is a value no-op,
it only ever needed to shrink the array. And `X_RemoveSecondary` (now `XI_RemoveSecondary`) **stopped
accepting an account list from its caller at all** and derives the complete list on-chain via
`URH_ExistingAutostakePairs`, closing a latent gap where the admin path could under-supply the list.
`09_U_ATS.pact:394-404` and `10_ATSU.pact:1530-1596`. [V-read]

Note what the audit did *not* claim. Its original plan was to drive the proof through
`A_RemoveSecondary` with a deliberately incomplete caller-supplied list. It records honestly that
this input *no longer exists to construct*, because the fix removed the parameter — so the proof
demonstrates the equivalent property (an account never mentioned in the removal call is still found
and correctly reshaped) and says so. [REPORTED]

The proof itself was strong: a brand-new account, funded, coiled, cold-recovered through the pool's
own real split maths (`[6.0627 PKOSON, 6.0175 EKOSON, 8.3403 AKOSON]`), then EKOSON removed through
the production Talos owner path, then culled — with the actual DPTF balance deltas asserted:
`PKOSON +12.080149529322803393554764`, `AKOSON +8.340265093244058451673906`, bit-for-bit matching the
pre-cull stored amounts. [REPORTED]

**And that proof no longer runs.** See §2.5. This is the single most important caveat in this
chapter.

### (b) C3 — the function that had never once worked, and the fixture that nearly hid it

`C_Redeem` is the only exit from hot recovery. It fed `are-fee-rts` — a summed *decimal* fee amount —
straight into `(if are-fee-rts …)`. Pact's `if` requires a `:bool` and does not coerce a decimal
either way, including `0.0`. Every call reverted. Anyone who had gone through `C_HotRecovery` was
permanently locked out of their underlying tokens.

The reason this survived is visible in the REPL file it should have been caught by. The canonical
"Redeem Test" section had the `C_Redeem` call **commented out**, with `C_Reverse` substituted in its
place, under a fixture that set `block-time` to `2024-10-11` — two years *before* the nonce's own
mint time of `2026-10-10`. A dead test, with a wrong date, standing where the live test should be.

The owner's instinct was that the comment-out might be benign — "nothing to redeem". The audit ran
three escalating checks rather than accept either story:

1. An isolated Pact 5.4 repro confirming `(if <decimal>)` fails for both a nonzero decimal and
   exactly `0.0`.
2. Uncommenting the real call as-is. **It failed — for a different reason**: `ico3`'s
   `TFT::C_MultiTransfer` rejected a negative amount, traced to the backwards fixture date. This is
   the step that matters. A pass that stopped here would have "confirmed" the finding with evidence
   that proves nothing about it.
3. The same call under honestly forward-moving time (mint `2026-10-10`, redeem `2026-10-12`, past
   the decay window — the cleanest possible input). It failed exactly where predicted:
   `10_ATSU.pact:1067:28: expected bool value, got 0.0`.

The fix is one added binding (`10_ATSU.pact:2117` [V-read]) and the dead test was **rewritten rather
than patched around** — into two real assertion-backed branches. It is one of the few ATS proofs that
is still live today: `[6.6]_ATS.repl:483-484` asserts the early redeem paid *strictly less* than full
value (proving a real fee was withheld, not just "didn't crash"), and `:565` asserts the matured
redeem paid exactly full value. [V-read]

### (c) N3 — two admin functions that were dead on arrival, found only because someone wrote a test

`P|A_Define` is the function each Talos module runs once at init to register itself as a permitted
caller into every core module its admin functions must reach — one `(ref-P|<MODULE>::P|A_AddIMP mg)`
per module. Every core module's `UEV_IMC` checks that whitelist before any key-authorisation logic
runs at all.

`TS01-A`'s own `P|A_Define` registered into DALOS, IGNIS, BRD, DPTF, DPOF, LIQUID, OUROBOROS and
SWP — but not ATS or ATSU. `ATS` was even **bound as a local variable (`ref-P|ATS`) and then never
used in the body**: a half-finished registration, not a typo elsewhere. Every *other* Talos module's
`P|A_Define` registers into both.

Consequence: `ATS|A_RemoveSecondary` and `ATS|A_KickStart` — real admin entrypoints, not scaffolding
— were **completely unreachable via their real Talos admin path, unconditionally, regardless of who
signed**, failing inside `UEV_IMC` with *"None of the guards passed"* before the admin's own key
check could matter.

Two things about this are instructive. First, it is invisible to code review of ATS: nothing in
`08_ATS.pact` or `10_ATSU.pact` is wrong. The defect is an *absence* in a third file. Second, it was
found by **writing the missing tests from finding L4** — the coverage gap and the bug were the same
event, and the audit chose to log it as its own numbered finding rather than fold it into L4's
narrative, on the explicit precedent that C5 and H4/M1 were also "bugs testing revealed" and still
got their own IDs. That is the right call: a coverage gap that hid a bug should leave two entries in
the record, not one.

`3_Talos/01_TS01-A.pact:249-250` [V-read].

### (d) M2 — the finding whose premise was refuted, and which survived anyway

M2 (`#11M`) originally rested on the same "silent zero-mint donation" story as H3, which the audit
had just **refuted**: an exact-`0.0` mint reverts the whole transaction atomically via
`DPTF|C>CREDIT`'s `UEV_Amount`, so there is no silent donation.

The easy move here is to close M2 as a dependent of a refuted finding. The audit re-examined it
instead and found the premise wrong but the attack intact, in a regime the original write-up had not
described: a genesis ratio extreme enough that a later `Coil`'s `floor(rt_amount / index, p)` lands
on a tiny **nonzero** RBT amount. The transaction then succeeds. The depositor's real RT is credited
in full to the pool's resident bucket; their RBT is a negligible fraction of fair value; the
difference is a permanent transfer to whoever already held RBT. That is the classic first-depositor
vault inflation attack, and it does not need a zero-mint to work.

The fix is the shape worth copying. Rather than pick a single bound, it **layered** the capability
per `StoicSyntax §14.7` — one unevented core holding the shared checks and the floor, two
distinctly-`@event`-tagged leaves on top:

```
ATSU|C>X_KICKSTART              (core, unevented)  — shared checks + index >= 0.1
  ├─ ATSU|C>KICKSTART           (@event leaf)      — CAP_Owner + index <= 100.0
  └─ ATSU|C>ADMINISTRATIVE-KICKSTART (@event leaf) — GOV|ATSU_ADMIN, no ceiling
```

So the pool owner is bounded on both sides; module governance can exceed the ceiling for legitimate
high ratios but still cannot go below the floor; and the two paths emit distinguishable on-chain
events. `10_ATSU.pact:340, 359, 370` [V-read].

The audit also disclosed a limitation of its proof rather than glossing it: a full end-to-end run
through a brand-new virgin pool was out of scope (pair creation needs a separate multi-step token
registration flow), so the bound checks were driven via `test-capability` against the real deployed
capabilities on an already-kickstarted pair, with real signatures — proving every bound exactly as it
runs in production, with only the orthogonal virgin-pool gate inferred rather than re-demonstrated.
[REPORTED] That coverage has since been replaced by real assertions: `modules/ATS.repl:850`
`<<ATS-G9>>` refuses an owner-path KickStart above index 100.0. [V-read]

### (e) C5 — the owner worked out why the suspicious code was correct, and found the real gap underneath it

`C_HOT-RBT|UpdatePendingBranding` and `C_HOT-RBT|UpgradeBranding` wrapped themselves in
`with-capability (ATS|GOV)` — the trivially-true "Simple vault" cap that C1 had just been refuted
over. The obvious reading is "here it is again, and this time it's exploitable."

The owner reasoned it out the other way. A Hot-RBT's DPOF owner-konto is `ATS|SC_NAME` (rotated there
by `C_AddHotRBT`), so DPOF's own branding gate resolves to *"prove you own `ats-sc`"* — something
only ATS's own code can do, via `ATS|GOV`. `ATS|GOV` was never the bug; it was load-bearing and
correct.

The real gap was one level up: **nothing checked *who* was allowed to trigger it.** A repo grep over
the exact 21 lines of both functions returned zero `CAP_Owner`, zero `UEV_IMC`, zero enclosing
defcap. Any account could rewrite or paid-upgrade branding on a Hot-RBT it did not own.

The fix is also where a documented StoicSyntax rule was born. The first pass used a **single `@event`
capability shared by both functions**. The owner caught it: sharing one evented cap across two
distinct client actions collapses their on-chain events into one indistinguishable signature — and,
separately, the codebase already had an undocumented pattern for exactly this (one unevented "core"
holding the shared validation, thin distinctly-`@event` leaves on top). The audit verified the
pattern was already live in the same file (`ATS|S>CONTROL-RECOVERY` → two unevented middles → five
`@event` leaves) before adopting it, then formalised it as `StoicSyntax.md §14.7` with this case as
the worked example. It is the same §14.7 that M2's KickStart fix then used.

`08_ATS.pact:736` (core), `:746`, `:750` (leaves) [V-read].

### (f) N1 — the crash that was live on mainnet and had simply never been triggered

`URC_MultiCull` returns an object on its "here's what's cullable" branch and a bare `[decimal]` on
its "nothing cullable yet" branch. `XI_MultiCull` binds the result as `:object`. Any account calling
`C_Cull` with nothing currently past its `cull-time` gets a hard runtime type failure instead of
"nothing to cull".

The audit did something here that most audits cannot: it checked the **live deployed module**. Using
PYTHIA's public dirty-read console — reachable keyless via a `Sec-Fetch-Site: same-origin` header,
which PYTHIA's own source documents as intentionally forgeable by non-browser clients, blast radius
"public chain reads only" — it pulled `describe-module "ouronet-ns.ATSU"` and confirmed **the broken
branch is byte-for-byte identical on mainnet**. It then enumerated all 11 real live ledger rows and
called `URC_MultiCull` against each. All 11 succeeded — *purely because every existing live account
happens to have something already past its cull-time right now.* [REPORTED]

That is a materially different statement from "we found a bug in the source". It is "this bug is
deployed, and the only thing standing between it and every user is the current shape of eleven
ledger rows."

The owner's ruling shaped the fix twice over: nothing lets funds move early, so this is a
**soft-failure** problem, not a fund-safety one — and the correct repair is not a silent zero-value
success but a *distinguishable* message. So `URC_MultiCull`'s empty branch returns the same 4-key
object shape (`10_ATSU.pact:641-681`) and `ATS|C_Cull` reports *"Nothing to Cull just yet for
ATS-Pair {} - no positions have reached their cull-time"* (`03_TS01-C2.pact:1030`). [V-read]

Worth noting for its own sake: a first attempt at this fix was applied **without owner
authorisation** and fully reverted once caught, and the fix entry says so in its own opening
paragraph. An audit that records its own procedural breaches is more trustworthy than one that
doesn't have any.

---

## 2.5 What remains open

### Deliberately open

| item | state today | why |
|---|---|---|
| **`#28L` / L10** — three dead StoicTag functions in `U_ATS` that collide by name with the live, unrelated CODEX StoicTag feature | **Present.** `09_U_ATS.pact:57, 58, 63` declare `UC_IzStoicTagIndexChar`, `UC_IzStoicTagIndex`, `UEV_StoicTagIndex`. [V-cmd] | Owner, explicitly: *"leave them."* Recorded as a deliberate keep, **not** a not-a-bug verdict — the tree is careful about that distinction and so is this chapter. |
| **`#30L` / L12** — ATSU master defcaps place a bare cross-module ref call before their own local `enforce`s | Deferred to the StoicSyntax sweep. | Harmless by construction: every statement in a defcap body runs top-to-bottom to first failure, so the only effects are which message a caller sees when several conditions fail at once, and a little gas on a doomed call. No input gets through that shouldn't. |
| **`#20L` / L2** — `UR_P-KEYS`/`UR_KEYS` are raw `keys` scans under a `UR_` prefix | Repo-wide, off any client mutation path. | Owner: *"by design so far"*; belongs to the module rehaul, not a piecemeal ATS fix. |
| **`#31L` / L13** — Talos/core naming asymmetry on `SetHotRecoveryFee(s)` | Left as-is. | Renaming cascades into a new interface version plus two citizen-module consumers plus a coordinated redeploy, for a cosmetic gain. |

### Closed as NOT A BUG, but a reader should know

- **`#4C` / C4 — the syphon lever is unbounded above `0.1` and has no timelock.** A pool owner can
  re-lower `syphon` at will and extract the great majority of a pool's commingled RT backing
  (principal *and* yield) in a single call. The audit confirmed the mechanics and the owner confirmed
  the design: stakers trust the pool owner with this parameter, and a monotonic ratchet was
  explicitly rejected because `0.6 → 0.5` must remain an ordinary adjustment. **This is the single
  largest trust assumption in the module** and it is not mitigated by anything technical. Anyone
  evaluating an ATS pair is evaluating its owner.
- **`#6H` / H1's six exempt fields.** Only `royalty-promile` and the two hibernation-fee fields got
  the parameter-lock gate. `owner-konto` (rotation), the three `C_Control` toggles
  (`can-change-owner`/`syphoning`/`hibernate`) and the three recovery on/off switches were
  *confirmed* exempt under the same trust model. The lock therefore protects less than its name
  suggests.
- **`#17M` / M8's invariant is protocol-maintained, not self-enforced.** The div-by-zero cannot fire
  *provided* `resident-sum` and `rbt-supply` stay in lockstep — which is exactly the class of
  invariant C2's bug was about. The audit noted this explicitly: no caller of
  `UC_SplitByIndexedRBT`'s chain checks `index > 0` before calling in. Safe by construction today;
  safe by a construction that has been wrong before.

### Fixes present in source with no witness that would go red if reverted

This is where the ATS tree is in materially worse shape than it looks, and the cause is mechanical
rather than anyone's neglect.

Most ATS Round-II proofs were appended to **`REPL/_audit_ats_baseline.repl`**. That file now lives in
`REPL/archive/`, and the gate excludes it *by name*, with a reason that is the finding:

> `("_audit_", "one-off audit baselines; archive/_audit_ats_baseline.repl **does not run to
> completion**, so its 32 assertions are NOT coverage")`
> — `REPL/tools/_gate.py` EXCLUDED [V-read]

Thirty-two assertions that the audit trail treats as its proof of record do not execute and would not
go red. Fix #15 (`#22L`) migrated *some* of them into the canonical `[6.6]_ATS.repl`, and the later
Part II work added `REPL/modules/ATS.repl` (275 assertions) and `REPL/modules/UTILITIES.repl`, which
between them re-cover several more. The following are what is left:

| finding | fix present in source? | witness in the running suite |
|---|---|---|
| **`#2C` / C2** — the audit's priority finding | Yes: `09_U_ATS.pact:394-404`, `10_ATSU.pact:1530-1596` [V-read] | **None.** `UC_ReshapeUnstakeObject` is referenced by exactly one `.repl` in the tree — `archive/_audit_ats_baseline.repl`, which does not run. `modules/UTILITIES.repl:213` `<<UTIL-05>>` tests `UCv_SolidifyUnstakeObject` **directly**, i.e. the inner function, bypassing the gate whose removal *was* the fix. Re-introducing `UC_IzUnstakeObjectValid` into `UC_ReshapeUnstakeObject` would leave `<<UTIL-05>>` green. And `UC_IzUnstakeObjectValid` still exists, with **zero callers** (`09_U_ATS.pact:47`, `:291`) — the exact artefact a future reader might helpfully re-wire. The royalty half (C2b) has no assertion either: `[6.6]_ATS.repl`'s `Secondary Remove 1|5`–`5|5` blocks (lines 1326-1620) contain **zero `expect` forms**. [V-cmd] |
| **`#6H` / H1** — parameter-lock gate on royalty + hibernation fees | Yes: `08_ATS.pact:638`, `:660` [V-read] | **None.** `UEV_ParameterLockState`'s message *"Parameter-lock for ATS Pair {} must be set to {} for this operation"* (`08_ATS.pact:2388`) appears in **no** `.repl` file. `modules/ATS.repl:1284` `<<ATS-G16>>` tests the lock's own two-sided rule, not that the royalty setter is behind it. [V-cmd] |
| **`#32N` / N1** — `URC_MultiCull` soft failure | Yes: `10_ATSU.pact:641-681`, `03_TS01-C2.pact:1030` [V-read] | **None.** The string *"Nothing to Cull"* appears only in `archive/_audit_ats_baseline.repl`. [V-cmd] |
| **`#5C` / C5** — Hot-RBT branding ownership | Yes: `08_ATS.pact:736` [V-read] | **Not found.** `[6.6]_ATS.repl` exercises Hot-RBT branding on the happy path (`:3298`, `:3379`) but no assertion refuses a non-owner. The negative proof lived in the baseline. [V-cmd] |

Conversely, and to be fair to the tree, these **are** witnessed today and this chapter names the
assertion: C3 (`[6.6]_ATS.repl:483, 484, 565`), `#7H` (`:3689`–`:3717`), `#21L`
(`:2653`, `:2654`, `:2698`), `#33N` (`:3557`, `:3563`), `#11M` (`modules/ATS.repl` `<<ATS-G9>>`,
`<<ATS-G5>>`), `#9H` and `#16M` and `#15M` (`modules/UTILITIES.repl` `<<UTIL-03>>`, `<<UTIL-02>>`,
`:350-355`), and `#34N` indirectly (the `A_KickStart`/`A_RemoveSecondary` blocks in `[6.6]` can only
pass because the registration exists).

### One regression in the audit's own fix

Fix #15's write-up states that it *"uncommented the `[6.5]_DPOF.repl`/`[6.6]_ATS.repl` load lines in
`Stage01_Tester.repl`"*, and records that it found them disabled in that worktree — *"the same class
of silent-revert data loss documented in the Claudstermind handoff, this time surviving the worktree
transition undetected until this pass."*

**They are commented out again today**: `REPL/Stage01_Tester.repl:48-49`. [V-cmd]

The reason given is legitimate and is not a revert of the fix's intent: a `#12a GUARD` comment
explains that the Stage-2 AQP path self-loads `[6.5]_DPOF.repl`, so loading it in Stage 1 too
re-issues a token and aborts on duplicate-insert. The coverage itself did **not** disappear —
`[6.6]_ATS.repl` is loaded by `ZALL.repl:38` and by `REPL/modules/ATS.repl:6`, and `ZALL.repl` is
what the exhaustive path runs. [V-cmd]

But the guard's own justification has gone stale in a way worth flagging:

> *"ATS tests run via their own driver `_audit_ats_baseline.repl` (Stage-1-only, no double-load)."*
> — `Stage01_Tester.repl:47` [V-read]

`_audit_ats_baseline.repl` is in `archive/`, is excluded by the gate, and does not run to completion.
The comment that tells a reader why it is safe to skip `[6.6]` points at a file that has not executed
for weeks. The coverage is real; the reason written next to the exclusion is not. That is the
documentation form of the same pathology this programme keeps finding in code — a statement that
outlived the thing it described, and is indistinguishable from a true one from the outside.

### Not re-verified for this chapter

`#25L` (the `XI_Normalize` 16-branch trace), `#12M`, `#13M`, `#14M`, `#17M`, `#18M`, `#23L`, `#24L`
and `#26L` were closed by tracing arguments that this chapter did not re-derive. Their verdicts are
**[REPORTED]**, not re-established. Of these, `#25L` carries the most weight — it is the only
finding in the tree closed by exhaustive manual trace of a 9-branch, 7-slot reshuffle with no
automated check behind it, and nothing in the running suite would catch a regression in
`XI_Normalize`.
