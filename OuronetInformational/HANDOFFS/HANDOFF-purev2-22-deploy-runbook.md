# Runbook — deploying PureV2/22, and the five things that go stale when you do

Written 2026-09-27, before the deploy rather than after, because every consequence below is a
CHECK that will start failing and it is cheaper to know why in advance than to debug it.

## What is being deployed

`Deploy/PureV2/22_deploy.pact` — the ATS module, module-only, carrying two fixes:

- `UCx_FilterHibernatedAts` drops the `[BAR]` sentinel before any table read. Without it,
  `O-UI-EIGHT::URC_07|Buttons` RAISES for any token whose two-hop reward chain dead-ends —
  measured, 1 of 15 held tokens.
- `UC_CanCoil` / `UC_CanConstrict` derive their flag from their target list, as their two
  siblings already did. Without it, Constrict lights up with nowhere to act.

```
3,166 lines · 1 module · 0 interfaces · 0 create-table
```

Zero interfaces because Pact refuses an interface name twice; zero `create-table` because this is
an upgrade. Both were verified on the emitted file, not assumed.

## Before you send it

The registry snapshot was confirmed against the chain on 2026-09-27: **12 modules, 12 current,
0 drifted**. So what follows is drift caused by the deploy, not drift that was already there.

## After you send it — in order

**1. The live check will report ATS drifted.** Expected. A Pact module hash changes on any
redeploy, and this one carries a real change.

```
python3 REPL/tools/_registrylive.py
```

**2. Regenerate the registry.** The surface is UNCHANGED — this deploy alters no signature, only
three function bodies — but `moduleHash` is embedded in every entrypoint record, and ATS carries
its own entrypoints (`ATS.HOT-RBT|C_*`, the ones the gas station does not sponsor). So the
artefact must be re-read from the chain. `--probe` is the flag that does that; `--check` is
offline and only compares the artefact to itself, which is the gap this whole step exists
to close:

```
python3 REPL/tools/_registry.py --probe        # reads the CHAIN and rebuilds; needs network
```

**3. The `surfaceHash` WILL change**, even though nothing callable changed. It is a sha256 over
entrypoints + previews, and entrypoints carry `moduleHash`. Today it is `7e59e59d4c5b7257`.

This is worth saying plainly because it looks alarming and is not: **a changed surfaceHash after
a body-only upgrade means the hash is doing its job.** It tracks the deployed bytes behind the
surface, not just the shape of it.

**4. `_pkgsync` will warn** that `@ouronet/talos-registry` carries a stale surface, because the
package bundles a snapshot rather than fetching at runtime. Re-sync it, bump its version and
republish. Consumers pin it exactly, so nothing moves until they choose to.

**5. Record the new confirmation**, so the artefact's "last checked against mainnet" date is the
truth rather than the date of the last time someone remembered:

```
python3 REPL/tools/_registrylive.py --record
```

## How to tell it worked

Two reads, no signing. Before the deploy both are broken; after, both should be clean:

```
(ouronet-ns.O-UI-EIGHT.URC_07|Buttons "<your account>" "AURYN-8Nh-JO8JO4F5")
    now: No value found in table ouronet-ns.ATS_ATS|Pairs for key: |
    then: an object with 19 button flags

(ouronet-ns.ATS.UC_CanConstrict "OURO-8Nh-JO8JO4F5")
    now: {"can-constrict": true,  "where-constrict": []}     <- lit, nowhere to act
    then: {"can-constrict": false, "where-constrict": []}
```

The UI needs no redeploy for either. It already fails CLOSED on a failed permission read, so
AURYN currently shows "permissions unavailable for this token" rather than every button lit —
correct behaviour before the fix, and it simply starts working after it.

## What does NOT change

No table is created or migrated. No entity id moves. No interface is touched, so no cascade.
No signature changes, so no consumer has to be rebuilt to keep working — `_pkgsync` is a
freshness warning, not a compatibility break.

## Cross-references

- `Deploy/PureV2/22_deploy.pact` — the transaction, with its own long-form header
- `OuronetInformational/memories/2026-09-27-bar-sentinel-sweep.md` — why only this one site needed fixing
- `REPL/modules/STAGE-Z.repl` `<<STAGEZ-13>>` / `modules/OUROBOROS.repl` `<<ORBR-SENTINEL>>` — the regression proofs
