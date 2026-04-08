# Agents — Ouronet repo

High-level guidance for automated or semi-automated helpers working in this repository.

## Before changing code

- Read `OuronetInformational/CONTEXT.md`.
- For a map of existing modules/interfaces/REPL, see `OuronetInformational/ARCHITECTURE/README.md`.
- When editing sovereign **core** or **Talos** modules, read `OuronetInformational/MODULE_ARCHITECTURE.md` (prefixes UC/UR/…, C1–C4 caps, policies, Talos wiring).
- Follow existing Pact indentation/style exactly; optimize for human readability and avoid unrelated formatting churn.
- REPL Stage 0: **`Stage00_Sanboxes.repl`** (Kadena `kadena-coin`, then Stoa `coin` + namespaces), then **`Stage00a_StoaTests.repl`** (Stoa `coin` tests in one file). Ouronet module tests use **`ouronet-ns`**, not `free`.
- Respect existing patterns in the codebase; prefer minimal, focused diffs.

## After learning something important

- Update `OuronetInformational/CONTEXT.md` and/or add a note under `OuronetInformational/memories/`.

*(Customize this file as Ouronet workflows become clear.)*
