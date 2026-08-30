# REPL harness and test scenarios

REPL files under **`REPL/`** load sovereign modules in order and run scripted transactions. **They are not** a substitute for on-chain deploy checks; they are a **local harness** for integration smoke tests.

## Canonical layout for integration test `.repl` files (required for new work)

**All new or heavily refactored** integration REPLs (those using **`begin-tx`** / **`commit-tx`** with grouped steps) **must** follow the same model as **`REPL/Stage_02/[6.2.1]_AQP-ANK.repl`** and **`REPL/Stage_02/[6.2.2]_AQP-SCORE.repl`**. Short checklist: **`OuronetInformational/ouronet/conventions/repl-integration-test-layout.md`**.

### Inter-transaction separators

Between transactions, use the **three-line** `;;|| NEXT >` block (same as **`REPL/Stage_01/[2.2]_Core.repl`**), optionally wrapped in blank **`(print "")`** lines.

### Intra-transaction groups (`mm` index)

Inside each **`begin-tx`**:

1. Pair every **`;;==== TX… · mm · <slug> ====**` comment with a **banner** on the **very next line**: **`(print "--- [TX… · mm · …] ---")`** so logs and source stay aligned. **`mm`** is **`01`**, **`02`**, … **per transaction** (reset each **`begin-tx`**).
2. Transaction id in logs: **`TX001`**, **`TX004`**, or **`TX-SCORE-01`** style as appropriate; keep **one numbering stream per `begin-tx`**.

### Assertions and visibility

- Use **`(expect (format "…" [vals]) expected actual)`** and **`(expect-failure (format "…" [vals]) expr)`** with a **single** **`format`** for the doc string (no nested **`format`** wrapping the whole **`expect`**).
- Because **`expect`** / **`expect-failure`** return **strings**, wrap batches in **`(map print [ (expect …) … ])`** so the REPL prints **each** result line.

### File header

Include **`FILE`**, **Legend** (what **`<<…>>`**, **`<(Talos…>`**, **`<(Module|UR_…>`**, **`<(REPL|env-gas)>`** mean), **Source** line, and **REPL tests** line (see ANK/SCORE REPLs).

### `map print` return values

**`(map print xs)`** returns **`[() () …]`** (length = **`(length xs)`**). The **`let`** body’s **last** form is what the REPL echoes; place **`map print`** accordingly or end with a neutral form if a long bracket line is undesirable.

### Bulk maintenance

For mechanical alignment (legacy **`;;>>>>>>>>…`** → **`;;|| NEXT >`**, **`FILE`** / legend preamble when missing, and **intra-`begin-tx`** **`mm`** banners), use:

- **`REPL/_normalize_repl_layout.py`** (run from repo root: **`python3 REPL/_normalize_repl_layout.py`**) — preamble, **`NEXT`** between **`commit-tx`** / **`begin-tx`**, then **subdivision** (see below). It skips **`Stage_02/[6.2.1]_AQP-ANK.repl`** and **`Stage_02/[6.2.2]_AQP-SCORE.repl`** (those are the hand-maintained reference layouts).
- **`REPL/_subdivide_repl.py`** — same **`mm`** insertion logic **alone** (strips obsolete pre-**`begin-tx`** **`· 01 · (group)`** pairs, inserts **`01`/`02`/`03`** inside each **`(begin-tx …) … (commit-tx)`** at fixed anchors: **`env-sigs`** / chain / namespace / gas model, **`let`** / **`load`**, first gas **`format "<<<<<<<"`** echo). Run: **`python3 REPL/_subdivide_repl.py`**. Skips the same two reference REPLs.

Automated subdivision is a **baseline**; refine slugs or add **`04`**, … by hand where a transaction has more phases than those anchors cover.

---

## Stage 2 AQP + AQP-BOOT (resume / handoff)

Use this section when continuing **Stage 02** integration work on another machine or in a new chat. It records **load order**, **transaction ordering constraints**, and **fee-split expectations** that are easy to break when refactoring REPLs.

### Citizen module: `2_CITIZEN/Stage_02/04_AQP-BOOT.pact`

**Handoff guide (mainnet operator + REPL):** [2_CITIZEN/Stage_02/README_AQP_BOOT.md](../../2_CITIZEN/Stage_02/README_AQP_BOOT.md) — id chain table, `NEXT=` fields in return strings, collection id inputs vs `UDC_Makeid` outputs.

**`AQP-BOOT`** implements **`AcquisitionPoolBootV1`**: discrete bootstrap steps **`C_Step1`** … **`C_Step7`**. Live deploy uses these instead of a monolithic “bootstrap everything” call. **Each step returns a formatted string** — copy ids from the tx result into the next step's arguments when running separate mainnet transactions.

- **Step 1** — `C_Step1_CreateBunnySet` (KBN bunny set).

- **Step 2** — `C_Step2_CreateSnakePowerAnchorClasses` (Bronze/Silver/Golden SnakePower + related NF anchors).

- **Step 3** — `C_Step3_CreateBoosterAnchorClasses` (Unity/Stoa/Vesta booster anchors).

- **Step 4** — `C_Step4_CreateCoreScores` (includes **TheCodingDivision** and other core score rows in **`SCR|T|Score`**).

- **Step 5** — `C_Step5_CreateSubsidiaryScores` (includes **SubsidiaryWonderCoach**, **SubsidiaryBunnies**, etc.).

- **Step 6** — `C_Step6_CreateOuroLpTriplet` — LP triplet **scores only** (no pool or farm wiring); pass **`lp-denominator`** as the **full native DPTF id** of the common pool leg (e.g. **`"OURO-98c486052a51"`**), not the ticker alone — SCORE validates via `DPTF::UEV_id` at class-0 issue.

- **Step 7** — `C_Step7_CreatePoolsAndScores`: six DH pools (**class 3 DPSF** or **class 4 DPNF** by entity) + score slots from Steps 4–5, one **class-0** LP pool + Step 6 triplet. Pass explicit `dh-asset-ids`, `dh-pool-ids`, and score id lists (see `;;` block in `04_AQP-BOOT.pact`). FVT links pending. See **`README.md`** Phase E for the pool map and REPL example ids (`DHCD-…`, `DHB-…`, etc.).

### Multi-LP OURO farm (architecture)

One Farm FVT aggregates many OURO LPs via **many `FVT|T|ScoreLink` rows** (typically **3 per LP** when using the Step 6 triplet). Each LP still gets its **own** class-0 pool and **new** score issuances (`aqpool-link` is one-time per score). Liquidity sync on the hot path is **per pool** (≤ 7 scores), not O(all farm members). Detail: **`README_FVT.md`** § Multi-LP farms.

### Loading `AQP-BOOT` in the REPL

**`REPL/Stage02_Tester.repl`** loads **`04_AQP-BOOT.pact`** inside a deploy-style block: **`begin-tx`** → **`(namespace "ouronet-ns")`** → **`env-sigs`** → **`load "../2_CITIZEN/Stage_02/04_AQP-BOOT.pact"`** → **`commit-tx`**, **before** **`[6.2]_AQP.repl`**. If **`AQP-BOOT`** loads only from a leaf REPL without that namespace/context, lookups like **`OuronetDalosV1`** can fail.

### `[6.2.1]_AQP-ANK.repl` (anchors)

Typical **end-of-file** order: mock / strip tests → read-only echo (**`TX005`**) → **AQP-BOOT anchor steps** last:

| Transaction | Role |
|-------------|------|
| **`TX006`** | **`C_Step2_CreateSnakePowerAnchorClasses`** — STOA fee split **`7 × UR_UsagePrice "standard"`** (four **`coin.TRANSFER`** caps). |
| **`TX007`** | **`C_Step3_CreateBoosterAnchorClasses`** — STOA split **`14 × standard`**. |

Rationale: match **real issuance counts** per step so payer caps stay sufficient (**`URC_SplitKDAPrices`** scales with **`acnoi=true`** anchor issuances).

### `[6.2.2]_AQP-SCORE.repl` (scores)

**Boot-style score steps are placed at the end of the scripted block** (after early **`TX-SCORE-01`** / **`02`** probes and **`TX-SCORE-07`** read-only echo), so STOA/IGNIS behaviour stays aligned with “mocks first, provisioning last.”

| Transaction | Role |
|-------------|------|
| **`TX-SCORE-08`** | **`C_Step4_CreateCoreScores`** — **`4 × smart`** fee split for four score issuances. |
| **`TX-SCORE-09`** | **`C_Step5_CreateSubsidiaryScores`** — **`5 × smart`**. |
| **`TX-SCORE-10`** | **`C_Step6_CreateOuroLpTriplet`** — **`3 × smart`**; boost-class ids from **`U|DALOS::UDC_Makeid`** for Silver/Bronze/Golden snake powers. |
| **`TX-SCORE-11`** | **Score definition vectors** (`C_IssueSemiFungibleScoreDefinition`, `C_IssueNonFungibleScoreDefinition` for boot score ids such as **TheCodingDivision**, **SubsidiaryWonderCoach**, **SubsidiaryBunnies**) — **must run only after Steps 4–5 (and Step 6 if LP-related)**. |

#### Critical dependency: score definitions after boot rows exist

**`C_IssueSemiFungibleScoreDefinition`** (via Talos into **`AQP-SCORE`**) calls utilities such as **`UR_SCR|ScoreOwnerKonto`**, which **`read`** **`SCR|T|Score`** for the **score-id**. If a REPL block issues definitions **before** **`C_Step4`** / **`C_Step5`** create those rows, Pact fails with:

**`No value found in table … SCR|T|Score for key: <score-id>`**

So: **never** place “definition vector” transactions **before** **`TX-SCORE-08`** / **`09`** (the historical mistake was a **`TX-SCORE-06`**-style block running before Step 4).

**`TX-SCORE-01`** uses **`BootPhaseProbe`** so reserved names do not collide with boot-issued score names (e.g. **TheCodingDivision**) in the same chain.

### Fee vocabulary (short)

- **STOA / anchor issuance (ANK):** fee tier **`"standard"`**; multiply **`UR_UsagePrice "standard"`** by the number of paid anchor issuances in that step (**`URC_SplitKDAPrices`**) and attach the usual **four** **`coin.TRANSFER`** caps to the gas payer key.

- **Score issuance (SCORE):** **`"smart"`**; multiply by the number of **`C_Issue*Score`** calls in that transaction (**4× / 5× / 3×** for Steps 4–6 in the current REPL).

---

## Top-level loaders

| File | Role |
|------|------|
| `Z.repl` | Full pipeline: Stage 00 sandboxes → Stage 00a Stoa tests → Stage 01 → Stage 02 → Stage ZZ (DPL-UR deploy only) |
| `Stage01_Tester.repl` | Stage 1 deployment + scenario blocks (6.1–6.8) |
| `Stage02_Tester.repl` | Stage 2 deployment + selected scenarios |
| `StageZZ_Tester.repl` | Deploy **`2_CITIZEN/Stage_Z/01_DPL-UR.pact`** only (`load` path relative to `REPL/`) |

## Stage 0

| File | Role |
|------|------|
| `Stage00_Sanboxes.repl` | Kadena sandbox + Stoa sandbox bootstrap |
| `Stage00a_StoaTests.repl` | Stoa `coin` regression tests |

## Stage 1 — representative REPL files

| File | Role |
|------|------|
| `[0.0]_Starter.repl` | Starter keys / env |
| `[0.1]_Interfaces.repl` | Load Stage 1 interfaces |
| `[1]_Utilities.repl` | Load utilities |
| `[2.1]_Dalos.repl`, `[2.2]_Core.repl` | Core deploy |
| `[3]_Talos.repl` | Talos deploy |
| `[4.0]_Sovereign-Executor.repl` | Sovereign executor txs |
| `[5.1]_Aoz+.repl`, `[5.2]_Dispenser+.repl` | Citizen modules |
| `[6.1]_Cumulator.repl` … `[6.8]_Dispenser.repl` | Long scenario suites (SWP, DPTF, ATS, VST, DPOF, dispenser, etc.) |
| `[6.9]_CODEX.repl` | **CODEX** via **TS01-C4** (A_ / C_); see § *Stage 1 CODEX* below |

---

## Stage 1 CODEX (resume / handoff)

**Modules:** **`22_CODEX.pact`**, Talos **`06_TS01-C4.pact`**. Scenario REPL: **`REPL/Stage_01/[6.9]_CODEX.repl`**.

### Deploy order

1. **`[2.2]_Core.repl`** — **CODEX** (TX-15) only; **do not** deploy **TS01-C4** here (needs **TS01-A**).
2. **`[3]_Talos.repl`** — **TS01-A** … **TS01-C4** (TX-03b) after **CODEX** exists.
3. **`[4.0]_Sovereign-Executor.repl`** — **`P|A_Define`**, **`DALOS|A_UpdateUsagePrice "codex"`**.

Detail: **`OuronetInformational/ouronet/conventions/module-load-order-and-pact-refs.md`**, **`OuronetInformational/modules/stage01/codex-repl.md`**. Cursor: **`OuronetInformational/ouronet/conventions/module-load-order-and-pact-refs.md`**.

### Common failures

| Symptom | Fix |
|---------|-----|
| **`Cannot find module: TS01-A`** at **TS01-C4** load | Deploy **TS01-C4** in **`[3]_Talos`**, not Core |
| **`Expected: ['}']`** in **`[6.9]_CODEX`** TX000 | Commas in **`env-data`** object |
| **`Keyset failure … PK_Flore…`** on rotate | Use **`PK_Florean`** in **`env-sigs`**, not **`PK_Florian`** |
| **`closure to too many arguments`** on StoicTag / Apollo check | **`fold (and) true`** in **`U|ATS`** / **`U|DALOS`**; reload utilities |

---

## Stage 2 — representative REPL files

| File | Role |
|------|------|
| `[0.1]_Interfaces.repl` | Stage 2 interfaces |
| `[2.1]_DpdcCore.repl` | DPDC family load order |
| `[2.2]_DemiPad.repl` | DemiPad + satellites |
| `[2.3]_EarningPools.repl` | AQP-related |
| `[3]_Talos.repl` | Stage 2 Talos |
| `[4.0]_Sovereign-Executor.repl` | Stage 2 executor |
| `[5.1]`–`[5.4]_Populate*.repl` | Population scenarios |
| `[5.3]_Launchpad.repl` | Launchpad |
| `[6.1]_DPDC.repl`, `[6.2]_AQP.repl`, `[6.3]_STOAICO.repl` | Feature scenarios |

## Notes for documentation

- DPL-UR-dependent reads may be **commented** in some REPLs when DPL-UR is not loaded in that chain.
- **`StageZZ_Tester.repl`** load path for DPL-UR must be **`../2_CITIZEN/...`** when CWD is `REPL/` (not `../../`).
