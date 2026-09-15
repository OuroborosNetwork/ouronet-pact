# An abbreviation is not an identity

*2026-09-15. Red-team Stage 11, RT-D-002. Found while extending family J into DPDC.*

## The defect in one line

**`DPDC|NonceElement.nonce-holder` stores an 11-character abbreviation of the owner, and the NFT
possession gate compared it.**

```pact
(defun OI|UC_ShortAccount:string (account:string)      ;; 02_IGNIS.pact
    (concat [(take 5 account) "..." (take -3 account)]))
```

Two of those five leading characters are the fixed `Ѻ.` prefix, so the stored value carries **six
characters of entropy** out of a 162-character account.

`UEV_NonceQuantityInclusion` — the gate inside `DPDC-C|C>SINGLE-DEBIT`, which guards **every NFT
debit, burn and transfer** — had this shape:

```pact
(let ((nonce-supply (UR_AccountNonceSupply account id son nonce)))   ;; keyed by the FULL account
    (if (or son (< nonce 0))
        (enforce (<= amount nonce-supply) ...)     ;; SFT branch: spends it
        (... (enforce (= sa nft-holder) ...))))     ;; NFT branch: binds it and NEVER USES IT
```

## Why no grinding is needed

`GLYPH|UEV_DalosAccount` enforces exactly four things: **length 162**, first char `Ѻ` or `Σ`, second
char `.`, body in `DALOS|CHARSET`. **No checksum. No binding between the account string and the
guard.** The account name is chosen freely by whoever deploys it.

So a collider is *written down*, not searched for:

```
collider = "Ѻ." + victim_body[0:3] + any_other_real_account_body[3:157] + victim_body[157:160]
```

`CAP_EnforceAccountOwnership account` does not help — the attacker names their **own** account and
owns it genuinely. `DALOS|C_DeployStandardAccount` is a permissionless client wrapper whose STOA fee
is toggle-conditional, so the collider can cost nothing.

## The fix was already inside the function

`nonce-supply` is read from `AccountSupplies`, whose key carries the **complete 162-character
account**. The NFT branch now spends it, and keeps the abbreviation compare with its **own message**
because that check carries a second meaning (an inactivated NFT stores `BAR` there):

```pact
(enforce (<= amount nonce-supply) "Account {} doesnt hold NFT {} Nonce {}")
(enforce (= sa nft-holder)        "NFT {} Nonce {} is not active on Account {}")
```

**Safety established before changing it**, not assumed: across the harness's DPNF population, all
6 active nonces have exactly one full-account holder with supply 1 whose short form equals the
stored abbreviation, and all 7 inactive nonces are held by nobody.

## The generalisable lesson

`OI|UC_ShortAccount` lives in the INFO module. Its ~20 other call sites are all `TS01-C1` Talos
result strings — exactly what it was built for, and harmless. **One caller persisted it and then
compared it.**

> Grep for a display/formatting helper appearing inside an `enforce`, a `defcap`, or a table write.
> A value built to be *read by a human* is lossy on purpose.

## Cheap check worth repeating elsewhere

**A `let` binding that one branch uses and another ignores is worth reading twice.** Here the
unused binding was not dead code — it was the *correct* check, already computed, on the branch that
needed it most. `_deadbind.py` counts fully-dead bindings; a binding that is live on one branch and
dead on another is invisible to it.

## Related facts recorded on the way

- DPNF `nonce-supply` is **"Always 1 for NFT, even when burned or wiped"** (schema, `01_DPDC-UDC.pact:55`)
  — it is NOT a conserved quantity. `nonce-holder = BAR` means *inactivated*.
- DPSF conserves normally: per-nonce supply == sum of `AccountSupplies` over holders. Verified
  across 72 nonces, 0 mismatches.
- DPDC exposes only `URH_AS-Keys` (AccountSupplies keys). No id or nonce enumerator — the same
  structural gap as `DALOS|AccountTable`. Ids and nonces must be derived from holding rows, so an
  id with **zero** holdings anywhere is invisible to a sweep.
- `U|LST::UC_SplitString "|" k` is the way to parse these composite keys; ids themselves contain
  bars (`E|DH-…`, `Z|P|OURO-BUSD|LP-…`), so split-and-rejoin the middle segments.

## The fix I applied first was wrong, and the gate caught it

My first version put the new full-account check FIRST and **reused the original error message on
it**, giving the abbreviation compare a new one. The gate went red on
`[6.4]_AQP-EXHAUSTIVE-DPNF.repl` `<<TX-AQP-NF01>>`, whose whole point is to pin *which* guard
answers:

```
expected 'doesnt hold NFT DHB-… Nonce 1'
got      'NFT DHB-… Nonce 1 is not active on Account Ѻ.A0ěь…'
```

It also told me something I had not known: that AQP path calls the gate with **amount = 0**, so
`0 <= 0` passed and the second check answered. A quantity check does not subsume a possession check
when the quantity is zero.

**The corrected fix is purely additive**: the original check keeps its original position and its
original message, and the new one is appended with a distinct message. Every refusal that fired
before still fires, with the same wording; only the collider — which passes the abbreviation compare
by construction — reaches the new check.

> A fix that *renames* an existing error message is an interface change, not an addition. Message
> pins are the project's main tool for proving a refusal came from the right guard, so renaming one
> silently invalidates whatever it was protecting.

`<<RT-D-002e>>` and `<<RT-D-002f>>` now pin both messages, so neither check can be removed or
reordered without a red gate.
