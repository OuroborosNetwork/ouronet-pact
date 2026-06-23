---
name: ouronet-pact-conventions
description: Ouronet Pact coding conventions — let ref;;var layout, UR owns with-default-read / XI uses UR+write, no keys/select outside URD, defcap body order, smart-account GOV vs RemoteGov, P|A_Define IMP. Use when writing or reviewing sovereign AQP/core Pact modules.
---

# Ouronet Pact conventions (index)

Read **`OuronetInformational/`** for full architecture; this skill is the agent checklist for day-to-day edits.

## Quick rules

| Topic | Rule |
|-------|------|
| **`let` bindings** | All **`ref-*:module{…}`** first → **`;;`** → variables. Detail: **`OuronetInformational/skills/let-binding-layout.md`** |
| **Reads** | Domain table **`read`** / **`with-default-read`** only in **`UR_*`**. **`XI_*`** calls **`UR_*`**, never reads tables directly. Detail: **`OuronetInformational/skills/ur-with-default-read-and-xi-write.md`** |
| **Writes** | **`XI_*`**: compute from **`UR_*`**, then **`write`** (avoid **`keys`** + insert/update split). |
| **Scans** | **`keys`**, **`select`** only in **`URD_*`** (or explicit scan helpers), nowhere else. |
| **`defcap` body** | **`let`** → outside **`UEV_*`** / **`CAP_*`** → one boolean **`enforce`** → **`compose-capability`**. Detail: **`OuronetInformational/skills/defcap-body-order.md`** |
| **Booleans** | 1 plain; 2 **`and`**; 3+ **`fold (and)`**. **`.cursor/skills/ouronet-pact-enforce/SKILL.md`** |
| **Bool param names** | Do **not** use the **`use-`** prefix on identifiers (`use` is a Pact keyword). Prefer **`iz-*`** for other mode flags when needed. **DPOF stake:** whole-nonce **`C_Transfer` only** — no `iz-transmit` on the stake path. |
| **Smart vault** | **`MODULE|GOV`** on TFT send **and** receive; rotate with **`create-capability-guard (MODULE|GOV)`** when module owns **`MODULE|SC_NAME`**. RemoteGov only for hub/forward patterns. **`OuronetInformational/skills/smart-account-governor.md`**, **`ouronet-tft-vault-imc`** |
| **`P|A_Define` IMP** | Only when target module **`UEV_IMC`** applies (e.g. TFT). Not for unprotected DALOS **`UR_*` / `CAP_*`**. |

## Architecture hub

- **`OuronetInformational/MODULE_ARCHITECTURE.md`** — prefixes, **`C_`/`XI`/`XE`**, UR layout, boolean grouping.
- **`OuronetInformational/CONTEXT.md`** — repo vocabulary and stage boundaries.
- **`OuronetInformational/skills/README.md`** — all skill files + Cursor skill map.

## When user says “check OuronetInformational”

1. Read **`CONTEXT.md`** + **`MODULE_ARCHITECTURE.md`** if unfamiliar with the area.
2. Read the matching **`OuronetInformational/skills/*.md`** for the task (REPL layout, deploy handoff, UR layout, etc.).
3. Apply matching **`.cursor/skills/ouronet-*`** entries (listed in **`skills/README.md`**).

Skills are **not** injected automatically from **`OuronetInformational/`** alone — the agent must **read** those files (or use this index skill + linked Cursor skills).
