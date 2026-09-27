# Sovereign and citizen

Ouronet's code is split in two, and the split is not organisational. It is the difference between
*the protocol* and *things built on the protocol* — and the second category is the reason the first
one is shaped the way it is.

```
1_SOVEREIGN/    75 files · 107,583 lines    the protocol. maintained by the project.
2_CITIZEN/      30 files ·  15,386 lines    built ON the protocol. anyone may write one.
```

---

## 1. What makes a module sovereign

Three things, and all three are structural rather than a matter of who wrote it:

1. **It owns tables.** Every balance, every asset record, every pool is a row in a sovereign
   module's table. Citizen modules own their own bookkeeping but nothing anyone else's correctness
   depends on.
2. **It holds capabilities.** The gates that guard those tables are sovereign `defcap`s. A citizen
   module cannot define a capability that opens a sovereign table.
3. **Talos is sovereign-only.** The gas boundary — where host gas is sponsored and IGNIS is
   collected — is sovereign code, with one deliberate exception covered in §4.

## 2. What a citizen module may do, and what it may not

A citizen module is, structurally, **a client that happens to live on chain**. It calls the same
Talos entrypoints a browser calls.

| | |
|---|---|
| may call Talos `A_` / `C_` entrypoints | **yes** — this is the whole surface |
| may read sovereign tables via `UR_`/`URC_` readers | yes |
| may call a protected `X*` function directly | **no.** `[citizen-calls-X] 0 violation(s)` |
| may define its own tables, schemas, capabilities | yes, freely |
| must carry `UEV_IMC` on its client functions | **no** — that inter-module gate belongs to Talos and core paths |
| pays IGNIS | yes, on the same terms as any client |

The third row is the load-bearing one and it is mechanically checked. `X*` prefixes mark functions
protected inside the module boundary (`XI_` internal, `XE_` for external modules, `XB_` both), and
a citizen module reaching one directly would bypass the capability gate that a Talos wrapper
composes. Zero do.

## 3. The ruling that defines the boundary

Owner ruling, 2026-09-26:

> **"citizen modules are free to construct functions as they please."**

This settled a real question. Sovereign entrypoints obey a strict positional canon — every `A_`/`C_`
takes `patron` first, `executor` second, `executee` third where one exists — and it was unclear
whether citizen code inherited it. It does not.

The ruling is now *printed by the tool* rather than remembered:

```bash
python3 REPL/tools/_executorplan.py
# A_/C_ entrypoints in 1_SOVEREIGN modules: 776
#    DONE 776 ... remaining: 0
#
# OUT OF SCOPE by owner ruling (2026-09-26) -- citizen modules are free to construct
# functions as they please: 136 A_/C_ entrypoints in 2_CITIZEN, 2 of them (patron, executor) anyway
#    NOT a backlog. Printed so the boundary is a stated fact rather than an inference.
```

That last line is the interesting engineering decision. 136 non-conforming entrypoints could be
reported as a to-do list, as clean, or not at all. All three would be misleading. Printing them
with the ruling attached makes the boundary **a stated fact** — a reader learns both that they are
out of scope and *why*, from the tool, at the moment they would otherwise wonder.

### The corollary a client must know

If a citizen `C_` may take any parameter list, then **nothing about its shape can be inferred**. No
convention tells you the argument order. So:

> For a citizen entrypoint, the **registry is the only authority on how to call it.**

This is why `2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact` carries all 7 of its entrypoints in
`Deploy/OURONET-REGISTRY.json`, and why six citizen `INFO_` cost readers appear there as previews.
The rest of the citizen tree exposes reads, which a client-entrypoint registry does not index.

## 4. The one exception: a citizen Talos

Talos is sovereign-only — except that the launchpad has its own.

| module | which | holds |
|---|---|---|
| `1_SOVEREIGN/STAGE_02/3_Talos/05_TS02-DPAD.pact` | **sovereign** | the `DEMIPAD\|*` rules |
| `2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact` | **citizen** | every per-sale user wrapper, and the sole gas-funded path for the sales |

**One letter separates them**, and it is the letter that assigns the sovereign/citizen role. This
has caused documented confusion: `CLAUDE.md` itself carried a sentence naming
`99_TS02-DPAD.pact` as "the sovereign Talos orchestrator co-located with the launchpad" — a file
that does not exist, in a sentence that contradicted the layout table thirteen lines above it.
Corrected 2026-09-17.

The citizen Talos exists because the launchpad sales are pure-citizen modules that still need a
gas-funded path for their users. It is deployed last.

## 5. The citizen modules that exist, and why they matter

These are the project's own, and they are the test of the whole claim. If the sovereign surface
were not genuinely sufficient, the project would have cheated — reached into a protected function,
or added a capability to the core for its own convenience. It did not, and that is checkable.

| module | what it is | entrypoints |
|---|---|---|
| `01_NOSFERATU` | collectable minter | 48 |
| `02_KBunnies` | collectable minter | 18 |
| `04_AQP-BOOT` | vault/pool bootstrapper | 16 |
| `03_DSP+` | the dispenser automaton — daily emission splitting | 10 |
| `01_AOZ+` | Age of Zalmoxis, primal-asset registrar | 9 |
| `05_STOAICO` and the other launchpad sales | per-asset token sales | 7 + |
| `03_CADUCEUS` | bridge controller — **scaffold, not deployed** | — |
| `01_DPL-UR`, `02_EXPLORER`, `AppReads/*` | read modules, per consuming app | reads only |

Two are worth singling out:

**AOZ and DSP are Talos-only.** They call nothing but Talos operations — the strictest possible
citizen posture, and proof the surface is usable without special access.

**The launchpad sales are pure-citizen.** Each calls only Talos operations, is billed normally, and
carries its own `URCi_`/`INFO_` cost readers so its users get a price preview like any other
operation. A third party could write the same thing.

## 6. What this means if you are writing one

- **You are not constrained by the sovereign canon.** Shape your functions as you like.
- **You must publish your shape.** Since nothing is inferable, a consumer needs your entrypoints in
  the registry — or they cannot call you safely.
- **Write cost readers.** Users of your module deserve the same price preview every sovereign
  operation gives. The launchpad sales are the reference.
- **Do not expect privileged access, and do not need it.** If you find yourself wanting a protected
  `X*` function, the operation you want is either a Talos entrypoint already or is missing from the
  sovereign surface — and the second is a conversation, not a workaround.

`../40-journeys/04-as-a-builder.md` is the practical walk-through.

---

## Where to go next

- `01-the-layer-cake.md` — the layering this boundary cuts across
- `03-the-module-map.md` — every module, sovereign and citizen, by role
- `../40-journeys/04-as-a-builder.md` — writing one, end to end

## Sources

- **The ruling**, and the 776 / 136 figures: `python3 REPL/tools/_executorplan.py`, run 2026-09-27.
  Note the tool globs `1_SOVEREIGN` only — its predecessor's blindness to citizen modules is why
  the `OUT OF SCOPE` line exists at all.
- **`[citizen-calls-X] 0 violation(s)`**: `python3 REPL/tools/_conformance.py`.
- **The canon itself**: `OuronetInformational/StoicSyntax-Prefixes.md` §2.2, and
  `OuronetInformational/HANDOFFS/HANDOFF-executor-canon-sweep.md`.
- **The DPAD/CPAD correction**: `CLAUDE.md`, *"Sovereign vs citizen"*, corrected 2026-09-17.
- **Per-module line counts**: `find 2_CITIZEN/<dir> -name '*.pact' -exec cat {} + | wc -l`.
