#!/usr/bin/env python3
"""Emit and verify the PureV6 hand-deploy round.

ROUND V6 IS OPEN AND EMPTY. V5 closed 2026-10-09 with all six of its transactions on mainnet.
The sleeping-LP duration round lands here.

WHY A NEW FOLDER RATHER THAN REOPENING V5. `--write` regenerates from the CURRENT tree, so
re-adding a shipped file to a manifest overwrites the bytes the owner signed with bytes nobody
has deployed. V5's `02_deploy.pact` would have been rewritten the moment AQP-SCORE gained the
sleeping-LP duration scale -- the gate reported it STALE, which was the correct report and the
wrong fix. A round is a record of what went out.

QUEUED FOR THIS ROUND (see HANDOFF-sleeping-lp-duration-multiplier.md):
  * SCORE   per-nonce sleeping multiplier -- DONE in-tree, pinned by `[6.2.2] TX-SCORE-16`.
  * SCORE   the gated multiplier setter + `mx-frozen >= 2*mx-sleeping - 1`.
  * AQP     the re-rate sweep -- a FED-SLICE recipe (parallel-safe), NOT a cursor pager.
  * AQP     custody stake path for sleeping LP + the ordinary owner-unstake BLOCK.
  * TALOS   the orchestration, and direct sleeping-LP staking disabled.

    python3 REPL/tools/_purev6.py --plan / --write / --check

PACKING, unchanged: gas grows as the SEVENTH power of size (ceiling ~395 KB); the dot-pin
cascade is usually most of the round (`_dotpin.py`); a new interface cannot be simulated before
the transaction defining it has landed.
"""
import sys, os, re, difflib, json, io

# StoaChain runs `--block-gas-limit 2000000`; the UI's own fallback constant is
# `STOA_BLOCK_GAS_LIMIT` in `daimons/OuronetUI/src/lib/gas-limits.ts`. Named here rather
# than inlined so the manifest's gasLimit and this file's size-charge model (`gas()`,
# which solves for the same ceiling) cannot drift apart silently.
BLOCK_GAS_LIMIT = 2_000_000

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV6")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev6.py"

# 320,000 BYTES -- the same cap as V3, for the same measured reason. The binding constraint is
# GAS, and it scales as the seventh power of transaction size:
#
#   gas_size(S) ~= 95_225 * (S_KB / 256)**7
#
# fitted from the wallet deploy editor's own two data points (3 x ~256 KB = ~285,675 gas against
# ~202,525,154 for one 768 KB transaction), giving an exponent of 6.97 and a ceiling of ~395 KB at
# the 2.00M gas limit. `_purev3.py` carries the full derivation and the record of the 3-file
# consolidation that would have cost ~100,000,000 gas per transaction.
MAXBYTES = 320_000
# Header allowance used by --plan for a file that has not been emitted yet. The six current
# headers run 5,600-5,700 bytes; this is deliberately generous.
HEADER_RESERVE = 6_000

# A `create-table` form, INCLUDING a trailing ;; comment -- `(create-table FVT|T)   ;; Key = ...`.
# The obvious `[^)]+\)\s*$` misses those, and three survived into V3/06 on its first emission. A
# create-table in an UPGRADE aborts the whole transaction on a table that already exists, so the
# miss is paid in the owner's gas at signing time with nothing before it to object.
CT_RE = r'^\(create-table [^)]*\)[ \t]*(;;.*)?$'

AQP = "1_SOVEREIGN/STAGE_02/2_Core/03_AQP/"

# deploy file -> sources in deploy order.  ("path", mode):
#   module-only    ship from `(module `, create-table stripped -- the interface is already live
#   iface+upgrade  ship a NEW interface whole, then the module as an upgrade
MANIFEST: dict[str, list] = {}
FROZEN = {
    # ROUND V6 CLOSED 2026-10-10 -- all eleven transactions are on mainnet. From here these
    # files are a RECORD, not a source: `--write` must not touch them or it overwrites the
    # bytes that were signed. The sources they were cut from have already moved on (V7 changes
    # AQP-SCORE and AQP-POOL), so regenerating would silently rewrite deployed history.
    #
    # TX 11 NEEDED A HAND EDIT ON CHAIN. It shipped without `(acquire-module-admin AQP-SCORE)`
    # and failed with "Module admin is necessary but has not been acquired"; the owner added
    # the line and re-sent. The file here carries the corrected form -- see DEFECT-LEDGER 8.45.
    "01_deploy.pact": "on mainnet 2026-10-10",
    "02_deploy.pact": "on mainnet 2026-10-10",
    "03_deploy.pact": "on mainnet 2026-10-10",
    "04_deploy.pact": "on mainnet 2026-10-10",
    "05_deploy.pact": "on mainnet 2026-10-10",
    "06_deploy.pact": "on mainnet 2026-10-10",
    "07_deploy.pact": "on mainnet 2026-10-10",
    "08_deploy.pact": "on mainnet 2026-10-10",
    "09_deploy.pact": "on mainnet 2026-10-10",
    "10_deploy.pact": "on mainnet 2026-10-10",
    "11_init_create-table.pact": "on mainnet 2026-10-10 (hand-edited: acquire-module-admin)",
}

HANDWRITTEN = {
    # (moved into FROZEN above -- the round is closed)
    # NOT generated from a source module: a `create-table` for a table added to an
    # already-deployed module. Upgrade sources must not carry one (it aborts when the table
    # exists, which is why both packers strip them), so the table is created once, by hand,
    # in its own transaction. Run it AFTER TX 03 (AQP-SCORE) and before any sleeping stake.
}

# Interfaces SHIPPED NEW by this round. Every module naming one must come LATER in the global
# sequence; a module naming an interface that has not loaded yet fails its modref at deploy.
NEW_IFACES: list[str] = []

# (callee module, caller module) pairs this round must honour: callee ships STRICTLY earlier.
# Derived from `_dotpin.py` and restricted to modules in this round.
DOT_EDGES: list[tuple[str, str]] = [
    # (callee, caller): the callee ships STRICTLY earlier in the global sequence. Derived from
    # `python3 REPL/tools/_dotpin.py` and restricted to the modules in this round.
    ("AQP-SCORE", "RPS"), ("AQP-SCORE", "AQP-INFO"),
    ("AQP-POOL", "RPS"), ("AQP-POOL", "AQP-VCT"), ("AQP-POOL", "AQP-INFO"),
    ("AQP-POOL", "AQP-BOOT"),
    ("RPS", "AQP-FVT"), ("RPS", "AQP-VCT"), ("RPS", "MTX-AQP"), ("RPS", "AQP-DSA"),
    ("RPS", "AQP-INFO"),
    ("AQP-FVT", "AQP-INFO"), ("AQP-FVT", "AQP-BOOT"),
    ("AQP-VCT", "AQP-INFO"), ("AQP-DSA", "AQP-INFO"),
    ("TS02-C3", "AQP-INFO"), ("TS02-C3", "AQP-BOOT"),
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


def check_shape():
    """The two ways an emitted file burns the owner's gas, asserted on the emitted BYTES.

    Neither is visible to a source diff, and neither can be checked in the REPL: the load
    harness deploys from source, so it never sees an upgrade-mode body at all.

      create-table in an UPGRADE  aborts the whole transaction. 02_SCORE.pact ends in twelve of
                                  them and 11_EQUITY+.pact in two, all live since round V1.
      interface/module count      `iface+upgrade` emitting `module-only` drops the NEW interface
                                  and every module naming it fails to resolve its modref;
                                  emitting an already-live interface is refused outright.
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
    """Every dot-callee ships strictly before its callers; every new interface before its namers.

    NO-OPS ON A FROZEN ROUND. Ordering is a constraint on what is ABOUT TO BE SENT; once the
    manifest is empty every file is a record of something already on chain, and there is no
    sequence left to constrain. Without this the interface check fails the moment a round is
    frozen -- `NEW_IFACES` still names what the round shipped (which is worth keeping as the
    record) while no source remains to define it. Emptying `NEW_IFACES` instead would delete
    that record to satisfy a check that should not be running.
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

    WHY THIS IS NOT "one file that deploys everything". It is one file to LOAD; it is
    still eleven transactions, and it has to be. The size charge grows as the SEVENTH
    POWER of transaction size, so concatenating this round into a single `exec` would
    cost ~106,650,000,000 gas against a 2,000,000 limit -- fifty-three thousand times
    over. The split is not packaging, it is the only shape that deploys at all. What a
    manifest removes is the ELEVEN PASTES, which is the part a human can get wrong.

    SEQUENTIAL, AND THE MODE IS THE WHOLE POINT. `DOT_EDGES` in this file records the
    cross-module dot-call edges this round must honour: a caller deployed before its
    callee's upgrade keeps the OLD callee forever, and because these callees own tables
    it does not go stale, it ABORTS with "hash not blessed" on some later unrelated
    call. `parallel` would submit all eleven at once and nothing orders a miner's
    inclusion -- not submission order, not arrival order. So the group is sequential and
    says why, rather than leaving the reader to infer that a deploy round is ordered.

    THE INIT TRANSACTION RIDES IN THE SAME GROUP, last. `11_init_create-table.pact`
    must land AFTER tx 03 (it creates a table on the module 03 deploys) and it is
    hand-written rather than generated -- but it is still part of the round, and leaving
    it out of the manifest would be the one step a human has to remember separately,
    which is exactly the failure this removes. Sequential ordering makes "after 03"
    automatic.

    HASHES ARE PER-TRANSACTION AND THE BODY HASH COVERS THE WHOLE FILE, because the
    signer cannot read what they are signing -- 1.9 MB of generated Pact. `--write`
    having produced these bytes is not the same as the bytes in the manifest being
    those bytes, and the only honest way to offer "click once" is for the artefact to
    carry its own integrity.
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
            label = f"{name[:2]} — INIT create-table SCR|T|SleepStake"
        txs.append(MP.transaction(
            name.replace(".pact", ""), code, label=label,
            gas_limit=BLOCK_GAS_LIMIT, est_gas=int(gas(nbytes))))

    if missing:
        print("  MISSING: " + ", ".join(missing) + "\n  Run `--write` first.")
        return 1

    grp = MP.group(
        "PureV6 — duration multipliers, special-satellite scoring, custodial sleeping",
        "sequential",
        txs,
        note="STRICTLY ORDERED. Dot-pin edges between these modules mean a caller "
             "deployed before its callee's upgrade keeps the old callee and later "
             "ABORTS with 'hash not blessed' on an unrelated call. The last "
             "transaction creates a table on the module transaction 03 deploys, so it "
             "must follow it. Do not switch this group to parallel.")
    doc = MP.manifest(
        name="Ouronet PureV6",
        source="python3 REPL/tools/_purev6.py --multipact",
        groups=[grp], draft=False,
        signer={"role": "module governance keyset",
                "note": "Every transaction upgrades a module in ouronet-ns and is signed by "
                        "that module's governance keyset; the init transaction is signed by "
                        "AQP-SCORE's. AFTER the round, re-run "
                        "AQP-BOOT.C_Step0_WireImcAndGovernor -- it registers AQP-FVT's caller "
                        "guard on VST's IMP list, which nothing in this manifest does."},
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
        # EMITTED bytes, not body bytes. `_purev3.py --plan` reported the body and so UNDERSTATED
        # every transaction by the header -- ~5.6 KB here, and at the seventh power a 5.6 KB
        # understatement on the 296 KB file is ~13k gas. `--check` enforces MAXBYTES on the emitted
        # file, so a planner that measures something else is the "proxy whose check is advisory"
        # trap CLAUDE.md records against `_deploybundle.py`. When the file does not exist yet, fall
        # back to body + HEADER_RESERVE and say so, rather than silently reporting a smaller number.
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
        return 1 if (check_order() + check_shape()) else 0

    if "--multipact" in sys.argv:
        return emit_multipact()

    check, write = "--check" in sys.argv, "--write" in sys.argv
    if not (check or write):
        print(__doc__)
        return 0
    bad = check_order() + check_shape()
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
    # `ROUND.multipact.json` is an EMISSION OF the round, not a transaction in it: one file
    # OuronetUI's deploy queue loads so the operator does not paste eleven bodies by hand.
    # Known here so `--check` does not call it an orphan -- it is regenerated by
    # `--multipact`, which re-reads whatever `--write` last produced, so it can never
    # describe bytes that are not in this folder.
    known = set(MANIFEST) | set(FROZEN) | set(HANDWRITTEN) | {"README.md", "ROUND.multipact.json"}
    for f in sorted(os.listdir(DEPLOY)):
        if f not in known:
            print(f"  ORPHAN   {f}")
            bad += 1
    if bad and not write:
        print(f"PureV6: {bad} problem(s). Run REPL/tools/_purev6.py --write")
        return 1
    if not bad:
        print(f"PureV6: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen")
    return 0


if __name__ == "__main__":
    sys.exit(main())
