# Handoff — building the documentation site

**Read this first.** It is the single entry point to `OuronetDocumentation/`: what is here, what
it is for, what is deliberately absent, what you must not touch, and how it stays true.

You are building a website from this folder. Nothing here concerns navigation, styling or routing
— those are yours. Everything here is content and the rules that keep it correct.

---

## 1. What this folder is

The complete written documentation of Ouronet — **the Sovereign DeFi Layer of StoaChain** — for a
reader who arrives knowing nothing.

> If you meet the phrase **"virtual blockchain"** anywhere in the wider repository, it is retired.
> The designation is the one above. `00-orientation/01-what-ouronet-is.md` carries the note.

**152 files · ~135,000 words · 1.3 MB.** Roughly **89,000 words hand-written**, **46,000
generated from the chain and the source tree**.

The reader it is written for, stated once and honoured throughout:

> A capable technical person who has never seen Ouronet, is not a Pact programmer, and needs to
> understand what this system is, what it does, how it does it, and why it was built this way.

They are not an auditor, not a UI developer, not a casual visitor. Consequences you will see in
the prose: **nothing assumes Pact**, nothing assumes the reader was present for any prior
conversation, and depth is not traded for brevity.

---

## 2. The map

| section | files | what it is | state |
|---|---:|---|---|
| `00-orientation/` | 4 | what Ouronet is and why it exists | **complete** |
| `10-architecture/` | 8 | layers, sovereign vs citizen, deploy order, accounts, gas, interfaces, reads | **complete** |
| `20-assets/` | 8 | the four asset types, sets and fragments, special variants, pool positions | **complete** |
| `25-defi/` | 5 | the three pool families and their mathematics | **complete** |
| `30-modules/` | 98 | one page per deployed module, plus an index | **complete, see §5** |
| `40-journeys/` | 5 | what a holder, issuer, pool owner, builder, integrator can do | **complete** |
| `50-economics/` | 4 | the cost model, why it is expensive, heavy reads, the price sheet | **complete** |
| `60-methodology/` | 4 | StoicSyntax, semi-self-auditing, the gate, what went wrong | **complete** |
| `70-comparison/` | 3 | versus ERC-20, versus a same-platform AMM, what the complexity buys | **complete** |
| `80-cryptography/` | 4 | the custom curve, derivation, browser signing, what is not on chain | **complete** |
| `90-reference/` | 5 | entrypoint catalogue, glossary, figure provenance, the directive, source map | **complete** |
| root | 4 | this file, `README.md`, `BUILD-PLAN.md`, `MAINTAINING.md`, `RESUME-HERE.md` | — |

**Start a reader at `00-orientation/`.** Start yourself at `README.md`, then this file.

### Reading order that actually works

The sections are numbered in dependency order, not importance order. A reader who follows the
numbers never meets a term before it is defined. Two exceptions worth surfacing in navigation:

- **`30-modules/` is reference, not narrative.** Nobody reads it front to back. It needs search
  and the index (`30-modules/00-INDEX.md`), not a "next chapter" link.
- **`90-reference/04-the-owner-directive.md` is a primary source**, quoted verbatim. Every claim
  this folder makes about *intent* traces there. Do not paraphrase it in any summary you generate.

---

## 3. THE ONE RULE THAT MATTERS: generated vs written

**About a third of this folder is machine-generated. If you edit it, your edit is destroyed on the
next regeneration and the build gate goes red.**

Two forms:

**Marker regions.** Inside a hand-written page, between:

```
<!-- @generated:module-page:DPTF -->
   ...everything here is rendered from the chain...
<!-- @end:module-page:DPTF -->
```

Text outside the markers is prose and is never touched. Text inside is rewritten wholesale.

**Whole generated files**, which say so in a banner at the top:

```
> **This page is GENERATED.** Edit `REPL/tools/_docsref.py`, never this file.
```

Those are `90-reference/01-entrypoint-catalogue.md`, `02-glossary.md`, `05-source-map.md`, and the
generated regions inside `10-architecture/03-the-module-map.md` and every `30-modules/` page.

**Why it is split this way, measured rather than asserted:** the predecessor of this
documentation was a hand-written whitepaper, code-accurate when written. One refactor later,
**55 of its 58 signatures were wrong.** The half that rots is exactly the half a generator
produces; the half that survives is exactly the half it cannot. `MAINTAINING.md` §0 has the
measurement.

**For your build:** treat generated regions as data. If you want to render them differently —
tables, expandable sections, a searchable API browser — parse them, or better, read the same
sources the generators read. Do not transform them in place.

---

## 4. Keeping it true

One command, after any change to the Pact code:

```bash
python3 REPL/tools/_docsall.py --write --probe    # asks the chain, then regenerates everything
python3 REPL/tools/_docsall.py --check            # is anything stale? (offline, fast)
```

It runs five generators **in an order that is load-bearing** — the two checkers run last because
they validate the other three's output. Without `--probe` it never touches the network.

All five are also **fatal checks in `REPL/tools/_gate.py`**, the repository's build gate. A stale
page fails the build rather than shipping.

**If you are regenerating as part of a site build:** use `--check`, not `--write`. A site build
that silently rewrites its own sources hides drift instead of reporting it.

---

## 5. What is here, honestly, and what is not

This folder's own discipline is that a gap stated is better than a gap hidden. Applying it to
itself:

### The 45 prose chapters are finished

Orientation, architecture, assets, DeFi, journeys, economics, methodology, comparison,
cryptography. Each is a complete argument with a sources footer and measured figures. **You should
not need to expand these — only render them.**

### The 96 module pages are uneven, and here is the distribution

| prose depth | pages |
|---|---:|
| 300–600 words | 3 |
| 150–300 words | 60 |
| **under 150 words** | **33** |

Every page's **enumeration is complete**: on-chain hash, deployed size, interfaces, tables,
schemas, capabilities, every function grouped by what its prefix promises, and client entrypoints
with their previews. That part is generated and exhaustive.

What varies is the narrative around it — *what it is for*, *where it sits*, *traps*. For the 13
utility modules and the 11 read modules, thin is correct; they are small. For roughly twenty
substantial modules it is thinner than the build plan intended.

**The plan asked for per-function explanation — what each function does, how, and why. That is not
delivered.** 8,848 functions are enumerated and grouped, not individually explained. This is a
deliberate stop, not an oversight: per-function narrative at that scale is several times the
volume of everything else here, and much of it would restate what the prefix already promises.

**If your build wants an API browser**, the generated blocks plus `90-reference/01-entrypoint-catalogue.md`
and `02-glossary.md` are the right inputs — not the prose.

### Deliberately absent

- **No PDF edition.** Asked and declined.
- **No per-function reference.** See above.
- **No navigation, styling, routing, or search configuration.** Yours.
- **No API documentation for client developers** — that is `docs/CHAPTER-INTEGRATION/`, a separate
  five-file folder, already written, and `40-journeys/05-as-an-integrator.md` points at it rather
  than restating it.

---

## 6. Conventions you will meet

**Cross-references are bare filenames in backticks** — `` `20-assets/01-true-fungibles.md` `` —
resolved against the documentation tree by basename, not by relative path. **195 of them.** A
checker enforces that every one resolves; if you rewrite links for the web, keep the mapping
one-to-one or the checker becomes meaningless.

**Figures are load-bearing and checked.** Five cross-cutting numbers — 423 client entrypoints, 405
sponsored, 410 divergent previews, 122,969 contract lines, 8,848 functions — are re-derived from
the tree on every gate run and must appear in the prose. **Do not "round for readability" anywhere
in your output**: the check looks for the exact figure, and a near-miss is reported as a stale
copy.

**Quotations from source are verbatim and marked.** Where a page quotes a code comment or an owner
ruling, that is primary evidence, not decoration. Preserve blockquote formatting.

**Every prose page ends with `## Sources`.** Those are provenance, not further reading. A reader
verifying a claim starts there.

---

## 7. Tone, and why it is like that

You will notice this documentation says what does **not** work, what was got wrong, and what is
absent — at length, in a public document. That is deliberate and it is the folder's argument:

> A system that only publishes its capabilities is asking to be trusted. One that publishes its
> costs and its failures can be evaluated.

Concretely: `60-methodology/04-what-went-wrong.md` is a catalogue of failures including checks
that reported success while proving nothing. `25-defi/02-swap-pools.md` names a permanent,
bounded precision loss that was assessed and declined rather than fixed.
`70-comparison/02-versus-an-amm.md` has a section on where the competitor is better.
`80-cryptography/` records that the production curve's point count could not be independently
confirmed.

**Do not soften, summarise away, or bury these when you build.** They are load-bearing. A reader
who finds them is the reader this was written for.

---

## 8. If you change something

| you want to | do this |
|---|---|
| fix a typo in prose | edit the file |
| fix a number | **fix the generator or the code**, then `_docsall.py --write` |
| fix anything between `@generated` markers | edit `REPL/tools/_docspages.py` |
| fix the entrypoint catalogue, glossary or source map | edit `REPL/tools/_docsref.py` |
| add a section | add it to `BUILD-PLAN.md` first — the link checker reads the plan to know what is *planned* versus *dangling* |
| check you broke nothing | `python3 REPL/tools/_docsall.py --check` |

---

## 9. Where to go from here

| | |
|---|---|
| `README.md` | why this folder exists and what it is not |
| `BUILD-PLAN.md` | what every file is and what it must contain |
| `MAINTAINING.md` | why it will not be stale in a month — a directive requirement, not housekeeping |
| `90-reference/04-the-owner-directive.md` | the commissioning brief, verbatim |
| `90-reference/03-how-these-figures-were-obtained.md` | the command behind every number |
| `30-modules/00-INDEX.md` | all 96 modules, grouped by layer, in deploy order |

**One note on `BUILD-PLAN.md`:** it plans 132 files and 148 exist. The difference is the module
section, which the plan sized at 79 and the chain reports as **96**. That gap is left visible on
purpose — the plan's figure was a count of something else, and taking the number from the chain is
what found it. It is a small example of the rule this whole folder runs on:

> **Count, do not recall.**
