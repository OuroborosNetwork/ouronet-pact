# Accounts and identity

Ouronet does not use StoaChain accounts. It defines its own, and the relationship between the two
is the first thing to understand about the system — because it is where the sovereign layer stops
being a set of contracts and starts being a chain.

A StoaChain account is a principal: `k:` followed by a public key. An Ouronet account looks like
this:

```
Σ.W∇ЦwÏξБØnζΦψÕłěîбηжÛśTã∇țâĆã4ЬĚIŽȘØíÕlÛřбΩцμCšιÄиMkλ€УщшàфGřÞыÎäY8È₳BDÏÚmßOozBτòÊŸŹjПкц
ğ¥щóиś4h4ÑþююqςA9ÆúÛȚβжéÑψéУoЭπÄЩψďşõшżíZtZuψ4ѺËxЖψУÌбЧλüșěđΔjÈt0ΛŽZSÿΞЩŠ
```

That is one account, on one line in the source, 162 characters long. This chapter explains what
those characters are, why there are exactly that many, and what an account can do.

---

## 1. Two types, one row

There are exactly two kinds of Ouronet account, and they share a single schema —
`DALOS|AccountSchemaV2`, 13 fields.

| | **Standard** | **Smart** |
|---|---|---|
| First character | `Ѻ` (U+047A) | `Σ` (U+03A3) |
| `smart-contract` | `false` | `true` |
| `sovereign` | itself | a **Standard** account |
| Receives value | always | only if a flag permits |

A Standard account is a person. A Smart account is a contract-like actor — a treasury, a pool, a
staking vault — that is *owned* by a Standard account through its `sovereign` field.

The type is stored **and** encoded in the first character, and the validator checks both together:

```pact
(and (= first sigma) (= x true))     ;; smart
```

Requiring agreement between a glyph and a boolean looks redundant. It is not: the glyph is what a
caller passes and a human reads, the boolean is what the contract branches on. Checking only one
lets an account be one type to the reader and another to the code.

### Receiving is a permission, not a default

A Standard account can always receive. A Smart account decides, per route, through three flags:

| flag | permits |
|---|---|
| `payable-by-method` | a transfer explicitly marked as a method call |
| `payable-as-smart-contract` | an ordinary transfer from a Standard account |
| `payable-by-smart-contract` | a transfer from another Smart account |

All three are `false` at creation. A newly deployed Smart account **can hold nothing until its
owner opens a door.** That is the point of the type: a pool that has not been wired yet cannot be
funded by accident, and a treasury can accept from the protocol while refusing arbitrary deposits.

### Creating one is permissionless, and proves itself

Both deploy entrypoints are open to anyone. They have to be — the executor *is* the account being
created, so there is no row to read an owner from. The proof is the guard itself, enforced before
anything else in the capability:

> the caller must satisfy either the guard they are submitting, or Ouronet's own governance guard.

So an account is created by demonstrating control of the key that will own it. An admin path
(`A_DeploySmartAccount`) exists alongside for genesis and support, and composes the governance
capability on top of the same checks.

---

## 2. The identifier: 1 + 1 + 160

Every Ouronet account, of either type, is **exactly 162 characters**. Not a maximum — an equality,
enforced on every validation:

```pact
(enforce (= account-len 162) ...)
```

| position | width | content |
|---|---|---|
| 1 | 1 | the type glyph — `Ѻ` Standard or `Σ` Smart |
| 2 | 1 | a literal `.` |
| 3–162 | **160** | the body |

Every body character must be a member of `DALOS|CHARSET`, which is assembled from ten named
sub-alphabets:

| | | | |
|---|---:|---|---:|
| digits | 10 | Greek capitals | 10 |
| currencies | 10 | Greek small | 23 |
| Latin capitals | 26 | Cyrillic capitals | 19 |
| Latin small | 26 | Cyrillic small | 25 |
| Latin extended capitals | 53 | Latin extended small | 54 |
| | | **total** | **256** |

**256 glyphs, 160 positions.** That is not a coincidence, it is the design: a 256-symbol alphabet
carries exactly one byte per character, so the body is 160 bytes — **1,280 bits** of identifier.
For comparison, a Kadena `k:` account carries a 256-bit public key.

The separator is unambiguous by construction. `.` lives in a *different* constant, `CHR_AUX`
(31 punctuation characters), and `CHR_AUX` is **not** part of `CHARSET`. So a `.` can never occur
in a body, and splitting an account into its parts never needs to guess.

> **Why glyphs at all?** Because the alphabet had to be 256 symbols wide to make the byte
> arithmetic exact, and ASCII does not have 256 printable characters. Reaching into Latin
> Extended, Greek and Cyrillic is what buys the clean power of two. The result is unreadable to a
> human — which is a cost the system pays deliberately, and why every interface shows accounts
> elided.

### A second namespace with the same geometry

Ouronet's Apollo/Codex identities use the identical shape — 162 characters, the same 256-glyph
body alphabet — with different type glyphs: `₱` for standard, `Π` for smart. Same validator
family, same lengths. One set of rules, two populations.

---

## 3. Guard and governor: two authorities that cannot be the same kind of thing

Each account row carries **two** guards, and this is the subtlest part of the model.

| | **guard** | **governor** |
|---|---|---|
| answers | "which *keys* control this?" | "which *code* operates this?" |
| principal protocols | `k:` `w:` `r:` — keyset-based | `u:` `c:` `m:` `p:` — capability, module, user, pact |
| rotated by | `C_RotateGuard` | `C_RotateGovernor` |

The split is not a convention. It is **enforced structurally**, by a validator that refuses the
wrong protocol outright:

```pact
(if is-keyset-based
    (enforce (contains proto ["k:" "w:" "r:"]) "Guard must be key-based ...")
    (enforce (contains proto ["u:" "c:" "m:" "p:"]) "Governor must be non-key-based ..."))
```

A governor can therefore never be a keyset, and a guard can never be a module. The two authorities
are drawn from disjoint universes, so "a human signed" and "a contract acted" can never be
confused for one another — which is the single most useful invariant in an account model that has
both.

### The asymmetry, which is deliberate

Rotating them is **not** symmetric, and the reason is worth following:

- **`C_RotateGovernor` works on Smart accounts only.** Its capability requires the account to be
  smart. On a Standard account there is no separate operator to rotate.
- **`C_RotateGuard` works on both** — but on a Standard account it writes `guard` **and**
  `governor` together, and on a Smart account it writes `guard` alone.

The consequence: **on a Standard account the two fields can never diverge.** Creation writes them
equal, the only rotator that touches a Standard account moves both, and the one function that
could move `governor` alone is gated to Smart. The validator still checks equality as a corruption
backstop, and the test suite forces the divergence artificially — using a module-admin override —
to pin what happens when it is violated.

That is the shape of a good invariant: established by construction, checked anyway, and tested by
deliberately breaking it.

### Ownership means different things to each type

| | how ownership is proven |
|---|---|
| **Standard** | `sovereign` is itself, `guard` equals `governor`, **and the guard must sign** |
| **Smart** | `sovereign` is someone else, then **any one of three** satisfies: its own guard, its sovereign's guard, or its governor |

A Standard account has one way in. A Smart account has three, because it must be reachable by its
owner *personally*, by its owner's *keys*, or by the *module* that runs it — and in normal
operation the third is the one that fires.

---

## 4. How a wallet key becomes an Ouronet account

The two identity systems are joined by a pair of structures pointing opposite ways.

| direction | where it lives | cardinality |
|---|---|---|
| Ouronet account → `k:` account | a column on the account row | **1 : 1** |
| `k:` account → Ouronet accounts | a dedicated ledger table, keyed by the `k:` account | **1 : many** |

One wallet key may therefore own **several** Ouronet accounts, and each Ouronet account settles
back to exactly one wallet. Both sides are maintained by a single writer, called on creation and
twice on rotation — remove from the old key, add to the new.

That rotation carries a fix worth knowing about, because it is the kind of bug that is permanent
rather than loud: the old `k:` account must be read **before** the account row is overwritten. Read
it after, and the cleanup deletes from the wrong key and orphans a ledger row forever.

The onboarding path, end to end:

1. The user holds a StoaChain keypair — an ordinary `k:` account.
2. A 162-character identifier is generated (see the gap in §7).
3. `DALOS|C_DeployStandardAccount` is called with that identifier, the keyset guard, the `k:`
   account, and a public-key string.
4. The capability enforces the guard, then the glyph format, then the guard's protocol.
5. The row is inserted and the reverse ledger updated.

**An unset ledger row defaults to `["|"]`** — a sentinel, not an empty list. Code that reads it
must expect the sentinel; an empty-list assumption sees one phantom entry.

### Whether an account exists is an economic question

There is no "does this row exist" test. `UEV_EnforceAccountExists` reads the account's **elite
debt** field and requires it to be at least `1.0`. A missing row defaults to a `VOID` elite record
with `deb 0.0`; a live account carries `PLEB` with `deb 1.0`.

So existence is inferred from a value the account cannot have unless it was properly created. It
is an unusual choice and it has a consequence: existence and standing are the same question, asked
once.

---

## 5. What DALOS holds

Seven tables, of which two are the standard policy pair every sovereign module carries:

| table | keyed by | holds |
|---|---|---|
| `DALOS\|AccountTable` | the 162-char account | the account row — 13 fields |
| `DALOS\|KadenaLedger` | a `k:` account | the list of Ouronet accounts under that key |
| `DALOS\|PropertiesTable` | one fixed key | 16 global settings — the canonical token ids, treasury policy |
| `DALOS\|GasManagementTable` | one fixed key | 7 fields — the gas tanks, toggles and spend counters |
| `DALOS\|PricesTable` | an action name | a displayed price |
| `P\|T`, `P\|MT` | policy name | inter-module authorisation guards |

The module is **159 functions and 22 capabilities** in 2,124 lines. A third of the functions
(52) are plain table reads — which is what an identity core mostly is.

### A naming incident worth one paragraph

In August a commit renamed both a column (`kadena-konto` → `stoa-konto`) and a table
(`DALOS|KadenaLedger` → `DALOS|StoaLedger`), as part of moving the project's vocabulary off
Kadena.

**A Pact module upgrade replaces code and leaves rows untouched.** Every existing account still
carried `kadena-konto` while the new code asked for `stoa-konto`, so the reader threw for *every
account* — taking out 33 call sites across 9 modules. The column was reverted; the table rename
was missed in the same pass, because a renamed table does not throw, it merely reports as
uncreated.

Both identifiers are now pinned by tests. The *function* names stayed renamed, which is the right
resolution: a function is code and may be renamed freely, a column is data and may not.

---

## 6. The reserved accounts

**"Demiurgoi" names two different things**, and conflating them is easy.

**The keyset** — Ouronet's governance identity. Every sovereign module binds its admin guard to
it. This is the key that deploys and administers.

**The list** — three Ouronet accounts stored in the properties row, addressed *by position*:

| index | role |
|---|---|
| 0 | the treasury, a Smart account |
| 1 | CTO — takes **30%** of STOA revenue |
| 2 | HOV — takes **20%** |

Positional addressing is fragile by nature; every consumer indexes it by hand. It is worth knowing
that reordering that list silently redirects revenue.

Revenue splits four ways, 10/20/30/40: HOV, the gas station, CTO, and the liquid-staking
contract — the largest share going to stakers.

Alongside these, **nine system Smart accounts** are hardcoded as constants: the gas station, the
autostake, vesting, liquid-staking, Ouroboros, swap and acquisition-pool contracts, and the two
development accounts. Eight are `Σ`; one is `Ѻ`, and its `Σ` twin is *derived from it* — same
160-character body, different type glyph. The same identity in both roles.

### One account is exempt from gas, and the exemption used to be much wider

The gas station's own account is the sole `GASLESS-PATRON` — the one account that pays no IGNIS.

That check previously asked whether the patron was *any Smart account*. Since every Smart account
is created with `smart-contract: true`, and anyone may create one permissionlessly, that made the
exemption available on request. It now compares against the single named constant. Narrowing it
was verified safe by measurement: all 37 genuine patron slots passing a smart-account constant
were in one module.

---

## 7. What an account costs, and what is not settled

Account creation is **STOA-priced, not IGNIS-priced** — one of the few operations that bypasses
the virtual gas economy entirely. The Talos wrapper collects native STOA and returns no cumulator.

| | dollar basis | at the current peg |
|---|---|---|
| Standard | $5 | 50 STOA |
| Smart | $10 | 100 STOA |

**And it is switched off.** A dedicated toggle — `account-creation-stoa`, genesis value `false` —
zeroes both prices. It is deliberately *independent* of the global native-gas switch, so the
protocol can charge for everything else while onboarding stays free. Turning it on has its own
capability rather than reusing the gas one.

The quoted price and the charged price read the same function, so a preview cannot drift from the
charge.

### Two honest gaps

**The identifier generator is not in this repository.** Nothing here derives a 162-character
account from a public key; every account arrives as a literal from the caller. Whether the body is
a deterministic function of the key or simply random is not answerable from the contracts.
The consequence is concrete: **there is no on-chain binding between an account's stored public key
and its identifier.** The chapter on cryptography is where this is resolved.

**The `k:` account field is not validated on write.** The deploy and rotate capabilities accept it
as a string and enforce nothing — no principal validation, no prefix check, no existence test
against `coin`. Correctness there is a caller convention rather than a contract guarantee. This is
recorded as observed, not as intended; it may be deliberate and is worth confirming before being
relied upon.

---

## Sources

- `1_SOVEREIGN/STAGE_01/2_Core/01_DALOS.pact` — the account core; schemas, capabilities, tables
- `1_SOVEREIGN/STAGE_01/1_Utilities/08_U_DALOS.pact` — the glyph alphabet and format validators
- `1_SOVEREIGN/STAGE_01/2_Core/02_IGNIS.pact` — account-creation pricing and the gasless patron
- `1_SOVEREIGN/STAGE_01/3_Talos/02_TS01-C1.pact` — the client wrappers
- `REPL/modules/DALOS-ADMIN.repl` — the guard/governor divergence tests

Character counts and alphabet sizes in this chapter were measured from the source constants with a
bracket-aware parser, not estimated. See `90-reference/03-how-these-figures-were-obtained.md`.
