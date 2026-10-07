#!/usr/bin/env python3
"""Emit and verify the PureV5 hand-deploy round.

ROUND V5 IS OPEN AND EMPTY. This is the scaffold the next contract change lands in, created
2026-10-08 so that a change has somewhere to go the moment it exists -- V3 and V4 both began as
an edit made first and a pipeline assembled afterwards, which is how `Deploy/` drifted from its
sources twice.

HOW TO FILL IT. Add sources to `MANIFEST` keyed by deploy file, in deploy order, then:

    python3 REPL/tools/_purev5.py --plan     size + gas + the order proof, before writing
    python3 REPL/tools/_purev5.py --write    emit the bodies under the hand-written headers
    python3 REPL/tools/_purev5.py --check    regenerate in memory and diff (fatal in _gate)

THREE THINGS THAT DECIDE THE PACKING, all of them learned the expensive way:

  GAS GROWS AS THE SEVENTH POWER OF SIZE. `gas ~= 95_225 * (KB/256)**7`, ceiling ~395 KB at the
  2.00M limit. Fewer, bigger transactions is the wrong instinct: V3 was nearly consolidated from
  8 files to 3 of ~692 KB, which would have cost ~100,000,000 gas EACH. BALANCE beats count.

  THE DOT-PIN CASCADE IS USUALLY MOST OF THE ROUND. A dot call resolves at the CALLER's deploy
  time, and a stale caller of a table-owning callee ABORTS with "hash not blessed" rather than
  going quietly stale. V4 was twelve modules for a three-place change; seven of them were
  byte-identical to what was live. Run `python3 REPL/tools/_dotpin.py` and take the closure.

  A NEW INTERFACE CANNOT BE SIMULATED BEFORE IT EXISTS. Any module naming an interface this round
  introduces will fail the wallet's simulation until the transaction defining it has landed. That
  is expected and is not a reason to repack -- the modules that simulate FINE are the ones
  ordering actually protects. See `Deploy/PureV4/README.md` for the worked case.

CANDIDATES ALREADY KNOWN FOR THIS ROUND (neither is committed to -- both need an owner ruling):

  * `SCR|C>ENABLE-DEB-BOOST-SCORE` could enforce that a satellite's DEB flag matches its hub's,
    at ENABLE time rather than by inheriting at read time. Read-time inheritance would make
    `UR_SCR|ScoreDebBoost` stop reporting what is stored, and the deb-staleness check at
    `02_SCORE.pact:1691` compares against exactly that. Enforcing at the write is the smaller,
    honest version.
  * `09_AQP-INFO.pact` is absent from `deploy-stage02.repl`. It is live on mainnet (V3/08, and
    again in V4/06) so nothing is pending there, but a FROM-SCRATCH chain would miss it. That is
    a loader fix, not a deploy -- listed here so it is not forgotten when one is next assembled.
"""
import sys, os, re, difflib

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEPLOY = os.path.join(ROOT, "Deploy", "PureV5")
MARK = ";;@GENERATED-BODY-BELOW -- do not edit past this line; see REPL/tools/_purev5.py"

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
MANIFEST = {
    # EMPTY -- nothing is queued for V5 yet. Add entries as ("path", mode):
    #   "01_deploy.pact": [("1_SOVEREIGN/.../FOO.pact", "module-only")],
    # mode is "module-only" when the interface is already live, "iface+upgrade" when this round
    # ships a NEW interface whole and the module as an upgrade.
}
FROZEN = {}
HANDWRITTEN = {}

# Interfaces SHIPPED NEW by this round. Every module naming one must come LATER in the global
# sequence; a module naming an interface that has not loaded yet fails its modref at deploy.
NEW_IFACES: list[str] = []

# (callee module, caller module) pairs this round must honour: callee ships STRICTLY earlier.
# Derived from `_dotpin.py` and restricted to modules in this round.
DOT_EDGES: list[tuple[str, str]] = [
    # (callee, caller) pairs this round must honour: the callee ships STRICTLY earlier in the
    # global sequence. Derive from `python3 REPL/tools/_dotpin.py`, restricted to this round.
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
    known = set(MANIFEST) | set(FROZEN) | set(HANDWRITTEN) | {"README.md"}
    for f in sorted(os.listdir(DEPLOY)):
        if f not in known:
            print(f"  ORPHAN   {f}")
            bad += 1
    if bad and not write:
        print(f"PureV5: {bad} problem(s). Run REPL/tools/_purev5.py --write")
        return 1
    if not bad:
        print(f"PureV5: clean -- {len(MANIFEST)} generated, {len(FROZEN)} frozen")
    return 0


if __name__ == "__main__":
    sys.exit(main())
