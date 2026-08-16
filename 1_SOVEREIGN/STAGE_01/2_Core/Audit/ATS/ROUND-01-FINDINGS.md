# ROUND I — Findings (ATS modules)

**Date:** 2026-08-16 · **Status:** frozen (append-only). Owner verdicts recorded inline as they arrive.
**Scope:** `1_SOVEREIGN/STAGE_01/2_Core/08_ATS.pact` (`AutostakeV2`, 2832 lines), `10_ATSU.pact`
(`AutostakeUsageV1`, 1414 lines), `1_Utilities/09_U_ATS.pact` (647 lines), `1_Utilities/10_U_DPTF.pact`
(173 lines — ATS-relevant slice only, see note below), the ATS/ATSU section of `3_Talos/03_TS01-C2.pact`
plus wiring slivers in `01_TS01-A.pact` / `02_TS01-C1.pact` / `05_TS01-P.pact`, and the interfaces
`AutostakeV2`, `AutostakeUsageV1`, `AutostakeComputerV1`, `BrandingUsagePrimaryV1`, `BrandingV1`,
`UtilityAtsV2` (all inside `0_Interfaces/01_Utilities.pact` / `02_Core.pact`). Module list enumerated from
`OuronetInformational/MODULE-INDEX.md` rows `U|ATS`, `U|DPTF`, `ATS`, `ATSU`, `TS01-C2` — not guessed.
`VST` is a documented boundary (called from `ATS|C_VestedCoil`/`VestedCurl`), not independently audited.

**Baseline:** `[6.6]_ATS.repl` is **not part of the default pipeline** — it is commented out in
`Stage01_Tester.repl:56` (along with `[6.5]_DPOF.repl` and `[6.7]_VST.repl`). A standalone run
(`REPL/_audit_ats_baseline.repl`, Stage00 sandboxes → Stage01 prefix → `[6.5]_DPOF` → `[6.6]_ATS`, pact
5.4) was executed for this audit: **`Load successful`, 15 `expect`/`expect-failure` assertions, 0
failures.** This gap (ATS's own integration suite not wired into the CI-equivalent pipeline) is itself a
contributing factor to several findings below shipping unnoticed — see L4. Critically, "0 failures" does
**not** corroborate C2: the suite's `"Secondary Remove …"` → `"Add Secondary AGAIN with Hybrid Cull Test
1|3/2|3/3|3"` transactions (`REPL/Stage_01/[6.6]_ATS.repl:1536-1953`) walk through **exactly** C2's
scenario — remove reward-token `AKOSON`, re-add it, open new Cold-Recovery positions for account `AOZET`,
then `C_Cull` — but every observability block in that section is a bare `let`-returned list literal (e.g.
`:1792-1817`, `:1895-1911`) that is never passed to `print`/`map print`, unlike this file's own documented
convention elsewhere (`"expect / expect-failure return strings; map print surfaces each line"`). Confirmed
by grepping the actual run output: zero occurrences of `"AOZET P"`, `"AOZET has"`, or `"Culling AOZ"`
anywhere in the transcript, even though the section executes `(ref-TS01-C2::ATS|C_Cull aoz aoz ps)` and
formats its result. **This exact code path produces no observable output and is covered by zero
assertions** — the harness cannot currently detect C2 even though it exercises the vulnerable sequence.
(Separately, this particular test instance opens `aoz`'s Cold-Recovery positions *after* the re-add, so it
would not by itself demonstrate C2(a)'s cross-token misattribution even if it were observed — C2(a) needs a
position opened *before* removal, as constructed in this document's own scenario. It would, however, be
positioned to catch C2(c), the reshape-gating defect on `aoz`'s never-yet-used P2-P7 slots, and does not.)

> **Ground truth for reward math** (carried over from the AQP audit for cross-reference): the proven
> UrStoa RPS vault, `00_StoaSandbox/coin.pact` 1520-1940 — floor-division conservation, guard `S>0` before
> `G += floor(R/S, PREC)`. ATS's own index (`URC_Index`, `08_ATS.pact:1097-1111`) is a **different**
> model — a full resident-backing ratio (`resident-sum / rbt-supply`), not a yield-only accumulator — this
> distinction matters for C4/H1/H2 below (syphon/royalty draw from *total* backing, not just accrued yield).

Verification tags: **CONFIRMED** = re-read/traced the exact code path (one case empirically reproduced in
a standalone Pact REPL) · **PLAUSIBLE** = strong evidence from reading the code, recommend REPL
confirmation before the fix round.

---

# HIGHEST PRIORITY — reward-token remove/re-add on a living pool

This was the audit's explicit priority target: verify that removing a reward token from an ATS-Pair and
later re-adding one preserves exact reward accounting for every staker, including those who entered or
exited during the window. **It does not.** Three independent, confirmed sub-mechanisms all trace back to
one root design gap — see **C2** below for the full write-up, invariant statement, and per-path proof.
Short version: an ATS-Pair's `reward-tokens` array is a Pact list, and every place downstream that stores
a **per-account** value keyed to "which reward token is this" does so **positionally** (`Awo.reward-
tokens:[decimal]`, no token id stored per slot) rather than by token identity. `XE_RemoveSecondary`
splices an element out of that array (`UC_RemoveItem`), permanently shifting every later position down by
one — and nothing re-derives or re-validates any already-existing per-account row against the new layout.
The three confirmed consequences (payout misattribution, royalty stranding, and a total inability to
detect "does this account have an open cold-recovery slot") are documented as C2(a)/(b)/(c).

---

# CRITICAL

## C1 · Talos/ATS — `ATS|GOV` is `(defcap () true)` and backs the Autostake vault's governor guard — full drain, any caller `[REFUTED — see correction below]`

> **CORRECTION (owner, 2026-08-16) — REFUTED. Not a bug.** This finding is factually wrong and is kept
> below only as a frozen historical record of what was originally claimed (per this round's append-only
> discipline), not as a live finding. **Do not act on this section.** Pact requires a foreign caller — a
> different module, or bare transaction/top-level code — to already hold **`ATS`'s own module admin**
> before it can acquire `ATS|GOV` (or any capability defined in `08_ATS.pact`) via `with-capability`.
> Verified independently in an isolated two-module Pact 5.4 repro (a foreign module with zero relation to
> the target, attempting to acquire the target's trivially-`true` capability, fails with `"Module admin
> necessary for operation but has not been acquired"`). `ATS|GOV` is `StoicSyntax.md §14.5`'s documented,
> intentional **"Simple vault"** pattern — safe precisely because only code physically inside `08_ATS.pact`
> can ever compose it, which is exactly how `C_AddHotRBT`/`C_HOT-RBT|Repurpose` legitimately use it. The
> "empirical reproduction" originally cited below did not actually isolate a truly foreign, non-admin
> caller and was itself flawed. Full detail: `ROUND-01-OWNER-FEEDBACK.md` and
> `memories/2026-08-16-with-capability-requires-module-admin-for-foreign-callers.md`. **What survives:**
> **C5**, below, is a real, separate bug in the same neighborhood — two specific *public* ATS functions
> compose `ATS|GOV` (safely, as home-module code) with no ownership check gating who may call them.

**Location:** `08_ATS.pact:251-254` (`(defcap ATS|GOV () true)`); genesis wiring
`REPL/Stage_01/[4.0]_Sovereign-Executor.repl:432-441` (`ats-sc`'s governor guard =
`UEV_GuardOfAny [(create-capability-guard (ATS.ATS|GOV)), P|ATSU|RemoteAtsGov, P|TFT|RemoteAtsGov,
P|VST|RemoteAtsGov]`); `01_DALOS.pact:924-943` (`UEV_SmartAccOwn`, `enforce-one` over
account-guard/sovereign-guard/**governor**); `01_DALOS.pact:1054-1060` (`CAP_EnforceAccountOwnership`,
Ouronet's central sender-ownership gate, used by every fungible transfer); `09_TFT.pact:294-317`
(`DPTF|C>X-TRANSFER`, calls `CAP_EnforceAccountOwnership sender`); `1_Utilities/02_U_G.pact:55-71`
(`UEV_Any`/`UEV_GuardOfAny` — succeeds if *any one* candidate guard passes).

**What's wrong:** `ATS|GOV`'s body performs zero authorization — it is the literal boolean `true`. Pact
does not restrict `with-capability` to "callers inside the defining module" (that's a StoicSyntax
*discipline* convention, not something the language enforces); any transaction, from any account,
including one wholly unrelated to Ouronet's own Talos/gas-station path, can request
`(with-capability (n_xxx.ATS.ATS|GOV) body)` and have it granted unconditionally. `ats-sc` (`ATS|SC_NAME`)
— the smart account that custodies **every** resident reward token and in-flight Cold/Hot-RBT across
**every** ATS-Pair system-wide — accepts `create-capability-guard (ATS.ATS|GOV)` as one of its valid
governor guards. Once `ATS|GOV` is on the active-capability stack, any subsequent `enforce-guard` against
that governor guard (which is exactly what `CAP_EnforceAccountOwnership ats-sc` does, transitively, via
`UEV_SmartAccOwn`'s `enforce-one`) succeeds — for **anyone**.

**Empirical verification:** reproduced the exact mechanic in isolation with the repo's pinned `pact 5.4`
binary: a throwaway two-module REPL where module `A` defines `(defcap FREE () true)` and
`(defun vault-guard () (create-capability-guard (FREE)))`, and unrelated module `B` defines
`(defun spend (g:guard) (enforce-guard g) ...)`. `(B.spend (A.vault-guard))` called bare fails
(`enforce-guard` has nothing granted). The **same call**, wrapped as
`(with-capability (A.FREE) (B.spend (A.vault-guard)))`, from top-level/outsider code, **succeeds** — an
outsider freely acquires and weaponizes another module's zero-check capability against a guard evaluated
in a completely different module. This is exactly the `ATS|GOV` → `ats-sc` governor → 
`CAP_EnforceAccountOwnership` → `TFT::C_Transfer` chain.

**Failure scenario:** a self-paid, non-Talos transaction:
```pact
(with-capability (n_xxx.ATS.ATS|GOV)
  (with-capability (n_xxx.ATSU.P|ATSU|CALLER)   ;; also unconditionally-true — see cross-ref below
    (n_xxx.TFT.C_Transfer <any-resident-reward-token> ats-sc <attacker-account> <full-balance> true)))
```
`CAP_EnforceAccountOwnership ats-sc` (the sender check on the outbound transfer) passes via the forged
`ATS|GOV`; the transfer executes. This drains the **entire** resident reward-token balance of the
Autostake system in one transaction. The same forged capability also passes any other
`CAP_EnforceAccountOwnership ats-sc` gate — e.g. permanently re-rotating `ats-sc`'s governor to a guard
the attacker fully controls, seizing the vault outright rather than just draining its current balance.

**Cross-cutting (flagged to the owner, out of strict ATS scope):** the identical pattern —
`MODULE|GOV = (defcap () true)` used as a Stage-1 smart account's governor guard — repeats verbatim for
`VST|GOV` (`11_VST.pact:103-106`), `LIQUID|GOV` (`12_LIQUID.pact:59-62`), `ORBR|GOV`
(`13_OUROBOROS.pact:50-53`), `SWP|GOV` (`15_SWP.pact:137-140`). If exploitable on live StoaChain, this is
one root cause draining **every** module-owned custody vault in Stage 1, not just ATS's. See README.md's
cross-cutting note. Separately, `10_ATSU.pact:80-85` (`P|ATSU|CALLER`/`P|ATSU|REMOTE-GOV`) are **also**
unconditionally `true` — closing C1 on the `ats-sc` governor list alone (removing the
`create-capability-guard (ATS.ATS|GOV)` entry) is insufficient if the fix routes through those.

**Fix direction:** `ATS|GOV`'s body must perform real enforcement before it can safely back a governor
guard: gate it behind the existing admin authority (`(enforce-one "ATS Governor" [(enforce-guard
GOV|MD_ATS) (enforce-guard GOV|SC_ATS)])`, mirroring `GOV|ATS_ADMIN`), and re-architect the ATS-internal
calls that currently rely on `(with-capability (ATS|GOV) ...)` for ordinary custody moves (`C_AddHotRBT`,
etc.) to route through `SECURE`-gated, module-local `XI_*` instead of leaving the module under a
governor-guard capability. This is a **behavioral fix, not an interface change** — `ATS|GOV` is not
exposed on any interface, so no version cascade is triggered; but `P|ATSU|CALLER`/`P|ATSU|REMOTE-GOV`
need the same audit-and-fix before this is actually closed end-to-end.

**Owner verdict:** _pending_

---

## C2 · ATS/ATSU/U_ATS — reward-token remove/re-add corrupts per-account claim accounting `[CONFIRMED — 3 independent proofs]`

**The invariant that must hold:** for every account's outstanding unbonding/cull position, the value
stored for "reward token at slot i" must, at settlement time, be paid out **in the same token** that
occupied slot i when the position was created — equivalently, `Σ(all outstanding per-account claims, per
token) == that token's pool-level resident+unbonding aggregate`, and no mutating path may ever transfer
token X to satisfy a claim that was originally denominated in token Y, nor silently drop a claim.

**Root cause:** `Awo` (`UtilityAtsV2.Awo`, `0_Interfaces/01_Utilities.pact:256-259` /`:290-293`) is
```pact
(defschema Awo
    reward-tokens:[decimal]   ;; NO token identity per slot — pure position
    cull-time:time
)
```
Every P0-P7 unbonding-position object stores one decimal per reward token, **indexed purely by array
position** in whatever the pair's live `reward-tokens` list order was *at creation time*
(`UDC_MakeUnstakeObject`, `08_ATS.pact:1720-1723`: `(make-list (length (UR_RewardTokenList atspair)) 0.0)`
— length and order both borrowed from the list at that instant, then frozen). `XE_RemoveSecondary`
(`08_ATS.pact:2469-2485`) removes a reward token via `(ref-U|LST::UC_RemoveItem rt (at rtp rt))` — a real
splice (`UC_RemoveItem` = `(filter (!= item) in)`, `1_Utilities/05_U_LST.pact:91-94`) that permanently
shifts every later array position down by one. `C_AddSecondary` → `XI_AddSecondary`
(`08_ATS.pact:2369-2382`) always **appends** the new token at the end. Neither touches, resizes, or
re-validates a single already-existing `Awo` row anywhere in `ATS|Ledger`.

### (a) Payout misattribution at settlement — `[CONFIRMED, lead trace]`

**Location:** `10_ATSU.pact:873-921` (`C_Cull`); `08_ATS.pact:1262-1279` (`URC_CullValue`, returns
`(at "reward-tokens" input)` **verbatim, unresized**); `08_ATS.pact:1215-1227`
(`URC_RewardTokenPosition`, resolved against the **live** list).

`C_Cull`'s payout loop:
```pact
(rt-lst:[string] (ref-ATS::UR_RewardTokenList ats))         ;; LIVE list, current order
(cw:[decimal] (ref-U|DEC::UC_AddHybridArray [c0 c1 c2 c3 c4 c5 c6 c7]))  ;; culled Awo arrays, raw, unresized
...
(enumerate 0 (- (length rt-lst) 1))    ;; zips cw[idx] against rt-lst[idx] BY POSITION
  ... (ref-TFT::C_Transfer (at idx rt-lst) ATS|SC_NAME culler (at idx cw) true) ...
```
`UC_AddHybridArray` (`1_Utilities/07_U_DEC.pact:57-84`) pads short arrays with `0.0` for out-of-range
indices, so pure **append-only growth is safe** (an old, shorter `Awo` array never accidentally claims a
newly-added token — verified: it contributes `0.0` at that index). Growth is not the bug. **Removal is.**
A middle-splice reindexes every later slot; `URC_CullValue` never re-derives the array against the
*current* list, and `C_Cull` unconditionally zips whatever it gets against the current `rt-lst` by
position.

**Concrete failure scenario:** pair `MYATS` has reward tokens `[KDA(0), USDX(1)]`. Alice opens an
unbonding position while the list is `[KDA, USDX]`; her `Awo.reward-tokens = [50.0, 10.0]` (50 KDA-
equivalent, 10 USDX-equivalent, queued). Owner later calls `C_RemoveSecondary` to remove USDX (position 1
— allowed; the only removal guard, `ATSU|C>X_REMOVE-SECONDARY`, `10_ATSU.pact:205-218`, checks
`rt-position > 0` and pool-wide lock/recovery *toggle* state, never any per-account balance or Alice's
specific position). Live list becomes `[KDA]`. Owner then calls `C_AddSecondary` to add DAI — appended at
position 1. Live list is now `[KDA(0), DAI(1)]`. Alice's `Awo` is untouched: still `[50.0, 10.0]`. Alice
culls: `C_Cull` zips `cw=[50.0, 10.0]` against `rt-lst=[KDA, DAI]` — idx 0 correctly pays 50 KDA; **idx 1
pays Alice 10.0 DAI**, a token she never held any position in. Her real 10.0-USDX claim is gone (USDX no
longer appears anywhere reachable — `URC_RewardTokenPosition` hard-`enforce`-fails "RT isnt not an RT in
the ATS-Pair" for USDX now), and the pool pays out 10.0 units of DAI it may be relying on to back *other*
accounts' legitimate DAI positions — a cross-account fund misdirection, not merely Alice's own loss.

### (b) Royalty bucket stranded on removal — `[CONFIRMED, ATSU lens]`

**Location:** `10_ATSU.pact:1353-1410` (`X_RemoveSecondary`), specifically `:1393-1394`
(`XE_UpdateRUR ats primal-rt 1 true resident-sum` / `... 2 true unbound-sum`) vs. `08_ATS.pact:2469-2485`
(`XE_RemoveSecondary`, deletes the **whole** `ATS|RewardTokenSchemaV2` row, buckets 1/2/**3** together).

`X_RemoveSecondary` migrates bucket 1 (resident) and bucket 2 (unbonding) of the removed token into the
primal token's buckets before deleting the row — but **never reads or migrates bucket 3 (royalty)**. The
physical payout to the remover (`ico2`, `:1381-1383`, `TFT::C_Transfer reward-token ATS|SC_NAME remover
remove-sum true`) moves only `resident-sum + unbound-sum`, **not** `+ royalty`. Any accrued, un-withdrawn
royalty on that token (from prior `C_Coil`/`C_Curl` calls) is deleted from the array with no transfer, no
migration, no event — physically still custodied in `ATS|SC_NAME`, but permanently unreachable
(`URC_RewardTokenPosition` will hard-fail on that token name forever after; `C_WithdrawRoyalties` can
never target it again). Concrete: token `X` has royalty `50.0`, resident `1000.0`, unbonding `0.0` at
removal time — `1000.0` is paid out, `50.0` vanishes into stranded custody permanently.

### (c) Cold recovery permanently disabled for every pre-existing account — `[CONFIRMED, U_ATS lens]`

**Location:** `1_Utilities/09_U_ATS.pact:145-176` (`UC_ReshapeUnstakeObject`); symptom at
`08_ATS.pact:1404-1420` (`URCX_PosObjSt`) and `10_ATSU.pact:1293-1303` (`XI_StoreUnstakeObject`, P0
branch).

`X_RemoveSecondary` does try to reshape every account's stored positions (`XE_ReshapeUnstakeAccount`,
`08_ATS.pact:2548-2572`) — but `UC_ReshapeUnstakeObject` only actually resizes a slot when
`UC_IzUnstakeObjectValid` (`sum(reward-tokens) > 0`) is true; otherwise it returns the **input
unchanged, at its old length**:
```pact
(defun UC_ReshapeUnstakeObject (input remove-position)
    (if (UC_IzUnstakeObjectValid input)
        (UC_SolidifyUnstakeObject input remove-position)
        input                                    ;; array NOT resized
    )
)
```
Every default/untouched P0-P7 slot (`UDC_MakeUnstakeObject`) has `sum == 0` by construction — the
overwhelming majority of all ledger rows at any given time (any account that staked but never yet
initiated a cold-recovery unstake). So on **every** removal, every account's *unused* slots silently keep
the pre-removal array length while the pair's live list shrinks by one. `URCX_PosObjSt`
(`08_ATS.pact:1404-1420`) then decides "is this slot open?" by **structural equality** against a
freshly-sized zero sentinel (`UDC_MakeZeroUnstakeObject`, sized to the *current*, now-shorter list); two
Pact lists of different length are never `=`, so every never-reshaped slot reads as "occupied" — even
though it's never been touched. `URC_WhichPosition` finds no open slot for that account. **Cold recovery
becomes permanently unusable** for every pre-existing account on any pair that has ever had a reward token
removed, with no self-healing path (the stale array is only ever rewritten when a position IS
successfully claimed — which this bug prevents). The identical structural-equality check in
`XI_StoreUnstakeObject`'s P0 branch (`10_ATSU.pact:1296-1303`) fails the same way, so instead of reusing
an empty P0 slot, every future unstake for that account **appends** a new row, leaking toward the
`size < 250` hard cap (`10_ATSU.pact:1295`).

**Fix direction (all three):** stop treating the reward-token array as position-identity. Minimum viable
fix: (1) `UC_ReshapeUnstakeObject`/`UC_MultiReshapeUnstakeObject` must **unconditionally** resize/reorder
every stored `Awo.reward-tokens` to match the post-removal list (merging into slot 0 only when there's a
nonzero value to preserve — resizing regardless); (2) `X_RemoveSecondary` must migrate bucket 3
(royalty) exactly as it does buckets 1/2, or `enforce` royalty `== 0.0` before allowing removal; (3)
`URCX_PosObjSt`/`XI_StoreUnstakeObject`'s emptiness checks must compare against a *reshaped* sentinel (or
compare lengths first) instead of raw structural equality against a differently-sized fresh object. A more
robust long-term fix replaces the bare positional `[decimal]` with `[{token:string, amount:decimal}]` (or
equivalent identity-keyed structure) so no future removal/reorder can silently desync stored claims from
live token identity at all.

**Owner verdict:** _pending_

---

## C3 · ATSU — `C_Redeem` passes a decimal where `if` requires a boolean — every call reverts, permanent fund lock `[CONFIRMED]`

**Location:** `10_ATSU.pact:1054` (binding) / `:1069` (use), inside `C_Redeem` (`:1017-1104`).

**What's wrong:**
```pact
(fee-rts:[decimal] (zip (lambda (x:decimal y:decimal) (- x y)) total-rts earned-rts))
(are-fee-rts:decimal (fold (+) 0.0 fee-rts))       ;; declared :decimal, not :bool
...
(folded-obj:[...] (if are-fee-rts (fold ...) [EOC]))   ;; :decimal fed to `if`, which requires :bool
```
`are-fee-rts` is an explicitly-typed `:decimal` sum, not a predicate — every other `are-*` boolean in this
codebase (`are-e`, `are-transfer-roles-active` in `09_TFT.pact`/`06_DPOF.pact`) is a genuine bool; this is
the sole outlier, confirming a naming-convention slip rather than an accepted idiom. Pact's `if` requires
`cond:bool` and will reject a `:decimal` argument at execution time. `folded-obj` is an **unconditional**
`let` binding (Pact evaluates every `let` binding once, regardless of later use), so this fires on
**every single call**, with no way to route around it.

**Failure scenario:** any Hot-RBT holder calling `C_Redeem redeemer id nonce` to convert a matured (or
partially matured) position back into underlying RT hits this binding and the tx aborts with a native
argument-type error, unconditionally. `C_Recover` (the only sibling function) only does cold↔hot
conversion — it never releases underlying RT. **No other function in `ATSU`'s public surface converts a
Hot-RBT nonce into RT.** Any account that has gone through `C_HotRecovery` has **no live path** to ever
recover the underlying reward token — a permanent, total fund lock for that entire user cohort, not an
inconvenience.

**Corroboration:** `REPL/Stage_01/[6.6]_ATS.repl` never actually calls `C_Redeem` — the only reference
(line ~456) is commented out, replaced with `ATS|C_Reverse`. Directly explains why this shipped: the
reference suite doesn't exercise the code path (compounded by L4 — the whole file isn't even in the
default pipeline).

**Fix direction:** `(if (!= are-fee-rts 0.0) ...)`, or bind a real boolean
(`have-fee-rts:bool (!= are-fee-rts 0.0)`) matching the `are-*` naming convention used elsewhere. Add a
REPL regression exercising `C_Redeem` both pre- and post-decay before closing.

**Owner verdict:** _pending_

---

## C4 · ATS — `syphon` floor has no monotonicity or lock; owner can extract ~full pool backing in one call `[CONFIRMED]`

**Location:** `08_ATS.pact:438-451` (`ATS|S>SYPHON`), `08_ATS.pact:2330-2335` (`XI_UpdateSyphon`),
`08_ATS.pact:1168-1206` (`URC_MaxSyphon`), `08_ATS.pact:1097-1110` (`URC_Index`), issuance default
`syphon: 1.0` (`:2268`).

**What's wrong:** `URC_Index atspair = resident-sum(RT reserves) / rbt-total-supply` — the pool's **full
backing ratio** (principal *and* accrued yield, commingled), not a yield-only accumulator. `syphon` is a
floor on that index; `URC_MaxSyphon`'s syphonable amount is `rbt-supply * (index - syphon)` ==
`resident-sum - rbt-supply * syphon` — everything above the floor is extractable in one call. `ATS|S>
SYPHON`'s **only** bound is `(enforce (>= syphon 0.1) ...)` plus a precision check — no check that
`syphon >= current syphon` (a ratchet), no check against the current index, and (per **H1**) no
`UEV_ParameterLockState` gate either. The owner can move the floor from any elevated value straight back
to `0.1` in a single `C_UpdateSyphon` call, instantly re-exposing the entire accrued spread as syphonable
— including users' own original principal, not just yield, since `index` conflates the two.

**Concrete numbers:** pair issued with `rbt-supply = 1,000,000`, `index = 1.0` (`resident-sum =
1,000,000` RT), `syphon = 1.0` (default at issuance — nothing syphonable, as intended). Rewards accrue and
users stake more; `index` rises to `2.0` (`resident-sum = 2,000,000` RT — original principal + yield,
commingled). Owner calls `C_UpdateSyphon(atspair, 0.1)` — passes (`0.1 >= 0.1`, nothing else checked).
`URC_MaxSyphon = 1,000,000 * (2.0 - 0.1) = 1,900,000` RT — **95% of total reserves** — syphonable in one
call, no timelock, no user consent, and (per H1) no protection even while cold/hot/direct recovery is
actively in progress for users trying to exit.

**Fix direction:** enforce `syphon` can only move **upward** relative to its stored value (a ratchet —
consistent with "syphon promises a floor the owner won't skim below"), and/or gate `C_UpdateSyphon` behind
`UEV_ParameterLockState atspair false` (matching H1's broader fix). Consider bounding the *rate* of
decrease per unlock cycle, or a timelock/notice period before a lowered floor takes effect.

**Owner verdict:** _pending_

---

## C5 · ATS — `C_HOT-RBT|UpdatePendingBranding` / `C_HOT-RBT|UpgradeBranding` have no owner/entity-linkage check `[CONFIRMED]`

**Location:** `08_ATS.pact:1818-1838`; contrast `C_UpdatePendingBranding`/`C_UpgradeBranding`
(`:1787-1816`, gated by `ATS|C>UPDATE-BRD`/`C>UPGRADE-BRD`, both call `CAP_Owner atspair` at `:499`/`:504`)
and `C_HOT-RBT|Repurpose` (`:1839-1870`, gated by `ATS|C>REPURPOSE-HOT-RBT`, `CAP_Owner atspair` at `:515`
**before** composing `ATS|GOV` at `:516`); `06_DPOF.pact:527-536` + `:1389-1406`
(`DPOF|C>UPDATE-BRD`/`UEV_ParentOwnership`); `3_Talos/03_TS01-C2.pact:286-330` (Talos wrappers).

**What's wrong:** every other owner-gated `C_*` in `08_ATS.pact` composes `CAP_Owner atspair` (directly or
transitively) before doing anything privileged — confirmed for all 21 sibling functions, including this
pair's own twin (pair-branding, above) and its neighbor (`Repurpose`, above). `C_HOT-RBT|
UpdatePendingBranding`/`UpgradeBranding` are the sole exceptions: no `UEV_IMC`, no cap, no `CAP_Owner` —
straight into `(with-capability (ATS|GOV) (ref-B|DPOF::C_UpdatePendingBranding entity-id ...))`. Since
these two functions are themselves defined *inside* `08_ATS.pact`, their `with-capability (ATS|GOV)` call
succeeds unconditionally for **any caller** — this is the correct, intended, safe way `ATS|GOV` is meant
to be composed by the module's own code (see C1's correction — this is *not* a capability-forgery issue).
The actual bug is narrower and doesn't need C1 at all: **nothing gates *who may call these two specific
public functions in the first place***, unlike every sibling function, which checks `CAP_Owner` before
doing anything. DPOF's own branding gate then resolves ownership via `CAP_EnforceAccountOwnership
(UR_Konto id)` — for a Hot-RBT this is `ATS|SC_NAME`, and it passes because `ATS|GOV` is already
legitimately on the call stack (composed by ATS's own code, per the corrected C1 semantics) — so DPOF has
no way to know the *original* caller wasn't the pair owner. This is inconsistent with every sibling
function's ownership model, and directly contradicts what the sibling function's own doc string promises
for the same subsystem: `C_HOT-RBT|Repurpose`'s Talos doc, `TS01-C2.pact:314`: *"Can only be done by
atspair owner."*

**Failure scenario:** any account calls, via Talos,
`ATS|C_HOT-RBT|UpdatePendingBranding(patron=attacker, entity-id=<victim's hot-rbt>, ...)` — gated only by
the global-pause check `P|TS`, no per-caller/per-entity restriction. Succeeds end-to-end: attacker
rewrites branding (logo/description/website/social) of a token they don't own. `UpgradeBranding` is the
paid variant — attacker pays KDA to force a branding *upgrade* onto someone else's token, a paid
defacement primitive.

**Fix direction:** add `CAP_Owner atspair` (resolved via `ref-DPOF::UR_RewardBearingToken hot-rbt`, exactly
as `ATS|C>REPURPOSE-HOT-RBT` already does at `:513-515`) before composing `ATS|GOV`, in both functions,
wrapped in a proper master-defcap per the `C_*` contract (`UEV_IMC` + `with-capability`) — mirroring the
two sibling functions that already do this correctly. `ATS|GOV` itself needs no change (C1 is refuted).

**Owner verdict:** _pending_

---

# HIGH

## H1 · ATS — parameter-lock protects fee-schedule config but not royalty/syphon/hibernation-fees/ownership/control `[CONFIRMED]`

**Location:** `08_ATS.pact:124` (`UEV_ParameterLockState` decl), `:1654-1660` (impl); composed by
`ATS|C>CONTROL-COLD-RECOVERY` (`:647-650`), `ATS|C>CONTROL-HOT-RECOVERY` (`:694-697`),
`ATS|S>CONTROL-DIRECT-RECOVERY`/`C>SET_DIRECT_FEE` (`:699-712`), `ATS|C>ADD-TOKEN` (`:593-599`). **Not**
composed by `ATS|S>ROTATE_OWNERSHIP` (`:411-422`), `ATS|S>CONTROL` (`:423-437`), `ATS|S>ROYALTY`
(`:462-471`), `ATS|S>SYPHON` (`:438-451` — see C4), `ATS|S>SET-HIBERNATION-FEES` (`:452-461`), or any of
the cold/hot/direct recovery on/off *switches* themselves (`:477-491`).

**What's wrong:** the lock's own toggle cap (`ATS|C>TOGGLE-PARAMETER-LOCK`, `:548-576`) requires at least
one recovery mechanism ON to lock, and all OFF to unlock — implying the lock is meant to freeze a pair's
economics while a recovery is actively in progress, protecting users mid-unwind. But because the recovery
on/off switches aren't themselves lock-gated, the owner can flip `cold-recovery`/`hot-recovery`/
`direct-recovery` to `false` one at a time while `parameter-lock` stays `true`, quietly violating the
invariant the lock is meant to guarantee — and, more materially, royalty, syphon (C4), and hibernation
fees can all be changed freely at any point during an active recovery window, lock notwithstanding.

**Fix direction:** gate `C_UpdateRoyalty`, `C_UpdateSyphon`, `C_SetHibernationFees`,
`C_SwitchColdRecovery`/`HotRecovery`/`DirectRecovery` on `UEV_ParameterLockState atspair false` too (or, at
minimum, document the feature precisely as "cold/hot/direct fee-schedule + token-addition lock" so users
don't read it as a general economics freeze — given C4's severity, gating is the safer default).

**Owner verdict:** _pending_

## H2 · ATS — royalty ceiling (99.9%) applies instantly, no lock/timelock `[CONFIRMED]`

**Location:** `08_ATS.pact:462-471` (`ATS|S>ROYALTY`), `1_Utilities/08_U_DALOS.pact:432-450` (`UEV_Fee`,
bounds royalty to `{-1.0, 0.0} ∪ [1.0, 999.0]` promile, i.e. up to 99.9%).

**What's wrong:** no parameter-lock gate (H1), no per-tx delta cap, no timelock. The owner can move
royalty from `0.0` to `999.0` in one call, instantly redirecting up to 99.9% of future yield to themselves
with zero notice to stakers.

**Fix direction:** gate on `UEV_ParameterLockState` (H1's fix); consider a maximum delta per update, or a
minimum notice window for increases above some threshold.

**Owner verdict:** _pending_

## H3 · ATSU — `URC_RBT`'s `abs()` masks the `-1.0` uninitialized-index sentinel; `Coil`/`Curl` bypass `KickStart` `[CONFIRMED]`

**Location:** `08_ATS.pact:1097-1111` (`URC_Index`, returns sentinel `-1.0` for a never-kickstarted, zero-
RBT-supply pool), `08_ATS.pact:1138-1153` (`URC_RBT`, `(index:decimal (abs (URC_Index atspair)))` at
`:1143`); `10_ATSU.pact:661-702` (`C_Coil`), `:703-760` (`C_Curl`); gates `ATSU|C>COIL` (`:265-276`),
`ATSU|C>CURL` (`:277-289`) — neither checks the index; contrast `ATSU|C>KICKSTART` (`:234-252`,
`enforce (= index -1.0)` at `:247`) and `ATSU|C>FUEL` (`:253-264`, `enforce index >= 0.1`).

**What's wrong:** for a virgin pool, `abs(-1.0) = 1.0` — `URC_RBT` proceeds as if the owner had already
set a real `1.0` index via KickStart, minting RBT 1:1. Neither `COIL` nor `CURL` requires the index to be
anything other than "not obviously broken," and neither requires the caller to be the pool owner.

**Failure scenario 1 (KickStart permanently DoS'd):** owner issues a fresh pair intending to bootstrap via
`C_KickStart` with a deliberate ratio and simultaneous secondary-RT seeding. Before the owner acts, *any*
third party calls `C_Coil` with a trivial amount. `URC_RBT` mints RBT 1:1 against the empty pool; RBT
supply becomes nonzero; `URC_Index` no longer returns `-1.0` — ever again for that pair. Owner's later
`C_KickStart` call now fails permanently at `(enforce (= index -1.0) ...)`. The owner-gated bootstrap path,
including the multi-token `rt-amounts` seeding it offered, is dead for the pair's lifetime.

**Failure scenario 2 (silent zero-mint donation, general case):** neither `C_Coil` nor `C_Curl` enforces
`c-rbt-amount > 0.0`. Whenever the pool's index is large relative to a depositor's `amount` (e.g. after
heavy `C_Fuel` donations), `URC_RBT`'s `floor` can legitimately round `c-rbt-amount` to `0.0` for a real,
positive deposit — the RT is still transferred in and credited to the resident bucket, but
`DPTF::C_Mint c-rbt ATS|SC_NAME 0.0 false` mints nothing back. The depositor's funds silently become a
donation to existing RBT holders — no warning, no minimum-mint floor, no revert.

**Corroboration:** `REPL/Stage_01/[6.6]_ATS.repl` never calls `C_KickStart` (zero occurrences); the
reference suite bootstraps its test pair via a bare `C_Coil` call (line ~150), i.e. it already exercises
exactly the "genesis via bare Coil" path described here, without ever attempting `C_KickStart` afterward —
so the lockout consequence was never observable in-suite.

**Fix direction:** in `ATSU|C>COIL`/`C>CURL`, `enforce (!= (ref-ATS::URC_Index ats) -1.0)` (require an
explicit kickstart-or-prior-coil state rather than relying on `abs()` to paper over the sentinel), or
formally decide bare-Coil bootstrap is intended and replace `C_KickStart`'s `-1.0` gate with a state flag
that survives it. Separately, add `(enforce (> c-rbt-amount 0.0) ...)` in `C_Coil`/`C_Curl` to close the
general zero-mint donation path (this also closes M2 below).

**Owner verdict:** _pending_

## H4 · U_ATS — `UEV_ColdDurationParameters` soft branch calls `enforce` with 3 arguments `[CONFIRMED]`

**Location:** `1_Utilities/09_U_ATS.pact:488-503`. Client-reachable via `ATS|C>SET_COLD-DURATION`
(`08_ATS.pact:620-629`) → `XI_SetCRD` (`:2399-2414`).

**What's wrong:**
```pact
(if soft-or-hard
    (enforce
        (and (= (mod base growth) 0) (= (mod growth 3) 0))
        "Invalid Soft Cold Recovery Duration Parameters"
        (format "Invalid CRD Parameters For "))         ;; 3rd argument — enforce takes exactly 2
    (enforce (= (mod base growth) 0) "Invalid Hard Cold Recovery Duration Parameters"))  ;; well-formed
)
```
Pact's `enforce` is strictly `(enforce test:bool "msg")` — a 2-argument native. Defun bodies aren't
type/arity-checked until actually invoked, so this ships silently and only detonates the first time the
soft path is exercised.

**Failure scenario:** any call to set a Soft cold-recovery duration schedule (`soft-or-hard=true`) throws
immediately at this line, before any real validation runs — **no pool owner can ever configure a Soft
duration schedule after pair genesis** (genesis itself bypasses this by calling `UC_MakeSoftIntervals`
directly with hardcoded defaults, `08_ATS.pact:2285` — so the bug only surfaces on updates, consistent
with zero REPL coverage for this path). The Hard branch is unaffected.

**Fix direction:** drop the third argument; the two conditions are already correctly combined via `and`.

**Owner verdict:** _pending_

---

# MEDIUM

## M1 · U_ATS — `UEV_HibernationFees` contains a malformed predicate; `C_SetHibernationFees` can never succeed `[CONFIRMED — independently found by 2 lenses]`

**Location:** `1_Utilities/09_U_ATS.pact:459-486`. Client-reachable via `ATS|S>SET-HIBERNATION-FEES`
(`08_ATS.pact:452-461`), sole call site.
```pact
(enforce
    (fold (and) true
        [ (= (floor peak 4) peak) (> peak 0.0) (<= peak 800.0)
          (= (floor decay 4) decay) (> decay 0.0) (< decay 1.0)
          (= () 0.0) ])                    ;; <-- stray/malformed term
    "Invalid Hibernation Fees")
```
The 7th term compares Pact's empty-parens unit expression against `0.0` — not a valid boolean predicate;
this is the only occurrence of `(= () ...)` anywhere in the repo. Unconditionally evaluated for every
call, regardless of how valid `peak`/`decay` are — so `enforce` fails (or the term fails to typecheck)
**for every input**, and `C_SetHibernationFees` is dead on arrival for every pool owner, forever, leaving
every pair permanently stuck at its issuance-time defaults. Zero REPL coverage anywhere for this path —
consistent with a live-but-never-exercised bug.

**Fix direction:** remove the stray `(= () 0.0)` term (or replace it with whatever 7th bound was
intended); add a REPL assertion exercising `C_SetHibernationFees` with a valid `peak`/`decay` pair to lock
in the fix.

**Owner verdict:** _pending_

## M2 · ATSU — `C_KickStart` has no sanity bound on `rt-amounts : rbt-request-amount` ratio `[CONFIRMED]`

**Location:** `ATSU|C>KICKSTART` (`10_ATSU.pact:234-252`); `C_KickStart` (`:601-645`). Relates to H3.

**What's wrong:** the cap only enforces array-length parity and `rbt-request-amount > 0.0` — no bound on
the resulting genesis index. Combined with H3's `abs()` bypass, the owner (sole caller, `CAP_Owner ats`)
can pick an arbitrary genesis index, including an astronomically high one (tiny `rbt-request-amount` vs
large `rt-amounts`) — the classic vault "inflation attack" setup: subsequent real depositors' `URC_RBT`
rounds to `0.0` (floor), silently donating their deposit to the kickstarter's outsized initial position.

**Concrete numbers:** `rt-amounts=[1000.0]`, `rbt-request-amount=0.000001` → index ≈ `10^9`. A depositor
coiling `500.0` RT gets `floor(500.0 / 10^9, p) = 0.0` RBT, while their `500.0` RT is still credited to
resident — a full donation to the kickstarter.

**Fix direction:** bound the resulting index to a sane range (e.g. `0.001 <= index <= 1000`), or require
`(enforce (> c-rbt-amount 0.0) ...)` on the depositor-facing `Coil`/`Curl` path (H3's fix closes this too).

**Owner verdict:** _pending_

## M3 · ATS — `XE_UpdateRUR` has no floor-at-zero on any of its three buckets `[PLAUSIBLE]`

**Location:** `08_ATS.pact:2486-2522`.

**What's wrong:** `rur-amount` on `direction=false` is a plain `(- current amount)`, no `max 0.0` clamp,
for all three buckets (resident/unbonding/royalty). Every call site traced (`C_WithdrawRoyalties`,
`C_ColdRecovery`, `C_Redeem`, `C_DirectRecovery`, `C_Cull`, `C_Syphon`, `X_RemoveSecondary`) currently
decrements by values sourced from the same balance being decremented, so no negative was observed by hand-
tracing today. `UDC_RT`'s constructor (`:1733-1744`) does `enforce (>= c 0.0)(>= d 0.0)(>= e 0.0)`, so a
bug that *did* try to over-subtract would hard-abort rather than silently corrupt — a real backstop, but
`C_ColdRecovery` decrements bucket 1 **twice** from two independently-floored splits
(`URC_RTSplitAmounts` on fee, then again on remainder, `:794-799`) rather than one split of the combined
amount, which is rounding-dust risk (favors the protocol) rather than fund-loss today — but it's exactly
the "no floor, no defense-in-depth" pattern the AQP audit flagged as cross-cutting (its H1/L6/L7).

**Fix direction:** add `(UC_Max amount-after-decrement 0.0)` or an explicit `enforce (>= amount-after 0.0)`
in `XE_UpdateRUR` for `direction=false`, matching the delta-accounting discipline used elsewhere.

**Owner verdict:** _pending_

## M4 · ATSU — `C_Fuel` doesn't gate on the same lock-state flags `RemoveSecondary` requires `[PLAUSIBLE]`

**Location:** `ATSU|C>FUEL` (`10_ATSU.pact:253-264`) vs `ATSU|C>X_REMOVE-SECONDARY` (`:205-218`).

**What's wrong:** `RemoveSecondary`'s composed cap requires `ParameterLockState`/`ColdRecoveryState`/
`HotRecoveryState`/`DirectRecoveryState` all `false` before running — the codebase has a "don't let other
mutators run mid-administrative-flow" concept. `C_Fuel` (public, not owner-gated) checks none of these,
only `UEV_RewardTokenExistance` and `index >= 0.1`. Not a same-tx race (Pact txs are atomic/sequential),
but the lock concept is inconsistently applied across mutators touching the same RUR buckets.

**Fix direction:** either document Fuel/Coil/Curl as intentionally exempt from the lock flags, or fold the
relevant `UEV_*LockState` checks into their caps for consistency.

**Owner verdict:** _pending_

## M5 · ATS — Elite toggle switches the position-selection algorithm on already-populated ledger rows with no reconciliation `[PLAUSIBLE]`

**Location:** `08_ATS.pact:630-646` (`ATS|C>TOGGLE_ELITE`), `:2415-2420` (`XI_ToggleElite`),
`:1280-1352` (`URC_WhichPosition`/`URCX_ElitePosition`/`URCX_NonElitePosition`), `:1364-1399`
(`URCX_PosSt`), `10_ATSU.pact:2523-2547` (`XE_SpawnAutostakeAccount`, sic — actually `08_ATS.pact`).

**What's wrong:** `URC_WhichPosition` dispatches to structurally different algorithms based on the
**live** `c-elite-mode` flag (`URCX_NonElitePosition`: first-empty-slot scan; `URCX_ElitePosition`: tier-
gated windowed search) over the *same persisted* P1-P7 rows. `ATS|C>TOGGLE_ELITE`'s only guard on turning
elite on is `(= (UR_ColdRecoveryPositions atspair) 7)` — a slot-*count* check, not a check that no account
has an active P1-P7 position. Separately, `URCX_PosSt`'s read-time default for a not-yet-spawned row uses
`zero` for P1 but an elite-conditional value for P2-P7 (`:1376-1379`), while
`XE_SpawnAutostakeAccount`'s actual row-creation default sets P1-P7 uniformly to `negative` regardless of
elite (`:2531`) — a pre-spawn vs. post-spawn definitional mismatch of what "empty" means.

**Fix direction:** require `c-positions == 7` **and** no account has any non-terminal P1-P7 slot before
allowing the elite toggle (or explicitly document eventual-consistency, mirroring the AQP audit's H4
treatment of a similar gap). At minimum, align `URCX_PosSt`'s default-read fallback with
`XE_SpawnAutostakeAccount`'s actual insert default.

**Owner verdict:** _pending_

## M6 · U_ATS — `UEV_CRF|FeeThresholds` never validates threshold *values* despite its own `@doc` `[CONFIRMED]`

**Location:** `1_Utilities/09_U_ATS.pact:363-400`.

**What's wrong:** `@doc`: *"Enforces `<fee-thresholds>` are between 1 and 100, conform with the C-RBT
precision, and are increasing one after another."* Code only enforces array-length bounds (`1..100`
*entries*, not values), strict monotonic increase, and per-entry precision conformance — never a
`[1,100]` bound on the threshold **values** themselves. `URC_ColdRecoveryFee` (`08_ATS.pact:1450`) consumes
these directly as C-RBT amount cutoffs, so out-of-range (even negative) thresholds are structurally
acceptable to the validator and only misbehave downstream.

**Fix direction:** either add the missing value-range enforcement to match the doc, or correct the `@doc`
if thresholds are genuinely meant to be unbounded raw C-RBT amounts.

**Owner verdict:** _pending_

## M7 · U_ATS — hard-branch cold-recovery duration params never enforce `growth > 0` `[PLAUSIBLE]`

**Location:** `1_Utilities/09_U_ATS.pact:68-91` (`UC_MakeHardIntervals`), `:498-501`
(`UEV_ColdDurationParameters` hard branch).

**What's wrong:** both only enforce `(= (mod base growth) 0)` — divisibility, not sign. A negative
`growth` that evenly divides `base` (Pact `mod` follows floor/divisor-sign semantics) passes.

**Concrete numbers:** `UC_MakeHardIntervals 100 -5` → chain `100, 95, 90, …, -140`; `big = -35`;
`very-last = -175` — the resulting `c-duration` schedule is monotonically **decreasing**, the opposite of
the ever-growing unbonding schedule any consumer implicitly assumes.

**Fix direction:** add `(> growth 0)` (and plausibly `(> base 0)`) to `UEV_ColdDurationParameters`'s hard
branch, mirroring the soft branch once H4 is fixed.

**Owner verdict:** _pending_

## M8 · U_ATS — `UC_SplitByIndexedRBT` has no zero-guard on `resident-sum` `[PLAUSIBLE]`

**Location:** `1_Utilities/09_U_ATS.pact:220-264`, division at `:250`
(`(/ (at idx resident-amounts) resident-sum)`).

**What's wrong:** on the non-short-circuit branch (`rbt-amount != pair-rbt-supply`), `resident-sum` is used
as a divisor with no `(!= resident-sum 0.0)` guard. `resident-sum` can legitimately be `0.0` (a freshly
issued pair pre-first-deposit, or immediately after a full syphon) while `pair-rbt-supply` (computed
independently) can be nonzero.

**Failure scenario:** any caller of `URC_RTSplitAmounts` (`08_ATS.pact:1154-1167`, which forwards here) in
that pair state hits a hard division-by-zero abort instead of a graceful "nothing to distribute yet" — a
reachable transaction-failure DoS on any preview/quote flow.

**Fix direction:** short-circuit to a zero-filled output when `resident-sum == 0.0`, mirroring the existing
`rbt-amount == pair-rbt-supply` short-circuit.

**Owner verdict:** _pending_

## M9 · U_ATS — `UC_SplitByIndexedRBT` trusts `resident-amounts`/`rt-precisions` positional alignment with no length-parity guard `[PLAUSIBLE — connects directly to C2's theme]`

**Location:** `1_Utilities/09_U_ATS.pact:220-264`.

**What's wrong:** this is the core RBT→RT split math, explicitly flagged for scrutiny given C2. Every read
(`(at idx resident-amounts)`, `(at idx rt-precisions)`, the dust-routing `max-pp` index reused across both
lists) assumes the two caller-supplied lists refer to the same reward token **by position**, with no
`(enforce (= (length resident-amounts) (length rt-precisions)) ...)` at entry. Both are supplied
independently by `URC_RTSplitAmounts` (`08_ATS.pact:1161-1162`, reading `UR_RewardTokenRUR atspair 1` and
`UR_RtPrecisions atspair` separately) rather than derived together inside this utility. As long as both
`UR_*` readers are refreshed from the same current list in lockstep this is safe today — but the utility
itself provides no safety net if that ever desyncs (e.g. a variant of C2's stale-array class of bug
reaching these readers, or a future refactor decoupling the two reads). The split *math itself* was
verified exact and conservation-safe (see Verified Correct) — this is purely a missing input-validation
backstop.

**Fix direction:** add `(enforce (= (length resident-amounts) (length rt-precisions)) "Misaligned reward-
token split inputs")` as the first statement, so a future desync fails loudly instead of misattributing
value across token identities or throwing a confusing out-of-bounds `at` error.

**Owner verdict:** _pending_

---

# LOW (discipline / hygiene)

- **L1 · ATS** — `ATS|F>OWNER` (`08_ATS.pact:493-495`) is defined but never composed/required anywhere in
  the module (`grep` → 1 hit, the definition itself). Dead capability. `[CONFIRMED]`
- **L2 · ATS** — `UR_P-KEYS`/`UR_KEYS` (`:738-743`) are `UR_*`-prefixed but perform raw `(keys ...)` scans
  — StoicSyntax reserves `keys`/`select` for `URD_*`. Repeated verbatim across `05_DPTF.pact`/
  `06_DPOF.pact`/`00_DPMF.pact` — a repo-wide convention, not ATS-specific; off the execution path (admin-
  dashboard fallback helpers). `[CONFIRMED]`
- **L3 · ATS** — `can-upgrade` (schema field, `:337`) is set `true` at issuance and has no setter anywhere
  — vestigial from the V1→V2 migration (`URU_UpgradeAtspairToV2`, `:716-733`, is read-only). Harmless dead
  validation (`UEV_CanUpgradeON`, gating `C_Control`, is permanently satisfied). `[CONFIRMED]`
- **L4 · ATS/ATSU** — Hot-RBT registration/branding/repurpose (`C_AddHotRBT`, `C_HOT-RBT|*`),
  `C_UpdatePendingBranding`/`C_UpgradeBranding`, `C_UpdateRoyalty`, `C_SetHibernationFees` (M1),
  `C_SetColdRecoveryFees`/`Duration` (H4), `C_ToggleElite` (M5), `C_SetHotRecoveryFees`,
  `C_SetDirectRecoveryFee`, `C_SwitchDirectRecovery`, `C_KickStart` (H3/M2), `C_Redeem` (C3, only
  commented-out), `C_DirectRecovery`, `A_RemoveSecondary` (admin variant) — **all** have zero REPL
  coverage. Directly correlated with C3/C5/H4/M1/M5 shipping unnoticed. Compounded by the file itself
  (`[6.6]_ATS.repl`) not being in the default `Stage01_Tester.repl` pipeline at all (see Baseline note at
  top of this file). Worse: the one section that *does* exercise C2's remove/re-add/cull sequence
  (`"Add Secondary AGAIN with Hybrid Cull Test"`, `:1663-1953`) computes its observability output into a
  bare `let`-returned list that's never `print`ed — confirmed zero occurrences of its own format strings
  anywhere in an actual run's output — so even that path is functionally silent, covered by zero
  assertions, despite running the exact vulnerable code. `[CONFIRMED]`
- **L5 · ATSU** — hibernation fee (`CoilData.hibernation-fee`) is computed in `URCX_RBT-Amount`
  (`08_ATS.pact:1534-1558`) but never separately tracked or read by `C_Coil`/`C_Curl` — unlike
  `royalty-fee`, which gets its own bucket-3 tracking and a dedicated exit (`C_WithdrawRoyalties`). Token
  conservation still balances (verified — see below); the asymmetry is undocumented design, not a fund-
  safety bug: the hibernation fee permanently and silently redistributes to existing RBT holders as index
  appreciation. `[PLAUSIBLE]`
- **L6 · ATSU** — `URC_RewardBearingTokenAmounts` (used by both `C_Coil` and `C_Curl`) always calls
  `URCX_RBT-Amount ats rt amount 1` — hardcoded `dayz=1` — rather than
  `URC_RewardBearingTokenAmountsWithHibernation` with a caller-supplied day count. Whether a hibernating
  pair's decay should reflect actual elapsed/target hibernation period rather than a flat "1 day" is a
  design question, not clearly a bug on either side. `[PLAUSIBLE — needs reconciliation]`
- **L7 · ATSU** — `XI_Normalize`'s 16-branch position-reshaping fold (`10_ATSU.pact:1200-1267`) is
  intricate enough (elite/non-elite × 7 fixed position counts × unlimited mode, each folding p0..p7
  through zero/negative sentinel classification) that it could not be fully hand-verified for "never drops
  or duplicates a slot" in this pass. No dropped-slot bug found by inspection; needs a dedicated REPL
  property test across all `positions`/`elite`/`major-tier` transitions before it can be marked verified.
  `[flagged, not a confirmed defect]`
- **L8 · ATSU** — `C_KickStart`'s `rt-amounts` positional array vs. `UR_RewardTokenList` ordering is caller
  responsibility with no name-based matching; low risk since only the pair owner can call it, but a wrong
  ordering silently seeds the wrong token amounts with no error. `[PLAUSIBLE]`
- **L9 · U_DPTF** — `UC_UnlockPrice` (`10_U_DPTF.pact:126-135`) `@doc` reads "Computes ATS unlock price" —
  copy-pasted from `09_U_ATS.pact:265-274`'s wrapper. **Not** a logic bug: both are correct, intentional
  thin wrappers over the single shared core (`07_U_DEC.pact:105-121`), differentiated by a
  `dptf-or-ats` flag — this is StoicSyntax "single core, no duplicate logic" done *correctly*. The
  docstring should say "DPTF" though. `[CONFIRMED]`
- **L10 · U_ATS** — `UC_IzStoicTagIndexChar`/`UC_IzStoicTagIndex`/`UEV_StoicTagIndex` (`:310-352`) declared
  on `UtilityAtsV2` with **zero callers** anywhere outside their own definitions — dead code. The live ATS
  pair-id gate (`UEV_AutostakeIndex`/`UEV_UniqueAtspair`, `:278-357`) permits mixed case with no case-
  folding uniqueness check, so nothing stops registering both `"MyPair"` and `"mypair"` as distinct index
  names today. Separately, `22_CODEX.pact` has an entirely unrelated, **live** "StoicTag" feature (social-
  handle registry) reusing the identical vocabulary. Abandoned V2 tightening attempt + a naming collision
  for future maintainers. `[CONFIRMED dead code; PLAUSIBLE practical collision risk]`
- **L11 · Talos** — `defcap P|ATS` in `05_TS01-P.pact:48-57` (module `TS01-CP`) is dead code: real
  enforcement (ownership of a hardcoded "master" account), but never called anywhere in the repo (`grep`
  finds only the definition). Not itself a vulnerability — it does real enforcement — but shadows the
  naming of the real ATS IMC machinery (`P|ATS|CALLER`, `08_ATS.pact:267`) — a landmine if
  ever wired in without understanding it's unrelated to ATS policy. `[CONFIRMED]`
- **L12 · ATSU** — several master defcaps (`ATSU|C>FUEL`, `C>COIL`, `C>CURL`, `C>SYPHON`) place a bare-ref
  validation call before local `enforce`s, inverting StoicSyntax's "all enforce first, then bare refs" body
  order. Functionally harmless (both gates are unconditional either way), a style deviation worth a pass.
  `[CONFIRMED]`
- **L13 · Talos** — `03_TS01-C2.pact:581` names the wrapper `ATS|C_SetHotRecoveryFee` (singular) but it
  calls the correctly-named core `C_SetHotRecoveryFees` (plural, matching the interface). Naming asymmetry
  only — 3-way signature parity confirmed correct. `[CONFIRMED]`, cosmetic.

---

# What is VERIFIED CORRECT

**ATS core (`08_ATS.pact`)**
- Issuance is race-safe and insert-once: `XI_Issue` uses `insert` (not `write`) on `ATS|Pairs id` (atomic
  per-key collision rejection), and in-batch name collisions are additionally pre-rejected by
  `UC_IzUnique`.
- Every `ATS|PropertiesSchemaV3` field initializes to a sane, self-consistent default: `syphon = 1.0`
  equals starting `index` (so `URC_MaxSyphon` correctly yields `0` until real yield accrues),
  `royalty = 0.0`, `parameter-lock = false`, all recovery toggles `false`.
- Ownership rotation / control toggles are atomic single-`update` writes with no split-authority window;
  `UEV_EnforceAccountExists` guarantees the new owner account exists before rotation.
- `C_Control`'s hibernate=true path is cross-module consistency-checked against a real VST hibernation link
  on the cold-RBT before the ATS-level flag can be set.
- Hot-RBT reuse-across-pairs is blocked by defcap statement *ordering* in `ATS|C>ADD-HOT-RBT`
  (bare-ref DPOF-ownership check evaluated **before** `compose-capability (ATS|GOV)`) — distinct from C5,
  where the missing `CAP_Owner` call removes this protection entirely for the two branding functions.
- Cold-recovery fee-schedule config validators are internally consistent as a *set*
  (`UEV_CRF|Positions`/`FeeThresholds`/`FeeArray` together reject non-monotonic thresholds, length
  mismatches, and out-of-range fees) — modulo M6's specific value-range gap.
- `UEV_IMC` is the first statement of every cross-module mutator; no `enforce`/`UEV_*` appears in any
  `XI_*` body (pure `require-capability` + one `update`).

**ATSU (`10_ATSU.pact`)**
- Token conservation in `C_Coil`/`C_Curl`: transferred RT amount equals resident-bucket delta + royalty-
  bucket delta exactly, hibernation-off and hibernation-on branches both hand-verified.
- `C_Curl`'s intermediate leg is minted directly into shared custody, never transiently caller-exposed;
  leg-2 computation isn't manipulable between legs (pure reads of unchanged state, same atomic tx).
- `C_Cull`/`XI_MultiCull`/`XI_SingleCull` zero culled slots in the same `let` that produces payout amounts
  — no double-cull/double-pay across separate transactions (independent of C2's positional-attribution
  defect, which corrupts *what token* is paid, not *how many times*).
- `C_WithdrawRoyalties` reads-then-zeroes bucket 3 for exactly the read amount — cannot double-withdraw.
- `C_Syphon`'s authorization (`CAP_Owner`) and bounding (array-length parity, per-token resident bound,
  `URC_MaxSyphon` sum bound) are enforced in the defcap itself, not merely assumed by Talos.
- No structural reentrancy vector: token-module calls take plain string ids/accounts, not callbacks; Pact
  capabilities are module-local (no foreign-cap composition), so a token module cannot call back into ATSU
  mid-transfer.

**Utilities (`09_U_ATS.pact` / `10_U_DPTF.pact`)**
- `UC_PromilleSplit`: `remainder + fee == input` exactly by construction (direct subtraction), every time —
  no dust vanishes or over-issues.
- `UC_SplitBalanceWithBooleans`: N-1 equal chunks + one dust-absorbing last chunk, `enforce (= (+ big-chunk
  last-split) amount)` guarantees exact conservation for both `milestones=1` and `milestones>1`.
- `UC_SplitByIndexedRBT`: dust from per-token floor rounding is deterministically routed to the highest-
  precision reward token; `Σoutput == indexed-rbt` exactly by algebraic construction. The `rbt-amount ==
  pair-rbt-supply` short-circuit correctly hands back the full resident-amount vector — a genuine "last
  claimant sweeps all remaining dust" branch matching the AQP audit's `unclaimed-count==1` reference
  pattern. (M8/M9 are missing *input guards*, not math defects — the math itself is exact.)
- `UC_SolidifyUnstakeObject`: for any `Awo` that *does* get reshaped, the array-position removal + merge-
  into-slot-0 deliberately mirrors `X_RemoveSecondary`'s pair-level 1:1 primal-RT swap — intentional
  design. (The *gating* of when reshape runs is C2(c)'s defect, not this function's own math.)
- `UEV_Fee`/`UEV_Decay` are bounded on both ends; `UEV_CRF|Positions` correctly excludes `0`;
  `UEV_CRF|FeeArray`'s inner/outer dimensioning is off-by-one-free.
- Rounding-convention cross-check: `URC_Index` (core) and every arithmetic split helper here use `floor`
  exclusively — no round-half-even or ceiling divergence anywhere in scope.

**Talos wiring (`03_TS01-C2.pact` + interfaces)**
- **Completeness:** every core `C_`/`A_` function in `08_ATS.pact` (21) and `10_ATSU.pact` (14) has a
  Talos wrapper — no orphaned/unreachable recipe.
- **Wiring shape:** all 26 `ATS|C_*` wrappers follow the identical `with-capability (P|TS) → refs → core
  call → format` shape; none contain a bare `enforce`; `UEV_IMC` is correctly first inside the *core*
  mutator (not the wrapper), matching StoicSyntax's Aggregator pattern.
- **Compute-before-mutate hunt:** `ATS|C_Fuel`'s `prev-index` snapshot (captured before `C_Fuel` runs) is
  used **only** in the trailing human-readable `format` string — no accounting/transfer decision depends
  on it. Not the AQP-C2 bug shape.
- **TOCTOU hunt:** `ATS|C_VestedCoil`/`VestedCurl` precompute `rbt-amount` via a pure `URC_` read, then
  `C_Coil`/`C_Curl` independently recompute the **identical** value from the same unchanged state —
  confirmed nothing intervenes that could mutate the inputs between the two computations. What's minted/
  transferred and what's promised to the vesting schedule are the same number.
- **Branding routing:** the pair-branding path (`ref-B|ATS:module{BrandingUsagePrimaryV1}`) and the Hot-
  RBT branding path (`ref-ATS:module{AutostakeV2}` → internally `ref-B|DPOF`) are genuinely distinct
  targets and Talos routes each client call correctly — no cross-wiring. (C5 is an *authorization* gap on
  the Hot-RBT side, not a routing bug.)
- **Signature parity:** three-way diff (Talos wrapper / interface / module `defun`) for `C_Issue`,
  `C_AddSecondary`, `C_Fuel`, `C_Coil`, `C_Curl`, `C_ColdRecovery`, `C_Syphon`, `A_RemoveSecondary` — all
  match exactly in count, order, type.
- **Policy wiring:** `P|A_Define` boilerplate matches the StoicSyntax hub+children pattern consistently
  across `TS01-A`/`TS01-C1`/`TS01-C2`/`08_ATS`/`10_ATSU`; the genuine admin-keyset gates (`GOV|ATS_ADMIN`,
  `GOV|ATSU_ADMIN`, `GOV|TS01-A_ADMIN`) correctly `enforce-guard`/`enforce-one` real keysets.
- **`ATS|GOV` smart-account governor pattern** (originally misreported as C1): confirmed correct per
  `StoicSyntax.md §14.5`'s "Simple vault" pattern — Pact requires a foreign caller to hold `ATS`'s module
  admin before acquiring any of `08_ATS.pact`'s capabilities, so `ATS|GOV`'s `true` body is safe as a
  governor guard; only `08_ATS.pact`'s own code can ever compose it. See `ROUND-01-OWNER-FEEDBACK.md`.

---

# Interface-version state

| Interface | Current version | Notes |
|---|---|---|
| `AutostakeV2` | **V2** (only version implemented; `AutostakeV1` retained historically) | Bump is a **pure typing cascade** — `@doc`: "same surface as AutostakeV1 with UtilityAtsV2.Awo typing." Business logic didn't change. |
| `AutostakeUsageV1` | **V1** | No V2 exists; consistent with pre-mainnet-deploy policy. |
| `AutostakeComputerV1` | **V1** | No V2 exists. |
| `BrandingUsagePrimaryV1` | **V1** | No V2 exists. |
| `BrandingV1` | **V1** | No V2 exists. |
| `UtilityAtsV2` | **V2** (only version implemented; `UtilityAtsV1` retained historically) | V1→V2 added the (now-dead, L10) StoicTag index helpers — a genuine post-deploy adjustment. |

**Why `AutostakeV2` is already bumped (the documented exception to "stay on V1 pre-mainnet"):**
`UtilityAtsV1` → `UtilityAtsV2` (adding StoicTag helpers, a post-deploy adjustment) forces every interface
typing `object{UtilityAtsV1.Awo}` to cascade. `AutostakeV1` types its unstake-object schema that way, so it
cascaded to `AutostakeV2` referencing `object{UtilityAtsV2.Awo}` — the ATS business logic itself did not
change. `URU_UpgradeAtspairToV2` (`08_ATS.pact:716-733`) is a companion migration helper consistent with a
post-deploy version-migration event. This is the policy's documented exception case actually occurring,
not a violation. **Stale-reference check:** zero remaining `module{AutostakeV1}`/`module{UtilityAtsV1}`
references anywhere in `1_SOVEREIGN/`/`2_SLAVE/` — every consumer types against V2 only; V1 survives solely
as a historical/frozen entry in the interfaces pack, per StoicSyntax.

**What this means for the fix round:** C4/C5/H1/H2 are all **behavioral** fixes to `08_ATS.pact` (module
body only) — none require a new interface version, since none change a public function's signature or add
a new public function whose type must be interface-declared. C2's minimum-viable fix (unconditional
reshape) is also module-body-only. C2's long-term fix (replacing `Awo.reward-tokens:[decimal]` with an
identity-keyed structure) **would** require a `UtilityAtsV2 → V3` cascade (the schema is interface-owned)
and would ripple to `AutostakeV2 → V3` (types `object{UtilityAtsV2.Awo}`) and every consumer listed in the
stale-reference check above — a large-blast-radius change to scope carefully before committing to it over
the minimum-viable fix.

---

# Live vs local (Pythia dirty-read)

**Not performed.** `POST /{chain}/read` requires an owner-supplied `x-pythia-key`
(`OuronetInformational/pythia-dirty-read-access.md`) that was requested from the owner during this audit
and had not arrived by the time this round closed. No `describe-module` call was made against any ATS-
family module; **all findings above are against local repo source only, with no confirmation of what is
actually deployed on StoaChain.** Given C2's severity (the reward-token remove/re-add mechanic), this is
still a material gap — see README.md's "Live vs local" section for the exact follow-up commands to run
once a key is available.

---

# Needs a REPL to confirm (Round III fodder)

Directly testable, each should become a regression assertion once fixed. `[6.6]_ATS.repl` should also be
un-commented in `Stage01_Tester.repl` as part of closing L4.

- ~~**C1:** forged `ATS|GOV` transaction~~ — moot, C1 refuted (the scenario doesn't reach a live tx to test).
- **C2(a):** remove reward token B from a 3-token pair, add token D, then cull a pre-existing position that
  had a nonzero B-denominated claim → payout must be in the *originally-claimed* token/amount, not D.
- **C2(b):** remove a reward token with nonzero royalty bucket → rejected, or royalty transferred/migrated
  (not silently deleted).
- **C2(c):** account with only never-used (sum=0) P1-P7 slots; pool removes a reward token; account
  attempts to open a new cold-recovery position → succeeds (does not read as "occupied").
- **C3:** `C_Redeem` on a matured Hot-RBT position → succeeds and returns underlying RT.
- **C4:** owner raises `syphon` to track a risen `index`, then lowers it back toward `0.1` → rejected (or:
  post-fix syphonable amount is bounded to not exceed what was syphonable at the prior high value).
- **C5:** non-owner calls `C_HOT-RBT|UpdatePendingBranding`/`UpgradeBranding` for a hot-rbt they don't own
  → rejected.
- **H3:** bare `C_Coil` on a never-kickstarted pool (index `-1.0`) → rejected (or: `C_KickStart` remains
  callable afterward, whichever fix direction is chosen).
- **H4:** `ATS|C_SetColdRecoveryDuration(..., soft-or-hard=true, ...)` with valid params → succeeds.
- **M1:** `C_SetHibernationFees(atspair, 100.0, 0.01)` (valid per existing bounds) → succeeds.

---

# Addendum — baseline test run

`REPL/_audit_ats_baseline.repl` (Stage00 sandboxes → Stage01 prefix through `[5.2]_Dispenser+.repl` →
`[6.2+3]_DPTF-SWP_Issuance-Only.repl` → `[6.5]_DPOF.repl` → `[6.6]_ATS.repl`, pact 5.4, audit-only, not
part of the canonical suite) was run to establish a real pass/fail baseline for the ATS integration suite
given it is not wired into `Stage01_Tester.repl` by default (L4). Result: **`Load successful`, 15
`expect`/`expect-failure` assertions, 0 failures.** See the Baseline note at the top of this file for why
this figure does not corroborate C2, and does not exercise C1/C3/C4/C5/H4/M1 at all (zero REPL coverage
per L4). The temporary runner file has been left at `REPL/_audit_ats_baseline.repl` for reuse in Round III
(it is not part of the canonical suite and should be deleted or formalized, not silently left as
scratch — see `OuronetInformational/skills/` REPL layout conventions before promoting it).
