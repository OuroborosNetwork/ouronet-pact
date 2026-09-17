# Chapter 4 — DPDC, the collectables family

> **Source tree:** `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/Audit/` (7 files, 5,093 lines)
> **Audited:** 2026-08-18 → 2026-08-27, on a dedicated `dpdc` branch (48 commits)
> **Scope:** all 11 modules, `01_DPDC-UDC.pact` through `11_EQUITY+.pact`
> **Tracked items:** 58 · **Fixed and proven:** 35 · **Refuted:** 13 · **Deferred:** 4
> **Verification pass for this chapter:** 2026-09-17. Every fix recorded below was looked for in
> current source. Results are in §7.

---

## 1. What DPDC is, and what breaks if it breaks

DPDC — *Digital Property / Deed Collectable* — is Ouronet's NFT and SFT stack. Where `DPTF` handles
plain fungible tokens and `DPOF` handles metadata-carrying "ortofungibles", DPDC handles the two
asset families where **individual units are distinguishable**: `DPSF` (semi-fungibles — many
identical copies of a numbered *nonce*, like a concert-ticket tier) and `DPNF` (non-fungibles — one
holder per nonce, the ordinary NFT). It is not one module. It is eleven, sharing one set of tables:

| module | what it owns |
|---|---|
| `01_DPDC-UDC` | pure constructors — no tables |
| `02_DPDC` | **the tables**: `Properties`, `Nonces`, `VerumRoles`, `Account`, `AccountSupplies`, for both DPSF and DPNF |
| `03_DPDC-C` | the credit/debit ledger primitive — every balance change in the family passes through it |
| `04_DPDC-I` | collection issuance and account association |
| `05_DPDC-R` | the twelve role toggles (freeze, burn, mint, royalties, transfer, …) |
| `06_DPDC-MNG` | admin supply operations: add-quantity, burn, respawn, and the `Wipe*` family |
| `07_DPDC-T` | transfer, bulk transfer, repurpose, and IGNIS royalty collection |
| `08_DPDC-S` | **sets** — combine N nonces into one "set" nonce and break it back apart |
| `09_DPDC-F` | **fragments** — split one nonce into 1,000 tradeable pieces held in protocol escrow |
| `10_DPDC-N` | per-nonce metadata mutation (name, description, score, URIs, royalties) |
| `11_EQUITY+` | shareholder collections — a cap-table instrument built on DPSF |

Three things about that shape matter for an audit. First, **one shared table set, ten thin writer
modules** is the widest fan-out of any module family in Ouronet: a missing check in `03_DPDC-C` is a
missing check in all ten callers at once. Second, DPDC holds *escrow*: when a nonce is fragmented,
the real asset moves into the protocol's own `dpdc` system account and 1,000 fragment claims are
issued against it. Third, `11_EQUITY+` is a **financial instrument** — package shares with a
dilution-sensitive cap table — and at the start of this audit it had zero test coverage anywhere in
the repository.

If DPDC breaks, the failure modes are: supply minted from nothing (the ledger primitive), user value
permanently stranded (a set that can be made but never broken), escrow collateral destroyed under
outstanding fragment claims, or a collection owner locked out of their own collection with no
recovery path. All four of those were found.

Some of this code is **live on StoaChain**. That is not a hypothetical audit.

---

## 2. How it was audited

The tree records five documents and one honest gap. The real sequence was:

**Round I — parallel deep reads (2026-08-18).** Eleven auditors, one per module file, working
read-only, each told to load `StoicSyntax.md` first and to assume nothing is correct despite the code
being live-adjacent. Cross-module composition was traced explicitly rather than assumed, because the
shared-table decomposition means no single file contains a complete operation. Output:
`ROUND-01-FINDINGS.md`, 1,589 lines, **frozen** — never edited after the fact.

**Ranking.** `ISSUES-RANKED.md` flattened the eleven per-module reports into one severity-ordered
list, `#1C` … `#55L`, each carrying a back-reference to its module-local id (`DPDC-C·C1` and so on).
This is the working document: findings were taken **one at a time, in this order**.

**Round I feedback — the owner loop.** `ROUND-01-OWNER-FEEDBACK.md` (938 lines), append-only, one
entry per finding. Thirteen findings died here: the owner corrected a technical premise and the
finding did not survive it. Those are recorded with the correction, not deleted.

**Round II — sequential fixes.** `ROUND-02-FIXES.md` (1,638 lines), 35 numbered `Fix #N` entries,
each with root cause, diff, and REPL proof. Code changed **only** here, one fix at a time, each
green-lit individually.

**The hard rule.** Written into `README.md` and worth quoting, because it exists for a reason:

> A finding that was only discussed in chat and never landed in these files **is not closed**, no
> matter how thoroughly it was reasoned through.

That rule is inherited verbatim from the SWP audit, where findings silently skipped mid-session went
uncaught until an audit-of-the-audit. Four things had to happen in the same turn a verdict was
reached: feedback entry, tracker row, `ISSUES-RANKED` annotation, and — if code changed — a numbered
fix entry with its proof.

### The method's one real discipline

Fourteen findings were proved by **reverting the fix and re-running** (`git stash`), so the pre-fix
bug shape was observed rather than assumed: C1, C7, H1, H2, H5, H8, H11, #24M, #31M, #32M, #35M and
others. This caught two methodology errors before they were presented as proof — in both cases an
`expect-failure` that "passed" because an unrelated `UEV_IMC` guard rejected the call, not the check
under test. The audit recorded those errors rather than quietly correcting them.

It also produced the round's sharpest result, on **#7C**: the `C_UpdateSetMultiplier` type bug was
confirmed **byte-identical on mainnet** through a keyless Pythia dirty-read against the deployed
`ouronet-ns.DPDC-S` (hash `Qslr8IXA10HEYsiHPnjvvCy4hYNIh3bfPQvD7w5QEoU`). The feature had never
worked in production, and the audit could say so with a hash rather than a guess.

### Round III never happened

`README.md` names a Round III re-verify and says *"(not yet created)"*. It was not created. The
`FINAL-AUDIT-REPORT.md` closes the audit on Round II plus `Z.repl` green. **The DPDC audit is a
two-round audit that planned a third.** Everything below is verified against current source by this
chapter, which is the closest thing the tree has to the Round III that was skipped.

### New test coverage built

Three canonical integration suites, all wired into the live `Stage02_Tester.repl` pipeline rather
than written and left disconnected [VERIFIED by command — `Stage02_Tester.repl` lines 38, 41, 45]:

| suite | covers | born from |
|---|---|---|
| `REPL/Stage_02/[6.1.1]_EQUITY.repl` | Issue baseline, Make/Convert/Break exact conservation, 5 negative paths | #22H |
| `REPL/Stage_02/[6.1.2]_DPDC-FRAGMENTS.repl` | Make→Merge conservation, repurpose-without-consent | #27M |
| `REPL/Stage_02/[6.1.3]_DPDC-S.repl` | Primordial/Composite/Hybrid Make→Break round trips, admin mutations | #39L |

All three modules (EQUITY, DPDC-F, DPDC-S) had **zero reachable coverage** before. The pre-existing
`[6.1]_DPDC.repl` contained EQUITY test code, but the file was disabled, crashed on an earlier
unrelated bug when run directly, never created the collection it tested, and its assertions were
print-only. That is worth stating plainly: the prior coverage was not thin, it was **fictional**.

---

## 3. The findings

Severity is as **recorded by the audit**. Verdict is as closed by the audit. The evidence column is
**this chapter's** verification — what, in current source as of 2026-09-17, would have to be deleted
for the finding to come back.

Line numbers drift. Every citation below was resolved fresh on 2026-09-17.

### CRITICAL (8)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **#1C** | Unsigned `amount` on every Credit/Debit path — a negative `amount` inverts direction and mints supply from nothing | **FIXED** | `03_DPDC-C.pact:594` `UEV_Amount`, called at `:1086` from the sole write path. [VERIFIED by reading] |
| **#2C** | `C_IgnisRoyaltyCollector` debits an arbitrary `patron` with no ownership check | **REFUTED, hardened anyway** | `07_DPDC-T.pact:396` `CAP_EnforceAccountOwnership sender` inside `IGNIS|C>DEBIT`. [VERIFIED by reading] |
| **#3C** | Same unsigned-amount hole reached through `C_MakeFragments`/`C_MergeFragments` | **ALREADY CLOSED by #1C** | Same chokepoint. Rejection traced live to `03_DPDC-C.pact` `UEV_Amount`. [VERIFIED by reading] |
| **#4C** | `C_RepurposeCollectableFragments` moves a holder's balance with no consent/freeze/wipe gate | **REFUTED — design** | Deliberate admin account-recovery tool, gated on `CAP_Owner` via `wipe-mode=true`. No code change. |
| **#5C** | Burn/wipe orphans fragment collateral held in the `dpdc` escrow account | **FIXED (+narrowed)** | `06_DPDC-MNG.pact:439-470` `C>REMOVE-CLASS-ZERO-NONCES`, escrow block narrowed to *currently fragmented* nonces via `UR_SplitNonceData`. [VERIFIED by reading] |
| **#6C** | Composite set with `allowed-sclass = 0` — Make succeeds, Break can never succeed, value stranded | **FIXED** | `08_DPDC-S.pact:968-971` — `(fold (and) true (map (lambda (sc) (> sc 0)) …))`. [VERIFIED by reading] |
| **#7C** | `C_UpdateSetMultiplier` crashes on every call — a `let` type annotation bug. Confirmed on mainnet | **FIXED, then removed entirely** | Function deleted by #15H. `08_DPDC-S.pact:99` and `:1143` carry removal notes; Talos wrappers removed at `01_TS02-C1.pact:148/1190`, `02_TS02-C2.pact:145/1041`. [VERIFIED by command — 0 live definitions tree-wide] |
| **#8C** | `how-many-sets` unbounded on Make/Break | **FIXED** | `08_DPDC-S.pact:323` and `:338` — `(enforce (> how-many-sets 0) …)` in both `C>MAKE` and `C>BREAK`. [VERIFIED by reading] |

### HIGH (14 + 2 sub-findings)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **#9H** | Talos `DPSF|C_UpdatePendingBranding` passes 7 args to a 6-parameter function — feature 100 % broken | **FIXED** | `01_TS02-C1.pact:418-427` — 6 params, 6 args forwarded. [VERIFIED by reading] |
| **#10H** | NFT issuance billed at the SFT price — 20 % silent revenue shortfall | **FIXED** | `04_DPDC-I.pact:263-264` and `:275` — `son` selects `"issue-sft"` vs `"issue-nft"`. **The implementation was later rewritten by the Part II re-pricing work and the distinction survived it.** [VERIFIED by reading] |
| **#11H** | NFT genesis owner==creator denied its own royalty/exemption/creator roles | **FIXED** | `04_DPDC-I.pact:505-511` — the NFT owner==creator branch writes `true` for all three. [VERIFIED by reading] |
| **#12H** | Shared `XE_*` write surface performs zero value-level validation | **REFUTED — verified live** | Every real call site either self-derives (`current+1`) or is pre-validated by the calling defcap. |
| **#12Hb** | *(found verifying #12H)* nonce `name`/`description`/`meta-data`/`asset-type`/`uri-*` had no content validation, ever | **FIXED** | `02_DPDC.pact:1150/1157/1181/1190/1205` — five validators, wired into `03_DPDC-C.pact:553-556` and each DPDC-N update cap. [VERIFIED by reading] |
| **#12Hc** | *(found verifying #12Hb)* `meta-data.composition` — the escrow record for an NFT set — overwritable to arbitrary values | **FIXED** | `10_DPDC-N.pact:456` `UEV_NotSetInstance`, wired at `:241` and `:352` into the shared `C>DATA`/`C>SET-DATA` chokepoints. [VERIFIED by reading] |
| **#13H** | `can-freeze` gates unfreeze as well as freeze → permanently bricked account | **FIXED** | `05_DPDC-R.pact:239-242` — `(if frozen (UEV_CanFreezeON …) true)`. [VERIFIED by reading] |
| **#14H** | Pause gates no mutating entrypoint in DPDC-MNG | **REFUTED — design** | Pause halts transfers only (MultiversX token semantics); `DPDC-T` enforces it, `DPDC-MNG` correctly does not. |
| **#15H** | Set-class `score-multiplier` unbounded and retroactively re-priceable | **FIXED ×3** | `08_DPDC-S.pact:1031-1047` `UEV_ScoreMultiplier` — precision 3 and `[1.0, 100.0]`; wired into all three Define caps (`:351`, `:362`, `:375`); Update path deleted. [VERIFIED by reading] |
| **#16H** | `UEV_TransferRoles` reads `sender` twice — receiver-side role check is dead code | **FIXED** | `07_DPDC-T.pact:688` — `(r:bool (… UR_CA|R-Transfer id son receiver))`, with the DPOF sibling cited in the comment. [VERIFIED by reading] |
| **#17H** | `C_RepurposeCollectable` skips frozen/transfer-role gates | **REFUTED — design** | Same admin escape hatch as #4C; owner explicitly rejected freezing the source afterward. |
| **#18H** | Native NFT Credit never checks the nonce isn't already held | **REFUTED — verified live** | All three real callers (Transfer, CreateNewNonce, RespawnNFT) gate at their own layer. |
| **#19H** | `UR_N|Score` fails to clamp the `-1.0` unscored sentinel in 3 of 4 branches | **FIXED, then renamed** | `08_DPDC-S.pact:554-570` `URC_N|Score` — sentinel checked **once, at entry, on the raw value**. [VERIFIED by reading] |
| **#20H** | `C_UpdateNonceIgnisRoyalty` has no upper bound at all | **REFUTED — design** | Owner: no principled ceiling exists. Precision check only. |
| **#21H** | `score-multiplier` unvalidated at Define, checked at Update | **ALREADY CLOSED by #15H** | Subsumed by the fix chain above. |
| **#22H** | EQUITY — the entire financial-instrument module had zero test coverage | **FIXED** | `REPL/Stage_02/[6.1.1]_EQUITY.repl`, wired at `Stage02_Tester.repl:38`. [VERIFIED by command] |

### MEDIUM (16)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **#23M** | 16-branch capability dispatch `cond` fails **open** on an unmatched shape | **FIXED** | `03_DPDC-C.pact:859` — `(enforce false (format "Unreachable nonce/amount shape …"))`. [VERIFIED by reading] |
| **#24M** | NFT `amount=1` enforced on native Credit, absent on 3 fragment/hybrid variants | **FIXED** | `03_DPDC-C.pact:600` `UEV_FragmentCreditAmount` — positive multiple of 1000 — wired at `:325`, `:345`, `:373`. [VERIFIED by reading] |
| **#25M** | Royalties read live at transfer time, no snapshot or max-price guard | **REFUTED — design** | Three options weighed; owner: a timelock buys nothing against a role holder who controls the lock. |
| **#26M** | `C_UpdateNonceRoyalty` mutates a field with zero on-chain consumers | **FIXED (doc)** | Confirmed intentional — a hook for the unbuilt Escrow/marketplace. Documented at schema, reader and entrypoint. |
| **#27M** | Fragment make+merge round trip and repurpose-without-consent executed but never asserted | **FIXED** | `REPL/Stage_02/[6.1.2]_DPDC-FRAGMENTS.repl`, wired at `Stage02_Tester.repl:41`. [VERIFIED by command] |
| **#28M** | EQUITY "shareholder collection" identity is a self-checked `"E\|"` string prefix | **REFUTED** | Two stacked walls: `iz-special=false` is hardcoded on the only public issuance path, so `\|` cannot appear in a publicly-issued ticker; and `DPDC-I\|C>ISSUE` enforces ownership of `dpdc` itself. |
| **#29M** | EQUITY's 50 % packaging cap is an undocumented magic constant | **FIXED** | `11_EQUITY+.pact:239` `PACKAGING_CAP_DIVISOR`, used at `:388`. [VERIFIED by reading] |
| **#30M** | `C_EnableSetClassFragmentation` skips the active-state gate its four siblings enforce | **FIXED** | `08_DPDC-S.pact:402` — `(UEV_SetActiveState id son set-class true)` with the audit reference in the comment. [VERIFIED by reading] |
| **#31M** | Primordial set bounds check only the running maximum, not each value | **FIXED** | `08_DPDC-S.pact:914-928` — per-element `0 < abs(n) <= nu`. [VERIFIED by reading] |
| **#32M** | Hybrid set Make-time and Break-time constituent ordering are opposite conventions | **FIXED** | `08_DPDC-S.pact:1080` — normalised to primordial-first, with cross-referencing comments at both sites. [VERIFIED by reading] |
| **#33M** | Collection id keyed only on `prev-block-hash` — same-block same-ticker collides | **REFUTED — accepted** | Live-verified twice; the second check corrected the first assumption (NFT+SFT same ticker **also** collides, in the shared `BRD|BrandingTable`, before DPDC's own tables are reached). Documented on `UDC_Makeid` (`08_U_DALOS.pact:231`). |
| **#34M** | `URD_AccountNoncesWithSupplies` returns `[{}]` instead of `[]` when empty | **FIXED** | `02_DPDC.pact:892-913`, now `URH_AccountNoncesWithSupplies`, empty case `[]` with the audit note in place. [VERIFIED by reading] |
| **#35M** | `XB_DeployAccount{SFT,NFT}` never verify the caller controls the target account | **FIXED by removal** | `04_DPDC-I.pact:55` and `:396` removal notes; `01_TS02-C1.pact:65/484` the Talos halves; DemiPad redirected, see `05_TS02-DPAD.pact:207/278`. [VERIFIED by command — 0 live definitions] |
| **#36M** | `AUP_Account`/`AUP_Property` slice composite keys by hardcoded offsets | **REFUTED** | `08_U_DALOS.pact:490` — every valid DALOS account is hard-enforced to exactly 162 characters. The offsets rest on a real system-wide invariant. [VERIFIED by reading] |
| **#37M** | `UDC_ZeroNonceData` called cross-module through a typed ref but absent from that interface | **FIXED, +3 more** | `01_DPDC-UDC.pact:273`; sweep found `CAP_OwnerOrCreator` (`02_DPDC.pact:221`), `UEV_CanWipeON` (`:193`), `C_DefineHybridSet` (`08_DPDC-S.pact:127`). [VERIFIED by reading] |
| **#38M** | `UDC_NoPrimordialSet`/`NoCompositeSet` sentinels indistinguishable from real data | **ALREADY CLOSED** | Primordial `[0]` blocked by #31M's per-element bound; Composite `-1` by the `sc > 0` check. Both present. [VERIFIED by reading] |

### LOW (17 + 1 unnumbered)

| id | summary | verdict | evidence today |
|---|---|---|---|
| **#39L** | Zero REPL coverage for DPDC-S Make/Break and admin mutations | **FIXED** | `REPL/Stage_02/[6.1.3]_DPDC-S.repl`, wired at `Stage02_Tester.repl:45`. [VERIFIED by command] |
| **#40L** | The `Wipe*` family has zero REPL coverage | **⏸ DEFERRED** | Open. See §6. |
| **#41L** | Branding functions untested; stark SFT-vs-NFT test asymmetry | **⏸ DEFERRED** | Open. See §6. |
| **#42L** | No negative-path coverage of the ownership gate on any of 12 role functions | **⏸ DEFERRED** | Partially closed later, not by this audit. See §5. |
| **#43L** | `XI_RegisterCollectionElement` returns a display string instead of ending on a write | **⏸ DEFERRED** | Open. See §6. |
| **#44L** | Dual `implements DpdcTransferV1 + V2` deviates from latest-version-only | **CLOSED** | Already self-documented as intentionally additive in `DpdcTransferV2`'s own `@doc`. |
| **#45L** | `UDC_ScoreMetaData` is dead code | **FIXED by removal** | `01_DPDC-UDC.pact:276` and `:654` removal notes. Removed rather than rewired — wiring it in would have reset a real set-instance's composition. [VERIFIED by command] |
| **#46L** | Constructors take 5-8 same-typed positional params in a row | **CLOSED — no live bug** | Every call site audited safe in Round I. |
| **#47L** | `C_RepurposeCollectableFragments` Multi Mode has no `length > 0` guard | **FIXED** | `09_DPDC-F.pact:236` — `(enforce (and (= l1 l2) (> l1 0)) …)`. [VERIFIED by reading] |
| **#48L** | `DPDC-F\|C>MERGE` omits `id`/`son`; two caps missing `@event` | **FIXED** | `09_DPDC-F.pact:268-272` — params and `@event` present, with the audit reference. [VERIFIED by reading] |
| **#49L** | EQUITY Make/Break reimplements DPDC-S's pattern divergently | **FIXED (doc)** | Cross-referencing `@doc` notes flag the intentional divergence for future review. |
| **#50L** | `URC_SingleSharePerMillions` has no declared return type | **FIXED** | `11_EQUITY+.pact:60` and `:374` — `:integer` on both interface and module. [VERIFIED by reading] |
| **#51L** | Empty set-definitions crash with `Array index out of bounds` | **FIXED** | `08_DPDC-S.pact:891-897` and `:951-956` — `MAX_SET_DEFINITION_SIZE` length bound on both validators. [VERIFIED by reading] |
| **#52L** | `URC_NoncesSummedScore` discards a nested set's own multiplier | **REFUTED — design** | Raw-sum by design; a multiplier applies once at its own set's level. Matches observed mainnet Bloodshed scores. |
| **#53L** | `creator-account` bound with no ownership/consent check | **REFUTED — design** | Same "owner has complete dominion" trust model as #4C/#17H/#20H. |
| **#54L** | `C_DeployAccount{SFT,NFT}` carry no `UEV_IMC`/cap/`@doc` | **MOOT** | The functions no longer exist — removed by #35M. |
| **#55L** | `UR_AS-KEYS` is a full table scan named with the point-read prefix | **FIXED** | `02_DPDC.pact:541`, now `URH_AS-Keys`. [VERIFIED by reading] |
| *(unnumbered)* | `DPNF\|AccountRoles` interface `@doc` states the reverse composite-key field order | **FIXED (doc)** | Doc-only. |

**A note on the count.** `FINAL-AUDIT-REPORT.md` opens with *"Findings: 56 (8 CRITICAL, 14 HIGH,
16 MEDIUM, 17 LOW)"*, and 8+14+16+17 is 55. The tracker's own wording is the correct one: **55
numbered findings + 1 unnumbered doc note = 56; + 2 sub-findings (#12Hb, #12Hc) = 58 tracked items.**
The headline compresses two different denominators into one number. This book's third rule says a
count is reported with its exclusions or not at all, so it is stated here in full rather than
repeated as published.

---

## 4. Seven findings worth the retelling

These are chosen for what they teach, not for severity. Four of them start with a hypothesis that was
**wrong**.

### 4.1 #1C — the fix was one function, because the bug was one function

The finding read like eleven bugs. A negative `amount` passed to `DPDC-T::C_Transfer` inverts the
sign of a credit into a debit; the same hole is reachable through fragments (#3C), through hybrid
credits (#24M), through set composition (#8C). Each auditor found it in their own module and reported
it as their own module's bug.

They were all the same bug. Every SFT and fragment balance change in all eleven modules funnels
through one function in `03_DPDC-C.pact`. A single `UEV_Amount` there closed #1C, closed #3C outright
with no additional code, and closed the negative half of #8C. The list-form callers came along for
free, because they `map` the same single-value function.

The exploit was reproduced before the fix, as a real signed transfer: sender balance **+50** from a
`-50` "debit", receiver driven to **−50**. After the fix, submitted as a real uncaught transaction,
it aborts before `commit-tx` and nothing persists.

The detail worth keeping is what the enforce actually says. It is **not** `> 0`:

```pact
(enforce (>= amount 0) "Amount cannot be negative")
```

Zero is legal, and the `@doc` explains why — EQUITY issues tier nonces with zero initial supply — with
a separate guard one line below rejecting a zero-amount *debit* against a zero balance. A reviewer
grepping for `> 0` would conclude the fix was weakened. It was made correct.

**Verified 2026-09-17:** `03_DPDC-C.pact:594`, called at `:1086`. [VERIFIED by reading]

### 4.2 #2C — refuted twice, hardened anyway, and the hardening is the point

Reported as a CRITICAL drain: `C_IgnisRoyaltyCollector` debits a caller-named `patron`'s IGNIS
balance with no authorisation check anywhere in the chain. Name someone else's smart account, collect
their balance to a collectable's creator.

The first refutation was mechanical — `IGNIS|C>DEBIT` already rejects smart-account patrons through
`UEV_EnforceAccountType`, so the "any smart account" shape was never reachable. Narrowing to
*standard* accounts, the second refutation was subtler and more interesting: the royalty-bypass in
`C_IgnisRoyaltyCollector` and the fee-ownership check in `C_Collect` **key off the same toggle**.
"Royalty is nonzero" and "the ownership check gets skipped" cannot both be true. No reachable drain.

The owner asked for `CAP_EnforceAccountOwnership` to be added to `IGNIS|C>DEBIT` anyway — *so the
debit does not depend on that external invariant holding forever.* That is the entire argument for
the fix, and it is a better one than the finding. A correct refutation tells you the system is safe
**today**, by a coincidence of two toggles in two modules. It does not tell you the system will be
safe after someone edits one of them.

Live-proven both directions: a real owner still collects a genuine 500.0 IGNIS royalty; an attacker
naming someone else's account is rejected at the new line with a keyset failure.

**Verified 2026-09-17:** `07_DPDC-T.pact:396`, inside `IGNIS|C>DEBIT`, alongside the
`UEV_EnforceAccountType sender false` at `:395` that the refutation rested on. **Both are present** —
the refutation's premise and the belt-and-braces fix. [VERIFIED by reading]

### 4.3 #5C → Fix #19 — the fix that broke EQUITY, and the test that found it

#5C: nothing stopped a collection owner from freezing and wiping the protocol's own `dpdc` escrow
account, destroying the collateral behind every outstanding fragment claim. Fix #3 added one check to
the shared `C>REMOVE-CLASS-ZERO-NONCES` chokepoint: `account != dpdc`. Both burn and wipe rejected at
the identical line, ordinary burn still working, `Z.repl` green.

Three days later, building real EQUITY test coverage for **#22H**, that blanket check turned out to
block EQUITY's legitimate `Convert`/`Break` flows. EQUITY uses `dpdc` as a *same-transaction escrow*
— transfer in, burn the old tier, credit the new tier, transfer out — which has nothing to do with
fragments.

The narrowed check asks the question #5C actually cares about: is this nonce **currently backing an
outstanding fragment claim**? Since the capability only ever handles Class-0 nonces, that reduces to
"does it have non-zero split-data", answerable without a forward reference to `DPDC-F` (which deploys
*after* `DPDC-MNG` and cannot be referenced by interface type this early — confirmed live, not
assumed: referencing `module{DpdcFragmentsV2}` there throws *"Cannot find module"* at DPDC-MNG's own
deploy step).

Two lessons stacked. The first: **a fix that passes the full suite can still be wrong, if the thing
it breaks has no test.** #5C's fix broke EQUITY and `Z.repl` stayed green for three days, because
EQUITY had no reachable coverage at all. The second: writing the missing test is what found it. The
audit did not discover this by re-reading its own fix.

**Verified 2026-09-17:** `06_DPDC-MNG.pact:439-470`. The narrowed form is present, the reasoning is
in the source comment, and the deploy-order constraint is recorded there too. [VERIFIED by reading]

### 4.4 #15H — a bound, then immutability, then a *tighter* bound, and the reason for each

The finding was ordinary: a set-class `score-multiplier` with no bound, retroactively re-pricing every
outstanding member of a set instantly (the same shape as the SWP audit's `C_ModifyWeights`).

Fix #13 added `UEV_ScoreMultiplier`: `(0, 100]` with 3-decimal precision, wired into all three Define
paths (which previously had **zero** validation) and the Update path (which previously had precision
only).

Fix #14, after the owner asked whether the multiplier is stable afterwards: not bounded — **immutable**.
`C_UpdateSetMultiplier` and its capability, `XI_*` and Talos wrappers were deleted outright. Write-once,
at Define, forever. This is also what closed #7C permanently: the type bug that made the function
crash on every call stopped mattering when the function stopped existing.

Fix #16, surfaced while discussing #19H: a multiplier is meant to **boost** a score, never quietly
shrink it. The floor moved from `0` to `1.0`. `0.5` — previously legal — is now rejected; `1.0` is the
neutral no-op.

Three edits to one validator over three days, each one triggered by a question the previous one
raised. That is what a sequential, one-finding-at-a-time process buys, and it is the argument against
batch fixing.

There is a coda. While fixing #15H the auditor checked whether the multiplier was consumed anywhere
live, and found `UR_N|Score` — the only function that applies it — had **zero callers**. The bound was
being placed on a value nothing read. A brief was handed off to a separate reviewer asking whether AQP
staking was meant to apply it, and `FINAL-AUDIT-REPORT.md` records that the answer *"has not yet come
back"*.

**It has since come back, and the answer was yes.** `02_SCORE.pact:2134` now calls
`ref-DPDC-S::URC_N|Score` for NFT score model 0, with a comment naming `DPDC #15H`. The bound is
load-bearing today in a way it was not when it was written.

**Verified 2026-09-17:** `08_DPDC-S.pact:1031-1047` (the bound), `:99`/`:1143` and the four Talos
sites (the removal), `02_SCORE.pact:2131-2134` (the consumer). [VERIFIED by reading]

### 4.5 #35M — removing the function was the fix, and the removal broke the launchpad

`XB_DeployAccountSFT`/`NFT` associate an account with a collection, and never check the caller
controls the target account. Any signer could force any account to associate with any collection.
State-bloat griefing, not theft — the write is idempotent-safe.

The obvious fix is an ownership check at the `XB_` layer. **That would have been wrong**, and the
audit established why before doing anything: the same `XB_` is used for legitimate
auto-associate-on-transfer, where the caller is by definition not the target. The fix that preserves
the feature is to remove the *standalone entrypoints* — the Talos `DPSF|C_DeployAccount` /
`DPNF|C_DeployAccount` wrappers and the orphaned `DPDC-I::C_DeployAccountSFT`/`NFT` — while leaving
the shared primitive alone. That is the #15H removal precedent applied a second time.

Then it broke. Every real caller was traced first, and one — `TS02-DPAD::A_RegisterAssetToLaunchpad`,
DemiPad's launchpad registration — genuinely depended on the removed path. It was redirected to call
`XB_DeployAccountSFT`/`NFT` directly, which required `TS02-DPAD`'s own guard to be registered as a
trusted DPDC IMC peer. **The redirect compiled cleanly and did not work.** It was caught by running
the real end-to-end launchpad scenario, which is not in the default test profile.

`FINAL-AUDIT-REPORT.md` singles this out, correctly, as the round's best argument for live
verification over a clean compile. The "Talos module needs its own IMC registration" shape had already
been fixed once each in the AQP and ATS audits — three modules, three times, found three separate
ways.

A handoff was drafted for DPTF/DPOF, where the identical shape was confirmed to exist.

**Verified 2026-09-17:** `04_DPDC-I.pact:55/396`, `01_TS02-C1.pact:65/484`, and the DemiPad redirect
documented at `05_TS02-DPAD.pact:207` and `:278`. No live definition of either function remains.
[VERIFIED by command]

### 4.6 #19H — one check at the entry, not four checks in four branches

`UR_N|Score` is the public "cooked" score reader. DPDC stores `-1.0` as the *unscored* sentinel, and
the reader is supposed to clamp it to `0.0`. It did — in one of its four arithmetic branches. The
other three either omitted the check or compared against `-1000.0`, a copy-paste leftover from the
fragment-scaling arm. Any composite-class nonce, and any fragment nonce created without explicit
metadata, read a real negative score.

The finding notes something that ought to make a reader uncomfortable: **a sibling audit (AQP) had
already recorded a false "already fixed" assumption about this exact function** in its own audit
trail.

The fix could have been four patches. It was one: hoist the sentinel check to function entry, on the
raw untouched value, before any multiply or divide. Three broken branches close at once and there is
no fifth branch to get wrong later. Eight-check live proof across NFT class-0 and SFT set-member,
scored and unscored, native and fragment; `git stash` reproduced the exact pre-fix values
(`-0.001`, `-2.5`, `-0.0025`).

Fix #18 then renamed it `UR_N|Score` → `URC_N|Score`, because **the prefix is the contract**: it reads
three tables and derives a computed value, which is `URC_`, not `UR_`. Zero callers existed at the
time, so nothing needed updating.

**Verified 2026-09-17:** `08_DPDC-S.pact:554-570`. The sentinel test is the first form inside the
`let` body, on `raw-nonce-score`, before either branch. [VERIFIED by reading]

### 4.7 #33M — the refutation whose own first assumption was wrong

`UDC_Makeid` derives a collection id from `prev-block-hash`, a block-level constant identical for
every transaction in a block. Two same-ticker issuances in one block collide, and the second aborts
with an opaque low-level error.

Confirmed live. Then, while documenting it, a second assumption was checked — *"at least NFT and SFT
with the same ticker work, they're in different tables"* — and it was **also false**. They collide
first in the globally-shared `BRD|BrandingTable`, used by seven modules (`DPDC-I`, `DPTF`, `ATS`,
`MTX-SWP`, `DPOF`, `DPMF`, `SWPI`), long before DPDC's own type-split tables are reached.

So the finding got *worse* during its own refutation, and was still accepted. The reasoning is worth
reading because it is a genuine engineering judgement rather than a dismissal: no fix is possible
inside `UDC_Makeid`, a Stage-1 utility that deploys before the `BRD` core module and cannot read it
without violating deploy order. A real fix needs collision-probe-and-retry logic added to all seven
consumer modules — disproportionate to a failure mode that is atomic, self-healing (the next block
has a different hash), and not exploitable beyond forcing a retry.

The outcome was a `@doc` on `UDC_Makeid` and nothing else. That is a defensible close, and it is
recorded as accepted-by-design rather than as fixed.

**Verified 2026-09-17:** `08_U_DALOS.pact:231`. [VERIFIED by reading]

---

## 5. What later rounds found in DPDC that this audit did not

The DPDC audit closed in August 2026. Two later programmes — the guard-reachability round and the
red-team round — went back over the same modules. What they found is not a criticism of this audit
so much as a demonstration that **reading a call chain to decide what refuses first is unreliable**,
which is this book's first rule.

### The guards this audit added, that could not speak

`#8C`'s fix put `(enforce (> how-many-sets 0) …)` inside `DPDC-S|C>MAKE`. Correct check, correct
capability. It sits in the `let` body, and the `let` binds `(iz-active (UR_IzSetActive …))`, which
funnels to `UR_Set`'s bare `read`. **Pact evaluates binding groups before the body**, so a set-class
that does not exist died on the raw table key and *neither* the "is not active" message nor #8C's own
message could ever speak for it. Set classes are 1-based, which puts `0` — the natural off-by-one —
squarely in the mute half.

That is `G-44` in `ARCHITECTURE/DEFECT-LEDGER.md` §1.2.1, fixed 2026-09-17 with a hoisted
`URC_SetExists` guard above the `let`. The entry records that **the defcap fix alone was not enough**:
the first raiser was in the *Talos wrapper*, which bound `(nonce (UR_NonceOfSet …))` eagerly, purely
to print it in the success message.

`G-45` is the sibling — `DPDC-S|C>RENAME` had no domain guard at all, and unlike `C>MAKE` never called
`UEV_SetClass`. *The module already contained a live guard for that exact input and RENAME was simply
not wired to it.*

Two more in the same family: `G-11` (`02_DPDC.pact` `UEV_Nonce`, all three predicates shadowed by
`UR_NonceValue`), `G-12` (`08_DPDC-S.pact` `UEV_SetClass`, both enforces shadowed by `UR_Set`), and
`G-10` (`06_DPDC-MNG.pact:287` `C>ADD-QUANTITY`'s `(> nonce 0)` — *partially* shadowed: nonce `0`
aborted in the row read, but a *negative* nonce reached the guard, because the reader keys on
`(abs nonce)` and found a real row. Mute for one input, live for another).

`G-08` is the most expensive of the set and belongs to EQUITY: `C_IssueShareholderCollection`'s
*"24 IPFS links must be provided"* check sat below a `let` binding that **issues the collection**. So
every rejected call **paid for a full collection issuance before its arguments were inspected**, and
whenever the issuance failed first for its own reasons — a duplicate name, the ordinary case — that
error was reported instead. Pinned by `<<EQ-G1>>`.

None of these are new *checks*. They are checks this audit and its predecessors wrote, which no input
could reach. The audit's own careful `expect-failure` proofs did not catch them, because a test that
drives a guard from a state where it *can* fire proves the guard works and says nothing about the
states where it cannot.

### #42L was deferred, and the red team partly closed it

`#42L` — *no REPL coverage exercises the ownership gate's negative path for any of the 12 role
functions* — was deferred to a planned suite refactor. It was the finding the audit itself called
*"the single highest-value missing assertion class for this module"*.

The red-team round arrived at the same place from the other direction. `DEFECT-LEDGER.md` §7.2h
measured **which owner gates have ever been observed refusing anybody**, and found that the entire
transfer family — `DPDC-T|C>TRANSFER`, `DPDC-T|C>BULK-TRANSFER`, `DPDC|C>TG_TRANSFER-R` and their
DPOF siblings — gate on `CAP_EnforceAccountOwnership sender` and **none had ever been shown refusing
a non-owner**. Their negative tests drove list-shape and nonce guards with the owner as sender.

`RT-D-004` wrote the first one for the collectable door, deliberately pinning **the victim's key by
name** rather than a bare `Keyset failure` — because on that family an unqualified match would not
separate "the owner gate refused" from "the attacker's own signature was rejected", which would pass
while proving the opposite.

Two `DPDC-S|C>` set witnesses and two DPDC nonce-level witnesses were added in the same sweep;
`[6.1.3]_DPDC-S.repl` has since grown from the audit's 40 assertions to a 67 KB suite carrying them
(`TX-SET-013` is the collection-owner gate's first witness).

**#42L is therefore partly closed, by a different programme, and its deferral stands for the rest.**

### The exec diagnosis bug behind a preview

`RT-K-004` went after `INFO_DPNF|Burn` and found the preview died on a raw properties read. The
*exec* turned out to be worse: `DPDC-MNG|C>BURN-NFT` checked the burn **role** before establishing the
collection exists, so for a non-existent id it answered *"NFT Burn Role for NOSUCHCOL-… must be set to
true"* — true, and useless, because there is no collection to hold a role on. `UEV_id` now runs first,
and the preview calls the same function.

---

## 6. What remains open

Four findings were deferred, deliberately and with reasons. None is a correctness gap; all four are
coverage or discipline items folded into larger planned work.

| id | what | why it is still open |
|---|---|---|
| **#40L** | The `Wipe*` family (`Heavy`/`Pure`/`Clean`/`Dirty`) has zero REPL coverage — the checked-in "Wipe Tests" transaction is commented out | The family itself needs renaming as part of a StoicSyntax architecture pass. Building coverage for names about to change is premature. |
| **#41L** | Branding functions untested; `DPNF|C_*` gets one exercised call in the entire suite against dozens for `DPSF|C_*` | Folded into a planned top-to-bottom Stage 1→2 REPL refactor. |
| **#42L** | No negative-path ownership coverage across 12 DPDC-R role functions | Same refactor. **Partly closed since, by the red-team round** — see §5. |
| **#43L** | `XI_RegisterCollectionElement` returns a formatted string instead of ending on a write | Touches the INFO-function architecture (UI cost/description read-points), rearchitected separately. |

Two cross-references were left open at close and have since moved:

- **The AQP multiplier-wiring question** (raised during #15H) — *closed*. `02_SCORE.pact:2134` now
  consumes `URC_N|Score`. [VERIFIED by reading]
- **The DPTF/DPOF handoff** (from #35M) — the identical standalone-`DeployAccount` shape was confirmed
  to exist there. Whether that audit acted on it is **not verified by this chapter.**

Two design positions are open by decision rather than by omission, and a reader should know they are
positions and not oversights:

- **The owner-dominion trust model.** #4C, #17H, #20H, #25M and #53L were all refused on one
  consistent principle: *a collection owner has complete, trusted dominion over their own token's
  economics and admin structure.* An unconsenting third party can be named "creator". A
  `role-modify-royalties` holder can raise a fee mid-flight against a pending buyer. There is no
  ceiling on an IGNIS royalty. These are deliberate, applied consistently across five findings rather
  than re-litigated each time, and the mitigation is off-chain: royalty changes are `@event`-logged in
  real time, a marketplace UI can re-read before signing, and Ouronet admin can red-flag an abusive
  collection. A reader who does not accept that model should treat those five as open.
- **The admin escape hatches.** `C_RepurposeCollectable` and `C_RepurposeCollectableFragments`
  deliberately bypass freeze and transfer-role gates, gated only on `CAP_Owner`. They exist for
  stolen and deceased-account recovery. The owner explicitly rejected freezing the source account
  afterward, because that would route through the real freeze path and become conditional on
  `can-freeze=true` (#13H) — defeating the point of an always-available escape hatch.
  `HEIR-SYSTEM-PONDERING.md` in the audit tree sketches a future design that removes admin discretion
  from the succession case.

---

## 7. Verification result for this chapter

Every finding recorded as FIXED was searched for in current source on 2026-09-17.

**Nothing was found missing.** All 35 fixes are present. This is a stronger result than it sounds,
because the codebase has been through at least four substantial rewrites since the audit closed:

- the **interface cascade** to `V2` — the audit's `DpdcV1`, `DpdcUdcV1`, `DpdcCreateV1` are now `V2`,
  and every fix survived retyping;
- the **Part II pricing rehaul**, which replaced `#10H`'s literal `"dpnf"` price key with the
  `URCi_IssueCollectionPrice`/`URCi_IssueCollectionStoa` reader pair — the *implementation* of that fix
  was rewritten and the *distinction* survived;
- a **StoicSyntax prefix sweep**, which renamed `#34M`'s `URD_AccountNoncesWithSupplies` →
  `URH_AccountNoncesWithSupplies` and `#55L`'s `URD_AS-Keys` → `URH_AS-Keys`. Both were briefly
  invisible to a grep on the audit's own wording, and both are correct. A fix verified by name is not
  verified;
- `XI_CreditOrDebitCollectables` → `XIv_CreditOrDebitCollectables`, the `v` marker for an intrinsic
  guard.

The reason the fixes are findable at all is a convention the audit adopted and stuck to: **35 of them
left a source comment naming the finding.** Counted 2026-09-17 [VERIFIED by command]:

| file | `DPDC Audit #` markers |
|---|---|
| `08_DPDC-S.pact` | 17 |
| `10_DPDC-N.pact` | 8 |
| `02_DPDC.pact` | 7 |
| `03_DPDC-C.pact` | 5 |
| `01_DPDC-UDC.pact`, `04_DPDC-I.pact`, `11_EQUITY+.pact` | 3 each |
| `09_DPDC-F.pact` | 2 |
| `05_DPDC-R.pact`, `06_DPDC-MNG.pact`, `07_DPDC-T.pact` | 1 each |

That is the mechanism that made this chapter's verification possible in an afternoon, and it is the
practice worth copying. A fix with a finding id attached can be found after four refactors. A fix
without one is indistinguishable from ordinary code the moment its line number moves.

**Two caveats on scope, stated because the book's rules require it.**

1. This chapter verified that each fix is **present**. It did not re-run the audit's proofs. Where
   the table says a fix is present, that is what was checked; where it says *live-proven*, that is the
   audit's claim, quoted.
2. The audit's `Z.repl`-green gate is **weaker than it reads**. `Z.repl` skips `[6.1]_DPDC.repl`
   entirely (`Stage02_Tester.repl:75`, and the header at line 8 names the skip). The three suites this
   audit built are in the fast path; the pre-existing DPDC scenario suite is not. The gate that
   actually covers this family is `python3 REPL/tools/_gate.py`.

---

*Next: Chapter 5 — DEMIPAD, the sovereign launchpad, and the smallest audit tree in the book.*
