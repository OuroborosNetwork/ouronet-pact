# The shape, in one diagram

One picture to carry through the rest of the documentation. Everything later refines it; nothing
later contradicts it.

---

## The layer cake

```
        ┌──────────────────────────────────────────────────────────────┐
        │  A CLIENT  (browser, wallet, script)                         │
        │  signs with a key; never holds the host chain's coin         │
        └───────────────┬──────────────────────────────┬───────────────┘
                        │  writes                      │  reads
                        ▼                              ▼
    ╔═══════════════════════════════╗   ╔══════════════════════════════════╗
    ║  TALOS         11 modules     ║   ║  READS         14 files          ║
    ║  the only supported way in    ║   ║  free, no signature, no IGNIS    ║
    ║                               ║   ║                                  ║
    ║  • sponsors the host gas       ║   ║  • INFO_  cost previews          ║
    ║  • collects IGNIS              ║   ║  • per-app composed page reads   ║
    ║  • holds the capability edge   ║   ║  • never writes                  ║
    ╚═══════════════╦═══════════════╝   ╚══════════════════════════════════╝
                    │ calls  A_ / C_ / X*                    ▲
                    ▼                                        │ reads
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  CORE          44 files (43 modules),  83,634 lines                  ║
    ║  the business logic, and every table that holds anything             ║
    ║                                                                       ║
    ║   identity      DALOS · IGNIS · BRD · CODEX · PYTHIA                 ║
    ║   assets        DPTF · DPOF · DPDC family · EQUITY                    ║
    ║   variants      VST · ELITE · TFT · LIQUID                            ║
    ║   pools         ATS · ATSU │ SWP family · MTX-SWP │ AQP family        ║
    ║   launchpad     DEMIPAD                                               ║
    ╚═══════════════════════════════╦══════════════════════════════════════╝
                                    │ calls
                                    ▼
    ╔══════════════════════════════════════════════════════════════════════╗
    ║  UTILITIES     13 modules,              5,126 lines                  ║
    ║  pure helpers. no state, no authority. strings, lists, decimals,     ║
    ║  rounding, glyph formats, and the breadth-first search               ║
    ╚══════════════════════════════════════════════════════════════════════╝

    ─────────────────────────────  all of the above is  ─────────────────────
                            S O V E R E I G N   (1_SOVEREIGN/)
                       75 files · 107,583 lines · maintained by the project

    ╔══════════════════════════════════════════════════════════════════════╗
    ║  CITIZEN     (2_CITIZEN/)   30 files · 15,386 lines                  ║
    ║  anyone may write one. calls Talos, exactly like a client does.      ║
    ║  minters · launchpad sales · the bridge · AOZ · the dispenser        ║
    ║  automaton · per-app read modules                                    ║
    ╚══════════════════════════════════════════════════════════════════════╝
```

Read it as **four rules**, which is all you need to remember:

1. **Calls go down, never up.** Utilities know nothing of Core; Core knows nothing of Talos.
2. **Every write enters through Talos.** There is no second path.
3. **Every read is free** and bypasses Talos entirely.
4. **Citizen code is a client**, not a layer. It sits beside the cake, not on top of it.

## Why each layer exists

**Utilities** — pure computation, no tables and no authority. A utility cannot be dangerous,
which is why the rest of the system may call them freely without thinking about it.

**Core** — the business logic and **every table that holds anything**. An asset, a balance, a
pool, a vesting schedule: all of it is a row in a Core module's table. Core modules hold the
capabilities that guard those tables, and a Core `C_` cannot be called by a client directly.

**Talos** — the orchestration and money boundary, and the most important idea in the architecture.
It is where three things happen and the only place they happen:

- **the host chain's gas is paid for the user**, by a gas station, so a user never needs the
  underlying coin;
- **IGNIS is collected**, after the operation, based on what the operation reported it cost;
- **the capability boundary is crossed** — Talos composes the Core capabilities a flow needs.

The consequence is a single place to audit: if an operation charges wrongly, is sponsored wrongly,
or is authorised wrongly, the defect is in Talos or in the Core function it wrapped, and there is
no third possibility.

**Reads** — a separate surface, because reads are a different problem. They take no signature,
cost nothing, and cannot change anything. Two kinds live here: `INFO_` previews that price an
operation before a user signs, and per-app composed reads that answer a whole screen in one call.
`../10-architecture/08-the-read-layer.md` covers why they are split per consuming app.

**Citizen** — extension modules. The critical structural fact is that a citizen module is
**not privileged**: it calls the same Talos entrypoints a browser calls and pays the same IGNIS.
This repository's own launchpad sales, minters, bridge and dispenser are citizen modules, which is
how the claim is tested instead of asserted.

## The two stages, and why you will keep meeting them

The tree is split `STAGE_01` / `STAGE_02`, and it is **chronology, not architecture**:

| | |
|---|---|
| **Stage 1** | identity, IGNIS, the fungible types, vesting, autostake, the swap family. 46 files, 58,687 lines. |
| **Stage 2** | collectables, equity, the launchpad, the acquisition pools. 29 files, 48,918 lines. |

Stage 2 was built after Stage 1 was live, and depends on it. Nothing is duplicated between them —
Stage 2's collectables use Stage 1's accounts and Stage 1's gas. Each stage has its own Talos
modules and its own read modules, which is why there are eleven Talos modules rather than one.

## Where the diagram is a simplification

Stated, because a mental model that hides something important is worse than a complicated one.

- **`0_Interfaces/` is empty.** Five files, 60 lines of comments. Interfaces used to live there and
  are now embedded in the files implementing them. They appear in the tree and deploy nothing.
- **Some flows cross Talos twice.** A Core operation may call another Talos client which collects
  its own IGNIS — one of six legitimate billing shapes, not one.
  `../10-architecture/06-ignis-and-the-gas-station.md` enumerates them.
- **Not every write is one transaction.** Operations too large for the host's gas ceiling exist as
  multi-transaction recipes; some are parallelisable and some are strictly sequential, and the
  difference is not visible in the diagram. See `../10-architecture/04-deploy-order.md` and
  `../50-economics/03-heavy-reads.md`.
- **Reads are not always free to the protocol.** They are free to the *user*. A read that scans
  still consumes real node resources, which is the tension `../50-economics/` is about.

---

## Where to go next

- `04-how-to-read-this.md` — three reading orders depending on why you are here
- `../10-architecture/01-the-layer-cake.md` — the same diagram, with the rules made precise
- `../10-architecture/06-ignis-and-the-gas-station.md` — how the money boundary actually works

## Sources

Per-layer figures counted 2026-09-27 with `find <dir> -name '*.pact'` and `-exec cat {} + | wc -l`;
they sum to the 107 files and 124,750 lines on the front page. Layer membership is the directory
structure of `1_SOVEREIGN/` and `2_CITIZEN/`; module roles from
`OuronetInformational/MODULE-INDEX.md` (generated) and `MODULE_ARCHITECTURE.md`. **Two counts here were wrong in the first draft and the correction is worth
keeping**, because it is the failure mode this documentation is built against. The read layer was
written as "12 modules" from recollection; counted from the tree it is **14 files** — the first
guess omitted Pythia's read module, and a second guess of 13 still omitted
`2_CITIZEN/Stage_Z/AppReads/00_Ids.pact`. Worse, the arithmetic check written to verify the diagram
was written *from the claim* rather than from the tree, so it confirmed the wrong number. A check
derived from the thing it is checking proves nothing. The figures above are now the output of
`find <dir> -name '*.pact'`.

The Talos count of 11 is 6 Stage-1 + 4 Stage-2 sovereign modules + the citizen launchpad Talos
(`2_CITIZEN/7_Launchpad/99_TS02-CPAD.pact`) — a distinction that has caused real confusion, since a
sovereign module one letter apart (`TS02-DPAD`) lives elsewhere. Core is 44 files holding 43
modules: `03_AQP/00_AQP-SCHEMAS.pact` is interface-only, carrying shapes the AQP family shares.
(That attribution was itself guessed wrong once — the guess was `00_Demipad.pact` — and found by
running the loop instead. Three wrong figures on one page, all from recollection, all caught by
counting. The page is evidence for its own method.)
