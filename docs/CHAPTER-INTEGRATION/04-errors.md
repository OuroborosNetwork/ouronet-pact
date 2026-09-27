# Errors — how Ouronet refuses, and which refusals you can catch

What a client sees when a call does not succeed, what each kind means, and — the part that
decides your error handling — **which failures Pact lets you catch and which take the whole
transaction down regardless of what you wrapped it in**.

Measured against mainnet on 2026-09-27 by simulating 41 client operations unsigned. Every
message quoted below was returned by the chain during that run; none is reconstructed from
memory. The harness is `scripts/simulate-token-ops.mjs` in the **OuronetUI** repo (a sibling of
this one in the workspace, not a path inside it).

---

## 0. Why this document exists

Ouronet's refusals are unusually informative — `Reservation is not opened for Token OURO-…`
tells a user exactly what to do next, which is better than most chains manage. That makes it
tempting to treat "handle the error" as "show the message".

It is not enough, because **the failures divide into two populations that look identical from
the call site and behave completely differently**:

- A **business refusal** is a value your client can reason about. The transaction fails, the
  message explains why, and `try` catches it if you are composing.
- A **structural failure** — a name that does not resolve, an argument of the wrong type —
  **cannot be caught by `try` at all.** It aborts the whole evaluation. A client that wrapped a
  read expecting a fallback gets no fallback and no message; it gets nothing, and the user gets
  an empty panel.

The second population is the one that has repeatedly reached mainnet in this project, because
it is invisible to every check that does not actually run the call.

---

## 1. The four outcomes, and how to tell them apart

Fire the call at `/local` **unsigned** and classify what comes back. This is the whole method,
and it costs nothing:

| outcome | what it means | is the call correct? |
|---|---|---|
| **OK** | the whole path ran, business logic included | yes |
| **GUARDED** | reached an ownership or keyset check and was refused for want of a signature | **yes** — only a signature was missing |
| **REFUSED** | a business rule said no | **yes** — it reached the rule that governs it |
| **BROKEN** | resolution, arity or type error | **no** — the call is malformed |

The useful asymmetry: **an unsigned refusal at a guard is a proof of correctness.** It means
the call resolved, took the right arity and types, ran through Talos, read live state, and got
as far as the check that protects the operation. That is everything except the signature.

So `/local` cannot tell you a transaction will succeed. It can tell you the transaction is
**well-formed and reaches its own rules**, which is the part wiring gets wrong.

### GUARDED does not always say "keyset"

Two different wordings mean the same thing, and treating only the first as a signature problem
will misfile the second as a business rule:

```
Keyset failure ( keys-all ):  0ddd486482...
Smart DALOS Account Σ.W∇Цw… Ownership could not be verified!
```

The second is Ouronet's own ownership gate (`CAP_EnforceAccountOwnership`, reached through
`CAP_Owner`). It never contains the word "keyset".

---

## 2. What you cannot catch

This is the section to read twice.

### 2a. Resolution errors

```
Module ouronet-ns.TS01-C3 has no such member: SWP|C_ToggleFeeLockk
```

A misspelled or removed function. **`try` does not catch this.** It is not a runtime value
error; the reference fails to resolve and evaluation stops. In OuronetUI this surfaced as
panels that rendered empty with no error state, because the code path that would have set the
error never ran.

**Reconciling this with `01`'s appendix**, which says a resolution error "surfaces as a default
value rather than an exception". Both are true and they describe different layers. On the CHAIN
it is an exception and it aborts — measured: `(try "fallback" (…UR_NoSuchFunction "x"))` returns
the resolution error, not the fallback. In the CONSUMER it becomes a default, because a client
that reads `.result.data` without checking `.result.status` gets `undefined` and substitutes an
empty list. The danger `01` names is real; the defaulting is your code's, not Pact's, which
means it is yours to remove.

This is why a client must not carry hand-written Pact strings. The names change —
`URD_ListActiveDualLinks` was renamed and broke fleet-wide authentication **twice** — and
nothing in a TypeScript build can see a string that no longer resolves.

### 2b. Type errors

```
Type check failed. The argument is  list but the expected type is  list
```

Also uncatchable. Note the message is unhelpful on purpose-by-accident: Pact truncates the
element types, so `[integer]` versus `[string]` both print as `list`. If you see this, the
shapes differ somewhere the message will not tell you.

A real instance: `VST|C_Unvest` handed a **hibernating** (`H|`) parcel raises this from inside
the contract, while the identical call on a **vesting** (`V|`) parcel refuses cleanly with a
business message. Passing an entity of the wrong family is not always a clean refusal.

### 2c. What `try` actually catches — measured, because the folklore is wrong

This was tested directly on mainnet rather than assumed, and the first draft of this document
got it wrong in a way that would have sent a reader the opposite direction:

| failure | wrapped in `try` |
|---|---|
| `enforce` failure — a business rule | **caught** |
| point read, key does not exist | **caught** |
| `select` / `keys()` anywhere inside the `try` | **not allowed to run at all** |
| resolution error — no such member | **uncaught** |
| type error | **uncaught** |

So "a failed table read is uncatchable" is false, and believing it leads to defensive code
nobody writes because it is thought pointless. A **point** read that misses is an ordinary
catchable failure:

```
No value found in table ouronet-ns.DPOF_DPOF|T|Nonces for key: V|GSTOA-8N…
No value found in table ouronet-ns.ATS_ATS|Pairs for key: |
```

Both of those are recoverable **if you wrap them**. What is not recoverable is a heavy read:

```
(try ["fallback"] (…URH_AccountNonces …))
  -> Error during database operation: Operation is not allowed in read-only or system
```

`select` and `keys()` are forbidden *inside* `try`, so a `URH_`/`URD_` scan cannot be given a
fallback that way — the guard has to sit around the failure, not around the scan. That is
exactly the shape the AppReads layer adopted: split the valuation out of the entry read and wrap
the part that can fail.

### 2d. The sentinel that became a key

The `ATS|Pairs for key: |` message above is a live example worth studying, and it was NOT
uncatchable — it simply was not wrapped. `DPTF::UR_RewardToken` answers "this
token is a reward token nowhere" with the sentinel `[BAR]` — a one-element list containing the
pipe glyph — **not** with an empty list. A filter downstream passed every element to a table
read, so the sentinel became a key, and the read raised. That killed the entire button-state
reader for one token out of fifteen, and every consumer of it got nothing rather than a degraded
answer.

**The rule this gives you:** a list returned by an Ouronet reader may be a SENTINEL rather than
data. Check for `[BAR]` before you iterate. The same convention appears in the swap path cache,
where `nodes: ["|"]` means "no route exists anywhere".

And the second rule, which is about your own code rather than the contract's: **a point read
that can miss should be wrapped.** It is catchable, so leaving it bare is a choice, not a
constraint.

### 2e. Short calls — loud, except in one position

A call with too few arguments partially applies in Pact rather than erroring outright. This is
widely repeated as "it submits and silently does nothing". **Measured, that is only true in one
position**, and the distinction matters:

```pact
(f "a" "b")                  ;; FAILS  "Evaluation did not reduce to a value"
(let ((x (f "a" "b"))) "z")  ;; SUCCEEDS, does nothing at all      <-- the dangerous one
(length [(f "a" "b")])       ;; FAILS  "Expected a Pact value, but got a closure"
```

A client emits top-level calls, so **arity mistakes from a client do fail loudly.** The silent
form needs a discarded binding, which only hand-written Pact produces.

That is still worth knowing, because the loud version is not obviously an arity error either:
*"Evaluation did not reduce to a value"* does not mention arguments. If you see it, count them.

---

## 3. The business refusals, by what the user should do

These are the catchable, explicable ones. Grouped by the action they imply, because a message
the user cannot act on is barely better than none.

### The user is not permitted

```
Executor is not the Token Owner
Burn Role for OURO-8Nh-JO8JO4F5 on Account Σ.…  must be set to true for exec…
Frozen for DHB-SUVEHxb9UQ6_ on Account Σ.… must be set to true for exec
Segmentation state for Orto-Fungible H|GSTOA-… must be set to true for exec
```

A role or flag is off. Note the last three share a shape — `<thing> for <id> on <account> must
be set to true` — and are worth pattern-matching if you surface a "you need permission X" hint.

### The entity is not in the right state

```
Reservation is not opened for Token OURO-8Nh-JO8JO4F5
Sleeping for the Token OURO-8Nh-JO8JO4F5 is not satisfied with existance
Merge requires a Sleeping DPOF
Cannot Constrict when Auryndex-O136CBn22ncY has Hibernation turned off
Invalid Hot-RBT
```

A prerequisite object does not exist yet. Several of these mean *"the counterpart link has not
been created"* — the `VST|C_Create*Link` family — which is a different operation the user can
perform first. This is the group most worth translating into a next step rather than echoing.

### The request itself is wrong

```
Sender and Receiver must be different
Only negative nonces can be used for merging
Nonce must be fragmented for operation
Only Class Non-0 Nonces can be broken Down
Insufficient Capacity Left (0) to combine 1 Individual Shares
Amount 1 is invalid for Debiting Nonce 1 of DHB-… on Account
```

Input validation. These are the ones a client should have prevented, and each is a candidate for
a pre-submit check.

---

## 4. Testing a call without submitting it

The whole method, reduced:

```js
// unsigned /local -- costs nothing, sends nothing
const res = await fetch(NODE + "/local?preflight=false&signatureVerification=false", {
  method: "POST", headers: { "Content-Type": "application/json" },
  body: JSON.stringify({ cmd, hash, sigs: [] }),
});
```

Then classify the message. Two rules learned the hard way:

**Include the operations you did not write.** A toolbar is only as trustworthy as its
least-checked button. Extending the sweep from "the ones I wired" to "all of them" is what found
that `ORBR|C_Compress` and `C_Sublimate` take `executor` only and **no patron**, where a blanket
patron would have been an arity error rather than a harmless extra.

**Give each call a fixture of the right family.** Orto parcels are `V|` vesting, `S|` sleeping,
`H|` hibernating; collectables split semi-fungible from non-fungible; autostake operations need
a pair that actually exists. One id reused across a whole family measures the fixture, not the
calls — and in the Unvest case it produced a type error that looked like a wiring defect and
was not.

**Carry a negative control.** "Zero malformed" means nothing unless malformed can be detected.
Three deliberately broken calls — a misspelled member, a short call, a wrong type — should all
classify as BROKEN. If they do not, the sweep is measuring nothing. This is not hypothetical:
a guard written during this round passed against the very regression it existed to catch,
because its regex matched a number in its own explanatory comment.

---

## 5. What to show a user

| situation | show |
|---|---|
| GUARDED | nothing — this is the normal path; they are about to sign |
| REFUSED, state | the prerequisite, ideally as an action ("create the sleeping link first") |
| REFUSED, input | the constraint, at the field that violated it |
| REFUSED, permission | who may do this, not the raw flag name |
| BROKEN | **an error, loudly.** This is your bug, not theirs, and it must not render as an empty panel |

The last row is the one that matters. A structural failure is indistinguishable from "no data"
unless you make it distinguishable, and every instance of it in this codebase reached a user as
blankness rather than as a message.

---

## Cross-references

- `Docs/CHAPTER-INTEGRATION/01-client-orchestration.md` — the read-build-execute shapes
- `OuronetInformational/HANDOFFS/HANDOFF-talos-registry.md` — why call names are not hand-written
- OuronetUI repo, `scripts/simulate-token-ops.mjs` — the 41-operation sweep, with `--selftest`
- OuronetUI repo, `scripts/simulate-pool-ops.mjs` — the same method for pool management
