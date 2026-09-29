# The price sheet

Every price is published, and the publication is **generated from the contracts** rather than
written.

`OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md`

This chapter does not copy it. Copying would create a second source of truth that drifts — which is
precisely the failure the generation exists to prevent.

---

## What it contains

**440 priced client functions**, across 29 module sections:

| | |
|---:|---|
| **183** | an exact price |
| **137** | a floor price — the operation scales with an item count |
| **2** | native-currency only |
| **118** | free or administratively exempt |
| **11** | unpriced, each with its reason stated |

Each row carries the entrypoint, its category, the virtual-gas price, the native price where one
applies, the dollar equivalent, and **the breakdown** — which deterrence entry and which components
produced the number.

That last column is what makes the sheet auditable rather than merely informative. A price is not
asserted; it is shown as a sum you can check against the maps in `01-the-cost-model.md`.

---

## Why "floor price" is a category

137 operations — nearly a third — do not have a single price, because they scale with how many
items you give them. A bulk transfer of three costs less than a bulk transfer of thirty.

The sheet publishes the **floor**: the minimum, with a note on what multiplies it. That is the
honest representation. Publishing an example price would be a number that is right once and wrong
every other time, and publishing nothing would hide a third of the surface.

---

## It is gate-enforced

The sheet and its companion worksheet are **regenerated and diffed on every gate run**. A
discrepancy is fatal.

The rule that follows is absolute: **edit the generator, never the artefact.** A hand-edited
generated file is a lie with a deadline — it survives exactly until someone regenerates.

That enforcement was itself once defective, in a way worth knowing about because it is the subtlest
failure in this project's record. The verifier's argument dispatch passed a *write* flag when given
`--check`, so **verify mode silently rewrote the artefacts and then reported no drift**. The
post-mortem is in the tool:

> A checker that resolves drift by overwriting it is worse than no checker: **it is a green light
> wired to nothing.**

It now hardcodes read-only, proved by re-injecting a known defect and watching the gate name the
line.

---

## A generated sheet still has to be generated correctly

Two further defects in the same generator are worth recording, because both were silent.

**A total that dropped a category.** The footer summed three of four groups. The sheet listed 442
rows and published 431 — and the artefact check *required* the prose to quote the wrong total:

> **The gate enforced the undercount, and anyone correcting the prose would have turned it red.**

**A rename outran the tool.** The gas collectors were renamed; the generator still matched the old
name. Nothing failed — three entrypoints simply stopped being recognised and fell through to a
generic case, so the sheet quietly stopped naming the cost reader holding their real price.

> A price sheet that drops an entrypoint silently reports as complete **while a client can still
> call them and be charged.** A rename pass has to carry the **tools** that grep for the old name.

---

## How to use it

**To find what an operation costs**, read the row. The dollar column is authoritative at the peg;
the virtual-gas column is what is actually charged.

**To check a price is right**, read the breakdown column and add up the maps yourself.

**To find what changed**, diff the file between releases. Because it is generated, a diff is a
statement about the contracts — not about who edited the documentation.

**To get a live quote**, don't use the sheet at all. Call the operation's preview function, which
runs the same cost reader the charge will use. The sheet is a catalogue; the preview is the price.

---

## Sources

- `OuronetInformational/IGNIS-PRICING/IGNIS-PRICE-SHEET.md` — the sheet
- `REPL/tools/_ignis_price_sheet.py` — the generator
- `REPL/tools/_pricesync.py` — the gate check

Totals in this chapter are the sheet's own generated footer, read rather than recounted.
