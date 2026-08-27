# Pact module sizing — a HARD RULE for Ouronet contract code

> Applies to **every** module and interface written in this repo. Section 6 is the
> user-facing text for the Ouronet informational / docs section (roughly verbatim).
> Source: owner directive 2026-08-27.

## 1. The rule

| Band | Lines | Action |
|------|-------|--------|
| Target | under **3,500** | fine |
| Acceptable | 3,500 – 4,000 | only **with a plan** |
| Warning | 4,000 – 4,500 | **start designing the split now** |
| Danger | above 4,500 | **split before deploying** |
| Impossible | ~6,635 | cannot be deployed at all, ever |

These are for **StoaChain's 2,000,000 block gas limit**. On Kadena mainnet (150,000)
the impossible line sits at roughly **2,900 lines**, so anything intended to be portable
should stay well under that.

Measured constants, from the real FVT module: **~59.7 bytes per line** of Pact,
**~0.85 gas of module-load execution per byte**. Re-derive from your own code if it
differs materially.

## 2. Why — the cost of a module is not linear in its size

A deployment pays two costs. Execution (loading the module) grows roughly linearly.
The **SIZE charge grows as the SEVENTH POWER** of the transaction's size.

```
lines      size charge      exec      TOTAL     % of 2M   size % of its own cost
1,000              600    50,731     51,331       2.6%          1.2%
2,000            1,569   101,463    103,032       5.2%          1.5%
3,000            8,200   152,194    160,394       8.0%          5.1%
3,500           20,944   177,560    198,503       9.9%         10.6%
4,000           50,400   202,925    253,325      12.7%         19.9%
4,500          112,188   228,291    340,479      17.0%         33.0%
5,000          231,924   253,657    485,581      24.3%         47.8%
5,500          449,422   279,022    728,444      36.4%         61.7%
6,000          823,913   304,388  1,128,301      56.4%         73.0%
6,477        1,405,198   328,586  1,733,784      86.7%         81.0%
6,635        1,669,856   336,805  2,006,661     100.3%    CANNOT DEPLOY
```

Read the last column. At 2,000 lines, 1.5% of what you pay is the mere fact of being
large. At 6,000 lines it is 73% — you stop paying for your code and start paying for its
bulk. The band **3,500–4,000** keeps that share under 20% AND leaves ~2,600–3,100 lines
of growth. That is the whole justification for the rule.

## 3. Why this is about UPGRADES, not deployment

**Every Pact upgrade redeploys the entire module.** A one-character bug fix in a
6,477-line module costs the full 1,733,784 gas — not once, **every time, forever**.

A module's line count is a **permanent tax on every future change**, and it compounds as
the module grows. It is a cliff with a trap at the bottom:

- At 6,477 lines you have **158 lines of headroom for the module's ENTIRE remaining life**.
- Cross ~6,635 and you **cannot deploy any change at all** — not a fix, not a patch, nothing.
- **And you cannot split your way out**, because **Pact tables are module-scoped**.
  `(create-table FVT|T)` binds that table to that module; another module cannot adopt it.
  Splitting a deployed module with live data means new tables + a migration, and the old
  data stays where it is.

The failure mode to design against: **unable to upgrade, and unable to split your way out
of being unable to upgrade.** Splitting is cheap before deployment, structurally hard after.

## 4. How to split — by CAPABILITY, never by line count

Do NOT cut a module at 3,500 lines because a counter said so. Cut it where the
authorization boundary already is.

**Capabilities are module-scoped.** That scoping is the security property Pact is built on
— it was the subject of a CRITICAL vulnerability fixed at block 516,500
(`compose-capability` could reach across module boundaries without the module guard).
It is correct now, but it means a module boundary is a **real security boundary** and
crossing it must be deliberate.

Choosing the seam:

- **a)** Anything that shares a `defcap` belongs in the **same** module. If the split
  forces a capability to cross the boundary, you cut in the wrong place — move the seam.
- **b)** Tables go with the module whose capabilities **guard writes to them**. Permanent
  — tables cannot be moved between modules later. Get it right the first time.
- **c)** Minimise the cross-module call surface. Every `ref-` indirection is a place
  authorization can be got wrong, and now also where the module-boundary guard does real work.
- **d)** Prefer **one clean seam over two arbitrary ones**. Two coherent modules beat three
  incoherent ones. If there is no natural seam, that is information: the module may genuinely
  be one thing — keep it small by **removing** code rather than cutting it.

## 5. What to check before deploying

The Ouronet execute console shows **DEPLOY HEADROOM**: a stacked gas bar (execution + size),
the byte size, the line count, the ceiling in lines, and remaining headroom.

- If it says you are over, you are **over**. The tx cannot be mined at any gas limit;
  raising the limit does nothing.
- If size is more than ~25% of your total, the module is **too big regardless** of whether
  it fits — you pay for bulk on every future upgrade.
- Headroom under 1,000 lines means **plan the split now**, not later.

Note: a failure reading `Cannot find module: ...` is a **DEPENDENCY** problem, not a size
problem. Deploy interfaces and dependencies first. Do not conflate them.

## 6. Text for the Ouronet informational section (user-facing, ~verbatim)

> **Module size limits**
>
> Chainweb charges a transaction for its size, and that charge grows as the seventh power
> of the size. Below about 50 KB it is a single unit of gas. Above about 387 KB — roughly
> 6,600 lines of Pact — no transaction can be mined at all, whatever gas limit you set.
>
> Because every Pact upgrade redeploys the whole module, a module's size is not a one-off
> cost. It is charged again on every future change.
>
> Keep modules under 3,500 lines. Above 4,000, plan to split. A 6,000-line module spends
> 73% of its deploy cost on simply being large, and leaves almost no room to grow.
>
> Split along capability boundaries, not by line count: code that shares a capability
> belongs in the same module, and tables belong with the module whose capabilities guard
> them. Tables cannot be moved between modules afterwards, so this choice is permanent.
>
> Splitting is also dramatically cheaper. Because the charge is a seventh power, halving a
> module divides its size charge by 128 — two modules of 3,200 lines cost about a tenth of
> one module of 6,400.

---

## Ouronet applicability note (2026-08-27)

Several sovereign cores are already large (FVT is the biggest — ~400 defuns). Under this
rule, **audit line counts before the next mainnet deploy** and identify capability seams for
any module in the Warning/Danger band. Cross-reference with `MODULE_ARCHITECTURE.md`
(prefixes/capability bands) when choosing seams — the C1–C4 cap bands and the `XI/XE/XB`
split already hint at natural authorization boundaries.
