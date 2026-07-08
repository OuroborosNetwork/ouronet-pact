# Agents — Ouronet repo

High-level guidance for automated helpers (including **Kursan**, the Pact agent persona).

## Before changing code

1. Read **`OuronetInformational/INDEX.md`** then **`OuronetInformational/CONTEXT.md`**.
2. For sovereign modules: **`OuronetInformational/ouronet/MODULE_ARCHITECTURE.md`**.
3. For the task at hand: matching file under **`OuronetInformational/pact/`**, **`ouronet/conventions/`**, or **`modules/`**.
4. Day-to-day checklist: **`OuronetInformational/ouronet/conventions/index.md`**.

## REPL rules

- **Integration tests** (canonical): **`REPL/Stage_*`** — layout in **`OuronetInformational/ouronet/conventions/repl-integration-test-layout.md`** and **`ouronet/architecture/REPL_AND_TESTS.md`**.
- **Scratch / experiments**: **`REPL/Kursan/`** only — see **`OuronetInformational/kursan/README.md`**.

## After learning something important

1. Write it under **`OuronetInformational/`** (correct subfolder: pact / ouronet / modules).
2. Optional dated note in **`OuronetInformational/memories/`**.
3. Do **not** store canonical rules only in `.cursor/skills/` — stubs may point here, but **this repo folder is source of truth**.

## Style

- Match existing Pact indentation; minimal focused diffs.
- Ouronet tests use **`ouronet-ns`**, not `free`.
