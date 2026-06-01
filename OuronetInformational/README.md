# OuronetInformational

Persistent notes about **Ouronet** for humans and for AI assistants in **new chat sessions** (after this conversation ends).

## How to use (next session)

1. Read **`CONTEXT.md`** first — consolidated facts, terminology, and project shape.
2. Read **`MODULE_ARCHITECTURE.md`** when touching sovereign modules — prefixes (UC/UR/URC/UEV/UDC/CAP, A_/C_/X*), capabilities C1–C4, Talos vs core, policies.
3. For **what exists in the repo** (modules, interfaces, REPL, whitepaper outline), skim **`ARCHITECTURE/README.md`**.
4. Skim **`memories/`** — chronological or topical snippets from past conversations.
5. Check **`skills/`** — reusable “how we work on Ouronet” procedures (optional).
6. Check **`agents/`** — high-level agent / workflow hints for this repo (optional).

## Conventions

- Prefer updating **`CONTEXT.md`** when something is stable and should stay true long term.
- If you say “add this to your skills,” persist it inside **`OuronetInformational/`** (usually `CONTEXT.md`, `MODULE_ARCHITECTURE.md`, or a dated note in `memories/`).
- Use **`memories/`** for dated conversation captures, decisions with context, or “we said X on date Y.”
- When a procedure becomes repeatable, consider a short file under **`skills/`** (or a Cursor skill under `.cursor/skills` that points here).

## Maintenance

Whoever learns something new in chat with the AI should ask it to **append or edit these files** so the next session does not start from zero.

## Quick REPL pointers

- **Stage 0:** `REPL/Stage00_Sanboxes.repl` (Kadena + Stoa sandboxes), then **`REPL/Stage00a_StoaTests.repl`** (Stoa `coin` tests, same file)
- **Full chain load:** `REPL/Z.repl`
- **Stage 2 smoke / AQP:** `REPL/Stage02_Tester.repl` loads **`AQP-BOOT`** then **`[6.2]_AQP.repl`** — resume notes (boot steps, fee splits, **tx order** for score definitions) are in **`ARCHITECTURE/REPL_AND_TESTS.md`** § *Stage 2 AQP + AQP-BOOT*
- **Ouronet test namespace:** `ouronet-ns` (not `free`)
- **Integration test `.repl` layout** (mandatory for new suites): **`ARCHITECTURE/REPL_AND_TESTS.md`** and **`skills/repl-integration-test-layout.md`**
