# Ouronet Documentation

The comprehensive written documentation of everything the Ouronet code does, written for a
reader who arrives knowing nothing and needs to understand what this system is.

Ouronet is the **Sovereign DeFi Layer of StoaChain**. If you have met the phrase "virtual
blockchain", read the note in `00-orientation/01-what-ouronet-is.md` — that designation was
retired, and this folder uses the current one.

**This folder is source material, not a website.** Every file here is a brick. The Ouronet
website agent assembles them into the published Documentation + Audit region; nothing here
concerns itself with navigation, styling or routing.

---

## Why this folder exists, and why it is not `OuronetInformational/`

`OuronetInformational/` is the project's working memory: 200 files, 413,000 words of handoffs,
defect ledgers, dated decisions, tool notes and canon. It is invaluable and it is **not
documentation** — it is addressed to whoever is building the thing, assumes the reader was
present for the argument, and nobody can tell from the outside what is current.

This folder is the opposite: addressed to someone who was not here, current by construction,
and organised by what a reader wants rather than by when we learned it.

The two must not merge. Where a fact lives in `OuronetInformational/`, this folder **cites it
rather than copying it**, because a copy is a second version to keep in step and this project
has been bitten by that repeatedly.

## Why it could only be written now

Every prior attempt failed the same way: document a module, then the next, while new code kept
arriving — so the work was thrown away because the shape had not settled. The directive that
created this workstream said so plainly, and made it a capstone gated on the final shape being
deployed.

That gate opened on 2026-09-27, when the last outstanding contract fix went to mainnet. The
code this documents is the code that is running.

## What is being documented

| | |
|---|---|
| `.pact` source files | 105 |
| modules / interfaces declared | 99 forms (98 names) / 98 |
| lines | 122,969 |
| `defun` forms | 8,848 |
| capabilities | 988 `defcap` |
| schemas / tables | 206 / 231 |
| the deploy round | 80 modules + 85 interfaces, 24 transactions |
| client entrypoints | 423, catalogued machine-readably |

Measured 2026-09-27, scoped to `1_SOVEREIGN/` + `2_CITIZEN/`. **Re-measure rather than trusting
this table** — the commands are in `90-reference/03-how-these-figures-were-obtained.md`, which
also records why an earlier version of this very table said "68 interfaces" and was wrong.

## The shape of it

```
00-orientation/   what Ouronet is, and why it exists at all
10-architecture/  the layer cake, sovereign vs citizen, deploy order, the gas model
20-assets/        the four asset types, their special variants, what each one IS
25-defi/          the three pool families — staking, swapping, earning — and their formulas
30-modules/       the per-module reference — the bulk of the work
40-journeys/      what a holder, an issuer, a pool owner, a builder can actually DO
50-economics/     why it costs what it costs, honestly
60-methodology/   StoicSyntax, and how a naming discipline made the code semi-self-auditing
70-comparison/    what this buys that an ERC-20 and a Uniswap pool do not
80-cryptography/  the custom curve, account derivation, browser Schnorr — the non-Pact layer
90-reference/     catalogues, figures, the directive verbatim, and where every number came from
```

Read `BUILD-PLAN.md` next: what each of the 132 files is, what it must contain, the order to
write them in, and which are done. Then `MAINTAINING.md`, which is why this folder will not be
stale in a month — it is a directive requirement, not housekeeping.

The commissioning directive itself is quoted verbatim in
`90-reference/04-the-owner-directive.md`. Every claim this folder makes about *intent* traces
there, because a paraphrase of intent decays: the first draft of the build plan was derived from
a same-day summary of that conversation and had lost two requirements and inverted one term.

## The rule every file here follows

**A figure is read, not remembered.** Where a number appears it was computed from the source,
the registry, or a live chain read at the time of writing, and the file says which. This is not
style — three separate rounds of this project found published figures that had gone stale while
every document agreed with every other one. Internal consistency is not evidence.

It is not an aspiration either. Applying it to this folder's own front page found two wrong
figures in the first pass.
