# REPL integration test file layout (canonical)

Use this checklist when **adding or restructuring** any Ouronet **`REPL/**/*.repl`** that runs **`begin-tx` / `commit-tx`** integration steps. Reference implementation: **`REPL/Stage_02/[6.2.1]_AQP-ANK.repl`** and **`REPL/Stage_02/[6.2.2]_AQP-SCORE.repl`**.

Mechanical pass (preamble, **`;;|| NEXT`**, one **`· 01 ·`** banner per **`begin-tx`**): **`REPL/_normalize_repl_layout.py`** from repo root (`python3 REPL/_normalize_repl_layout.py`).

## Inter-transaction (between `commit-tx` and the next `begin-tx`)

Use the same **three-line** separator as **`REPL/Stage_01/[2.2]_Core.repl`**:

```pact
;;||>>>>>>>>>>>>>>>>>>>>>>>>>
;;|| NEXT                   >
;;||>>>>>>>>>>>>>>>>>>>>>>>>>
```

Optional blank `(print "")` lines around it for readability.

## Intra-transaction (inside one `begin-tx`)

1. **Numbered groups** — Within each transaction, label each logical block with a two-digit group index **`mm`** restarting at **`01`** for that transaction only:
   - **Comment:** `;;==== TXnnn · mm · <short slug> ====  …` (or `TX-SCORE-nn · mm ·` for score REPLs).
   - **REPL banner (required):** the **next** line should be  
     `(print "--- [TXnnn · mm · <same idea as slug>] ---")`  
     so the console mirrors the source and you can grep either form.

2. **Source mirrors console** — Order of `;;====` / `print "--- [...] ---"` / bodies should match the order lines will appear in the transcript.

3. **`format "{}"`** — Use **`{}`** placeholders only for values documented in the file header (e.g. Talos **`C_*`** return strings, ref-module **`UR_*`** return strings, **`expect` / `expect-failure`** doc strings, **`(env-gas)`**). Do not nest **`format`** around whole **`expect`** forms; build the doc with **`(format "…" [vals])`** as the first argument to **`expect`**.

4. **Assertions** — **`expect`** and **`expect-failure`** return **strings**. Collect them in a **list** and run **`(map print [ … ])`** so **every** assertion’s pass/fail line is printed (not only the last form’s value).

5. **`map print` residue** — **`(map print xs)`** evaluates to a list of **`()`** (one per element). Only the **last** form in a **`let`** body is echoed as the `let`’s value; if a long **`map print`** is last, you will see a long **`[() () …]`**. Prefer ending the **`let`** with a neutral value (e.g. **`""`**) or a short final **`print`** if you want to suppress that noise.

## File header (integration suites)

At the top of the file (after the `;;` preface), include:

- A **`FILE`** / **`================================================================`** banner naming this **`.repl`** path.
- A **Legend** block explaining angle-bracket log prefixes (`<<…>>` for expects, **`<(Talos|…>`** for client calls, **`<(Module|UR_…>`** for utility reads, **`<(REPL|env-gas)>`** for gas).
- One-line **Source** summary (`;;|| NEXT >`, **`;;==== TX… · mm ·`**).
- One-line **REPL tests** summary (**`map print`** of **`expect`** / **`expect-failure`**).

## Sovereign module cross-reference (optional)

Where a REPL is the primary scenario for a module, a one-line comment at **`(module …)`** in the sovereign **`.pact`** may point to the REPL and the **`TX… · mm ·`** convention (see **`01_ANK.pact`** / **`02_SCORE.pact`**).
