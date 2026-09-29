# Signing in the browser

Ouronet ships a Schnorr signature scheme, implemented in TypeScript for the browser. This chapter
covers what it does, what it is used for, and — the part most likely to surprise — what it is
**not** used for.

---

## 1. It does not sign transactions

State this first, because the natural assumption is wrong.

**Ouronet transactions are signed with Ed25519, on a completely different key.** The custom Schnorr
scheme signs nothing that reaches a contract. The library says so itself:

> no DALOS Schnorr signatures are used on-chain today

A search across the whole workspace finds **exactly one** place that calls it, and it is an
off-chain proof of account ownership.

So the two key hierarchies are **disjoint, sharing only an origin seed**:

```
seed ─┬─ custom curve  → the Ouronet identity      → signed with Schnorr, off-chain only
      └─ Ed25519       → the spending account      → signs every transaction
```

A wallet integrating with Ouronet needs the Ed25519 half. The Schnorr half is for proving *who you
are* to something that is not the chain.

---

## 2. The scheme

Standard Schnorr over the custom curve, with two choices worth naming.

```
z = deterministic_nonce(tag, key, hash(message))
R = z·G
e = hash(transcript) mod Q
s = (z + e·key) mod Q
```

**The nonce is deterministic**, derived from the key and message rather than sampled. That removes
the entire class of failures caused by a bad or repeated random value — the one that has broken
real systems repeatedly, most famously a games console. There is no random source at signing time
to get wrong.

**The transcript is length-prefixed.** Each component is preceded by its own length before hashing.
Without that, concatenating variable-length values is ambiguous: two different inputs can produce
the same transcript. Prefixing removes the ambiguity, and the library records that naive
concatenation was the earlier approach.

Domain-separation tags distinguish the nonce hash from the challenge hash, so one cannot be
substituted for the other.

### Verification rejects properly

A signature is refused if it fails to parse, if the scalar is out of range, if either point is not
on the curve, **or if a point is in a small subgroup** — checked by multiplying by the cofactor and
requiring a non-identity result.

That last check is the one implementations most often omit, and omitting it is exploitable.

### The wire format reuses the account encoder

A signature is `{R encoded as a public key}|{s in base 49}` — so the nonce point is serialised by
exactly the same function that produces an account's public key. One encoder, two uses.

---

## 3. What it is actually used for

One thing: **proving to an external service that you control an Ouronet account.**

The flow is a redirect handshake. A service links to the interface with an account, a challenge and
a callback. The browser decrypts stored seed material, **re-derives the full key**, signs a
canonical message containing the challenge, and redirects back with the signature.

Two details are worth drawing out.

**The key is re-derived, not loaded.** What is stored is seed material, so every signature re-runs
the whole derivation. That is a deliberate trade: the private scalar never persists, at the cost of
repeating the work.

**The code checks its own answer.** After deriving, it regenerates the account identifier and
compares it to the one it was asked about — because *nothing else can*. There is no on-chain
binding between a key and an account, so the client verifies the relationship itself before
asserting it.

That self-check is the clearest possible illustration of `04-what-is-not-on-chain.md`.

**Replay is the caller's problem.** The scheme does not prevent it; the consumer must include a
nonce, and the one live consumer does.

---

## 4. Browser cryptography is hard, and the library says so

Three limitations, all acknowledged rather than discovered here.

**Constant time is not achievable in JavaScript.** The library's own statement:

> Modern V8 / SpiderMonkey JITs are not constant-time environments … best-effort branch-free at the
> TypeScript level.

The curve's arithmetic is branch-free by construction, which helps. But a just-in-time compiler may
introduce timing variation the source does not contain, and no native or WebAssembly fallback
ships. A local attacker able to measure signing precisely is outside what this defends against.

**The stored secret is protected by a deliberately weak function.** Single-pass, **no salt, no
iterations** — recorded as not-fixed-by-design to preserve a file format. Two secrets under one
password fall together. This guards the material the browser decrypts to sign.

**And the reference implementation has residual timing exposure too** — the big-integer library
underneath it is not constant-time, and fixing that would mean a custom implementation.

---

## 5. If you are integrating

**To sign transactions:** use Ed25519. The derived key is the standard 32-byte seed, importable by
ordinary wallet software, and a round-trip self-check proves it on derivation.

**To prove account ownership off-chain:** use the Schnorr path, include a challenge you generate,
and do not treat a signature as proof of anything on-chain.

**Do not expect a contract to verify a Schnorr signature.** There is no verifier in Pact. If your
design needs on-chain proof of identity, that does not exist today.

---

## Sources

- `_libs/DALOS_Crypto/docs/SCHNORR_V2_SPEC.md` — the specification
- `_libs/DALOS_Crypto/ts/src/gen1/schnorr.ts` — the browser implementation
- `_libs/DALOS_Crypto/Elliptic/Schnorr.go` — the reference implementation
- `_libs/DALOS_Crypto/AUDIT.md` — the acknowledged limitations
- `daimons/OuronetUI/src/routes/verify.tsx` — the one live consumer
