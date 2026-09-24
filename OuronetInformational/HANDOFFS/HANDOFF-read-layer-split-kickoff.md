# HANDOFF — read-layer split, kickoff signal

Short pointer, not a new plan. Owner has reviewed the shape and wants module-code migration
started now, on `dev`/local, per the existing plan.

## Start here, in this order

1. `HANDOFF-read-layer-split.md` (this folder) — why, module shape, the ids-registry decision.
2. `HANDOFF-ui-rewire-map.md` (this folder) — page-by-page UI call sites, in migration order,
   plus the write-side arity defects found in the same sweep (separate from reads, still open).
3. `2_CITIZEN/Stage_Z/READS_UI/README.md` — the numbered roster (`01_RD-HEADER` … `11_RD-PYTHIA`),
   rules (no tables, no hardcoded ids, no unexercised functions), and testing posture.
4. `2_CITIZEN/Stage_Z/READS_EXPLORER/README.md` — same idea for Explorer; greenfield, proposed
   roster only, owner should cut it before building.
5. `daimons/OuronetUI/docs/READ-LAYER-SPLIT-UI-CROSSCHECK.md` — an independent inventory built
   from the OuronetUI + `@ouronet/ouronet-core` + `@ancientpantheon/codex` package contents
   (not from this repo's source), cross-checked against #2 above. Confirms the roster is complete
   and adds nothing new except naming the three `RD-PYTHIA` reads (`0031`, `0033`, `0034`) as
   Codex-package-only callers — worth knowing since no OuronetUI source file references them
   directly, so they're easy to lose track of.

## State right now

- `01_RD-HEADER.pact` is **built** — use it as the template, per `READS_UI/README.md`.
- Nothing else in `READS_UI/` or `READS_EXPLORER/` exists yet.
- Next in the rewire-map's suggested order is `RD-WALLET` (`URC_0002_Primordials` — dashboard
  body / net-worth chart), since the argument-list drift guard (rewire-map step 1) and the
  `DPTF|C_Transfer` write-side fix (step 2) are UI/core-repo work, not blocking this repo.

## Scope reminder

- **Localhost only** — no dev/master deploy without explicit go-ahead.
- Reads only in this pass. The write-side arity/rename defects in `HANDOFF-ui-rewire-map.md`
  (`DPTF|C_Transfer`, `SmartSwap` bundle decision, `KPAY`/`SPARK` relocations) are a separate,
  already-scoped body of work — don't fold them into the read-split modules.
- `DPL-UR` stays deployed and becomes a stub as functions move out, per archive mode
  (`StoicSyntax-Prefixes.md` §7.21) — never delete a function anything still calls.

Go ahead and continue the roster from `RD-WALLET` down.
