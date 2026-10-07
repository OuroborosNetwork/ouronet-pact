# Cost preview — what to show a user before they sign

How to obtain the price of an operation, what the returned object actually contains, and the
four ways a client can display a confidently wrong number.

Measured against mainnet and the consumer registry on 2026-09-27. Figures were read from
`Deploy/OURONET-REGISTRY.json` or returned by a live `/local` call; none is remembered.

---

## 0. Why you cannot compute this yourself

An Ouronet price is not a constant you can look up and multiply. It is a multi-leg computation
over live state — tier discounts, fee toggles, per-pool settings, route length — assembled by
`URCi_` cost readers inside the contracts. `DPTF|C_ClearDispoForeign` is priced by a five-leg
concatenation that exists nowhere outside its reader.

So the only honest way to show a cost is to **ask the chain**, through the `INFO_` reader paired
with the operation. The registry carries **432** of them, and **all 427** client entrypoints
are paired — none is left without a cost preview.

That was briefly untrue, and the exception is worth recording because of how it arose. Four
per-leg vacate entrypoints were named `AQP-POOL|XB_Vacate*`, and an `XB_` name matches neither
the registry's entrypoint filter nor the price sheet's — so four live, BILLED client operations
sat in neither, for as long as they had existed. Renaming them to `CC_Vacate*` did not create
the gap; it made it reportable, and the gate reported it the same hour. Their `INFO_` readers
shipped in `PureV2/30`.

The lesson is about the filter, not the four: a naming convention that decides what a tool can
SEE will hide anything misnamed, and it will hide it silently.

---

## 1. The hazard that dominates everything else

**414 of the 427 entrypoints have a preview whose parameter list differs from their own.**
Only 13 match. Different names, different order, different arity.

A live example — the two are not close:

```
execution   DPTF|C_Transfer        (patron, executor, executee, id, transfer-amount, method)
preview     INFO_DPTF|Transfer     (patron, id, sender, receiver, transfer-amount)
```

`id` is the **fourth** argument of the execution and the **second** of the preview. A client
that collects values for the operation and passes them positionally to its preview puts the
executor's ACCOUNT where the TOKEN ID belongs.

That failure is silent. Both are strings, so nothing type-errors; the reader simply prices a
different question and returns a confident number. **This is the single most dangerous thing in
the cost-preview surface**, and it is dangerous precisely because it produces an answer.

### The rule

**Bind preview arguments by NAME, never by position.** The registry declares both parameter
lists, so a client can map one to the other explicitly — and should refuse rather than guess
when a preview declares a parameter the execution does not have.

Where a preview genuinely wants a different *type* for the same concept, map it deliberately.
`SWP|C_UpdateSpecialFeeTargets` takes `targets:[object{FeeSplit}]` while its preview takes
`targets:[string]` — the reader only formats them into a sentence, so it wants the accounts and
not the splits. A formatter that refuses an object where a string is declared is doing you a
favour; do not defeat it by flattening early.

---

## 2. What comes back

A `ClientInfo` object. Measured on `INFO_DPTF|Transfer`:

```json
{
  "ignis": {
    "ignis-full":     1,
    "ignis-discount": 0.52,
    "ignis-need":     0.52,
    "ignis-text":     "Operation costs 1 IGNIS discounted by 48.0% to 0.52 IGNIS valued at 0.520¢"
  },
  "stoa": {
    "stoa-full": 0, "stoa-need": 0, "stoa-discount": 1, "stoa-split": [0],
    "stoa-targets": ["|"],
    "stoa-text": "Operation is free of native Stoa (STOA)"
  },
  "pre-text":  [ "Operation: …" ],
  "post-text": [ "Succesfully …" ],
  "output":    []
}
```

`pre-text` describes what is about to happen, `post-text` what success will look like. Both are
lists — render them as lines, not as a single string.

### 2a. `ignis-discount` is a MULTIPLIER, not a discount

This field is misnamed and will catch you:

```
ignis-full 1  ×  ignis-discount 0.52  =  ignis-need 0.52
text: "discounted by 48.0%"
```

`0.52` is **the fraction you pay**. The 48% in the text is its complement. A client that renders
`ignis-discount` as "52% off" reports the opposite of the truth, and plausibly — the number is
in range and the arithmetic looks fine.

**Show `ignis-need`.** It is the amount that will be taken. Derive any percentage as
`1 - ignis-discount` if you must show one at all.

### 2b. Numbers arrive boxed

Pact decimals and integers come back as `{"decimal": "3.781627788266632705926895"}` and
`{"int": 24}`, not as JSON numbers — and not always. The same field may be boxed in one response
and bare in another depending on the reader.

Unbox defensively, and **do not round-trip a decimal through a JavaScript number if you intend
to submit it.** That example has 24 significant digits; `Number()` keeps 17. Display the parsed
value, submit the original object.

### 2c. Sentinels appear in previews too

`"stoa-targets": ["|"]` above is the same `[BAR]` sentinel documented in `04-errors.md` §2d — a
one-element list containing the pipe glyph, meaning "none", not a list containing a target
called `|`. Check before you iterate.

---

## 3. When the price depends on what the user has not chosen yet

Some costs are **route-dependent** and cannot be known at the moment the user clicks.

SmartSwap is the case that matters. `INFO_SWP|SmartSwap*Bundle` prices **the bundle it is
handed**, so a six-hop route costs more than a one-hop route. Before route discovery has run
there is no honest number to show — anything displayed is a guess about a route nobody has
chosen.

This forces a UI shape rather than suggesting one:

1. user supplies inputs and commits to the operation
2. discovery runs off-chain, free (measured: ~8 reads, ~0.5 s for one hop)
3. **only now** the preview is called, with the assembled bundle
4. the user sees route, output, floor and fee, and signs

If a client wants to skip step 4, that is a legitimate preference — but it means the user
approves a price they never saw, and it should be an explicit setting rather than the default.

**Corollary:** pair the operation with the preview that takes the same inputs. The bundle
entrypoints and the self-searching entrypoints share an action name, so a naive
`CATEGORY|Action` pairing gives the bundle operation the SELF-SEARCHING preview — which prices
whatever route it finds rather than the route being submitted. They agree only when the two
coincide, which at one hop they do, which is exactly why the mismatch survives casual testing.

---

## 4. Finding the right reader

Previews live in different modules from the operations they price (`INFO-ONE`, `INFO-TWO`,
`AQP-INFO`, and the citizen sale modules). Assuming one module is how a consumer ended up calling
`INFO-ZERO` for readers that had moved.

The general shape is `CATEGORY|C_Action` → `INFO_CATEGORY|Action`, but it does not always hold:

- **Citizen sales** put the reader on the sale module and drop the category segment.
- **Category aliases** — Talos says `LQD|`, the preview says `LIQUID|`.
- **Spelling** — `C_Redem…` against `INFO_Redeem…`.

**Twenty-one** entrypoints have a reader that exists but does not fit the pattern. Rather than
loosen the match — which risks pairing an operation with the WRONG preview, and a wrong price
shown to a user is worse than none — each is recorded as an explicit exception, and the registry
reports which entrypoints were paired that way.

**Twenty previews are referenced by nothing.** Some are genuinely spare; at least two are the
bundle-aware SmartSwap readers described above. An orphaned preview is worth checking before
assuming an operation has none.

---

## 5. What is NOT a cost

A `/local` read reports a `gas` figure. **That is not IGNIS.** IGNIS is Ouronet's virtual gas,
collected by Talos after a `C_`; a read is not a transaction, collects none, and costs the user
nothing. The `gas` field is the node's meter for a simulated execution, billed to nobody.

It is still worth surfacing in one situation: when a client does substantial off-chain work to
keep a transaction cheap, that figure is the size of the work it moved. Label it as simulated
and free, or it will be read as a second fee.

---

## Cross-references

- `04-errors.md` — what happens when a preview fails, and the sentinel convention
- `01-client-orchestration.md` — the read-build-execute shapes previews sit inside
- `OuronetInformational/IGNIS-PRICING/IGNIS-PRICING.md` — the cost model itself
- `OuronetInformational/HANDOFFS/HANDOFF-talos-registry.md` — where both parameter lists are declared
