# Sets and fragments

Two operations that go in opposite directions.

**Composition** binds several collectables into one: a five-card set becomes a single token you can
sell as a set. **Fractionalisation** splits one collectable into a thousand tradeable pieces.

Neither creates a new *kind* of asset. A set and a fragment are both ordinary nonces inside an
existing collection, distinguished by two fields, and that is the most important thing to
understand about them — it is why they need no new tables, no new identifier namespace, and no
special handling in the transfer layer.

---

## 1. Three discriminators on one record

Every collectable nonce carries a class number and an integer index. Two independent signals
decide what it is:

| signal | meaning |
|---|---|
| `nonce-class = 0` | a **native** nonce — an ordinary collectable |
| `nonce-class = N` | a **set instance**, and `N` *is* which set-class it belongs to |
| nonce is **positive** | the thing itself |
| nonce is **negative** | a **fragment** of the nonce at `abs(n)` |

The two are orthogonal, so all four combinations exist and are reachable: a native nonce, a
fragment of a native nonce, a set instance, and a **fragment of a set instance**.

A third signal is the identifier prefix: `E|` marks a special collection — Equity uses it, and it
also selects a pricing discount on a collection's first nonce.

Because a fragment is *the negation of the nonce it fractionalises*, no lookup table is needed to
relate the two. The relationship is arithmetic.

---

## 2. Sets

### A set-class is a recipe, written once

Defining a set does not create tokens. It registers a **recipe**: how many positions, and what
each position accepts. Three kinds:

| kind | each position accepts |
|---|---|
| **Primordial** | specific listed nonces — "position 1 must be card #3 or #7" |
| **Composite** | any instance of a named set-class — this is **sets of sets** |
| **Hybrid** | both, primordial positions first |

The recipe is written with `insert` rather than `write`, so **a set-class can never be
redefined**. The score multiplier is fixed at definition and there is no update path — an earlier
version had one, and it was removed outright rather than repaired.

Three limits, all enforced:

| | |
|---|---|
| positions per set | **1 to 20** |
| score multiplier | **1.0 to 100.0**, three decimals |
| allowed nonces | must reference a nonce that exists |

### Sets of sets terminate, by arithmetic

A composite position names a set-class, and a set instance is itself a valid constituent. So sets
nest. Nothing checks for cycles — and nothing needs to:

- a new set-class is numbered `set-classes-used + 1`
- its composite references must be `<= set-classes-used`

**A class can therefore only reference strictly lower-numbered classes.** The containment graph is
a directed acyclic graph as a consequence of the numbering, not as a rule anyone enforces. No
recursion check exists because no recursion can be expressed.

This is worth dwelling on as a design pattern: the cheapest invariant is the one that cannot be
violated, rather than the one that is checked.

### Composing holds; decomposing burns

The system account acts as escrow.

**Making a set:** the constituents transfer to the escrow account and a set token is issued to
you. For semi-fungibles the set nonce already exists — it was minted with zero supply when the
recipe was defined — so making adds quantity. For non-fungibles a **new nonce is minted per set**,
carrying the list of what went into it.

**Breaking a set:** the set token returns to escrow and is **burned**; the constituents come back
to you.

So the constituents are never destroyed — they are locked. The set token is the temporary thing.
That matters for anyone reasoning about supply: a collection's constituent supply does not drop
when sets are made, it merely stops being liquid.

**An inactive set can still be broken.** Making requires an active recipe; breaking deliberately
does not. Deactivating a set-class stops new ones being made without trapping the ones that exist
— a small decision that is the difference between pausing a product and confiscating it.

### The two halves of a hybrid must agree, and once did not

A hybrid set's constituent order is canonical: **primordial positions first, then composite**.
That ordering is applied in two separate places — when validating what you supply, and when
reconstructing what to give back.

They disagreed. Break-time returned the reverse order, so decomposing a hybrid set handed back the
right tokens in the wrong positions. Both sites now carry comments pointing at each other,
instructing that a change to one requires a change to the other.

Two functions that must agree and are edited independently is a recurring shape. The remedy used
here — a cross-reference at each site — is weaker than deriving one from the other, and is chosen
because the two genuinely compute different things.

---

## 3. Fragments

### One thousand, exactly

```pact
(defconst FRG 1000)
```

Fractionalising a collectable produces **exactly 1,000 pieces** per unit. Not a parameter, not a
per-collection setting — one constant.

The mechanism:

1. the native nonce transfers to the escrow account
2. `1,000 × amount` of nonce `−n` is minted
3. the fragments are delivered to you

Merging is the exact inverse, and refuses anything that is not a whole multiple of 1,000. So a
fragment can always be reassembled: there is no state in which 1,000 pieces exist and the original
cannot be reconstituted.

**Enabling fractionalisation is a one-way switch.** There is no disable function. A collection
whose holders may hold fragments keeps that property permanently — because a token that could stop
being fractionalisable would strand every fragment already issued.

### The escrow cannot be emptied underneath the fragments

The management module refuses to burn or wipe the escrow account's holding of any nonce that backs
outstanding fragments:

> "Not allowed for the DPDC system account when backing outstanding fragments"

Without that, an administrator could wipe the escrowed original and leave 1,000 fragments backed
by nothing. The guard is narrow and specific, and it has to be — the same escrow account is used
legitimately for same-transaction custody elsewhere, so a blanket prohibition would break
composition.

### A documented scope that is narrower than the enforced one

The fragments module describes itself as fractionalising *class-0* nonces. The gate it actually
enforces delegates, for a set instance, to the set-class's own fragmentation flag — so **a set
instance whose class has fragmentation enabled is fractionalisable**, which is the fourth
combination from §1.

Only the *enabling* step is class-0-only. This appears to be a documentation gap rather than a
defect: the behaviour is coherent, and it is recorded here because a reader following the
docstring would conclude the wrong thing about what can be fractionalised.

---

## 4. Equity: a company as eight nonces

The Equity module is the most concrete illustration of what this machinery is for. It issues a
**tokenised company** as a single semi-fungible collection with eight nonces:

| nonce | is |
|---|---|
| 1 | a barebone share |
| 2–8 | seven **package tiers** |

Issuance creates **1,000,000 barebone shares** and zero of every tier. The tiers are fixed
fractions of the company:

| tier | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| stake | 0.1‰ | 0.2‰ | 0.5‰ | 1‰ | 2‰ | 5‰ | **1%** |
| shares per million | 100 | 200 | 500 | 1,000 | 2,000 | 5,000 | 10,000 |

One operation moves between them, dispatching three ways:

- **shares → tier** — package loose shares into a tradeable unit
- **tier → shares** — unpackage; the tier token is **burned**
- **tier → tier** — convert, refused unless it divides exactly

The asymmetry is deliberate and worth noting: packaging **escrows** the shares, while unpackaging
and converting **burn** the tier token. Same pattern as sets — the composite is ephemeral, the
constituent is preserved.

**At most half the company may be packaged at once.** The remainder must stay as loose shares. The
cap was originally a bare `/ 2` in an expression and is now a named constant with its reasoning
attached — a small change that makes an economic policy findable rather than incidental.

### Why it does not reuse the sets machinery

Equity does the same thing as a set — bind many units into one — and shares no code with it. The
reason is in its own documentation:

> "EQUITY wants freely-transferable tier tokens, not opaque set-bundles, so it shares no code with
> DPDC-S. **A future DPDC-S invariant fix will NOT automatically propagate here.**"

That second sentence is the valuable part. The duplication is a decision, and the cost of the
decision is written down at the site where someone would otherwise assume a fix had propagated.

---

## 5. What the audits found here

The collectables family carried **58 tracked findings, all closed** — 35 fixed and proven, 13
refuted, the rest closed as already-handled or deferred. Four are instructive.

**A bound that only checked the maximum.** A set definition validated the *running maximum* of its
allowed nonces against what exists. A large negative value is always less than a small positive
one, so garbage hid behind a legitimate entry in the same definition — and silently consumed a
set-class number, which is monotonic and never reclaimed. The fix checks every element by
magnitude.

Closing it also closed a second finding for free: the "no primordial set" sentinel is `[0]`, and
`abs(0) = 0` fails the new positivity test, so the sentinel became unreachable from user input
without anyone targeting it.

**A set instance's contents were editable.** A non-fungible set records what went into it, and the
break operation trusts that record to decide what to hand back. The metadata-update path could
**overwrite it arbitrarily**. The fix blocks edits to set instances while leaving the *recipe*
editable — a distinction that took a specific test to pin, because the two look similar from the
outside.

**An empty list is not empty.** Several guards were derived from `(enumerate 0 -1)`, which in Pact
returns `[0 -1]` rather than `[]`. Empty inputs therefore reached code that assumed at least one
element and failed with an index error instead of a refusal.

**One finding was refuted rather than fixed**, which is worth including because a catalogue of
only-confirmed findings is not a catalogue. Identifiers are derived from the previous block hash,
so two collections with the same ticker issued in the same block collide. Investigation found the
collision surfaces *first* in a shared branding table, is atomic, and is self-healing — so it was
closed as by-design rather than patched.

---

## 6. One field currently reads nothing

The score multiplier is validated, bounded, immutable, and tested — and its reader has **no
callers on chain**. Nothing consumes it today.

It is included here rather than omitted because the alternative is a reader discovering it in the
schema and assuming it affects something. The scoring system that would consume it is in the
acquisition-pool family, and whether it should is an open question rather than an oversight.

---

## Sources

- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/08_DPDC-S.pact` — sets
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/09_DPDC-F.pact` — fragments
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/11_EQUITY+.pact` — equity
- `1_SOVEREIGN/STAGE_02/2_Core/01_DPDC/01_DPDC-UDC.pact` — the schemas
- `Audit/module-audits/DPDC/` — 58 findings and their verdicts
- `REPL/Kursan/_verify_finding_DPDC-*.repl` — one harness per finding

The acyclicity argument in §2 is derived from two source lines (class numbering and the composite
upper bound) rather than quoted from a comment; no comment in the tree states it.
