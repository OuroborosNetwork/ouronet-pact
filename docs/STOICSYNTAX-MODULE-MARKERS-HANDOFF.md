# StoicSyntax — Canonical module structure & block markers (handoff to canonize)

**Status:** DRAFT spec + handoff. Written by the party maintaining the StoicSyntax **colouring engine**
(Claudstermind's Pact viewer). It captures the module structure and the full block-marker system the owner
settled during the StoicSyntax sweep, so that **placement (markers)** and **colour** stay in lockstep — the
highlighter reads these markers to decide colour, so they are not decoration, they are part of the syntax.

**Your job (sweep agent):**
1. **Read this end to end.**
2. **Decide the exact glyph shapes** of the separator markers (block / sub-block / sub-sub-block) — the shapes
   below are placeholders; you choose the canonical forms (e.g. `;;<========>` + a label line, and the braced
   sub-block tags). Keep them cheap to grep and unmistakable.
3. **Write it all into canon** — fold/expand `OuronetInformational/StoicSyntax-Prefixes.md` (§5.1/§5.2/§5.4)
   so the module skeleton, every marker, its meaning, order, and its colour effect are authoritative.
4. **Create the canonical template** `OuronetInformational/canon.pact` — a module with **nothing but empty
   blocks filled with every marker**, in order, as the start-point for any new module. (A file with several
   logical module units repeats the per-unit skeleton once per unit — see §0.)
5. Follow this to the letter when rearranging / renaming / refactoring modules. Empty blocks are **still
   marked**. When a cap's correct band or a block placement is genuinely ambiguous, **STOP and ask** (same as
   the unknown-prefix rule) rather than guessing.

> **Colouring contract.** Sections tagged **⟨COLOUR⟩** below are the parts the highlighter keys off. When you
> finalize the marker spellings/numbering, tell the colouring maintainer so the classifier's marker checks are
> updated to match. Several of the rules below **change** what the classifier currently reads — they are called
> out explicitly under "Colouring dependencies" at the end.

---

## 0. Terminology — module FILE vs logical module UNIT

- A Pact **module file** may contain **several logical module units**. `coin` contains **3**; almost every
  Ouronet module contains **exactly one**.
- The canonical structure below is **per logical module unit**. A multi-unit file repeats it once per unit.
- **`@doc`** — each module *file* opens with an optional `@doc "…"` tag as the very first thing. It is **per
  file**, **not per logical unit** (you can't conjure a second `@doc`), and it is **not a code block** — it is
  metadata, so it sits *before* block 0 and carries no block marker.

---

## 1. The canonical block order (smallest → last), per logical module unit

```
@doc  "…"                      ; optional, per FILE, first thing, NOT a block
0)  IMPLEMENTERS
#)  GASSTATION                 ; optional, UNNUMBERED (rare — only DALOS today)
1)  GOVERNANCE                 ; sub-blocks G1..G5
2)  POLICY                     ; sub-blocks P1..P5
3)  CST  (Constants/Schemas/Tables)   ; sub-blocks 3.1 / 3.2 / 3.3
4)  CAPABILITIES               ; sub-blocks C1..C4
5)  FUNCTIONS                  ; 7 sub-blocks (the 7 function classes), each with ordered variants
```

Every block — **including empty ones** — carries its marker. An empty block is a marker with no body.

### 0) IMPLEMENTERS — first block
Only `(implements <interface>)` statements — which interfaces this module implements, nothing else.

### #) GASSTATION — optional, unnumbered
Holds the module's **Gas Station** logic. **The Gas Station must be named.**
- ⟨COLOUR⟩ **Every capability in this block is GOLD** (the gas station is an authority surface).
- Must contain **at least the minimum functions of the gas-payer interface** it implements; custom logic is
  optional. Any helper functions/caps it needs may live here **or** elsewhere in the module — placement of
  helpers doesn't matter, only that the gas-station surface is complete.
- It is **unnumbered (`#`)** because it is rare (only DALOS has one today) — so as not to waste a number
  position. The next block is therefore **1) GOVERNANCE**.

### 1) GOVERNANCE — sub-blocks G1..G5
The module's governance logic. **All functions here carry the `GOV|` prefix.**
| Sub-block | Contents | ⟨COLOUR⟩ |
|---|---|---|
| **G1** | constants | governance constants render **grey + BOLD** |
| **G2** | schemas | (per-type schema colours) |
| **G3** | tables | (table colours; key-shape comment — see CST 3.3) |
| **G4** | **capabilities** | the C1–C4 cap-band rules apply; **governance caps here are GOLD** (unless bronze by composition) |
| **G5** | functions (all `GOV|`) | may carry **custom designators** — e.g. Keys, SmartContract Names, PublicKey (always **camelCase**) — each separated by the standard sub-sub separator and its custom name listed |

> **NB — governance numbering changed.** The prior canon (§5.2.1) had G1=const, **G2=caps**, G3=defuns. The
> settled scheme is **G1 const · G2 schemas · G3 tables · G4 capabilities · G5 functions**. So the
> **governance-capability marker moves from `{G2}` to `{G4}`.** ⟨COLOUR⟩ The classifier currently treats `{G2}`
> as the gold gov-cap marker — that must become **`{G4}`** once you canonize this.

### 2) POLICY — sub-blocks P1..P5
Every module has a policy block (how the module is accessed, how policies are stored). It is governed by its
own **policy interface**, which **every module must implement**. Standardized like governance:
| Sub-block | Contents | Notes |
|---|---|---|
| **P1** | constants | likely empty as built today — **leave the marker** in case needed |
| **P2** | schemas | same — leave room |
| **P3** | tables | **in use today** |
| **P4** | capabilities | none today — leave room for future policy caps |
| **P5** | functions | all carry the **`P|`** prefix, then the standard function name |

**Function naming under `P|`:** the policy prefix comes **first**, then the normal StoicSyntax name:
`P|UR_IMP` (a policy read), `P|A_AddIMP` (a policy admin/user function), `P|UEV_IMC` (the policy enforce —
the function used hundreds of times becomes `P|UEV_IMC`).
- ⚠ **Rename needed:** functions are currently mis-ordered like `A_P|AddIMP` — they must become `P|A_AddIMP`
  (policy prefix leads), and the policy **interface rewritten** to match.
- ⟨COLOUR⟩ **New rule (settled):** a `P|<known-prefix>` name is coloured by the **known prefix after the `|`** —
  and the **whole token** takes that colour: `P|UR_IMP` → read, `P|A_Add` → admin, `P|UEV_IMC` → enforce. The
  `P|` scope does **not** force grey. Only a `P|` with **no** known prefix after it (e.g. `P|SomethingCustom`)
  stays grey/structural. General form: for `<CAPS-scope>|<known-prefix>_Name`, the known prefix wins the colour
  for the entire name. (`GOV|…` differs: its G5 functions use custom designators — no known prefix — so they
  stay grey structural.) **This is a new colouring rule — add it to canon.**

### 3) CST — Constants / Schemas / Tables (3 sub-blocks)
- **3.1 Constants** — every `defconst`.
- **3.2 Schemas** — every `defschema`.
- **3.3 Tables** — every `deftable`. ⟨COLOUR/CANON⟩ On the **same line, as a comment**, write the table's
  **key shape**, standardized with `|` as the semantic separator between key components:
  `<component>|<component>|<component>`. This documents how the table is reached. (The `|` bar as key-shape
  separator must be canon so it's read consistently everywhere.)

### 4) CAPABILITIES — sub-blocks C1..C4
As already settled (see `StoicSyntax-Prefixes.md` §5.2, amended 2026-09-02):
- **C1 → BRONZE** — trivial `true` caps (metadata like `@doc` ignored), **and** caps that compose only bronze
  caps (transitive). **Composition wins over placement** — a simple/true cap stays bronze even under {C4}.
- **C2 / C3 → SILVER** — custom, non-authority caps (C2 non-composing, C3 composing). These markers organise
  the file; they do **not** drive colour (silver is inferred).
- **C4 → GOLD** — ownership / governance / authority caps. ⟨COLOUR⟩ `{C4}` is a colour-bearing marker.

### 5) FUNCTIONS — the last & largest block: 7 classes, each an ordered sub-block
The 7 function classes are the **colour split** — the 37 prefixes collapse into 7 families, written in **build
order** (a value must exist before it's read/validated/written), and **strongest → lightest within** each
family. Each class is a sub-block; its **variants** are ordered sub-sub-blocks. (Cross-check the full 37 in
`StoicSyntax-Prefixes.md` §2 and the canonical order in §5.1.1 — reconcile any drift.)

| # | Class | Lead prefix | Variants / sub-types (ordered) | Family colour |
|---|---|---|---|---|
| 1 | **Construct** | `UDC_` | `UDC_` · `UDCx_` (auxiliary) | yellow |
| 2 | **Compute** | `UC_` | `UC_` · `UCk_` (key-building) · `UCx_` / `UCkx_` (auxiliary) | teal/blue |
| 3 | **Read** | `UR_` | `UR_` · `URC_` (composed) · `URU_` · `URCx_` (aux) · `URH_`/`URHC_` (**heavy — loud**) · `URCi_` (**cost**) | tan / amber (heavy) |
| 4 | **Validate / Enforce** | `UEV_` | `UEV_` · `UEV_IMC` (the IMC spine enforce) · `CAP_` (capability-**guard** function prefix — NOT a region-4 metallic cap) | red |
| 5 | **Write** | `WI_` `WU_` `WW_` | `WI_` (insert) · `WU_`/`WU2_`/`WU3_`/`WU4_` (update) · `WW_` (overwrite) — one write-site each, gated on a home `SECURE` | pink/magenta |
| 6 | **Aux-Protected / Orchestration** | `XI_` `XE_` `XB_` | `XI_` (internal — used within this module) · `XE_` (external — the client entry, reached via Talos) · `XB_` (**Both** — an auxiliary used in this module **and** in forward/downstream modules) | purple |
| 7 | **User / Recipe** | `A_` `C_` | `A_` (admin) + `AA_`/`Ap_`/`AAp_`/`AU_` variants · `C_` (client) + `CC_`/`Cp_`/`CCp_` variants | green (client) / dark-green (admin) |

Within every class, order **strongest → lightest** (e.g. plain `UR_` before `URC_` before aux `URCx_`). Keep
the class order 1→7 above; it is the build order (Construct leads — §5.3 amendment 2026-08-31).

---

## 2. The marker system — what to canonize

Three marker tiers. **You decide the exact glyph shapes**; below is the *structure* they must express.

1. **BLOCK marker** (top level: IMPLEMENTERS / GASSTATION / GOVERNANCE / POLICY / CST / CAPABILITIES /
   FUNCTIONS). Example placeholder shape:
   ```
   ;;<==========================================================>
   ;;GOVERNANCE
   ;;<==========================================================>
   ```
   A heavy rule + a NAME line. Pick the canonical rule glyph + width.
2. **SUB-BLOCK marker** (G1..G5, P1..P5, 3.1..3.3, C1..C4, and the 7 function classes). The braced tags already
   in use — `;;{G1}` `;;{P3}` `;;{C4}` `;;{3.2}` `;;{5}`… — are the machine-readable signal. Fix the exact
   scheme (letter+number for lettered regions; `n` / `x.y` for the numeric ones) and keep it closed.
3. **SUB-SUB-BLOCK marker** (the ordered **variants** inside a function class, and the custom G5 designators like
   Keys / SmartContract-Names / PublicKey). Pick a lighter separator than a sub-block.

**Rules that must be canon:**
- **Every block and sub-block is marked, even when empty** (an empty policy P1 still shows its `;;{P1}` marker).
  This is what makes a module scannable and diffable.
- Markers appear in the **canonical order** above; a real file's markers may be physically out of order but the
  canon fixes the intended order, and the sweep re-lays them to it.
- The `|` bar is the **canonical semantic separator** for key shapes (CST 3.3) and for qualified names
  (`GOV|…`, `P|…`, `MODULE|MEMBER`) — one meaning everywhere.

---

## 3. Colouring dependencies (⟨COLOUR⟩ — keep classifier and canon in sync)

The highlighter (`stoicsyntax-pact` / Claudstermind's `pact-medallion.js`) reads markers + composition to colour
caps and reads prefixes to colour functions. **These items CHANGE what it must read — implement them in the
classifier once you finalize the canon, and tell the colouring maintainer:**

1. **Governance cap marker `{G2}` → `{G4}`.** Gov caps now live in G4 (G2 became schemas). The classifier's
   "gold under `{G2}`" check must become **`{G4}`**. (`{G1}` grey-bold constants unchanged; `{C4}` gold
   unchanged.)
2. **GASSTATION block → all caps GOLD.** A new colour-bearing *block* (not a `{Cx}` sub-block): any capability
   inside the GASSTATION block is gold. The classifier needs to detect the GASSTATION block boundary and force
   its caps gold (composition-bronze still wins for a genuinely trivial `true` cap, but gas-station caps are
   authority surfaces and should not be trivial).
3. **`P|<known-prefix>` colours by the prefix.** A `<CAPS-scope>|<known-prefix>_Name` (e.g. `P|UR_IMP`,
   `DALOS|C_Create`) takes the **known prefix's** colour for the whole token — the classifier now checks the
   segment after the `|` and lets a known prefix win over the structural grey. A scope with **no** known prefix
   after it (bare `P|Custom`, `GOV|SC_…`) stays grey. **Already implemented** in the highlighter (2026-09-02).
4. **Composition precedence is settled** (§5.2 amendment 2026-09-02): trivial-`true` (metadata-ignored) and
   compose-only-bronze → **BRONZE**, and bronze **wins over any gold placement marker**. Unchanged — keep it.

**Net colour-bearing markers after this canon:** `{C4}` (gold caps) · `{G4}` (gold gov caps) · `{G1}`
(grey-bold gov constants) · the **GASSTATION block** (gold caps) · `GOV|`/`P|` (grey structural prefix filter).
Everything else (`{C1}`/`{C2}`/`{C3}`, `{P1..P5}`, `{1}/{2}/{3}`, the block/variant separators) is
organizational — read by humans and the sweep, not by the colourer.

---

## 4. Deliverables (what "done" looks like)

- [ ] Separator marker shapes chosen (block / sub-block / sub-sub-block) and written into
      `OuronetInformational/StoicSyntax-Prefixes.md` (extend §5.4 into a full **Placement-Marker Registry**),
      cross-linked from §5.1 (structure) and §5.2 (cap colour).
- [ ] The per-logical-unit block order (§1 here) canonized, including the unnumbered GASSTATION block, the
      G1..G5 / P1..P5 / 3.1..3.3 / C1..C4 sub-blocks, and the 7 function classes with their ordered variants.
- [ ] The new naming/colour rules recorded: `P|`-leads (rename `A_P|…` → `P|A_…` + rewrite the policy
      interface), the `P|` grey filter, GASSTATION-caps-gold, `{G2}`→`{G4}` gov-cap marker, CST 3.3 key-shape
      comments with `|` separators.
- [ ] **`OuronetInformational/canon.pact`** created: a module (single logical unit) that is **nothing but the
      full marker skeleton with empty blocks**, in canonical order — the start-point template for new modules.
      Note in it how to repeat the skeleton for a multi-logical-unit file (the `coin`-style case).
- [ ] A dated amendment note (like the 2026-08-31 / 2026-09-02 ones) summarizing the change.

When the registry + `canon.pact` are finalized, ping the colouring maintainer with the final marker spellings so
`{G4}` / GASSTATION / `P|`-filter land in the highlighter and the two stay in lockstep.
