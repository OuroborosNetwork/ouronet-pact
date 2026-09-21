# Part III · Chapter 2 — The gates that had never refused anybody

This is the largest single thread of the round, and the one with the least dramatic finding: no
capability was **missing**. Every ownership check the architecture called for was present in the
source, and every one of them was reachable from a live client path.

What the round established is that **presence is not protection**, and that the difference is
invisible to every form of review that does not execute the code.

---

## The question

Ouronet gates asset operations with capabilities of the form:

```pact
(defcap SOME|C>OPERATION (...)
    ...business checks...
    (CAP_EnforceAccountOwnership account)   ;; or (CAP_Owner asset-id)
    ...)
```

A reviewer reading that file sees the gate and moves on. The question this round asked instead was:
**has this capability ever actually turned anybody away?** Not *is it there* — has it **fired**.

For a large fraction of them, the answer was no. And a capability that has never refused anybody is
one whose deletion would turn nothing red.

---

## The measurement, and the four times it was wrong

The instrument is `REPL/tools/_ownerobs.py`. Its history is more instructive than its output, and it
is documented here rather than hidden because **every correction moved the number in the direction of
more work, not less.**

### It began by excluding a third of the tree from its own denominator

The first version mapped each Talos wrapper to the function it called, one hop, and asked which of
those functions acquired a gated capability. It reported *"39 of 112 witnessed"*.

The tree contains **185** such capabilities. Seventy-three never entered the denominator — and an
excluded capability is not reported as a gap, it is **absent**, which reads as neither.

The excluded third was not a random third. It held the entire token-DEBIT layer —
`DPTF|C>DEBIT`, `DPOF|C>DEBIT`, `DPDC-C|C>SINGLE-DEBIT` — and `DPTF|C>X-TRANSFER`: the gates that
stop a stranger moving somebody else's tokens. `DPTF|C>DEBIT` is the gate an existing red-team attack
was **written to witness**. The tool could not see the thing its own test proved.

The chain broke at a **non-gated intermediary**: `C_Transfer` acquires `DPTF|C>CLASS-1-TRANSFER`,
which carries no ownership check itself and merely *composes* `DPTF|C>X-TRANSFER`, which carries the
sender check. Filtering to gated capabilities *first* severed the transfer family at exactly that
link. Making the walk transitive — following both call edges and `compose-capability` edges, and
filtering at the end rather than at each hop — moved the denominator **112 → 167** and the actionable
list **9 → 23**.

> The fourteen extra gates were never closed. They were never **visible**. Several status reports had
> overstated progress for exactly that reason.

### Then it credited gates that no test had targeted

Transitive reachability makes `observed` an **upper bound**: one refused call credits every gate on
its path, though only one of them refused. This was written down as a caveat, and then demonstrated
the same day — a new attack driving a non-owner ortofungible transfer changed **no counts**, because
the gate it targeted was already credited by some other operation that merely passed through it.

Quantifying that took three attempts, and the first two were wrong in the same direction: toward a
tidier number.

| attempt | rule | verdict | why it was wrong |
|---|---|---|---|
| binary | attributable only if the crediting op reaches exactly one gate | **1 of 63** | read as *"the observed column is worthless"*; wrong axis |
| dilution | rank by how many gates the crediting op reaches | 30 of 63 well-evidenced | ranks a test by blast radius, not by target — it filed a regression test written *specifically* for a gate as near-worthless because that gate's operation happens to touch ten others |
| **depth** | how many hops from the operation the test actually called | **63 attributed at depth 0** | — |

Depth also had to stop returning the *first* crediting test found: `DPTF|C>DEBIT` was being reported
at depth 3 via an unrelated fee-withdrawal op while the attack written for it credited it at depth 0.
**A metric that ranks evidence must not pick its evidence by file iteration order.**

The depth split then paid for itself immediately. Six gates sat in the *observed* column, looking
covered, credited from four hops away, with no test having ever targeted them — including
`DPOF|C>BULK-TRANSFER` and `DPDC-T|C>BULK-TRANSFER`, each **the plural door beside a witnessed
singular one**. None was on the actionable list. Without the split, none would have been written.

### Then it generated impossible work

Some gates cannot be witnessed by any client-surface test: those composed only by another capability,
or acquired solely through an `XE_` forward-module entrypoint, which by this codebase's conventions is
called by another *module* and never by a client. The outer gate refuses first, by design.

Splitting those out prevented seven impossible tasks. **And then the split itself was wrong twice**,
in opposite directions — first treating `compose-capability` as a wall rather than an edge (which
would have retired the live DEBIT layer as unreachable), then testing four of the **eight** client
prefixes the architecture documents, which filed an entire batch-operation band as unreachable
although its entrypoints are client recipes by definition.

> A prefix filter that disagrees with the documented prefix table fails silently and **always toward
> less work** — the direction nobody audits, because a shrinking worklist reads as progress.

### And it had a blind spot the codebase's own style rule would trigger

The detector required the expected refusal message to appear *lexically inside* the assertion form.
Hoisting a repeated message literal into the enclosing `let` — which changes nothing about what the
test asserts, and which this codebase's style guide **actively encourages** — made an
already-witnessed gate report as never observed.

Found by controlled mutation, not by reading. Fixed by widening the search to enclosing binding
lists, *asymmetrically*: only the message search widened, because widening the operation-name search
too would have re-opened the over-crediting hole. **Trading a blind spot for a false positive is not
an improvement; it only moves which column lies.**

---

## Where it ended

| | at the round's start | at the round's end |
|---|---:|---:|
| ownership-gated capabilities in the tree | 185 | 185 |
| …reachable from a named client operation | 112 *(as then measured)* | **167** |
| …never observed to refuse anybody | 93 | **{{fig:gates_never}}** |
| …with a test that caused them to refuse | 19 | **{{fig:gates_observed}}** |
| …attributed at depth 0 (the test targeted *this* gate) | — | **{{fig:gates_depth0}}** |
| shadowed **and** never witnessed — **the worklist** | 23 | **0** |

**The worklist is empty.** Four capabilities remain unwitnessed and all four are *structurally
inner* — three forward-module entrypoints called only by another module, and one reached solely
through a both-internal-and-external function. No client-surface test can attribute a refusal to
those: the outer gate refuses first, by design. They are named rather than counted as a gap.

The 18 capabilities outside the denominator are named rather than buried, and the exclusion has
since been **verified rather than assumed**. **14 are in the legacy `00_DPMF` module**; the rest are
four special-band capabilities in `STOAICO`, `DPDC` and `RPS`.

`00_DPMF`'s exclusion was the open question, since it carries most of the 18. Measured: **zero**
modref bindings to its interface anywhere outside itself, **zero** `ref-DPMF::` call sites, **zero**
Talos wrappers reaching it — and it **is** deployed, at 128,156 gas.

> It is deployed and nothing **can** call it. Not "nothing does" — there is no binding through which
> any module could reach it, so it is unreachable from the only supported client path. Witnessing a
> gate on a module no caller can reach would test nothing, which makes those 14 a **correct
> exclusion rather than a gap**. The module's deploy-slot cost is real and is a separate question,
> belonging to the redeploy phase.

## The sharpest attribution proof came last

The final band produced the cleanest separation technique in the programme, and it is worth stating
because it generalises.

`DPDC-C|C>REGISTER-NONCES` is guarded on the holder of a **transferable role**, not on the collection
owner. In the fixtures those are the same account — so the refusal names a key that is true of
*either* reading, and attributes nothing. The two candidate explanations are indistinguishable.

The remedy was not a better assertion. It was to **move the role**: the owner legitimately transfers
it to a third party, leaving the owner konto untouched, and then the owner — **still the owner** — is
refused, naming the new role-holder's key.

> An owner gate cannot refuse the owner. One legitimate operation separates two readings that no
> amount of assertion-writing could.

## What the gates turned out to be guarding

Witnessing forces you to find out what an operation actually does, which repeatedly turned out to be
more than its name suggested.

- **`VST|C>REPURPOSE-TRUE-FUNGIBLE`** reads as a bookkeeping operation. Driven successfully it wipes
  a holder's **entire balance** — 999,250 tokens in the fixture — and re-mints it to an address the
  caller names, with the emptied account never consenting. It authorises on the *frozen variant's*
  owner while operating on the *base* token: coherent, since confiscation is a power of the freeze
  authority rather than the token's owner, but it means the key that matters is never the holder's.
- **`VST|X>REPURPOSE-ORTO-FUNGIBLE`**: the attacker chosen was the victim's own asset holder. She
  holds the nonces outright and is still refused, because **holding the asset is not authority over
  it** — repurposing decommissions a nonce and mints a replacement, an issuance power wearing a
  transfer's clothes.
- **`DPOF|C>DEBIT`** could only be reached through a partial-transfer path that requires a token
  property the obvious fixture did not have. The first attempt died at that property check — a green
  assertion that said nothing whatever about ownership.

## The one field that cannot be gated, and why we are saying so

Every finding above is a gate that was missing, misplaced or shadowed — all of them fixable, and
all of them fixed. This section is the opposite: a property the chain **cannot** enforce, stated
plainly because an audit that only lists solved problems is not telling you where the edges are.

### What the field is

A DALOS account row carries a `public` field. It is **not** the account's Kadena signing key. The
Kadena key is 64 hex characters and lives inside the account's `guard`; `public` is a **574–576
character** string over a 50-symbol alphabet with a `9G.` / `9H.` version prefix — an Ouronet
keypair of its own, used off-chain by the client for the account's key material.

It is written once, at deployment, by whoever calls the deploy entrypoint. Nothing reads it back
for validation. The only path that can change it afterwards is `DALOS::A_UpdatePublicKey`, which is
`GOV|DALOS_ADMIN`-only **by design** — there is deliberately no client path, because the field is
account identity rather than account preference.

### Why the chain cannot check it

Three independent routes were examined, and each is closed:

1. **Verify a signature under the claimed key.** Pact can enforce Kadena ed25519 and WebAuthn
   signatures and nothing else. There is no native that verifies a signature under a caller-supplied
   foreign keypair, so the account cannot be made to prove it holds the private half.
2. **Derive it from the guard.** `create-principal` does reach a key — this codebase already uses it
   in `UC_GuardProtocol` to classify guards as `k:` / `w:` / `r:` / `u:` / `c:` / `m:` / `p:`. But
   the key it reaches is the **Kadena** key. `public` is a different keypair with no arithmetic
   relationship to it, so the principal tells you nothing about the field.
3. **Derive it from the account name.** Ouronet account names are 162 characters, `Ѻ.` or `Σ.` plus
   a 160-glyph body, and `GLYPH|UEV_DalosAccount` validates exactly that. The name is not a hash or
   an encoding of `public`; the two are independent strings. There is no relationship to check.

So the property *"the `public` on this account is the public half of a keypair its owner holds"* is
**unenforceable on this blockchain**. Not difficult — unavailable.

### What that means in practice

Through the Ouronet UI the field is correct by construction: the client generates the keypair and
supplies the public half, and the user never types it. The exposure is the **console**, or any
hand-built transaction: the deploy entrypoints accept any string, so an account can be created
carrying a key nobody holds, or — the sharper case — a **well-formed key belonging to somebody
else**, which would publish a recipient the account's owner cannot read.

The loss is borne by the account itself in the first case and by its correspondents in the second.
No funds are reachable through it: `public` gates nothing on-chain, holds no authority, and is
consulted by no capability. It is a *correctness* property of account identity, not an
authorisation one — which is why the system stays safe without it and merely becomes wrong for that
account.

**The remedy exists and is the admin override.** An account created with a bad key is repaired by
`A_UpdatePublicKey`, and since that is the only writer, the repair is as authoritative as the
original write. **This is accepted, not unresolved** — the owner's position, and the audit's:
enforcement is impossible, detection is off-chain, and the correction path is present and
exclusive.

### The part that is NOT closed, and is offered as an open recommendation

The three routes above rule out proving **ownership** of the key. They do not rule out checking its
**shape** — and the shape is regular: a fixed prefix, a narrow length band, a 50-symbol alphabet.
The codebase already performs precisely this class of check on the field sitting beside it, in the
same insert: `GLYPH|UEV_DalosAccount` enforces the account name's length, prefix, separator and
charset. **`public` is the one account field admitted with no shape check at all.**

Adding one would not make the key provably the owner's — that remains impossible. It would collapse
the accidental case (a truncated paste, a wrong field, an empty string, a Kadena key pasted where an
Ouronet key belongs) from *silently permanent* to *refused at the door*, leaving only the deliberate
substitution of a well-formed foreign key — which is self-harming in the ordinary case and, being
deliberate, is the part no validation could have stopped anyway.

Recorded here as a recommendation rather than a change: it narrows the window, it does not close it,
and the distinction is the whole point of this section.
