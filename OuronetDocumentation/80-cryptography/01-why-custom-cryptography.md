# Why custom cryptography

Ouronet does not use its host chain's account model. It defines its own — a 162-character
identifier derived from a key on **a curve that does not appear in any standard**.

That is an unusual decision and it deserves the strongest available scrutiny, so this section
states what exists, where it lives, what has been verified, and — at length — what has not.

---

## 1. Where it lives

**Not in the contracts.** The derivation is in a separate library, in a separate repository,
published as a package:

| | |
|---|---|
| reference implementation | **Go** — the curve, the derivation, signing |
| production implementation | **TypeScript**, browser-targeted |
| pinned against | a frozen corpus of **105 test vectors**, byte-identical across both |

The Pact contracts contain **no cryptography at all**. No hashing, no encoding, no curve
arithmetic. A search across all 237 contract files finds none.

What the contracts *do* contain is the **alphabet** — the same 256 glyphs, mirrored on-chain so
that format can be validated. The shape is checkable by the chain. The derivation is not.

That split is the single most important fact in this section, and `04-what-is-not-on-chain.md` is
about its consequences.

---

## 2. What "custom" actually means here

Four distinct cryptosystems are in play, and only one is custom:

| | used for | standard? |
|---|---|---|
| a bespoke twisted Edwards curve | **the Ouronet account identifier** | **no** |
| **Ed25519** | signing transactions, paying gas | yes — RFC 8032 |
| **RSA-4096** | a permanent-storage identity | yes |
| a second bespoke curve | secondary "Codex" identities | no |

**All four derive from one seed.** A single 1,600-bit origin fans out to an Ouronet identity, a
host-chain spending account, a storage key and a secondary identity — each by a deterministic,
independent path.

So the honest characterisation is not "Ouronet rolled its own crypto". It is:

> **The identity is custom. The money is not.** Transactions are signed with stock Ed25519,
> importable by ordinary wallets.

That distinction bounds the risk. A flaw in the custom curve compromises *account identity*; it
does not by itself compromise the key that spends.

---

## 3. Why do it at all

The reasoning is not documented as a single decision, so what follows is what the design implies
rather than a recorded rationale — and it is marked as such.

**A 256-glyph alphabet makes the arithmetic exact.** The identifier body is 160 characters over
exactly 256 symbols, so it carries exactly one byte per character — 160 bytes, **1,280 bits**. A
hexadecimal or Base58 identifier of the same information would be longer and its length would not
be a round number of anything.

**One identity, many accounts.** Because derivation is deterministic from a seed, one seed
produces an unbounded family of accounts, each reachable directly by index. Nothing needs storing
between them.

**And the account is not the key.** A host-chain account *is* its public key. An Ouronet account is
a derived name, with the key stored beside it. That indirection is what permits key rotation and
administrative recovery — and it is also what removes the binding that `04` is about.

---

## 4. What has been verified

There is a verification directory with reproducible scripts, and the results are recorded honestly.

**Seven properties pass** for the production curve: both primes confirmed (50 rounds of
Miller-Rabin), the cofactor is an integer, the curve coefficient is a non-residue, the generator is
on the curve, the generator has the claimed order, and the scalar size fits.

The library's own audit ran across two weeks in 2026 and produced coded findings with fixes.

---

## 5. What has not

Four gaps, all documented in the library rather than by this chapter, and all worth stating plainly.

**No external audit.** The library says so itself:

> This is an **internal audit** … **not a substitute for a third-party cryptographic audit** by an
> accredited firm. A third-party audit is **strongly recommended**.

**The production curve's point count was never independently confirmed.** Point-counting succeeded
on three smaller sibling curves and matched their recorded values. On the production curve it ran
out of memory:

```
--- DALOS (p is 1606 bits) ---
  *** ellcard: the PARI stack overflows !
```

So the group order rests on a consistency proof — multiplying the generator by the claimed order
yields the identity — rather than on an independent count. That is meaningful evidence and it is
not the same thing.

**The password-derivation function is deliberately weak.** Single-pass hash, **no salt, no
iterations**, recorded as not-fixed-by-design to preserve a file format. Two files encrypted under
one password fall to a single key recovery. This is the function guarding the stored secret a
browser decrypts to sign.

**The secondary curve is less reviewed than the primary.** Only the production curve received the
internal audit. The secondary identities run on one that did not — which is the inverse of the
attention one would choose.

**And the audit trails the shipped code** by a minor version. What changed in between is not
covered by it.

---

## 6. How to read this section

`02-the-curve-and-derivation.md` gives the mathematics and the algorithm.
`03-signing-in-the-browser.md` covers signing and where it is actually used.
`04-what-is-not-on-chain.md` is the one to read if you only read one — it is the boundary between
what the contracts can enforce and what they simply accept.

## Sources

- `_libs/DALOS_Crypto/` — the library: Go reference, TypeScript port, test vectors
- `_libs/DALOS_Crypto/AUDIT.md` — the internal audit
- `_libs/DALOS_Crypto/verification/` — primality certificates and the point-counting log
- `_libs/DALOS_Crypto/docs/DALOS_CRYPTO_GEN1.md` — threat model and freeze policy

This section was written from the library's own sources and its own admissions. Where it states a
gap, the gap is the library's, documented there before it was documented here.
