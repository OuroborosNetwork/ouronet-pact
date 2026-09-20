# HANDOFF — THE PATRON / EXECUTOR / EXECUTEE CANON SWEEP

> **Read this first after any compaction or context loss.** It is the complete plan: the canon,
> the tooling, the worklist, the protocol, and the reference implementation. Nothing else needs to
> be reconstructed from conversation.

**Status at time of writing (2026-09-20):** preparation complete, sweep NOT started.
**81 done · 719 remaining · 46 modules.**

---

## 1. THE CANON (owner rulings, 2026-09-20)

Authoritative copy: `OuronetInformational/StoicSyntax-Prefixes.md` §2.2. Summary:

Every `A_`, `AA_`, `C_`, `CC_` function takes these parameters, **in these positions**:

```
1st   patron      ALWAYS      the account that PAYS
2nd   executor    ALWAYS      the account that ACTS
3rd   executee    when it exists   the account the execution is BESTOWED UPON
```

**Position is canon, not just presence.** An executor sitting fourth is non-conforming. Pact
arguments are positional, so reordering a signature **rewrites every call site**.

### Ownership obligations

| role | enforcement |
|---|---|
| `patron` | **always, directly** — via the gas-collection path. For the gasless patron this is proven by a capability on the function, and *that same capability proves the admin gating* |
| `executor` | **always** — directly or indirectly. If indirect, **the path MUST be named in the `@doc`** |
| `executee` | **conditionally** — the conditions MUST be named in the `@doc` |

A transfer is the canonical three-role case:
`(C_Transfer patron sender receiver ...)` → patron / executor / executee, where the receiver needs
an ownership check **only when `method` is true AND it is a smart Ouronet account**.

### Talos is where the two paths diverge

| | module signature | Talos wrapper signature |
|---|---|---|
| `C_` | `(patron executor ...)` | passes the **caller's** patron — customness preserved |
| `A_` | `(patron executor ...)` | **no patron** — supplies `GASLESS-PATRON` itself |

An `A_` is gasless **because its ordinary collection is served by the one account
`IGNIS::C_Collect` exempts** — not because collection is skipped. The path is preserved.
**Consequence:** the permissions the gasless patron needs must be granted **in Talos**.

### `P|` IS EXEMPT

`P|A_Define`, `P|A_Add`, `P|A_AddIMP`, … — **126 functions, leave exactly as they are.** They are
deploy-time setup and inter-module-guard registration with admin characteristics, not client
functions. The `P|` denomination exists to signal precisely this.

---

## 2. REFERENCE IMPLEMENTATION (already committed — copy this shape)

`ATS|A_KickStart`, the owner's own example. `kickstarter` was the executor under a bespoke name.

```pact
;; CORE — 1_SOVEREIGN/STAGE_01/2_Core/10_ATSU.pact
(defun A_KickStart (patron:string executor:string ats:string rt-amounts:[decimal] ...))

;; TALOS — 1_SOVEREIGN/STAGE_01/3_Talos/01_TS01-A.pact
(defun ATS|A_KickStart (executor:string ats:string rt-amounts:[decimal] ...)
    (ref-IGNIS::C_Collect GASLESS-PATRON
        (ref-ATSU::A_KickStart GASLESS-PATRON executor ats rt-amounts ...)))
```

`GASLESS-PATRON` is already `(defconst GASLESS-PATRON (URC_Gassless))` in `01_TS01-A.pact:260`,
and `IGNIS::C_Collect` already exempts it (`iz-gassles-patron`, `02_IGNIS.pact:1868`).

---

## 3. TOOLING

| tool | job |
|---|---|
| `REPL/tools/_executorplan.py` | **the worklist.** Classifies every entrypoint DONE / RENAME / ADD / PATRON. `--module F.pact`, `--state RENAME` |
| `REPL/tools/_executormigrate.py` | **call-site migration.** PARSES rather than regexes; rule table per function; `--apply` required |
| `REPL/tools/_authsurface.py` | **the safety net.** Gate-fatal; fails if any entrypoint's ownership set shrinks |
| `REPL/tools/_bandplan.py` | superseded for scoping — **its filter was blind to all Talos** (see below) |

### Classification, and why RENAME vs ADD cannot be guessed

- **RENAME (115)** — 2nd param is an ACCOUNT under a bespoke name: `account` 53, `owner-konto` 13,
  `client` 10, `injector` 8, `beneficiary-id` 5, `recoverer` 4, `owner-account` 3, and singles
  including `kickstarter`, `curler`, `coiler`, `fueler`, `coiler-vester`, `curler-vester`.
- **ADD (322)** — 2nd param is an ENTITY id (`id`, `ats`, `swpair`, `pool-id`, `fvt-id`). There is
  **no executor at all**; it is derived inside a capability. **Assuming "2nd param = executor"
  is wrong for these 322.**
- **PATRON (282)** — first parameter is not `patron`.

### The bug that made the first attempt wrong

`_bandplan.py` used `re.match(r'^(A|AA|C|CC)_|\|(A|AA|C|CC)_', n)`. `re.match` anchors the WHOLE
pattern at position 0, so the second alternative could only fire on a name starting with a bar.
**Every Talos entrypoint was invisible.** It reported **89** entrypoints against an actual **482**
— and Talos is the only client-facing path in the system. The first day of this refactor was
scoped, sequenced and reported against that number. Found by the owner reading `TS01-C1`, not by
the tooling.

---

## 4. THE WORKLIST — 46 modules, 719 functions, smallest first

R = rename · A = add executor · P = add patron

| # | module | R | A | P | total | interface(s) to update |
|---|---|---:|---:|---:|---:|---|
| 1 | `04_DPDC-I.pact` | 0 | 1 | 0 | **1** | `DpdcIssueV2` |
| 2 | `07_MTX-AQP.pact` | 1 | 0 | 0 | **1** | `AqpMtxV1` |
| 3 | `16_SWPI.pact` | 0 | 0 | 1 | **1** | — |
| 4 | `01_ANK.pact` | 0 | 0 | 2 | **2** | `AcquisitionAnchorsV1` |
| 5 | `02_DPDC.pact` | 0 | 1 | 1 | **2** | `BrandingUsageTertiaryV2` |
| 6 | `03_AQP.pact` | 2 | 0 | 0 | **2** | `AcquisitionPoolsV1` |
| 7 | `03_DPDC-C.pact` | 0 | 0 | 2 | **2** | `DpdcCreateV2` |
| 8 | `04_BRD.pact` | 0 | 0 | 2 | **2** | `BrandingV2` |
| 9 | `11_EQUITY+.pact` | 1 | 0 | 1 | **2** | `EquityV2` |
| 10 | `06_VCT.pact` | 0 | 0 | 3 | **3** | `AcquisitionVacateV1` |
| 11 | `07_DPDC-T.pact` | 1 | 0 | 3 | **4** | `DpdcTransferV2` |
| 12 | `08_DSA.pact` | 0 | 2 | 2 | **4** | `DsaV1` |
| 13 | `09_DPDC-F.pact` | 0 | 0 | 4 | **4** | `DpdcFragmentsV2` |
| 14 | `19_SWPU.pact` | 0 | 0 | 4 | **4** | `SwapperUsageV3` |
| 15 | `09_TFT.pact` | 0 | 0 | 5 | **5** | `TrueFungibleTransferV2` |
| 16 | `12_LIQUID.pact` | 0 | 0 | 5 | **5** | `StoaLiquidStakingV2` |
| 17 | `13_OUROBOROS.pact` | 0 | 0 | 5 | **5** | `OuroborosV2` |
| 18 | `21_CODEX.pact` | 0 | 0 | 5 | **5** | `CodexV2` |
| 19 | `02_IGNIS.pact` | 0 | 1 | 5 | **6** | `IgnisCollectorV3` |
| 20 | `05_TS01-P.pact` | 8 | 0 | 0 | **8** | `TalosStageOne_ClientPactsV4` |
| 21 | `10_DPDC-N.pact` | 0 | 0 | 8 | **8** | `DpdcNonceV2` |
| 22 | `05_FVT.pact` | 4 | 2 | 3 | **9** | `AcquisitionFarmsVaultsTreasuriesV1` |
| 23 | `22_PYTHIA.pact` | 0 | 0 | 9 | **9** | `PythiaLedgerV3`, `PythiaV5` |
| 24 | `00_Demipad.pact` | 2 | 2 | 6 | **10** | `DemiourgosLaunchpadV2` |
| 25 | `08_DPDC-S.pact` | 0 | 0 | 10 | **10** | `DpdcSetsV2` |
| 26 | `18_SWPLC.pact` | 0 | 1 | 9 | **10** | `BrandingUsageSecondaryV2`, `SwapperLiquidityClientV2` |
| 27 | `05_DPDC-R.pact` | 0 | 0 | 11 | **11** | `DpdcRolesV2` |
| 28 | `06_DPDC-MNG.pact` | 0 | 0 | 12 | **12** | `DpdcManagementV2` |
| 29 | `02_SCORE.pact` | 6 | 0 | 8 | **14** | `AcquisitionScoresV1` |
| 30 | `05_TS02-DPAD.pact` | 8 | 6 | 0 | **14** | `TalosStageTwo_DemiPadV1` |
| 31 | `06_TS01-C4.pact` | 1 | 12 | 1 | **14** | `TalosStageOne_ClientFourV8` |
| 32 | `10_ATSU.pact` | 0 | 0 | 14 | **14** | `AutostakeUsageV2` |
| 33 | `00_DPMF.pact` | 0 | 1 | 16 | **17** | `DemiourgosPactMetaFungibleV7` |
| 34 | `01_DALOS.pact` | 0 | 0 | 18 | **18** | `OuronetDalosV2`, `OuronetPolicyV2` |
| 35 | `15_SWP.pact` | 0 | 4 | 14 | **18** | `SwapperV4` |
| 36 | `06_DPOF.pact` | 0 | 1 | 20 | **21** | `DemiourgosPactOrtoFungibleV2`, `DpofUdcV2` |
| 37 | `05_DPTF.pact` | 0 | 2 | 22 | **24** | `BrandingUsagePrimaryV2`, `DemiourgosPactTrueFungibleV2` |
| 38 | `08_ATS.pact` | 0 | 3 | 21 | **24** | `AutostakeV3` |
| 39 | `01_TS01-A.pact` | 0 | 27 | 0 | **27** | `TalosStageOne_AdminV2` |
| 40 | `11_VST.pact` | 0 | 5 | 24 | **29** | `VestingV2` |
| 41 | `04_TS01-C3.pact` | 18 | 15 | 1 | **34** | `TalosStageOne_ClientThreeV4` |
| 42 | `04_TS02-C3.pact` | 15 | 27 | 0 | **42** | `TalosStageTwo_ClientThreeV1` |
| 43 | `02_TS02-C2.pact` | 9 | 50 | 0 | **59** | `TalosStageTwo_ClientTwoV2` |
| 44 | `02_TS01-C1.pact` | 10 | 49 | 2 | **61** | `TalosStageOne_ClientOneV2` |
| 45 | `01_TS02-C1.pact` | 11 | 54 | 0 | **65** | `TalosStageTwo_ClientOneV2` |
| 46 | `03_TS01-C2.pact` | 18 | 56 | 3 | **77** | `TalosStageOne_ClientTwoV2` |

**Interfaces get CONTENT updates, not necessarily VERSION bumps** — most are already ahead of
mainnet. This is what dissolved the "48-interface cascade" that blocked the first attempt.

---

## 5. PROTOCOL — one module at a time

Per module, in order:

1. `python3 REPL/tools/_executorplan.py --module <F>.pact` — the list.
2. Edit the **core module**: signatures (interface declaration **and** module defun), capability
   signatures, and bodies. `patron` 1st, `executor` 2nd, `executee` 3rd.
3. Edit the **interface** content to match. No version bump unless the owner says so.
4. Edit the **Talos wrapper(s)**: `C_` passes the caller's patron; `A_` drops patron and supplies
   `GASLESS-PATRON`.
5. Add a rule to `_executormigrate.py`, run `--apply` for the call sites.
6. `python3 REPL/tools/_deploybundle.py --write`.
7. `python3 REPL/tools/_authsurface.py --check` — must report *no entrypoint weakened*.
8. Full gate: `python3 REPL/tools/_gate.py`. Artefact chain if it complains:
   `_suite_stats.py` → `_figuresync.py --write` → `_auditbook.py --docx`.
9. **Commit per module.**
10. **Report to the owner**: *"processed module X, modified these functions, N in total, done,
    moving to next."*

### Rules that cost time when ignored
- **Never replace a derived ownership gate** — add the executor check *beside* it.
- **`executor = patron` is not a safe default.** Sovereign assets are owned by **smart accounts**
  (`Σ.` prefix); the human patron is usually the wrong answer.
- **Never read an owner eagerly in a `let`** — the entity may not exist yet, and in negative
  probes the read raises and replaces the refusal being asserted.
- **Negative probes keep plain accounts** — they must fail on the guard under test, not on arity.
- Where a guard is added, add a test that **fails without it**. A guard nothing ever fails on is
  indistinguishable from an absent one.

---

## 6. SURFACE TO THE OWNER, DO NOT DECIDE ALONE

- **Gasless-patron permissions in Talos.** If `P|ADMINISTRATIVE-SUMMONER` does not satisfy a
  collection path, show what is missing rather than invent a capability.
- **Where `executee` exists.** Clear for transfers. Elsewhere, check the body before promoting a
  parameter to 3rd — the RENAME/ADD split already proved position alone is wrong 322 times.
- **Functions that are permissionless by design** (`C_RecomputeCapture`, `C_Sync*Anchors`) or
  guard-based (`C_OracleWrite`) — a decorative executor is worse than none; it reads as a check.

---

## 7. RESUMING COLD

```bash
python3 REPL/tools/_executorplan.py          # what is left, by module
git log --oneline | head -20                 # what was done, one commit per module
```
The worklist table above is the plan; the tool is the ground truth. If they disagree, **the tool
is right and this table is stale** — regenerate it.
