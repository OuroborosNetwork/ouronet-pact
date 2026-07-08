# `defcap` validation body order (Ouronet)

For component / recipe caps with inline validation (e.g. **`AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY`**, **`PYTHIA|C>DEPLOY-STANDARD-API-KEY`**):

## Order (strict)

1. **`let`** — bind booleans / reads (see **`let-binding-layout.md`**: all **`ref-*:module{…}`** first, **`;;`**, then locals).
2. **Native Pact guards** — **`enforce`**, **`enforce-guard`**, **`enforce-one`**, **`enforce-keyset`** (plain Pact builtins; not module **`UEV_*`**).
3. **Cross-module ref calls** — **`ref-U|DALOS::GLYPH|UEV_*`**, **`ref-DALOS::UEV_*`**, **`ref-DALOS::CAP_*`** invoked inline (anything via **`ref-MODULE::…`** that enforces or validates).
4. **Home-module inline caps** — **`CAP_*`** / **`PYTHIA|OWNER`**-style helpers when invoked as a **function call** in the cap body (not via **`compose-capability`**).
5. **`compose-capability` last** — **`PYTHIA|OWNER`**, **`GOV|…_ADMIN`**, **`PYTHIA|CRONOTON`**, **`SECURE`**, **`P|CALLER`**, etc.

**Rule of thumb:** *enforce first → ref validators → compose caps.*

Do **not** place **`compose-capability`** before **`enforce`** or before **`ref-*::UEV_*`** calls.

## Example (PYTHIA deploy)

```pact
(defcap PYTHIA|C>DEPLOY-STANDARD-API-KEY
    ( owner-account:string apollo-account:string public:string consumer-lane:string )
    (let ((ref-U|DALOS:module{UtilityDalosGlyphsV2} U|DALOS))
        (enforce (!= public "") "Public key material must be non-empty")
        (ref-U|DALOS::GLYPH|UEV_ApolloAccount apollo-account false)
        (ref-U|DALOS::UEV_StoicTagName consumer-lane)
        (compose-capability (PYTHIA|OWNER owner-account))
        (compose-capability (SECURE))
    )
)
```

## Example (AQP recipe cap)

```pact
(defcap AQP|XE>TRUE-FUNGIBLE-POOL-CUSTODY (...)
    (let
        (
            (staked-bal:decimal (UR_AQP|DPTFTrackerBalance ...))
            (class-ok:bool (URC_StakeTrueFungiblePoolClassOk pool-id))
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

**Note:** **`UEV_*`** defined in the **same module** may appear in step 3 (after **`let`**, before boolean **`enforce`**) when they are reusable validators called from the cap — see AQP pattern above.

**Cursor skills:** `OuronetInformational/pact/enforce.md`, `OuronetInformational/ouronet/conventions/index.md`.
