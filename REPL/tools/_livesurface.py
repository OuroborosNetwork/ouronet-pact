#!/usr/bin/env python3
"""_livesurface.py -- the LIVE chain surface in ONE call, and what a deploy round must therefore be.

    python3 REPL/tools/_livesurface.py                 the whole live surface, grouped
    python3 REPL/tools/_livesurface.py --round DIR     audit a round against it (THE pre-deploy check)

WHY THIS EXISTS. Every deploy-round failure on 2026-10-24 -- five rounds declared ready and wrong,
six interfaces shipped at the wrong version, a genesis bundle sent at a live chain -- came from
the same move: answering "what is live?" from something OTHER than the chain. A hardcoded map, a
git commit, a cached JSON, a research summary. Each was right once and silently rotted.

`(list-modules)` ends that. ONE call returns every module and interface name in the namespace.
There is no version to guess, no map to re-point, nothing to go stale: the names ARE the answer.

    owner, 2026-10-24: "you can use (describe-namespace "ouronet-ns"), and see at a glance all
    modules and all interfaces bro. then you Know EXACTLY how to create the deploy pipeline"

(`describe-namespace` turned out to return only the namespace guards -- `list-modules` is the call
that enumerates. The instinct was exactly right; only the function name differed.)

WHAT IT CHECKS, with --round. The three failures that actually bit, each now mechanical:

  1. INTERFACE VERSION. A round declaring `XxxV3` when `XxxV3` is already live is dead on arrival
     ("Interface cannot be upgraded"). Required version is highest-live + 1, and a round must
     declare exactly that. The 2026-10-24 round got `TalosStageTwo_ClientThreeV3` wrong because it
     polled the eight AQP interfaces and never looked at Talos.

  2. GENESIS vs UPGRADE. A module already live must ship WITHOUT its `(create-table ...)` calls --
     they abort on a table that exists. `Deploy/1_Pure/` is the from-scratch bundle and keeps
     them; copying it into an upgrade round is what killed transaction 1.

  3. RE-SENT INTERFACE. A deployed interface can never be re-sent. If a round carries a file whose
     interface is already live at that exact name, it must ship MODULE-ONLY or bump.
"""
import os, re, sys, glob, json, importlib.util

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ROOT = os.path.dirname(ROOT)
TOOLS = os.path.join(ROOT, "REPL", "tools")


def _imp(name, path):
    sp = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(sp)
    sys.modules[name] = m
    sp.loader.exec_module(m)
    return m


def live_names():
    """-> set of every module/interface name live in ouronet-ns. ONE chain call."""
    reg = _imp("registry_livesurface", os.path.join(TOOLS, "_registry.py"))
    r = reg.rpc("(list-modules)")
    if not isinstance(r, list):
        sys.exit(f"list-modules did not return a list: {str(r)[:200]}")
    return {n.split(".", 1)[1] for n in map(str, r) if n.startswith("ouronet-ns.")}


def split_versioned(names):
    """-> {base: [versions]} for anything ending in V<n>, plus the unversioned rest."""
    fam, plain = {}, set()
    for n in names:
        m = re.match(r"^(.*?)V(\d+)$", n)
        if m:
            fam.setdefault(m.group(1), []).append(int(m.group(2)))
        else:
            plain.add(n)
    return {k: sorted(v) for k, v in fam.items()}, plain


def required_version(base, fam):
    """highest live + 1 -- the ONLY correct next version for an interface."""
    return max(fam.get(base, [0])) + 1


def audit(round_dir, live):
    fam, plain = split_versioned(live)
    files = sorted(glob.glob(os.path.join(round_dir, "*.pact")))
    if not files:
        sys.exit(f"no .pact files in {round_dir}")
    problems = []
    for p in files:
        txt = open(p, encoding="utf-8", errors="ignore").read()
        base_name = os.path.basename(p)
        for iface in re.findall(r"^\(interface\s+(\w+)", txt, re.M):
            m = re.match(r"^(.*?)V(\d+)$", iface)
            if not m:
                continue
            b, n = m.group(1), int(m.group(2))
            need = required_version(b, fam)
            if iface in live:
                problems.append((base_name, "RE-SENT INTERFACE", iface,
                                 f"already live -- ship MODULE-ONLY, or bump to {b}V{need}"))
            elif n != need:
                problems.append((base_name, "WRONG VERSION", iface,
                                 f"live={','.join('V%d' % v for v in fam.get(b, [])) or 'none'} "
                                 f"-> must be {b}V{need}"))
        for mod in re.findall(r"^\(module\s+([\w-]+)", txt, re.M):
            if mod in live and re.search(r"^\(create-table\s", txt, re.M):
                problems.append((base_name, "GENESIS BUNDLE", mod,
                                 "module is LIVE but the file carries (create-table ...) -- "
                                 "those abort on an existing table; build as an UPGRADE"))
    return problems


def main():
    live = live_names()
    fam, plain = split_versioned(live)
    if "--round" in sys.argv:
        rd = sys.argv[sys.argv.index("--round") + 1]
        probs = audit(rd, live)
        if not probs:
            print(f"{rd}: clean against the live surface "
                  f"({len(live)} live names) -- versions, upgrade-mode and interface re-sends all OK.")
            return 0
        print(f"{rd}: {len(probs)} problem(s) against the live surface\n")
        for f, kind, name, why in probs:
            print(f"  {kind:<18} {f:<22} {name}\n      {why}")
        print("\nNot deployable as-is. See OuronetInformational/HOW-DEPLOY-ROUNDS-WORK.md.")
        return 1
    print(f"LIVE SURFACE of ouronet-ns -- {len(live)} names (one `(list-modules)` call)\n")
    print(f"versioned families: {len(fam)}")
    for b in sorted(fam):
        vs = fam[b]
        print(f"  {b:<42} live {','.join('V%d' % v for v in vs):<22} next -> V{max(vs)+1}")
    print(f"\nunversioned: {len(plain)}")
    print("  " + ", ".join(sorted(plain)[:24]) + (" ..." if len(plain) > 24 else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
