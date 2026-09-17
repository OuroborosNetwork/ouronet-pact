# Chapter 1 — DALOS and the rest of Stage 1

> Source tree: `1_SOVEREIGN/STAGE_01/2_Core/Audit/DALOS/` (3,759 lines across 5 files).
> Audit ran 2026-08-22 → 2026-08-29. This chapter was written 2026-09-17 and re-checks every
> recorded fix against the tree as it stands today.

## Evidence labels used in this chapter

| label | means |
|---|---|
| **[V-cmd]** | established by running a read-only command (`grep`, `sed`, `git log`, `git show`) and reading its output |
| **[V-read]** | established by reading the cited source and judging what it does |
| **[INFERRED]** | reasoned from other facts; not directly observed |
| **[REPORTED]** | quoted from the audit trail, a commit message or `DEFECT-LEDGER.md`; **not** re-established here |

**Nothing in this chapter was established by running the test suite.** The suite and the gate were
off-limits to this pass (they are contended and slow). Every claim of the form *"this was reproduced
live"* is **[REPORTED]** — it is the audit's own record of an execution it performed, not an
execution performed for this chapter. Claims about what the source *says* today are **[V-cmd]** or
**[V-read]**, and those are the ones this chapter is actually staking its reputation on.

---

## 1.1 What the module does

"DALOS" names this audit but not its scope. The scope is **everything in Stage 1 that the sibling ATS
and SWP audits did not claim** — twenty-two modules and thirteen utility libraries, organised by the
audit into ten clusters. The name comes from its flagship, `01_DALOS.pact`.

**DALOS itself is the account layer.** Every actor on Ouronet — a person, a pool, a launchpad, a
bridge — is a *Ouronet account*: a string with a glyph prefix (`Ѻ.` for a standard account, `Σ.` for
a *smart* account governed by a module rather than a key), a guard, a linked StoaChain address, and a
sovereign. DALOS owns the table that maps all of that, the reverse index from chain address back to
account, the Elite-tier record that decides how far a user may overdraw, and the gas-station
capability (`GAS_PAYER`) that lets the protocol pay for its own users' transactions. If DALOS is
wrong, identity is wrong, and every authorisation decision downstream of identity inherits the error.

**IGNIS is the meter.** Ouronet is a virtual blockchain: it charges its own gas, denominated in
IGNIS, on top of whatever StoaChain charges in native gas. Client functions across the whole codebase
each return an `OutputCumulator` — a little ledger of *(who gets paid, how much)* — and Talos, the
orchestration layer, concatenates them and calls `IGNIS::C_Collect` exactly once per transaction.
`C_Collect` compresses the chain, splits fees between interactors and the treasury, and debits the
patron. Everything the protocol earns flows through this one function.

**The rest is the token estate.** `DPTF` (true fungibles) and `TFT` (their transfer layer) run the
plain token surface: mint, burn, transfer, freeze, the fee machinery, and the OURO overdraft — a
credit line whose size is a function of how much Elite-Auryn an account holds. `DPOF`
(orto-fungibles) runs the nonce-carrying, metadata-rich variant, where a single token id holds many
numbered positions with independent supplies. `VST` locks tokens into vesting, sleeping, hibernating
and reserved forms. `LIQUID` and `OUROBOROS` bridge to native STOA and mint/burn the OURO gas token.
`CODEX` and `PYTHIA` handle on-chain naming and the oracle/dirty-read relay. `BRD` and `ELITE` handle
branding and tiering. Thirteen `U_*` libraries carry the shared maths.

**If any of this breaks, the failure is not contained.** A DPOF nonce that can be double-counted
inflates an account's total supply, which feeds `ELITE`'s tier calculation, which sets the OURO
overdraft ceiling in `TFT` — a metadata bug becomes a credit-line bug three modules away. That is not
a hypothetical: it is finding C3, below, and it is exactly the path it took.

---

## 1.2 How it was audited

The audit ran in the same shape as its siblings (ATS, SWP, AQP) and borrowed their discipline
explicitly.

**Round I — ten parallel lenses, read-only.** The scope was enumerated from `MODULE-INDEX.md` and
direct file reads rather than guessed, and split into ten clusters: (1) DALOS/IGNIS/fuel core, (2)
legacy/branding/elite, (3) true fungibles, (4) orto-fungibles, (5) vesting/liquid/ouroboros plus
their Talos wiring, (6) identity/info, (7) oracle/codex plus Talos Client-Four, (8) utility maths,
(9) Talos Admin and Client-One wiring, (10) interface cascade review. One deep-read auditor per
cluster, run in parallel, each briefed to load `SKILL.md` and `StoicSyntax.md` first, to work
read-only, and — the instruction that matters — **to assume nothing is correct despite being live on
mainnet**. Each finding had to carry a severity, an exact `file:line`, a failure scenario, and a
CONFIRMED-or-PLAUSIBLE confidence tag. [REPORTED — `DALOS/README.md` § Method]

Round I produced **5 CRITICAL, 19 HIGH, 27 MEDIUM, 34 LOW**, compiled into `ROUND-01-FINDINGS.md`
(full write-ups, frozen) and `ISSUES-RANKED.md` (a flat `#1C` → `#85L` ranking). Three further
findings (N1–N3) were discovered later, during fix work, and appended rather than renumbered.
[V-cmd — the counts and the `#1C`–`#85L` range are read directly from `ISSUES-RANKED.md`]

**Round I — owner feedback, one finding at a time.** Findings were presented to the owner
sequentially in ranked order. The audit wrote itself a HARD RULE for this, because it had already
broken it: *no finding is settled until the verdict is written into all four places in the same
turn* — `ROUND-01-OWNER-FEEDBACK.md`, the README tracker, the `ISSUES-RANKED.md` annotation, and (if
code changed) a numbered entry in `ROUND-02-FIXES.md`.

The audit also logged its own bookkeeping failure in public: while presenting findings one at a time
it **skipped `#11H`–`#14H` and mislabelled H10 as `#11H` for several turns** before catching it —
the precise error class the SWP audit's HARD RULE had been written to prevent. All four affected
files were corrected before work continued. [REPORTED — `DALOS/README.md`, "Numbering-mixup note"]

**Round II — 31 sequential fixes.** Each fix got its own numbered entry with a diff, a rationale, and
a REPL proof. The methodology was adversarial and the owner enforced it: *reproduce the bug live
before accepting the finding; apply the fix; re-run the identical harness; then run the full
`Z.repl` regression.* Mid-audit the owner made this a standing instruction — **"everytime you give me
a bug i want you to confirm it to me in repl"** — and from `#25M` onward every finding was
re-verified live before a recommendation was even offered. [REPORTED — `ROUND-02-FIXES.md` Fix #21]

Two details of the method are worth recording because they are unusual and because they worked:

- **Reverts were done by hand, never by `git`.** The audit explicitly refused `git stash`/`reset` for
  pre-fix reproduction, citing a confirmed data-loss incident in a shared worktree. Where a fix had
  to be temporarily removed to prove the bug, the lines were commented out by hand and a grep for
  the marker string confirmed none survived. [REPORTED — `ROUND-02-FIXES.md` Fix #3 step 3-4]
- **The live chain was queried before deciding a fix's shape.** For `#30M` the audit did not guess
  whether a legacy backfill was still needed; it read all 18 deployed DPTF tokens off StoaChain via
  PYTHIA's dirty-read relay, found zero gaps, and only then deleted the backfill. [REPORTED —
  `ROUND-02-FIXES.md` Fix #25]

**Round III was never run on this branch.** The cycle table lists `ROUND-03-REVERIFY.md` as *"not yet
created"*, and it still does not exist. [V-cmd] What re-verification exists happened later and
elsewhere: the Part II/Part III programme, and this chapter.

**Was the audit thin anywhere?** Yes, in one place and by its own admission. Cluster 2
(DPMF/BRD/ELITE) had **no dedicated REPL file at all** — it was "grepped… covered incidentally".
Clusters 5, 6 and 7 leaned on REPL suites that were commented out of the default pipeline at the
time. The audit converted these into findings (`#38M`, `#41M`, `#47M`–`#49M`, `#55L`, `#59L`,
`#60L`, `#64L`, `#79L`) rather than footnotes, which is the right call, but it means the
CONFIRMED/PLAUSIBLE tags on those clusters rest more on reading than on execution.

---

## 1.3 The findings

88 findings: `#1C`–`#85L` plus N1–N3. Severity is **as recorded by the audit**, not re-graded here.
The *Evidence today* column is what this chapter checked, on 2026-09-17, against current source.

A note on names before the table: **a great many identifiers have changed since the audit.** The
StoicSyntax refactor (Part II) renamed `UEV_IMC` → `P|UEV_IMC`, `URC_Parent` → `URCv_Parent`,
`A_*`/`C_*` heavy variants to `AA_*`/`CC_*`, `UR|KDA-PID` → `UR_STOA-PID|Price`, and bumped almost
every interface. The `INFO-ONE+`/`INFO-ZERO` modules were moved out of `2_Core/` into
`STAGE_01/Z_Reads/` and their function family was re-shaped from `MODULE|INFO_Name` to
`INFO_MODULE|Name`. Where a fix is recorded against a name that no longer exists, this chapter says
so explicitly rather than reporting it missing.

### CRITICAL

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| C1 `#1C` | DPMF has no `create-table` calls anywhere — every function fails | CRIT | **NOT A BUG** | Technical claim stands; DPMF is the retired MetaFungible module, kept for history. `2_Core/00_DPMF.pact` still present, still tableless. [V-cmd] |
| C2 `#2C` | `DPOF::C_MoveCreateRole` never revoked the create role from the previous holder — every past holder kept mint access forever | CRIT | **FIXED** | `06_DPOF.pact:3076-3083` — `XI_SwitchCreateRole` now runs before `XI_UpdateVerum4`, with a comment naming #2C. **Witnessed**: `REPL/modules/DPOF.repl:239` `<<DPOF-MCR>>`, a two-move test whose third assertion is the revoke. [V-read] |
| C3 `#3C` | No nonce-uniqueness check on DPOF batch ops — supply inflation *and* negative nonce supply | CRIT | **FIXED** | `06_DPOF.pact:908, 1046, 1080` — `ref-U|LST::UEV_IzUnique` on `C>DEBIT`, `C>TRANSFER`, `C>BULK-TRANSFER` (the last against the flattened set). [V-read] **No witness found** — see §1.5. |
| C4 `#4C` | `VST::C_Unreserve` checks the issuer's ownership, not the reserver's — funds stuck | CRIT | **REFUTED** | Owner: Reserve/Unreserve is one-way escrow-for-purchase; the Token Manager is the intended sole collector. No code change. [REPORTED] |
| C5 `#5C` | `DPOF|INFO_UpgradeBranding` called `OI|OI|UDC_DynamicKadenaCost` — doubled prefix, unbound variable, every call crashed | CRIT | **FIXED** | **Fix site no longer exists.** `21_INFO-ONE+.pact` was retired (commit `42fb75d`); the successor `Z_Reads/02_INFO-ONE+.pact:1198 INFO_DPOF|UpgradeBranding` is a full rewrite delegating to `DPOF::URCi_UpgradeBranding`. Zero `OI|OI|` occurrences tree-wide. [V-cmd] |
| N1 | `DPOF::C_Transmit` completely non-functional for every caller — `C>TRANSMIT` read `"meta-data"`, schema field is `"meta-data-array"` | CRIT-equiv | **FIXED** | `06_DPOF.pact:1027` reads `"meta-data-array"`; the schema/constructor at `:1223` agrees. [V-read] `C_Transmit` is exercised by `modules/DPOF.repl` and `Stage_02/[6.1.6]_DPOF.repl`. [V-cmd] |

### HIGH

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| H1 `#6H` | Four DALOS `XE_*` writers skip a `SECURE`/named-cap second gate | HIGH | **REFUTED** | `UEV_IMC` alone is equivalent to `require-capability (SECURE)`; the sibling wrapper protects a shared writer, not an authorisation boundary. [REPORTED] |
| H2 `#7H` | `GLYPH|UEV_MsDc`'s charset fold seeded `false`/`or` — returned true if *any* character matched | HIGH | **FIXED** | `1_Utilities/08_U_DALOS.pact:572` `(and acc checkup)`, seed `true`. [V-read] **Witnessed** and gate-run: `REPL/_scratch_udalos_h1_msdc.repl` (2 asserts), listed in `REPL/tools/_gate.py` `SCRATCH_PROOFS`. [V-cmd] |
| H3 `#8H` | `IGNIS::C_Collect` had no per-leg zero filter — one legitimately-free leg aborted the whole bundle | HIGH | **FIXED** | `02_IGNIS.pact:1896-1901` — `(if (> amount 0.0) … (with-capability (IGNIS|S>FREE) true))`, comment names #8H. [V-read] **No witness found** — see §1.5. |
| H4 `#9H` | `DPTF::C_ToggleBurnRole`/`C_ToggleMintRole`/`C_ToggleFeeExemptionRole` missing `(UEV_IMC)` — reachable bare, bypassing Talos, pause check and billing | HIGH | **FIXED** | `05_DPTF.pact:3051, 3073, 3096` — `(P|UEV_IMC)` first statement on all three, matching the two siblings at `:3029, :3119`. [V-read] Partially witnessed by `modules/CONFORMANCE.repl` `<<CONF-01>>` for the sibling `C_DeployAccount`. [V-cmd] |
| H5 `#10H` | A zero-amount leg aborts the entire Multi(Bulk)Transfer batch | HIGH | **REFUTED** | Owner: dying in place on an invalid amount is intended; silently skipping would hide the caller's mistake. [REPORTED] |
| H6 `#11H` | `TFT::C_MultiBulkTransfer` refreshed the receiver's Elite tier but never the sender's — stale, over-generous OURO overdraft bound | HIGH | **FIXED** | `09_TFT.pact:1840` binds `contains-eazs`; `:1920-1923` refreshes the sender. Mirrors `C_MultiTransfer` at `:1781/:1820`. [V-read] |
| H7 `#12H` | `DPOF|C>UPDATE-SPECIAL`'s immutability guard tested `vzh-tag 2` twice instead of `2` then `3` — hibernation links silently re-pointable | HIGH | **FIXED** | `06_DPOF.pact:1094-1096` — the three branches are now `1`/`2`/`3`. [V-read] |
| H8 `#13H` | `LIQUID::C_RegisterOuronetAccountForUrstoaHoldings` had zero ownership check — account hijacking | HIGH | **FIXED (by removal)** | Function gone; only the tombstone comments remain at `12_LIQUID.pact:73` and `3_Talos/03_TS01-C2.pact:139`. Zero live references. [V-cmd] |
| H9 `#14H` | `U_VST::UEV_MilestoneWithTime` had no lower bound — a negative `duration` mints a lock already unlockable | HIGH | **FIXED** | `11_U_VST.pact:233-235` `(and (>= offset 0) (>= duration 0))`. [V-read] **Witnessed**: `REPL/modules/UTILITIES.repl` `<<UTIL-11>>`, both the negative-offset and negative-duration cases, by message. [V-read] |
| H10 `#15H` | `ATS|INFO_Coil`'s third leg built its cumulator from the wrong token with sender/receiver reversed | HIGH | **FIXED** | **Fix site no longer exists.** The successor `Z_Reads/02_INFO-ONE+.pact:2220 INFO_ATS|Coil` no longer hand-assembles legs at all; it takes one `ref-ATSU::URCi_Coil` cumulator. The defect class is structurally gone. [V-read] |
| H11 `#16H` | `ATS|INFO_ColdRecovery` bound two locals both named `ifp3` — the Transfer leg's cost was computed then shadowed away | HIGH | **DEFERRED** → now moot | Deferred in 2026-08 to the INFO-function project. That project landed: `Z_Reads/02_INFO-ONE+.pact:2428` now derives cost from a single `ref-ATSU::URCi_ColdRecovery` call. No duplicate binding survives. [V-read] |
| H12 `#17H` | `PYTHIA::A_UpdateDeployPrice`/`A_UpdateRenamePrice` never wired into Talos — unreachable even for the admin | HIGH | **FIXED** | `3_Talos/06_TS01-C4.pact:96-97` (interface), `:324, :335` (impl). [V-read] **Witnessed**: `REPL/modules/PYTHIA.repl:10` `<<PYTHIA-PRICE>>` — six assertions that the Talos wrapper *moves the value the readers return*, plus restore. [V-read] |
| H13 `#18H` | `U_VST::UC_MakeVestingDateList` silently dropped `offset` when `milestones = 1` — a cliff vest releases early | HIGH | **FIXED** | `11_U_VST.pact:138` `[(add-time first-time duration)]`. [V-read] |
| H14 `#19H` | The KDA/USD price oracle is a hardcoded stub, `1.0`, with the real call commented out | HIGH | **FIXED (interim)** | Renamed and re-denominated: `01_U_CT.pact:364 UR_STOA-PID|Price` returns `0.1` with the `#19H` comment and the dia-oracle call still commented at `:365`. **Still a stub.** See §1.5. [V-read] |
| H15 `#20H` | `U_DEC::UC_AddHybridArray` returns garbage on an empty column list and hard-crashes on an all-empty row list | HIGH | **FIXED** | `07_U_DEC.pact:141-146` — `(if (= maxl 0) [] …)` guard with a `#20H fix` comment; the original body is untouched inside. [V-read] |
| H16 `#21H` | ~Half of `TalosStageOne_AdminV1`'s surface has zero REPL exercise; `[6.4]_Admin.repl` asserts nothing | HIGH | **DEFERRED** → largely closed | `[6.4]_Admin.repl` now has 3 assertions (was 0); `[6.12]_DALOS-ADMIN.repl` has 35 and is in the default `Stage01_Tester.repl` path; `modules/DALOS-ADMIN.repl` has 94. [V-cmd] Not formally re-closed in the audit tracker. |
| H17 `#22H` | `DemiourgosPactOrtoFungibleV2`/`TalosStageOne_ClientOneV2` cascaded locally but not deployed | HIGH | **FINALIZED (status note)** | Superseded — DPOF now ships `DemiourgosPactOrtoFungibleV2` and TS01-C1 `TalosStageOne_ClientOneV2` as the *live* versions; the redeploy phase absorbed it. [V-cmd] |
| H18 `#23H` | `OUROBOROS::C_SublimateV2` is live and actively called but absent from `OuroborosV1` | HIGH | **FIXED** | `13_OUROBOROS.pact:72` declares it; `:791` implements it; `3_Talos/03_TS01-C2.pact:147/1816` and `04_TS01-C3.pact:875` call it. [V-read] |
| H19 `#24H` | Four live `C_*` functions absent from `CodexV1`, which declared no `C_` at all | HIGH | **FIXED** | `2_Core/21_CODEX.pact:120-123` — all four declared. [V-read] |

### MEDIUM

| id | summary | severity | verdict | evidence today |
|---|---|---|---|---|
| M1 `#25M` | `DALOS::C_RotateKadena` read the address *after* overwriting it — old reverse-index row orphaned forever | MED | **FIXED** | Now `C_RotateStoa`, `01_DALOS.pact:1865-1881` — `old-stoa` bound before `XI_RotateStoa`, comment names #25M. [V-read] |
| M2 `#26M` | Smart-account deploy validation lived inside the `XI_*` writer, not the client cap | MED | **FIXED** | `01_DALOS.pact:847` — new `DALOS|A>DEPLOY-SMART-OURONET-ACCOUNT` composes `GOV|DALOS_ADMIN` + the shared validation cap; used at `:1727`. [V-read] |
| M3 `#27M` | `GAS_PAYER`'s allowlist matches module names by string prefix, not identity | MED | **NOT A BUG** | Owner: intentional — every real Talos module is deliberately `TS`-prefixed. [REPORTED] |
| M4 `#28M` | `TFT::C_ClearDispo` unconditionally force-unfroze the Elite-Auryn account even if pre-frozen for an unrelated reason | MED | **FIXED** | `09_TFT.pact:1655-1662` — `ico3` now carries `ico1`'s own `(if (not frozen-state) …)` guard. [V-read] |
| M5 `#29M` | `dispo-data` snapshotted once before the multi-transfer fold and reused per leg — **real OURO-overdraft inflation** | MED (under-ranked) | **FIXED** | `09_TFT.pact:1797-1803` and `:1867-1869` — recomputed inside each leg's `let`, both functions, comments name #29M. [V-read] **No witness found for the staleness itself** — see §1.5. |
| M6 `#30M` | `DPTF::UR_Hibernation`, an unprotected "read", performed a live table `update` | MED | **FIXED** | `05_DPTF.pact:1212-1229` — pure getter; the `#30M fix` comment records the live-chain check that made the backfill provably dead. [V-read] Companion `REPL/_scratch_dptf_m6_urhibernation_purefetch.repl` is a gate entrypoint but carries **0 assertions**. [V-cmd] |
| M7 `#31M` | `DPOF::URC_Parent` contained a direct `enforce`, violating the `URC_` contract | MED | **FIXED, then partly self-defeated** | `06_DPOF.pact:1732` (now `URCv_Parent`) has no enforce; `:2038` in `UEV_ParentOwnership` has it. But the in-source note at `:2030-2037` records that the relocated enforce is now **shielded by an eager `let` that calls `URCv_Parent` first**, and is **UNPINNED**. [V-read] See §1.4. |
| M8 `#32M` | `DPOF::C_WipeHeavy` reaches a table-scanning `URDC_*` from a public `C_` without the HEAVY prefix | MED | **DEFERRED → closed** | The `CC_`/`AA_` HEAVY convention was applied by the StoicSyntax sweep; e.g. `10_ATSU.pact:81 CC_RemoveSecondary`, `:72 AA_RemoveSecondary`. [V-cmd] |
| M9 `#33M` | `AHU`/`AUP_OrtoFungible*` authorise via a hardcoded account literal, not `GOV|DPOF_ADMIN` | MED | **NOT A BUG** | Completed one-time DPMF→DPOF migration utility. Documented in place: `06_DPOF.pact:762-782`. [V-read] |
| M10 `#34M` | Two dead capabilities in `TS01-A`, one the sole path to a governor slot registered on DALOS's own vault | MED | **DEFERRED to red-team** | **Still open.** `3_Talos/01_TS01-A.pact:147 P|GOVERNING-SUMMONER` and `:151 P|SECURE-SUMMONER` still have zero callers; `P|TRG` at `:139` is composed only by the former and registered as a guard at `:242`. [V-cmd] |
| M11 `#35M` | `DPOF|C_TogglePause`/`C_ToggleFreezeAccount` bind a dead `ref-TS01-A` and skip the mandated result string | MED | **FIXED** | `3_Talos/02_TS01-C1.pact:1099-1113` — dead binding removed, `format` messages added, comment names #35M. [V-read] |
| M12 `#36M` | DPMF carries stale duplicate Elite-Auryn accounting, missing the 6th term ELITE adds | MED | **NOT A BUG** | DPMF permanently out of scope. [REPORTED] |
| M13 `#37M` | Malformed `format` in `DPMF|C>UPDATE-SPECIAL` | MED | **NOT A BUG** | Same. [REPORTED] |
| M14 `#38M` | Elite-tier update functions run on nearly every transfer but are never asserted; BRD's admin path has zero exercise | MED | **DEFERRED to REPL phase** | Partly closed by the Part II module testers; not re-closed in the tracker. [INFERRED] |
| M15 `#39M` | `DPTF|INFO_ClearDispo` carries a raw enforce, undeclared, zero callers | MED | **DEFERRED to INFO project** | INFO project landed; the whole family was rewritten. Not re-closed per-finding. [INFERRED] |
| M16 `#40M` | Six `LIQUID|INFO_*`/`ORBR|INFO_*` implemented but undeclared | MED | **DEFERRED to INFO project** | `Z_Reads/02_INFO-ONE+.pact` declares `INFO_LIQUID|*`/`INFO_ORBR|*` in its interface. [V-cmd] |
| M17 `#41M` | Near-total absence of asserted returns across 93 INFO functions — root enabler of C5/H10/H11 | MED | **DEFERRED to REPL phase** | Closed: `REPL/modules/INFO-ONE.repl` exists, and per-module testers carry `INFO_*` "quote vs measured charge" blocks (e.g. `modules/ATS.repl:1955 ATS-I1`). [V-cmd] |
| M18 `#42M` | `U_RS::UEV_EnforceReserved` over-blocks legitimate non-principal names | MED | **NOT A BUG** | Verbatim port of Kadena's own `coin.pact`; zero callers here. Pinned anyway: `REPL/_scratch_urs_m18_overblock.repl`, a gate entrypoint. [V-cmd] |
| M19 `#43M` | Several `U_LST`/`U_VST` `UC_*` functions perform `enforce` | MED | **DEFERRED to StoicSyntax sweep** | Sweep landed; the `v`-specialisation (`UCv_`/`URCv_`) now formalises the legitimate cases and renames the rest. [V-cmd] |
| M20 `#44M` | `UC_IzUnique` can never return `false` — its own comment promises a two-valued predicate that never existed | MED | **FIXED** | `05_U_LST.pact:222 UEV_IzUnique`, doc rewritten to state the true contract. Zero `UC_IzUnique` code references remain. [V-cmd] **Witnessed**: `REPL/_scratch_ulst_m20_uev_izunique.repl`, a gate entrypoint. [V-cmd] |
| M21 `#45M` | `UC_MaxInteger` crashes *uncatchably* on an empty list; reachable unguarded through a real `DPDC-S` client entrypoint | MED | **FIXED** | `06_U_INT.pact:193-194` — renamed `UEV_MaxInteger` with `(enforce (> (length lst) 0) …)` first. [V-read] **Witnessed**: `modules/UTILITIES.repl` `<<UTIL-11>>` asserts both the value and the refusal message. [V-read] |
| M22 `#46M` | `UEV_ContainsAll` checks set membership, not multiset containment | MED | **NOT A BUG** | Sole live caller is DPMF, permanently out of scope. [REPORTED] |
| M23 `#47M` | Zero `expect-failure` assertions anywhere in CODEX/PYTHIA suites | MED | **DEFERRED to REPL phase** | Closed: `modules/PYTHIA.repl`, `modules/CODEX.repl` exist with negative assertions. [V-cmd] |
| M24 `#48M` | Both suites commented out of the default pipeline | MED | **DEFERRED to REPL phase** | Still commented in `Stage01_Tester.repl:52-54`, but both run under `ZALL.repl:41-42` and their own module testers. [V-cmd] |
| M25 `#49M` | The PYTHIA flush-gas-probe REPL is broken — batch sizes exceed the module's own cap | MED | **DEFERRED to REPL phase** | [INFERRED — not re-checked] |
| M26 `#50M` | `INTERFACE_VERSIONING.md` doesn't document the additive/opt-in dual-implementation pattern | MED | **DEFERRED to StoicSyntax sweep** | [INFERRED] |
| M27 `#51M` | `MODULE-INDEX.md`'s "latest: X" points at frozen, never-deployed interfaces | MED | **DEFERRED to StoicSyntax sweep** | Superseded — the frozen-interface convention was abandoned entirely; all three Stage-1 registry files now declare zero interfaces. [REPORTED — `DEFECT-LEDGER.md` §8.6] |
| N2 | `TS01-C1::DPTF\|C_DeployAccount`/`DPOF\|C_DeployAccount` ungated — any signer could force any account to associate with any token | MED-equiv | **FIXED** | `3_Talos/02_TS01-C1.pact:710` — `(ref-DALOS::CAP_EnforceAccountOwnership account)`; new admin path `DPTF\|A_DeployAccount`/`DPOF\|A_DeployAccount` at `01_TS01-A.pact:574, :601` behind `P\|ADMINISTRATIVE-SUMMONER`. [V-read] |
| N3 | Three `TS01-A` treasury admin functions gated only by bare-true `P\|TS` | CRIT? | **REFUTED** | Core layer independently composes `GOV\|DPTF_ADMIN`. Pinned: `REPL/_scratch_ts01a_n3_treasury_gate_check.repl`, a gate entrypoint with one negative assertion. [V-cmd] |

### LOW

| id | summary | verdict | evidence today |
|---|---|---|---|
| `#52L` | `URD_AccountCounter` — dead, mis-sectioned | DEFERRED → gone | Zero references tree-wide; the function no longer exists. [V-cmd] |
| `#53L` | `A_UpdateUsagePrice` has no bound check on `new-price` | **FIXED** | `01_DALOS.pact:1783`. [V-read] |
| `#54L` | Self-referential `ref-DALOS::` call; hardcoded-account migration tool | NOT A BUG | Same verdict as M9. [REPORTED] |
| `#55L` | `[6.1]_Cumulator.repl` has zero assertions, never invokes `C_Collect`; `[6.4]_Admin` comments out `C_RotateKadena` | DEFERRED → closed | `REPL/modules/CUMULATOR.repl` exists; `[6.1]_Cumulator.repl` carries the 75 leg-level pricing assertions CLAUDE.md now cites. [V-cmd] |
| `#56L` | Two vestigial ELITE boilerplate items | **FIXED** | `07_ELITE.pact:84` tombstone; zero references. (Note: a separate `GOV\|CollectiblesKey` survives at `06_DPOF.pact:438` — out of #56L's stated scope.) [V-cmd] |
| `#57L` | Stale "DPMF" naming in Talos docs/REPL labels | DEFERRED to sweep | [INFERRED] |
| `#58L` | Dead `account-ea-supply` binding in `C_ClearDispo` | **FIXED** | `09_TFT.pact:1626` tombstone comment. [V-cmd] |
| `#59L` | DPTF/TFT REPL coverage gaps | DEFERRED → largely closed | `modules/DPTF.repl` carries `<<DPTF-G7>>` etc. [V-cmd] |
| `#60L` | DPOF's dedicated REPL has zero `expect`/`expect-failure` | DEFERRED → closed | `modules/DPOF.repl` has 30+ negative assertions. [V-cmd] |
| `#61L` | Dead `total-ouro` binding in `OUROBOROS::C_Compress` | **FIXED** | `13_OUROBOROS.pact:694` tombstone. [V-cmd] |
| `#62L` | `LIQUID::UEV_Amount` defined, never called | DEFERRED to red-team | **Still open.** `12_LIQUID.pact:472` — exactly one occurrence in the file, the definition. [V-cmd] |
| `#63L` | Native KDA `install-capability` supplied by off-chain code, untestable in the Pact REPL | NOT A BUG | Documented architectural limitation. [REPORTED] |
| `#64L` | Broad coverage gaps across VST/LIQUID/OUROBOROS | DEFERRED → closed | `modules/VST.repl`, `modules/LIQUID.repl`, `modules/OUROBOROS.repl` all exist. [V-cmd] |
| `#65L` | `UC_LpFuelToLpStrings` (a `UC_`) contains a raw `enforce` | DEFERRED to sweep | [INFERRED] |
| `#66L` | `UCX_*`/`UCXX_*` pre-migration spelling | DEFERRED → closed | Renamed to `UCx_` (e.g. `13_U_BFS.pact:382 UCx_GraphNodeLinks`). [V-cmd] |
| `#67L` | `VST\|INFO-HibernatedNonce(s)Display` hyphenated, undeclared, zero callers | DEFERRED to INFO project | Superseded by the rewrite. [INFERRED] |
| `#68L` | Dead constant `PYTHIA\|FLUSH-GAS-TARGET` | **FIXED** | `22_PYTHIA.pact:410` tombstone; zero references. [V-cmd] |
| `#69L` | `UR_AWT\|ListByCodex` scans but is named `UR_` | DEFERRED to sweep | [INFERRED] |
| `#70L` | CODEX defcap body-order deviations | DEFERRED to sweep | [INFERRED] |
| `#71L` | PYTHIA price-setters acquire `SECURE` inline | DEFERRED to sweep | [INFERRED] |
| `#72L` | Stale header on `[6.10b]_PYTHIA-ledger-v2.repl` | **FIXED** | [REPORTED] |
| `#73L` | Tautological `or` in `CT_DPTF-FeeLock` | **FIXED** | `01_U_CT.pact:244-247` — single named condition. [V-read] |
| `#74L` | Typos in enforce messages | **FIXED (partial, by design)** | `11_U_VST.pact:170` tombstone. "succesfully" deliberately left — it is the codebase's consistent 119-occurrence spelling. [V-cmd] |
| `#75L` | `UEV_StringPresence`'s `[bar]` sentinel doesn't cover a real empty list | **FIXED** | `05_U_LST.pact:262` — `(and (!= item-lst [bar]) (UC_IsNotEmpty item-lst))`. **Witnessed**: `REPL/_scratch_ulst_75l_stringpresence_empty.repl`, gate entrypoint. [V-read] |
| `#76L` | Self-referential module-ref style in `UC_NonceSplitter` | DEFERRED to sweep | [INFERRED] |
| `#77L` | `UR\|KDA-PID` section-placement mismatch | DEFERRED to sweep | Now sits under `{5.3} Read` in `01_U_CT.pact:361-364`. [V-cmd] |
| `#78L` | Off-by-one in `UC_Search`'s `enumerate` | DEFERRED to sweep | Standing instruction: never touch `U|LST::UC_Search`. [REPORTED] |
| `#79L` | `[1]_Utilities.repl` has zero assertions for any of 8 in-scope modules | DEFERRED → closed | `REPL/modules/UTILITIES.repl` carries `<<UTIL-01>>`…`<<UTIL-11>>+`. [V-cmd] |
| `#80L` | Talos wrapper naming drift vs core counterparts | DEFERRED to sweep | [INFERRED] |
| `#81L` | Misnamed `GOV\|MD_DPTF` constant in `04_BRD.pact` | DEFERRED to sweep | [INFERRED] |
| `#82L` | ~12 client wrappers missing the mandated `format` result string | DEFERRED to sweep | [INFERRED] |
| `#83L` | Dead/orphaned frozen interfaces | NOT A BUG | Superseded — the frozen-copy convention was abandoned. [REPORTED — §8.6] |
| `#84L` | Inconsistent "Frozen —" `@doc` labelling | DEFERRED to sweep | Moot with the convention. [INFERRED] |
| `#85L` | `[0.1]_Interfaces.repl` is a smoke test by design | NOT A BUG | Still true, and now *says* it is. [REPORTED — §8.6] |

**Plus one non-finding:** Fix #7 is an owner-requested IGNIS Compress/Prime gas optimisation, not a
Round-I item. It is present: `02_IGNIS.pact:1510 UC_FindKeyIndex`, used at `:1206` and `:1268`.
[V-read] The audit measured 35 gas saved on an 8-leg batch and 85 on a 20-leg batch [REPORTED], and
proved byte-identical output against retained `_OLD` copies before deleting them.

---

## 1.4 Six findings worth the telling

### (a) C2 — the revoke that revoked the wrong account, and why one test could never catch it

`DPOF::C_MoveCreateRole` is supposed to be one atomic grant-and-revoke: the new holder gets the
create/mint role, the old holder loses it. It called `XI_UpdateVerum4` (write the new holder of
record) and then `XI_SwitchCreateRole` (clear the old holder's flag, set the new one's).
`XI_SwitchCreateRole` derives "who is the old holder" *itself*, internally, via `(UR_Verum4 id)`.

By the time it ran, that read already returned the **new** holder. Both of its writes landed on the
same row — set `false`, then immediately `true`, a no-op — and the real previous holder was never
touched. Every past holder of a DPOF's create role kept mint access forever.

The interesting part is not the bug; it is why it survived. The master defcap
`DPOF|S>X_SWITCH-CREATE-ROLE` already computed the correct previous holder from pre-write state. The
correct value existed. It was simply never threaded through to the writer, which re-derived its own,
wrong copy. A reviewer reading the defcap would conclude the logic was right.

And **a single move cannot detect it.** After one move the previous holder is the token's owner, who
retains the role for an unrelated reason (`UR_R-Create` has an `account == owner-konto` OR-clause
that masks the result). It takes *two* consecutive moves, so that the second one's previous holder
is a third party with nothing else granting them the role. The audit's own harness did exactly that
— `emma` (owner) → `aoz`, then `aoz` → `patron` — and that structure is preserved in the live pin
today, `REPL/modules/DPOF.repl:239`, which explains the reasoning in its own comment before making
the assertion:

> *"A single move cannot detect this — after one move the previous holder IS the owner, who keeps the
> role for other reasons. It takes TWO consecutive moves…"*

**The fix was a reorder of two lines.** `06_DPOF.pact:3081-3083`. [V-read]

### (b) N1 — the bug found while building the proof for a different bug

While constructing the REPL proof for C3 (nonce uniqueness), the audit needed a *working*
`C_Transmit` call to attack with duplicated nonces. The very first ordinary, non-duplicated call
crashed: `Key "meta-data" not found`.

`DPOF|C>TRANSMIT`'s defcap read `(at "meta-data" td)`. The `TransmitData` schema's real field is
`meta-data-array` — as both the `defschema` and the constructor `UDCX_TransmitData` agree. Every call
to `C_Transmit`, from the core or through the Talos wrapper, had crashed unconditionally, for any
input, since it was written.

This is the finding class that no amount of reading produces, because the code reads correctly at
every level *except* the one string. It was fixed as a one-string change (`06_DPOF.pact:1027`
[V-read]) and logged as its own numbered finding rather than folded into C3's write-up — the right
call, since the two are causally unrelated.

The general lesson the audit drew, and it is worth keeping: **building the attack harness for one
finding is itself an audit technique**, because it forces you to execute the happy path first.

### (c) M5 — ranked MEDIUM, and it was an exploit

The finding as written was a code-organisation complaint: `TFT::C_MultiTransfer` and
`C_MultiBulkTransfer` compute `dispo-data` once, before the fold over legs, and reuse the snapshot
for every leg's debit check.

`dispo-data` captures the sender's current Elite-Auryn holdings. `UC_OuroDispo` — the maximum
permitted OURO overdraft — is directly proportional to that. So a *single batch* containing both an
Elite-Auryn-reducing leg and an OURO-overdraft leg gets its overdraft checked against the sender's
**pre-batch** holdings, regardless of leg order (the snapshot precedes everything either way).

The audit re-verified it live per the owner's standing instruction and reported the numbers:

```
patron EA before: 114907.2904 / half transferred away: 57453.6452
max overdraft under STALE dispo:    44446.6688…
max overdraft under CORRECT dispo:  22223.3344…
chosen overdraft amount: 33335.0016
BATCH SUCCEEDED. patron's OURO balance after: -33335.0016
```

[REPORTED — `ROUND-02-FIXES.md` Fix #24] That is a ~50% inflation of a credit line, in one
transaction, with no special privileges. The fix entry opens with an explicit severity correction —
*"this finding turned out more serious than its MEDIUM rank suggests… Flagging this explicitly since
the ranked tier undersells it"* — which is the correct behaviour and worth naming, because the
alternative (quietly fixing it at its original rank) leaves the ranking looking calibrated when it
was not.

**The fix is present**: `09_TFT.pact:1797-1803` and `:1867-1869` recompute per leg. [V-read] **The
staleness itself has no witness in the running suite** — see §1.5.

### (d) M7 — the fix that moved the problem instead of removing it, and said so

`DPOF::URC_Parent` contained `(enforce (!= fourth BAR) "Sleeping LP Tokens not allowed…")`. A `URC_`
contractually never enforces, and this one made *every* caller pay for a rejection only one of them
needed. The fix relocated the enforce to `UEV_ParentOwnership`, the one caller whose own `@doc`
already claimed it.

That is where a normal audit entry would stop. This one does not. Read the current source at
`06_DPOF.pact:2030-2042` [V-read]:

```pact
(parent:string (URCv_Parent id))
)
;;#31M fix: moved here from URCv_Parent, which must never enforce - this is the only
;;caller that actually needs this rejection (per this function's own @doc).
;;UNPINNED, and the reason is worth stating because it partly defeats the #31M fix
;;above: <parent> is bound EAGERLY in the same let, by calling URCv_Parent, which
;;READS the properties table. So a sleeping-LP id that does not exist aborts in that
;;read before this enforce runs -- the check was moved here to be reachable, and is
;;now shielded by the very function it was extracted from.
```

The enforce was moved *into* a function whose own `let` calls the function it was moved *out of*,
first. Reaching it now requires a real issued sleeping-LP token, which no suite creates. The
comment names the remedy (bind `parent` lazily inside the `if`) and names the twin that got it right
(`DPTF`'s `URCv_Parent`, pinned at `REPL/modules/DPTF.repl` `<<DPTF-G5>>`).

This is the eager-`let` pathology the book's Rule 1 exists for, appearing in a *fix* rather than in
original code. It is also, as far as this chapter can determine, the single most honest artefact in
the DALOS tree: the code documents the incompleteness of its own repair, at the site, in the place a
future reader will actually look.

### (e) H14 — the stub that was fixed, then quietly re-denominated

The finding: `U_CT::UR|KDA-PID`, the sole KDA/USD price feed used across asymmetric-LP IGNIS
taxation and DemiPad pricing, is a hardcoded `1.0` with the real `dia-oracle.get-value "KDA/USD"`
call commented out. Every dependent computation silently assumed permanent KDA/USD parity.

The owner's ruling was pragmatic: no oracle exists yet, set it to `0.1` (mainnet's approximate KDA
price) and defer the real wiring. Fix #17 did that.

Today the function is `UR_STOA-PID|Price` at `01_U_CT.pact:364`, it returns `0.1`, and the commented
oracle call above it reads `"STOA/USD"`. [V-read] The rename came from commit `0b0ad31`, *"Rename
KDA/Kadena -> STOA across all production code (native collect is STOA)"* [V-cmd], and it is
architecturally correct — the native chain token really is STOA, not KDA.

But **the number did not change when the denomination did.** `0.1` was chosen, on the record, as
"mainnet's approximate KDA/USD price". It is now serving as the STOA/USD price. Whether those two
quantities happen to coincide is not something this chapter can establish, and nothing in the tree
asserts that they do. [INFERRED — the risk; V-read — the value and the label]

The finding's substance is in any case still open: it is a stub, and `#L58` in the sibling SWP audit
confirms the same value fans out to 308 call sites across 17 files. See §1.5.

### (f) H4 — the escape hatches were checked before "different from its siblings" became "bug"

Three of the five Toggle-Verum client recipes in `05_DPTF.pact` lacked `(UEV_IMC)`. Two had it. The
tempting inference — *inconsistent, therefore broken* — is exactly the inference that had already
produced one refuted finding in this same audit (H1, where a missing `SECURE` wrapper turned out to
be structural rather than authorising).

So the audit enumerated the two ways it could be intentional, and killed both before proposing a fix:
(1) *maybe `UEV_IMC` belongs inside the capability instead* — checked: none of the five
`DPTF|C>TOGGLE-*` defcaps reference it, consistently; (2) *maybe these three are meant to be called
from within DPTF itself, where `UEV_IMC` would be wrong* — checked by repo-wide grep: zero internal
callers, the only callers anywhere are cross-module `ref-DPTF::` calls from the Talos wrapper,
exactly like the two correct siblings. Only then: *"it seems I simply forgot to add the line."*

The consequence was real. Neither DPTF nor TFT independently checks the Global Administrative Pause,
and IGNIS billing happens only in the Talos wrapper. A direct core call, signed by the token owner
alone, bypassed all of it — no pause check, no gas, nothing but `CAP_Owner`. Two of the three were
reproduced live; the third was confirmed by byte-identical code structure, and the report says so
rather than implying three live reproductions. [REPORTED]

`(P|UEV_IMC)` is present on all three today: `05_DPTF.pact:3051, 3073, 3096`. [V-read]

---

## 1.5 What remains open

### Findings the audit left open on purpose

| item | state today | why |
|---|---|---|
| **M10 `#34M`** — two dead capabilities in `TS01-A`, one the only path to a governor slot on DALOS's own vault | **Open.** `P\|GOVERNING-SUMMONER` (`01_TS01-A.pact:147`) and `P\|SECURE-SUMMONER` (`:151`) still have zero callers; `P\|TRG` (`:139`) is composed only by the former and is registered as a capability guard at `:242`. [V-cmd] | Owner: *"if it were needed it would already be used."* Deferred to the red-team pass to confirm empirically that DALOS's governor resolves without this path. The red-team pass ran (`REPL/RedTeam/`), but this specific question does not appear to have been put to it. [INFERRED] |
| **`#62L`** — `LIQUID::UEV_Amount` defined, zero callers | **Open.** Exactly one occurrence in `12_LIQUID.pact`, the definition at `:472`. [V-cmd] | Deferred to the same red-team pass; the question (does `DPTF::C_Mint`/`TFT::C_Transfer` already enforce the same precision check via each token's own setting?) is unanswered. |
| **H14 `#19H`** — no live price oracle | **Open by design.** `01_U_CT.pact:364` returns a hardcoded `0.1`; the real oracle call is commented one line above. [V-read] | Blocked on an oracle existing. Now carries the additional, unrecorded question of whether `0.1` is still the right number after the KDA→STOA re-denomination. |
| **C3(weighted)-class residues** — n/a to this tree | — | — |

### Findings closed as DESIGN or NOT A BUG that a reader should still know about

- **C4** — `VST::C_Unreserve` can only be called by the token manager, never the reserver. This is
  correct *given* that Reserve/Unreserve is escrow-for-purchase rather than a symmetric lock, but it
  means a reserver has no unilateral exit. That is a trust assumption, not a bug, and it should be
  visible to anyone integrating against VST.
- **M3** — the gas station's allowlist matches by **string prefix**. Safe today because namespace
  deploy governance controls who can create a `TS`-prefixed module. It is safe by governance, not by
  construction.
- **H5** — a zero-amount leg aborts an entire multi-transfer batch, deliberately. Integrators who
  build batches programmatically need to filter their own zero legs.
- **M22 / M12 / M13 / C1** — four findings closed as "DPMF is permanently out of scope". DPMF is
  dead code by design, but it is *loadable* dead code sitting in the deploy order; the closure rests
  on the promise that it will never be upgraded.

### Fixes that are present in source but have no witness that would go red if reverted

This is the book's Rule 2 applied to this chapter, and it is where the DALOS tree is weakest. The
audit's proofs were built as `REPL/_scratch_*.repl` harnesses. **Six of them were later promoted to
gate entrypoints**, listed by name in `REPL/tools/_gate.py`'s `SCRATCH_PROOFS` and in
`REPL/regressions/MANIFEST.md`. [V-cmd] The rest were moved to `REPL/archive/`, a directory whose own
README states: *"Files here contain no assertions and are referenced by nothing… evidence of past
investigation, not tests."* [V-cmd]

Of the DALOS fixes, the following have **no assertion anywhere in the running suite** that would fail
if the fix were reverted. Each was checked by searching `REPL/Stage_01`, `REPL/Stage_02`,
`REPL/modules`, `REPL/RedTeam` and the gate's own entrypoint lists:

| fix | in source? | witness |
|---|---|---|
| **C3 `#3C`** — DPOF nonce-uniqueness on `C>DEBIT`/`C>TRANSFER`/`C>BULK-TRANSFER` | Yes, `06_DPOF.pact:908, 1046, 1080` [V-read] | **None found.** `UEV_IzUnique`'s message `"Unique Items Required"` is asserted in `RedTeam/[RT-H]_InputDomain.repl:121` and `Stage_01/[6.3]_SWP.repl:4467` — but both are *other* call sites (swap input ids, pool tokens). No test passes a duplicated **nonce** list to any of the three DPOF capabilities. [V-cmd] |
| **H3 `#8H`** — IGNIS `C_Collect` per-leg zero filter | Yes, `02_IGNIS.pact:1896-1901` [V-read] | **None found.** Zero occurrences of `IGNIS\|S>FREE` or any zero-priced-leg scenario in any `.repl` outside `archive/_scratch_ignis_h3_zeroleg.repl`, which is not run. [V-cmd] |
| **M5 `#29M`** — per-leg `dispo-data` recomputation | Yes, `09_TFT.pact:1797, 1867` [V-read] | **None for the staleness.** `modules/DPTF.repl` `<<DPTF-G7>>` pins the OURO dispo *floor* on a wipe — a different guard. No test builds a batch combining an EA-reducing leg with an overdraft leg. [V-cmd] |
| **M6 `#30M`** — `UR_Hibernation` as a pure getter | Yes, `05_DPTF.pact:1212` [V-read] | **Zero-assertion file.** `_scratch_dptf_m6_urhibernation_purefetch.repl` *is* a gate entrypoint, but `MANIFEST.md` records it as `0 +asserts / 0 -asserts`. It runs and proves nothing. [V-cmd] |
| **M7 `#31M`** — relocated Sleeping-LP enforce | Yes, `06_DPOF.pact:2038` [V-read] | **None, and the source says so**: *"UNPINNED"*. See §1.4(d). [V-read] |
| **N2** — `C_DeployAccount` ownership gate | Yes, `02_TS01-C1.pact:710` [V-read] | **Partial.** `modules/CONFORMANCE.repl` `<<CONF-01>>` asserts `DPTF::C_DeployAccount` is refused *from outside Talos* — that is `P\|UEV_IMC`, not the ownership gate. No test drives the Talos wrapper against an account the signer does not own. [V-cmd] |
| **M1 `#25M`** — `C_RotateStoa` ledger cleanup | Yes, `01_DALOS.pact:1874` [V-read] | **None found.** `UR_StoaLedger` has zero references in any `.repl`. [V-cmd] |

Conversely, the following **are** witnessed today, and this chapter names the assertion for each:
C2 (`<<DPOF-MCR>>`), H2 (`_scratch_udalos_h1_msdc.repl`, gated), H9 and M21 and `#75L`
(`<<UTIL-11>>`), H12 (`<<PYTHIA-PRICE>>`), M20 (`_scratch_ulst_m20_uev_izunique.repl`, gated), M18
and N3 (gated scratch proofs), H4 partially (`<<CONF-01>>` on a sibling).

`REPL/modules/PYTHIA.repl` states the general problem in its own header better than this chapter can:

> *"PYTHIA|A_UpdateDeployPrice and PYTHIA|A_UpdateRenamePrice existed ONLY in
> `_scratch_pythia_h12_price_wiring.repl` — a file the gate does not run. **The ledger counted them as
> exercised; nothing re-executed them.**"* [V-read]

That is the failure mode, stated by the repository about itself. The seven rows above are the
remainder of it.

### Two fixes whose target no longer exists

Neither is a regression, but both should be stated plainly rather than ticked as "fixed":

- **C5** and **H10** were fixes inside `2_Core/21_INFO-ONE+.pact`. That module was retired (commit
  `42fb75d`) and its function family rewritten. The current equivalents
  (`Z_Reads/02_INFO-ONE+.pact:1198`, `:2220`) do not contain the fixed lines because they no longer
  contain hand-assembled cost legs at all — they delegate to `URCi_*` readers. [V-read] The defect
  *class* is gone, which is a stronger outcome than the fix. But a reader auditing the audit would
  find the cited lines absent, and should know why.
- **H11** was *deferred*, not fixed, and is now moot for the same reason: the duplicate `ifp3`
  binding cannot exist in a function that makes one `URCi_ColdRecovery` call. [V-read]

### Corrections to the audit's own record

- The DALOS README's status tracker is accurate on every row this chapter re-checked. No
  discrepancies found between the tracker, `ISSUES-RANKED.md` and `ROUND-02-FIXES.md`. [V-cmd]
- The README's claim that `#56L` removed "two vestigial boilerplate items copied from the module
  sample template" is true for `07_ELITE.pact`. A `GOV|CollectiblesKey` defun referencing the same
  unrelated `"dpdc-keyset"` string still exists in `06_DPOF.pact:438`. [V-cmd] That is outside the
  finding's stated scope (which named ELITE), so it is not a broken fix — but it is the same
  template artefact, in a second module, unremoved.
