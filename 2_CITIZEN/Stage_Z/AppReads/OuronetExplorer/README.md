# READS_EXPLORER — read modules for the Ouronet Explorer

Owner directive, 2026-09-24. Same rules as `../RULES.md`; read that first.

## State of the ground, measured rather than assumed

The Explorer's Pact side today is **one module, `2_CITIZEN/Stage_Z/02_EXPLORER.pact`, with two
public reads**: `UR_0001_AccountNonce` and `URC_0001_LandingPage`.

**The OuronetUI repo calls neither.** A repo-wide search for a Pact `EXPLORER.` call returns
zero hits; the only `EXPLORER` symbols in that codebase are URLs to external block explorers
(`explorer.stoachain.com`, `ouroscan.ancientholdings.eu`) and an in-app route
`/app/auxiliary/ouronet-explorer` that renders `<ComingSoon />`.

So this folder is **greenfield in a way `READS_UI` is not**. READS_UI is a migration with 26 live
call sites to preserve; this is a design with two existing reads and no consumers. That is worth
knowing before work starts, because the two folders deserve different care: READS_UI must not
break what works, and this one has nothing to break.

## Roster — PROPOSED, not agreed

Unlike the READS_UI roster, these are not derived from anything. They are the surfaces an
explorer usually has, and the owner should cut them before anyone builds them.

| # | module | surface |
|---|---|---|
| 01 | `OURO-EX-ONE`    | network-wide counters, supplies, toggles, gas collected |
| 02 | `OURO-EX-TWO`  | one account: balances, elite standing, roles, StoicTag |
| 03 | `OURO-EX-THREE`    | one DPTF/DPOF: properties, supply, holders, links |
| 04 | `OURO-EX-FOUR`     | one SWP/ATS pair: composition, fees, value, history pointers |
| 05 | `OURO-EX-FIVE`  | one collection: nonces, sets, fragments, owners |

## The constraint that will shape this folder more than any other

**Explorer reads are the heavy ones.** An explorer wants "all holders of token X", "every pool
containing Y", "the top N accounts" — and every one of those is a table scan.

Two things follow, and both are already demonstrated elsewhere in the tree:

- **`(keys OTHER.Table)` is admin-gated** in transactional mode, and permitted in `/local` only
  on a node started with `--allowReadsInLocal`. DPL-UR relies on that in five functions and it
  does work live — but it is a node-configuration dependency, not a Pact guarantee, and an
  explorer built on it inherits that dependency wholesale.
- **A scan that fits today stops fitting.** `URC_0035_EliteAccountRichList` walks every Standard
  account and insertion-sorts the result. That is O(n²) in accounts, in a read with a
  10,000,000 gas simulation ceiling. It is fine now and will not be fine forever, and the time
  to decide whether the explorer paginates is before five modules are written assuming it
  does not.

Prefer `URH_`/`URHC_` prefixes for anything that scans, so the cost is legible from the name —
the same discipline the sovereign modules use.
