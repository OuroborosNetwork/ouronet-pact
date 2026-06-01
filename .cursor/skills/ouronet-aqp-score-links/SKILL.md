---
name: ouronet-aqp-score-links
description: AQP-SCORE link fields — XI vs XE patterns, SECURE vs SCR|XE caps, BAR immutability, BoostClass existence via AcquisitionAnchors. Use when adding or editing score links, forward-module calls into AQP-SCORE, or ANK interface surface for anchors.
---

# AQP-SCORE — link writers (`XI_*` vs `XE_*`)

## Roles

- **Link slots** on **`SCR|Schema`** (**`boost-class-link`**, **`boost-link`**, **`aqpool-link`**, **`fvt-link`**) are **`[..]`** immutable once set: the **`defcap`** must enforce **`(= <slot> BAR)`** before the write.
- **Score ownership:** **`CAP_EnforceAccountOwnership`** on the score's **`owner-konto`** for all four link operations.

## `X*` do not return `OutputCumulator`

**`XI_*`** / **`XE_*`**: **writes only** — end the body on **`insert`/`update`/`write`** (no **`true`** tail). **`IGNIS::UDC_*`** belongs in **`C_`** or the forward orchestrator.

## Internal path (`C_` → `XI_*`)

- **`C_CreateBoostClassLink`**, **`C_CreateBoostLink`**: read **`owner-konto`**, **`UEV_IMC`**, **`with-capability (SCR|C>CREATE-…)`**, **`XI_*`**, then **`UDC_BiggestCumulator`** in **`C_`**. **No STOA.**
- **`defcap`:** validations + **`compose-capability (SECURE)`**.
- **`XI_*`:** **`require-capability (SECURE)`**, **`update`** (terminal).

**BoostClass exists:** call **`AQP-ANK::UR_BC|Active`** via **`module{AcquisitionAnchorsV1} AQP-ANK`**. The **`SCR|C>CREATE-BOOST-CLASS-LINK-SCORE`** cap enforces the BoostClass is active.

**AQP-ANK acnoi=true -> acnoi=false in same tx (important):**
- When a later call in the same transaction needs the BoostClass ID created inline by an earlier `AQP-ANK|C_Issue*Anchor ... acnoi=true ...`, derive the ID using **`U|DALOS::UDC_Makeid(<boost-class-name>)`**.
- Do **not** build the ID with string concat patterns like `<name>-<asset-id>`; ANK creates BoostClass IDs with `XI_IssueBoostClass -> U|DALOS::UDC_Makeid`.

**Boost score exists:** read **`SCR|T|Score`** for **`boost-score-id`** **after** ownership enforcement; **`fold (and)`** for BAR slot, non-BAR id, **`≠ score-id`**, and **`score-id` field matches key**.

## Forward path (`XE_*`)

- **`XE_CreateAqpoolLink`**, **`XE_CreateFvtLink`**: **`UEV_IMC`**, **`with-capability (SCR|XE>…)`**, **`update`** (terminal). Caller supplies **IGNIS** **`OutputCumulator`**. **No `SECURE`.**
- **`defcap` `SCR|XE>…`:** only **this module's** (and already-deployed deps') rules: owner, slot **`BAR`**, target id **≠ `BAR`**. **Do not** put pool-class / FVT-membership logic here — that belongs in **`AQP`**, **`FVT`**, or Talos **before** calling **`XE_*`**.

## Boolean `enforce` style

Follow **`ouronet-pact-enforce`**: 1 predicate → plain **`enforce`**; 2 → **`(and p q)`**; 3+ → **`fold (and) true [...]`**.

## Doc

See **`README_SCORE.md`** and **`README_ANK.md`** in **`1_SOVEREIGN/STAGE_02/2_Core/03_AQP/`** for full architectural documentation.
