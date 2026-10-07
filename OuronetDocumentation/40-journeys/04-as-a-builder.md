# As a builder

Anyone can write a module that calls Ouronet. This chapter is what the sovereign surface guarantees
you, what it refuses you, and why the refusals are the useful part.

---

## 1. The two halves

| | |
|---|---|
| **Sovereign** | the protocol's own modules. Business logic, capability gates, the orchestration layer. |
| **Citizen** | extension modules. **Anyone can write one.** They call sovereign public APIs and add no capabilities to the core. |

The owner's framing:

> **everyone is able to construct their own logic in so-called citizen modules**

Several already exist and are worth reading as examples: asset registrars, minters, a bridge, and
five launchpad sales.

---

## 2. What you may call

**The orchestration layer, and only it.**

Core modules expose client functions, but those build an unfinished bill that only the orchestration
layer may settle. You have no permission for them. What you call are **finished operations** — 427
of them, each of which charges its own gas and returns a result.

So a citizen module is a **composition of complete operations**, not an assembly of parts.

### This is enforced economically, not syntactically

A sovereign module composes one bill across several legs and charges once. You cannot, and the
consequence is stated in the source:

> A citizen cannot fold cumulators (no permission for the bare uncollected core functions), so
> **gas is billed Σ-wise — once per operation.**

**Your module costs the sum of its legs.** A launchpad sale that runs two operations pays twice; a
redemption path running six pays six times.

That is a real cost. It is also the enforcement mechanism: **the permission boundary and the
billing boundary are the same boundary**, so there is no way to be inside one and outside the other.
Nothing has to detect an abuse, because the abuse is not expressible.

---

## 3. Being callable and being paid for are different

Your module's functions are callable by anyone the moment you deploy.

**Being gas-sponsored is a separate grant.** The gas station inspects a transaction's code and pays
only for shapes it recognises. The launchpad's own citizen orchestrator says it plainly:

> the citizen functions stay callable directly from their own module, but **ONLY these wrappers are
> the gas-funded path** — a direct citizen-module call would not have its gas paid.

So: permissionless to write, permissionless to call, **sponsored by arrangement**.

There is also a general door. The gas station will underwrite an **arbitrary block of code** if the
transaction pays for it in virtual gas — a flat 25 units. That is a product, not a loophole: it is
how you get sponsored execution for logic the protocol has never seen.

---

## 4. What the sovereign surface guarantees

**Every operation prices itself, and the price cannot lie.** The preview and the charge call the
same function. If you build a preview for your own module, sum the sovereign previews of your legs
and you have a number that cannot drift from what executes.

**Refusals are specific.** Ouronet's errors name the subject and the rule. A missing row says which
table and which key.

**Ownership is enforced at the core**, not by you. When you call a transfer, the sovereign
capability checks the signer. You do not reimplement that, and you cannot weaken it.

**Asset semantics are yours for free.** Roles, fees, freezing, wiping, the special variants — all of
it applies to any token you build on, including one you issue yourself.

---

## 5. What it refuses you

**No new capabilities on the core surface.** Your module cannot add a gate to a sovereign module.

**No inter-module authorisation gate of your own.** That guard belongs to the sovereign paths.

**No folded billing**, per §2.

**No editing sovereign state except through published operations.**

The net: **a citizen module can do anything a user can do, faster and in combination — and nothing a
user cannot.** That is a small guarantee to state and a large one to rely on, because it means a
citizen module cannot be a privilege-escalation path.

---

## 6. Conventions worth adopting

Your module is yours — the owner has ruled that **citizen modules are free to construct functions
as they please**, and the sovereign naming canon does not reach you.

Three things are still worth copying, because they are what the sovereign surface expects:

**Take the payer as your first argument.** Sovereign operations take the paying account first and
the acting account second. Threading them through keeps you consistent with everything you call.

**Ship a cost reader and a preview.** Sum the sovereign cost functions of your legs. Then anyone
integrating with you gets the same guarantee you got.

**Register your entrypoints.** The published registry is the only authority on how to call a citizen
function — precisely *because* the naming canon does not constrain you. If it is not in the
registry, an integrator cannot discover its shape.

---

## 7. One defect worth learning from

A launchpad sale's preview omitted one leg — a royalty paid by a collectable transfer:

> **Measured: 89.002 quoted against 89.004 charged on a two-share buy.**

Two thousandths of a token. Found only because the preview and the charge were separately computed
from a shared definition and someone compared them.

The lesson for a builder is precise: **summing your legs' costs is right, and it is only right if
you sum all of them.** An operation that internally charges something you did not call is still
charged to your user.

---

## Where to read next

- `10-architecture/02-sovereign-and-citizen.md` — the boundary in full
- `25-defi/04-the-launchpad.md` — five citizen modules on one sovereign core
- `05-as-an-integrator.md` — wiring a client
