# `defcap` validation body order (Ouronet)

For component / recipe caps with inline validation (e.g. **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**):

## Order

1. **`let`** — bind booleans / reads (see **`let-binding-layout.md`**: refs, **`;;`**, vars).
2. **Outside-module side effects** — **`UEV_*`**, **`CAP_EnforceAccountOwnership`**, **`UEV_Fee`**, etc. that are **not** plain booleans for one **`enforce`** (per **`pact-enforce-boolean-grouping.md`**).
3. **Single boolean `enforce`** — 1 predicate plain; 2 → **`(and p q)`**; 3+ → **`(fold (and) true […])`**.
4. **Capabilities last** — **`CAP_*`**, then **`compose-capability`** chain (**`P|CALLER`**, **`MODULE|GOV`**, **`SECURE`**, …).

## Example

```pact
(defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (...)
    (let
        (
            (staked-bal:decimal (UR_AQP|DPTFTrackerBalance ...))
            (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
            ...
            (tracker-ok:bool (or direction (>= staked-bal amount)))
        )
        (UEV_StakeBeneficiaryAccount beneficiary-id)
        (enforce (fold (and) true [class-ok scores-ok dptf-ok tracker-ok]) "...")
        (CAP_StakeOwner owner-id)
        (compose-capability (P|AQP|CALLER))
        (compose-capability (AQP|GOV))
        (compose-capability (SECURE))
    )
)
```

**Cursor skills:** `.cursor/skills/ouronet-pact-enforce/SKILL.md`, `.cursor/skills/ouronet-pact-conventions/SKILL.md`.
