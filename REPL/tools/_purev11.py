#!/usr/bin/env python3
"""Emit and verify the PureV11 hand-deploy round.

ROUND V11 -- one operation, one event. TS02-C3 was emitting two.

Reported live, 2026-10-14, reading the explorer against a real
`CC_ReassignTrueFungibleStakeBeneficiary`: the transaction carried TWO near-identical events for
a single operation -- `FVT|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` from AQP-FVT, which is where the
conditions and the write live, AND `AQP|C>REASSIGN-TRUE-FUNGIBLE-BENEFICIARY` from the TS02-C3
Talos shell, which only forwards. The owner's call: *"only the function from the module itself has
to be evented ... on the P|TS capability would have been enough. there was no need to event from
the Talos Module."*

MEASURED, because the first instinct was that this was a slip in the three Reassign caps added
days earlier. It is not -- it is the whole module:

    TS02-C3        23 of 28 defcaps evented
    every other Talos module in the tree    0
      (TS01-A, TS01-C1, TS01-C2, TS01-C3, TS01-P, TS01-C4, TS02-C1, TS02-C2, TS02-DPAD)

and TS02-C3 already contradicts itself in its own file: `AQP-POOL|C_FinalizeVacate` and
`AQP-POOL|CC_FullVacate` acquire a bare `(with-capability (P|TS) ...)` -- the correct shape --
sitting a few lines from siblings that do not.

THE RULE APPLIED HERE (owner, 2026-10-14). One evented capability per core function called:

  * Talos FORWARDS to a core function that is already evented  -> Talos must NOT event.  14 caps.
  * Talos orchestrates SEVERAL evented core functions          -> still does not event; the
    several events are the several real operations, not a duplicate.
  * The core function carries NO evented capability            -> the Talos cap is the single
    event and STAYS.                                              9 caps, listed below.

The nine kept are the stake/unstake family: `FVT|C>TRUE-FUNGIBLE-STAKE-FLOW`,
`FVT|C>ORTO-FUNGIBLE-STAKE-FLOW` and `FVT|C>COLLECTABLE-STAKE-FLOW` are not evented, and each is
one `direction:bool` recipe shared by a stake and an unstake -- it could not name which happened
even if it were. Stripping those would leave the entire AQP stake surface with no event at all,
which is the opposite of the ask.

WHAT SHIPS. Removing `@event` changes no signature, no table, no interface -- `defcap`s are not
interface members here, so `TalosStageTwo_ClientThreeV3` is untouched and stays live as deployed
in V10. Only the module body changes. But TS02-C3 OWNS TABLES its dot-callers read, so
`python3 REPL/tools/_dotpin.py --upgrade TS02-C3` is the authority on the round's real size:

  01  TS02-C3     the fix -- 14 caps lose `@event`, 9 keep it
  02  AQP-INFO    dot-pin re-pin only (1 call site)
  03  AQP-BOOT    dot-pin re-pin only (1 call site)

A dot-caller left on the superseded hash does not go stale, it ABORTS with "hash not blessed" on
its next call in. 02 and 03 carry no source change of their own this round; they are here because
01 moved.

No client transaction this round -- nothing migrates. An event that is no longer emitted needs no
backfill, and the events already on chain stay exactly as they were recorded.

    python3 REPL/tools/_purev11.py --plan / --write / --check / --multipact
"""
import sys, os, re, difflib, json, io

# StoaChain runs `--block-gas-limit 2000000`; the UI's own fallback constant is
# `STOA_BLOCK_GAS_LIMIT` in `daimons/OuronetUI/src/lib/gas-limits.ts`.
BLOCK_GAS_LIMIT = 2_000_000

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV11")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev11.py"

# 320,000 BYTES -- the same cap every round since V3. The binding constraint is GAS, and the size
# charge grows as the SEVENTH power of transaction size:
#
#   gas_size(S) ~= 95_225 * (S_KB / 256)**7
#
# fitted from the wallet deploy editor's own two data points. See _purev8.py for the derivation.
# This round's three modules are 150 KB / 110 KB / 101 KB emitted -- comfortably inside it, and
# one module per transaction keeps it that way.
MAXBYTES = 320_000
# Header allowance used by --plan for a file that has not been emitted yet.
HEADER_RESERVE = 6_000

# A `create-table` form, INCLUDING a trailing ;; comment. An upgrade source must carry none --
# `create-table` aborts the whole transaction on a table that already exists.
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

TALOS = "1_SOVEREIGN/STAGE_02/3_Talos/"
AQP = "1_SOVEREIGN/STAGE_02/2_Core/03_AQP/"

# deploy file -> sources in deploy order.  ("path", mode):
#   module-only    ship from `(module `, create-table stripped -- the interface is already live
MANIFEST = {
    "01_deploy.pact": [(TALOS + "04_TS02-C3.pact", "module-only")],
    "02_deploy.pact": [(AQP + "09_AQP-INFO.pact", "module-only")],
    "03_deploy.pact": [("2_CITIZEN/5_VaultsMinter/04_AQP-BOOT.pact", "module-only")],
}
FROZEN = {}

HANDWRITTEN = {
    # None. Removing `@event` emits one fewer event from here on and rewrites nothing that was
    # already recorded, so there is no state to migrate and no client call to make.
}

# Interfaces SHIPPED NEW by this round. None -- `defcap`s are not interface members in this tree,
# so `TalosStageTwo_ClientThreeV3` is byte-identical to the copy V10 put on chain. Re-sending a
# live interface is refused, which is exactly why every source here is `module-only`.
NEW_IFACES: list[str] = []

# (callee module, caller module) pairs this round must honour: callee ships STRICTLY earlier.
# Derived from `python3 REPL/tools/_dotpin.py --upgrade TS02-C3`. TS02-C3 reads its OWN tables, so
# a pinned caller does not merely go stale -- it ABORTS with "hash not blessed". The tree blesses
# nothing, so both callers must be in THIS round, after it.
DOT_EDGES: list[tuple[str, str]] = [
    ("TS02-C3", "AQP-INFO"),
    ("TS02-C3", "AQP-BOOT"),
]


def read(rel):
    return open(os.path.join(ROOT, rel), encoding="utf8").read()


def module_name(rel):
    return re.search(r'^\(module\s+(\S+)', read(rel), re.M).group(1)


def source_body(rel, mode):
    text = read(rel)
    k = re.search(r'^\(module ', text, re.M).start()
    body = re.sub(CT_RE, '', text[k:], flags=re.M).rstrip()
    if mode == "iface+upgrade":
        j = re.search(r'^\(interface ', text, re.M).start()
        iface = text[j:k].rstrip()
        note = " (new interface, whole; module as an upgrade -- create-table stripped)"
        return f";; ---- source: {rel}{note}\n{iface}\n\n{body}\n"
    return f";; ---- source: {rel} (module only -- its interface is already live)\n{body}\n"


def body_for(sources):
    out = ['(namespace "ouronet-ns")', ""]
    for rel, mode in sources:
        out.append(source_body(rel, mode))
    return "\n".join(out)


def gas(nbytes):
    return 95_225 * ((nbytes / 1024) / 256) ** 7


def sequence():
    """Global deploy order: (position, deploy file, rel, mode). Modules inside one transaction
    load top to bottom, so position -- not transaction index -- is what ordering constrains."""
    out = []
    for name in sorted(MANIFEST):
        for rel, mode in MANIFEST[name]:
            out.append((len(out), name, rel, mode))
    return out


def check_events():
    """THE ROUND'S OWN INVARIANT, asserted on the source it is about to ship.

    A round that exists to remove 14 `@event`s should refuse to emit a TS02-C3 that still has
    them -- and should refuse just as loudly if someone later strips the nine that must STAY,
    which is the failure this file's docstring argues is worse. Both directions, by name, so a
    future edit cannot quietly land inside a deploy artefact.
    """
    KEEP = {
        "AQP|C>STAKE-TRUE-FUNGIBLE", "AQP|C>UNSTAKE-TRUE-FUNGIBLE",
        "AQP|C>STAKE-ORTO-FUNGIBLE", "AQP|C>UNSTAKE-ORTO-FUNGIBLE",
        "AQP|C>STAKE-SPECIAL-CUSTODIAL",
        "AQP|C>STAKE-SEMI-FUNGIBLE-COLLECTABLE", "AQP|C>UNSTAKE-SEMI-FUNGIBLE-COLLECTABLE",
        "AQP|C>STAKE-NON-FUNGIBLE-COLLECTABLE", "AQP|C>UNSTAKE-NON-FUNGIBLE-COLLECTABLE",
    }
    lines = read(TALOS + "04_TS02-C3.pact").split("\n")
    i, n, evented = 0, len(lines), set()
    while i < n:
        m = re.match(r'^\s*\(defcap\s+(\S+)', lines[i])
        if not m:
            i += 1
            continue
        depth, j, started, block = 0, i, False, []
        while j < n:
            block.append(lines[j])
            for ch in lines[j]:
                if ch == '(':
                    depth += 1
                    started = True
                elif ch == ')':
                    depth -= 1
            j += 1
            if started and depth <= 0:
                break
        if re.search(r'^\s*@event\s*$', "\n".join(block), re.M):
            evented.add(m.group(1))
        i = j
    bad = 0
    for cap in sorted(evented - KEEP):
        print(f"  EVENT   {cap} still carries @event -- it forwards to an already-evented core "
              f"capability, so shipping it reintroduces the double event this round removes")
        bad += 1
    for cap in sorted(KEEP - evented):
        print(f"  NO-EVENT  {cap} lost its @event -- the core recipe it calls "
              f"(FVT|C>*-STAKE-FLOW) is NOT evented, so this leaves the operation with no event "
              f"at all. See this tool's docstring for why the nine are the exception")
        bad += 1
    return bad


def check_shape():
    """The two ways an emitted file burns the owner's gas, asserted on the emitted BYTES.

    Neither is visible to a source diff, and neither can be checked in the REPL: the load
    harness deploys from source, so it never sees an upgrade-mode body at all.
    """
    bad = 0
    for name, sources in sorted(MANIFEST.items()):
        body = body_for(sources)
        ct = len(re.findall(r'^\(create-table ', body, re.M))
        if ct:
            print(f"  CREATE-TABLE  {name} -- {ct} create-table form(s) survived into an upgrade; "
                  f"this aborts the transaction on a table that already exists")
            bad += 1
        ifaces = len(re.findall(r'^\(interface ', body, re.M))
        want = sum(1 for _, m in sources if m == "iface+upgrade")
        if ifaces != want:
            print(f"  INTERFACE  {name} -- {ifaces} interface form(s), expected {want}. "
                  f"Too many re-sends a live interface (refused); too few drops a new one and "
                  f"breaks every modref downstream")
            bad += 1
        mods = len(re.findall(r'^\(module ', body, re.M))
        if mods != len(sources):
            print(f"  MODULE  {name} -- {mods} module form(s) for {len(sources)} source(s)")
            bad += 1
    return bad


def check_order():
    """Every dot-callee ships strictly before its callers.

    NO-OPS ON A FROZEN ROUND. Ordering is a constraint on what is ABOUT TO BE SENT; once the
    manifest is empty every file is a record of something already on chain.
    """
    seq, bad = sequence(), 0
    if not seq:
        return 0
    pos = {}
    for i, name, rel, _ in seq:
        pos[module_name(rel)] = (i, name)
    for callee, caller in DOT_EDGES:
        if callee not in pos or caller not in pos:
            continue
        if pos[callee][0] >= pos[caller][0]:
            print(f"  ORDER   {caller} dot-calls {callee}, but {callee} ships in "
                  f"{pos[callee][1]} and {caller} in {pos[caller][1]} -- callee must come EARLIER "
                  f"or {caller} pins a superseded hash and aborts on its tables")
            bad += 1
    for iface in NEW_IFACES:
        born = [i for i, _, rel, mode in seq
                if mode == "iface+upgrade" and re.search(rf'^\(interface {iface}\b', read(rel), re.M)]
        if not born:
            print(f"  INTERFACE  {iface} is listed in NEW_IFACES but no `iface+upgrade` source "
                  f"in the round defines it")
            bad += 1
            continue
        for i, name, rel, mode in seq:
            if i == born[0]:
                continue
            if re.search(rf'\b{iface}\b', read(rel)) and i < born[0]:
                print(f"  ORDER   {rel} names {iface} but ships in {name}, at sequence position "
                      f"{i}, before the interface itself at {born[0]}")
                bad += 1
    return bad


def emit_multipact():
    """Emit the round as ONE Multipact manifest for OuronetUI's deploy queue.

    SEQUENTIAL, AND THE MODE IS THE WHOLE POINT: TS02-C3 must land before the two modules that
    dot-pin it, or they keep the old hash and abort later on an unrelated call.
    """
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
    import _multipact as MP

    txs, missing = [], []
    for name in sorted(MANIFEST) + sorted(HANDWRITTEN):
        path = os.path.join(DEPLOY, name)
        if not os.path.exists(path):
            missing.append(name)
            continue
        code = io.open(path, encoding="utf-8").read()
        nbytes = len(code.encode())
        if name in MANIFEST:
            mods = ", ".join(module_name(r) for r, _ in MANIFEST[name])
            label = f"{name[:2]} — {mods}"
        else:
            label = name
        txs.append(MP.transaction(
            name.replace(".pact", ""), code, label=label,
            gas_limit=BLOCK_GAS_LIMIT, est_gas=int(gas(nbytes))))

    if missing:
        print("  MISSING: " + ", ".join(missing) + "\n  Run `--write` first.")
        return 1

    grp = MP.group(
        "PureV11 — one operation, one event: the Talos shell stops duplicating the core's",
        "sequential",
        txs,
        note="STRICTLY ORDERED. TS02-C3 owns tables that AQP-INFO and AQP-BOOT dot-call, so "
             "either of them deployed before TS02-C3's upgrade keeps the old hash and later "
             "ABORTS with 'hash not blessed' on an unrelated call. Do not switch this group "
             "to parallel.")
    doc = MP.manifest(
        name="Ouronet PureV11",
        source="python3 REPL/tools/_purev11.py --multipact",
        groups=[grp], draft=False,
        signer={"role": "module governance keyset",
                "note": "Every transaction upgrades a module in ouronet-ns and is signed by "
                        "that module's governance keyset."},
        defaults={"gasLimit": BLOCK_GAS_LIMIT})

    errs = MP.validate(doc)
    if errs:
        for e in errs:
            print("  INVALID: " + e)
        return 1

    out = os.path.join(DEPLOY, "ROUND.multipact.json")
    with io.open(out, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, indent=1)
    print(MP.summary(doc))
    print(f"\n  wrote {out}")
    print(f"  {len(txs)} transactions, {sum(len(t['code'].encode()) for t in txs):,} bytes, "
          f"~{sum(t['estGas'] for t in txs):,} gas in size charges")
    return 0


def main():
    if "--plan" in sys.argv:
        tot, gt, est = 0, 0.0, False
        for name, srcs in sorted(MANIFEST.items()):
            path = os.path.join(DEPLOY, name)
            if os.path.exists(path):
                b, mark = os.path.getsize(path), " "
            else:
                b, mark, est = len(body_for(srcs).encode()) + HEADER_RESERVE, "~", True
            tot, gt = tot + b, gt + gas(b)
            mods = ", ".join(module_name(r) for r, _ in srcs)
            flag = "  !! OVER CAP" if b > MAXBYTES else ""
            print(f"  {name} {mark} {b:7,} bytes  ~{gas(b):9,.0f} gas   {mods}{flag}")
        print(f"\n  {len(MANIFEST)} transactions, {tot:,} emitted bytes, ~{gt:,.0f} gas total "
              f"(per-tx ceiling ~395 KB / 2.00M gas; charge grows as size^7)")
        if est:
            print(f"  `~` = not yet written; body + {HEADER_RESERVE:,}-byte header reserve")
        return 1 if (check_order() + check_shape() + check_events()) else 0

    if "--multipact" in sys.argv:
        return emit_multipact()

    check, write = "--check" in sys.argv, "--write" in sys.argv
    if not (check or write):
        print(__doc__)
        return 0
    bad = check_order() + check_shape() + check_events()
    for name, sources in sorted(MANIFEST.items()):
        path = os.path.join(DEPLOY, name)
        if not os.path.exists(path):
            print(f"  MISSING  {name} -- no header written yet")
            bad += 1
            continue
        cur = open(path, encoding="utf8").read()
        if MARK not in cur:
            print(f"  NO-MARKER  {name}")
            bad += 1
            continue
        want = cur.split(MARK)[0] + MARK + "\n\n" + body_for(sources) + "\n"
        n = len(want.encode())
        if n > MAXBYTES:
            print(f"  TOO BIG  {name} -- {n:,} bytes over the {MAXBYTES:,} cap")
            bad += 1
        if want == cur:
            continue
        if write:
            open(path, "w", encoding="utf8").write(want)
            print(f"  wrote    {name}  ({n:,} bytes, ~{gas(n):,.0f} gas)")
        else:
            print(f"  STALE    {name}")
            for line in list(difflib.unified_diff(cur.splitlines(), want.splitlines(),
                                                  "on-disk", "regenerated", lineterm="", n=1))[:12]:
                print(f"           {line[:100]}")
            bad += 1
    known = set(MANIFEST) | set(FROZEN) | set(HANDWRITTEN) | {"README.md", "ROUND.multipact.json"}
    for f in sorted(os.listdir(DEPLOY)) if os.path.isdir(DEPLOY) else []:
        if f not in known:
            print(f"  ORPHAN   {f}")
            bad += 1
    if bad and not write:
        print(f"PureV11: {bad} problem(s). Run REPL/tools/_purev11.py --write")
        return 1
    if not bad:
        print(f"PureV11: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen")
    return 0


if __name__ == "__main__":
    sys.exit(main())
