# REPL harness and test scenarios

REPL files under **`REPL/`** load sovereign modules in order and run scripted transactions. **They are not** a substitute for on-chain deploy checks; they are a **local harness** for integration smoke tests.

## Canonical layout for integration test `.repl` files (required for new work)

**All new or heavily refactored** integration REPLs (those using **`begin-tx`** / **`commit-tx`** with grouped steps) **must** follow the same model as **`REPL/Stage_02/[6.2.1]_AQP-ANK.repl`** and **`REPL/Stage_02/[6.2.2]_AQP-SCORE.repl`**. Short checklist: **`OuronetInformational/skills/repl-integration-test-layout.md`**.

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

## Top-level loaders

| File | Role |
|------|------|
| `Z.repl` | Full pipeline: Stage 00 sandboxes → Stage 00a Stoa tests → Stage 01 → Stage 02 → Stage ZZ (DPL-UR deploy only) |
| `Stage01_Tester.repl` | Stage 1 deployment + scenario blocks (6.1–6.8) |
| `Stage02_Tester.repl` | Stage 2 deployment + selected scenarios |
| `StageZZ_Tester.repl` | Deploy **`2_SLAVE/Stage_Z/01_DPL-UR.pact`** only (`load` path relative to `REPL/`) |

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
| `[5.1]_Aoz+.repl`, `[5.2]_Dispenser+.repl` | Slave modules |
| `[6.1]_Cumulator.repl` … `[6.8]_Dispenser.repl` | Long scenario suites (SWP, DPTF, ATS, VST, DPOF, dispenser, etc.) |

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
- **`StageZZ_Tester.repl`** load path for DPL-UR must be **`../2_SLAVE/...`** when CWD is `REPL/` (not `../../`).
