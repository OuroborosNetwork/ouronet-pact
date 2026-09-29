# The curve and the derivation

How a seed becomes a 162-character Ouronet account.

---

## 1. The curve

A **twisted Edwards curve**, internally named for its own parameters, and not a published standard:

| | |
|---|---|
| field prime | **2¹⁶⁰⁵ + 2315** — a 1,606-bit prime |
| subgroup order | a **1,604-bit** prime |
| cofactor | **4** |
| coefficients | **a = 1, d = −26** |
| generator | **x = 2**, with the matching y |
| scalar size | **1,600 bits** |

Two properties make the implementation simpler than the size suggests.

**`d = −26` is a quadratic non-residue**, which makes the standard complete addition formula valid
everywhere — no exceptional cases, no special handling, and therefore **no branching**. A branch in
point arithmetic is a timing side channel; having none by construction is better than avoiding one
by care.

**Scalar multiplication decomposes in base 49** against a precomputed table, branch-free.

The claimed security level is roughly **2⁸⁰²** against the standard generic attack — half the
subgroup order's bit length. The library is explicit that the 1,600-bit scalar is *"a design
statement, not a security requirement"*.

Three sibling curves exist in the same family at smaller sizes. One of them carries the secondary
identities discussed in `04`.

---

## 2. From seed to key

Six entry points, all converging on one thing: **a 1,600-bit string**.

```
seed words · bit string · bitmap · base-10 integer · base-49 integer · random
```

Only the last touches a random source. Every other path is **fully deterministic** — the same input
always yields the same account.

The seed-words path is itself a **seven-fold hash chain**: the words are joined, hashed to 200
bytes, and expanded to 1,600 bits. Seven rounds, unrolled explicitly rather than looped.

The scalar then multiplies the generator to give a public point.

---

## 3. From key to identifier

This is the part worth following closely, because two steps are unusual.

### Step one — the point becomes a string

```
prefix = base49( number of decimal digits in x )
body   = base49( decimal(x) concatenated with decimal(y) )
public = prefix + "." + body
```

Two things to notice.

**The two coordinates are concatenated as decimal text, then re-read as one number.** Not
serialised as bytes — joined as digit strings.

**The prefix is a length, not a version.** The `9G.` that appears at the start of every public key
is just `483` written in base 49: the number of decimal digits in the x coordinate. Since the field
is 1,606 bits, that value is 483 or 484 and essentially nothing else. It looks like a version byte
and is not one.

The result is about **575 characters**.

### Step two — the string becomes glyphs

```
n   = parse the body in base 49          ← the prefix is DISCARDED here
s   = write n in decimal                 ← ASCII digits, not bytes
H   = hash(s) → 160 bytes                ← seven times, each feeding the next
addr = one glyph per byte
```

Again, two unusual choices.

**The prefix is dropped.** The length marker survives in the public key and plays no part in the
address.

**The hash runs seven times**, each round taking the previous 160 bytes and producing 160 more.

### Step three — bytes become glyphs

The final 160 bytes index a **16 × 16 matrix of 256 glyphs**:

```
row = byte / 16        column = byte % 16
```

Bijective — every byte has exactly one glyph and vice versa. The matrix is a hand-curated Unicode
selection: digits, currency signs, Latin, Latin Extended, Greek and Cyrillic in both cases.

**This matrix is mirrored inside the Pact contracts**, assembled from ten named constants, so the
chain can check that an identifier's characters are legal. The chain has the alphabet and not the
derivation.

### Step four — the type glyph

```
standard = matrix[0][10]  = 'Ѻ'
smart    = matrix[11][9]  = 'Σ'
```

Prepended with a `.` separator. **The type glyph is not part of the hash** — so the standard and
smart forms of one key share a **byte-identical 160-glyph body** and differ only in the first
character.

---

## 4. 162 characters, 287 bytes

Measured from a real test vector:

| | |
|---|---:|
| input bit string | 1,600 |
| public key | **575 characters** |
| account identifier | **162 characters** |
| the same identifier in UTF-8 | **287 bytes** |

That last row matters for anyone allocating storage or fixing column widths. The identifier is 162
*characters* and 287 *bytes*, because most of the alphabet is outside ASCII. The two numbers are
not interchangeable and code that assumes they are will be wrong by 125.

---

## 5. What follows from determinism

**One seed, unbounded accounts**, each reachable by index without storing anything between them.

**Nothing needs backing up but the seed.** The private key is not stored — it is re-derived on
every use, which is why the browser holds seed material rather than a key.

**And the same seed reaches other systems.** From the identical 1,600-bit origin:

```
custom curve → the Ouronet identity
Ed25519      → the host-chain account that pays gas
RSA-4096     → a permanent-storage identity
second curve → secondary identities
```

One seed, four cryptosystems, three of them standard. The path to the spending key is
**RFC 8032-compliant** — the stored value is the standard 32-byte seed, so ordinary wallet software
can import it.

---

## Sources

- `_libs/DALOS_Crypto/Elliptic/Parameters.go` — the curve
- `_libs/DALOS_Crypto/Elliptic/KeyGeneration.go` — the derivation
- `_libs/DALOS_Crypto/Elliptic/CharacterMatrix.go` — the glyph table
- `_libs/DALOS_Crypto/Chainweb/keygen.go` — the Ed25519 path
- `_libs/DALOS_Crypto/testvectors/` — the frozen corpus

Curve parameters and the character/byte measurement were read from source and from a test vector
directly.
