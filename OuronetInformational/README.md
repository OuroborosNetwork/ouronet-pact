# OuronetInformational

Persistent notes about **Ouronet** for humans and for AI assistants. **Everything durable lives in this folder** — Cursor `.cursor/skills/ouronet-*` files are thin pointers here so knowledge survives machine changes.

## How to use

1. **`INDEX.md`** — full map (pact / ouronet / modules / kursan)
2. **`CONTEXT.md`** — terminology and project shape
3. **`ouronet/MODULE_ARCHITECTURE.md`** — sovereign module prefixes, caps, Talos, UR/W layers
4. **`ouronet/architecture/README.md`** — repo inventories, REPL, deploy docs
5. **`memories/`** — dated decision notes

## Layout

| Path | Role |
|------|------|
| **`pact/`** | Pact language (enforce, defcap order, interfaces) |
| **`ouronet/conventions/`** | Cross-cutting Ouronet coding rules |
| **`ouronet/architecture/`** | Stage inventories, REPL spec, deploy |
| **`modules/aqp/`** | AQP-specific (score links, stake, vacate, TFT) |
| **`modules/stage01/`** | Stage 01 (CODEX REPL, etc.) |
| **`modules/deploy/`** | Deploy handoff, INFO-ONE pairing |
| **`kursan/`** | Agent persona; scratch REPL policy → **`REPL/Kursan/`** |

## Conventions

- Update **`OuronetInformational/`** first when learning something stable.
- Integration REPLs: **`REPL/Stage_*`**. Scratch probes: **`REPL/Kursan/`** only.
- Legacy **`skills/`** folder — see redirect **`skills/README.md`**.

## Quick REPL pointers

- **Stage 0:** `REPL/Stage00_Sanboxes.repl`, `REPL/Stage00a_StoaTests.repl`
- **Full chain:** `REPL/Z.repl`
- **Stage 2 AQP:** `REPL/Stage02_Tester.repl` — see **`ouronet/architecture/REPL_AND_TESTS.md`**
- **Namespace:** `ouronet-ns`
