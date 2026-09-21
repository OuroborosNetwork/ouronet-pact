# Foreign account deployment, and the one field the chain cannot check

**2026-09-21.** Two linked things, both arising from the attribution rule's base case.

## 1. The admin CANNOT deploy an account for someone else — verified, and now pinned

I had said the opposite earlier in the session, on the strength of an older owner note about admin
deploys. The owner corrected it and the code agrees:

`A_Deploy*Account` composes `SECURE-ADMIN`, which grants `GOV|DALOS_ADMIN` — and then reaches the
very same `DALOS|C>DEPLOY-*-OURONET-ACCOUNT` capability, and the very same
`UEV_Any [guard (create-capability-guard (GOV))]`, as the client path. `GOV|DALOS_ADMIN` is **not**
the `GOV` capability, so the second list element — the genesis door — is not satisfied either. The
admin is left needing the new account's own guard, exactly like everybody else.

So "admin deploy" means **gasless**, not **foreign**. Pinned by `REPL/modules/DALOS-ADMIN.repl`
`<<DALOS-G4b>>`, paired: the same admin, the same wrong glyph, refused by the GUARD with a guard it
does not hold and by the FORMAT with one it does.

**The absence of a foreign-deploy path is a security property**, not a gap. Anything that creates
accounts without their guard being signed is a way to create accounts other people are then told
are theirs.

## 2. The owner's sketch for a foreign deploy, recorded, NOT built

If it is ever wanted: `A_DeployForeignStandardAccount` / `A_DeployForeignSmartAccount`, over a
common core with a switch for whether the guard is enforced. That is genuinely
`(executor executee …)` — the admin acts, the new account is acted upon.

The obstacle the owner identified: **deployment needs the public key, and the public key cannot be
derived from the Ouronet account.** The admin does not have it.

Their proposed answer — deploy into a **zombie state** with `BAR` (`"|"`) as the public key, and let
the user unlock it later by supplying the real one — **already has read-side support in the tree**,
which is worth knowing before anyone designs it twice:

```pact
;; 2_CITIZEN/Stage_Z/01_DPL-UR.pact
(public-key:string (try BAR (ref-DALOS::UR_AccountPublicKey account)))
...
iz-activated  ==  (!= public-key BAR)
```

DPL-UR already treats `public == BAR` as **not activated** and returns `BAR`/`false` for every
derived field behind that flag. A zombie account would therefore read as inactive across the
deployer surface on day one, with no new convention invented. The unlock would need a client
entrypoint, which today does not exist — `A_UpdatePublicKey` is admin-only and deliberately so.

## 3. `public` is unvalidatable, and that is now written into the audit

The field is a 574–576 character Ouronet keypair half over a 50-symbol alphabet with a `9G.`/`9H.`
prefix — **not** the Kadena signing key (64 hex, inside the `guard`). Three routes to enforcement,
all closed:

- **verify a signature under it** — Pact verifies Kadena ed25519/WebAuthn and nothing else;
- **derive it from the guard** — `create-principal` reaches the *Kadena* key (this is what
  `UC_GuardProtocol` already does); `public` has no relationship to it;
- **derive it from the account name** — names are 162 chars of validated glyphs and are not a hash
  or encoding of the key. Independent strings.

So the property "this `public` is the public half of a keypair its owner holds" is **unavailable**,
not merely hard. Through the UI the field is correct by construction; through the console any
string is accepted. `A_UpdatePublicKey` is the remedy and the only writer. Stated as accepted in
`Audit/book/PART-III/02-OWNER-GATES.md`.

**The lesson worth keeping is the shape of the answer.** "Unsolvable" was right about *ownership*
and had to be checked route by route to be worth writing down — the `create-principal` route in
particular looked promising for ten minutes, because the codebase already uses it. But the same
investigation found that **`public` is the only account field inserted with no shape check at all**,
while the account name beside it gets length, prefix, separator and charset from
`GLYPH|UEV_DalosAccount`. Unenforceable-in-principle and unchecked-in-practice are different
claims, and the first is not a reason to stop looking for the second.
