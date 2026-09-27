# Reading data — where a client gets its state

Which modules to read from, how often, and what the response actually contains.

Measured against the deployed tree and OuronetUI on 2026-09-27.

---

## 0. The shape of the read layer

Ouronet's reads are **per-surface modules**, not one API. That is a deliberate correction to
what came before, and the reasoning is worth knowing because it explains the module names you
will be calling.

`DPL-UR` was one module carrying **71 public reads, 2,919 lines, 211,588 gas to deploy** — every
page read through it. Three problems followed:

- **It would not fit.** StoaChain allows ~2M gas per transaction and that one module was ~11% of
  a block with the pages still to come not yet in it.
- **Every change redeployed everything.** One dashboard field meant rerunning a 211k-gas
  transaction carrying 70 untouched functions.
- **Blast radius.** A 2026-09-24 outage took out *all 26* reads the UI makes at once, because
  they shared a module whose modrefs stopped binding.

So the reads were split one module per surface:

| module | surface |
|---|---|
| `O-UI-ONE` | dashboard header |
| `O-UI-TWO` | dashboard body — primordial asset cards |
| `O-UI-THREE` | Elite Account panel and rich list |
| `O-UI-FOUR` | Stoa ICO contributions |
| `O-UI-SEVEN` | Codex — account and StoicTag selectors |
| `O-UI-EIGHT` | True Fungibles |
| `O-UI-NINE` | Orto Fungibles |
| `O-UI-TEN` | Collectables |
| `O-UI-TWELVE` | SWP pools |

Numbers 5, 6 and 11 are not deployed. The sequence is reserved, not contiguous — do not infer a
module exists from the fact that its neighbours do.

---

## 1. If you are reading `DPL-UR` today

You are probably calling it without knowing, because the call is inside a package rather than in
your code. OuronetUI carries a **transport-level redirect**: **50** legacy `DPL-UR` reads are
rewritten to their AppReads replacements on the way out, and the response comes back in the shape
the original parser expects.

That shim exists for a specific reason worth repeating. `getPrimordials` lives in
`@ouronet/ouronet-core`, hardcodes its Pact string, and keeps its ~300-line response parser
**private**. Migrating call-site by call-site would have meant either a package release before
the UI could move, or duplicating that parser. Rewriting inside the reader avoided both — and
covered consumers that no UI source file mentions, including `@ancientpantheon/codex`, which
issues reads of its own.

**It is a shim and it should die.** When a package calls AppReads directly, its row is deleted;
when the table empties, the file goes. If you are writing new code, call the AppReads module
directly and never add a row.

One property to copy if you build something similar: **the fallback is per-read and loud.** If
the new module fails, the original call is re-issued, so a bad deploy degrades to old behaviour
rather than a blank page — and every rewrite and every fallback is logged. A silent fallback is
the failure worth guarding against, because it looks exactly like success for as long as nobody
checks.

---

## 2. How often to read

Reads are free, but they are not free to the node and they are not free to the user's battery.
OuronetUI runs a seven-tier cadence; a client of any size will want something like it:

| tier | name | interval | what it is for |
|---|---|---|---|
| `T1` | INSTANT | 0 s | a transaction confirmed — refresh now |
| `T2` | RAPID | 2 s | keystroke debounce while a user types an amount |
| `T3` | FAST | 5 s | nonce or set selection |
| `T4` | MEDIUM | 10 s | post-transaction propagation |
| `T5` | SLOW | 30 s | passive display |
| `T6` | LAZY | 60 s | background cycling |
| `T7` | IDLE | 120 s | keepalive |

The two that matter most for correctness rather than politeness:

- **`T2` for anything driven by an input.** A cost preview recomputed per keystroke is a request
  storm; coalescing them into one fetch per pause is the difference between a usable form and a
  rate limit.
- **`T1` after a confirmed transaction.** State the user just changed must not wait for a 30 s
  tick, or they will see the old value and do it again.

---

## 3. What a read returns

**The whole command result, not the value.** This catches everyone once:

```js
const r = await read(pactCode);
r["expected-output-amount"]        // undefined -- always
r.result.status                    // "success" | "failure"
r.result.data                      // the value you wanted
```

Reading the top level yields `undefined` for every field. If your code then defaults that to `0`
or `[]`, you get a plausible wrong answer rather than an error — a slippage floor of `0.000000`
and a fee that renders as a dash, both from the same mistake.

**Always check `.result.status` before using `.result.data`.** A failed read that you treat as
data is how a resolution error becomes a silent default (see `04-errors.md` §2a).

### Numbers are boxed, inconsistently

Decimals arrive as `{"decimal": "3.781627788266632705926895"}` and integers as `{"int": 24}` —
but not always, and the same field may be boxed in one reader and bare in another. Unbox
defensively.

**Do not round-trip a decimal through a JavaScript number if you intend to submit it.** That
example carries 24 significant digits; `Number()` keeps 17. Parse for display, submit the
original.

### Lists may be sentinels

A list may mean "none" rather than be empty. `["|"]` — one element, the pipe glyph — is the
`[BAR]` sentinel, and it appears in reader output, in preview output (`stoa-targets`), and in
the swap path cache (`nodes: ["|"]` means no route exists anywhere).

Check for it before you iterate. Inside the contracts, failing to do so is what took down a
whole button read: the sentinel was used as a table key.

---

## 4. Heavy reads

A read that scans — `URH_`, `URHC_`, `URD_` — is a different animal from a point read:

- It costs real gas to execute, even simulated.
- It **cannot be wrapped in `try`**. `select` and `keys()` are not permitted inside one at all:
  *"Operation is not allowed in read-only or system"*. The guard has to sit around the failure,
  not around the scan.
- It grows with the table. A read that is instant on a young chain is not necessarily instant
  later, and nothing warns you.

The AppReads modules handle this by splitting the scan out of the entry read and wrapping only
the part that can fail. Copy that shape rather than wrapping the whole thing and discovering it
does not compile.

---

## 5. Two failures that look like empty data

Both are worth a specific check, because both render as "nothing here" if you let them:

**A read that raised.** `.result.status === "failure"`. The message is in `.result.error.message`.
Show it, or at minimum distinguish it from an empty result — an unexplained blank panel is the
single most common way a real defect reaches a user in this codebase.

**A read that succeeded and returned a sentinel.** `.result.status === "success"` with
`data: ["|"]`. Nothing failed; the answer is "none". Rendering it as a one-item list produces a
row labelled `|`, which is how the sentinel gets noticed — usually by a user.

---

## Cross-references

- `01-client-orchestration.md` — reads that feed a transaction, and its registry appendix
- `03-cost-preview.md` — the `INFO_` readers specifically
- `04-errors.md` — what `try` catches, measured
- `OuronetInformational/HANDOFFS/HANDOFF-read-layer-split.md` — why the split, and the plan
