# What is not on chain

The most important chapter in this section, and the shortest to state:

> **The chain validates the shape of an account identifier. It never validates where it came
> from.**

Everything below follows from that.

---

## 1. What the contracts actually check

Four things, and only four:

```pact
(enforce (= account-len 162) …)
(enforce-one …  first character is 'Ѻ' or 'Σ'  …)
(enforce (= second ".") …)
(enforce (GLYPH|UEV_MsDc (drop 2 account)) "Characters do not conform to the DALOS|CHARSET")
```

Length, type glyph, separator, and alphabet membership. That is the entire on-chain notion of a
valid account.

The alphabet is mirrored into the contracts — all 256 glyphs, assembled from ten named constants —
so the fourth check is real. **The derivation is not mirrored.** No hashing, no encoding, no curve
arithmetic exists anywhere in the 237 contract files.

**Any 162-character string over the right alphabet is a valid account**, whether or not any key
produces it.

---

## 2. The binding that does not exist

An account row stores a `public` field — about 575 characters, the encoded curve point.

**Nothing on chain checks that it derives the account it sits beside.** They are two opaque strings
in one row. The field is written verbatim at account creation with no length check, no format
check, and no consistency check.

So the chain knows:

- this identifier is well-formed
- this string is stored next to it

and does not know, and cannot determine, that the second produces the first.

### Why this is not simply a flaw

It is load-bearing for two features that could not otherwise exist.

**Key rotation.** An account's controlling guard can be changed. If the identifier were derived
from the key on-chain, rotating the key would mean a different account — and the balance would
belong to a name nobody controls.

**Administrative recovery.** There is a path for an administrator to overwrite an account's public
key, and its documentation states the reasoning:

> The executor's ownership is enforced **indirectly**, by the administrative key alone —
> deliberately, because this is the path used when an account holder has **lost the key that would
> prove that ownership**.

A recovery mechanism cannot require the thing being recovered. That path is only coherent *because*
the chain never bound the key to the identifier.

Both are real capabilities with real value. They are also real trust: **an administrative key can
rewrite whose key controls an account**, and no cryptographic check downstream will object.

---

## 3. What only the client holds

| | |
|---|---|
| **the seed material** | words, bits, or an integer — the actual secret |
| **the private scalar** | never stored; re-derived on every use |
| **the derivation** | the hash chain, the glyph matrix, the encoder |
| **the key-to-account binding** | verified in the browser, nowhere else |
| **signature verification** | no Pact verifier exists |
| **the spending key** | the Ed25519 key that signs transactions |

The client verifies what the chain cannot. The one live signing flow **regenerates the account
identifier and compares it** before asserting ownership — because that comparison has no on-chain
equivalent.

---

## 4. What this means in practice

**For a user.** Your account's security is your seed's security. The chain enforces the guard on
your account; it does not enforce that the guard has anything to do with the identifier you
recognise as yours.

**For a wallet.** Derive, then **verify your own derivation** against the account you were given
before signing anything. Do not assume a well-formed identifier is one your key produces — the
chain accepted it either way.

**For an auditor.** The on-chain trust boundary is narrower than the system appears. Account
identity is enforced by *client software and an administrative key*, not by the contracts. That is
a defensible design and it is not the one a reader would assume from the contracts alone.

**For anyone weighing the custom cryptography.** A flaw in the curve does not directly compromise
funds, because the curve does not guard funds — the guard does, and it is a host-chain keyset.
What a flaw compromises is **identity**: the claim that an account belongs to whoever holds a
particular seed.

---

## 5. Stated plainly

The custom cryptography's role is **naming**, not **authorisation**.

It derives an identifier, deterministically, from a seed. The chain then treats that identifier as
an opaque, well-formed string and enforces access through an ordinary host-chain guard stored
beside it.

Once that is clear, the whole design reads differently — and the two things it costs are visible:
the chain cannot tell a derived account from a hand-made one, and an administrative key can
substitute the public record of who owns it.

Both are documented in the contracts themselves. Neither is hidden. Neither is a small thing.

---

## Sources

- `1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact` — the four format checks and the alphabet
- `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact` — the account row and the recovery path
- `daimons/OuronetUI/src/routes/verify.tsx` — the client-side binding check
- `_libs/DALOS_Crypto/` — everything the chain does not contain

The absence of cryptography in the contracts was verified by searching all 237 `.pact` files for
hashing, encoding and curve arithmetic. There is none.
