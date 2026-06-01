---
name: ouronet-repl-integration-tests
description: Canonical layout for Ouronet integration REPLs (begin-tx suites). Use when adding or restructuring REPL/Stage_*/*.repl test files.
---

Read and follow:

1. **`OuronetInformational/skills/repl-integration-test-layout.md`** — checklist.
2. **`OuronetInformational/ARCHITECTURE/REPL_AND_TESTS.md`** — full § *Canonical layout for integration test `.repl` files*; § *Stage 1 CODEX* for CODEX harness.
3. Reference **`REPL/Stage_02/[6.2.1]_AQP-ANK.repl`**, **`REPL/Stage_02/[6.2.2]_AQP-SCORE.repl`**, **`REPL/Stage_01/[6.9]_CODEX.repl`**.

Non-negotiables: **`;;|| NEXT >`** between txs; **`;;==== TX… · mm ·`** + next-line **`(print "--- [TX… · mm · …] ---")`** per group; **`(map print [ (expect …) … ])`** for assertion visibility; file header (**`FILE`**, legend, source, REPL-tests lines); **commas in `env-data`** objects.
