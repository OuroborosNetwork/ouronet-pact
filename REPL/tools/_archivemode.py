#!/usr/bin/env python3
"""Reduce an OBSOLETE module to ARCHIVE MODE: keep the data and the ability to READ it.

CANONICAL ARCHIVE MODE (owner ruling, 2026-09-21). When a module is superseded, it is not
deleted -- a deployed module cannot be removed in Pact, and its tables may hold history worth
reading. It is reduced instead:

    KEEP    schemas, deftables, constants, and every READ function
            (UR_ URC_ URCv_ URH_ URD_ UC_ UCv_ UDC_ INFO_ OI| CT_)
    DROP    every function that CHANGES something or gates a change
            (A_ AA_ C_ CC_ XI_ XE_ XB_ XIv_ XBv_ W_ WW_ AU_ URU_ P|A_ UEV_ CAP_)
    DROP    every `implements` -- an interface obligation would force non-read functions back in

The last line is the one with leverage: dropping `implements` removes the module from every
future interface CASCADE. DPMF implemented BrandingUsagePrimaryV2 alongside DPTF/DPOF/ATS/SWP,
so every branding signature change had to be carried into a module nobody calls.

WHY THE COMPILER IS THE ORACLE HERE. Unlike call ARITY -- which Pact resolves at runtime, and
which needs `_callarity.py` -- an unresolved NAME inside a module is a LOAD error. So removing
too much fails loudly and immediately. This tool therefore removes by BAND and expects you to
compile; `--keep NAME` puts back anything the closure needs. That is safer than trusting a
regex to compute the transitive closure, which over-matches on substrings.

USAGE
    python3 REPL/tools/_archivemode.py <file.pact>                  report what would go
    python3 REPL/tools/_archivemode.py <file.pact> --apply          do it
    python3 REPL/tools/_archivemode.py <file.pact> --apply --keep A --keep B

`--apply` is required to write (the 2026-09-15 rule for source-rewriting tools), and the file
argument is positional and mandatory -- there is no "all modules" mode, because archiving is a
per-module decision that someone must make deliberately.
"""
import os, re, sys

READ_PREFIXES  = ("UR_", "URC_", "URCv_", "URH_", "URD_", "URCi_", "UC_", "UCv_",
                  "UDC_", "INFO_", "OI|", "CT_")
WRITE_PREFIXES = ("A_", "AA_", "C_", "CC_", "Cp_", "CCp_", "Ap_", "AAp_",
                  "XI_", "XE_", "XB_", "XIv_", "XBv_", "W_", "WW_", "AU_", "AUx_",
                  "URU_", "UEV_", "CAP_")


# CAPABILITIES IN ARCHIVE MODE: only GOVERNANCE survives (owner ruling, 2026-09-21).
#
# A read-only module authorises nothing, so a capability in it gates nothing -- and a gate
# guarding nothing READS AS PROTECTION, which is the failure the Class-5 annotation work
# already documented. Three kinds go:
#
#   MOD|S>OP  MOD|C>OP  MOD|X>OP  MOD|W>OP   write gates; every consumer is gone
#   SECURE                                   `(defcap SECURE () true)` -- never protection
#   P|*|CALLER  P|SECURE-CALLER               inter-module caller guards for a surface that no
#                                             longer exists (nothing calls an archived module)
#
# `GOV` and `GOV|<MOD>_ADMIN` STAY, for two reasons that are not style: `(module X GOV)` NAMES
# its governance capability, so Pact will not load the module without it, and that capability
# still decides who may UPGRADE the archived module -- a live concern even when nothing calls it.
GATE_RE = re.compile(r'\|[SCXW]>')
DEAD_CAPS = ("SECURE", "P|SECURE-CALLER")


def band(name):
    if GATE_RE.search(name):
        return "write"
    if name in DEAD_CAPS or re.fullmatch(r'P\|[A-Za-z0-9_\-]+\|CALLER', name):
        return "write"
    core = name.split("|")[-1]
    for p in READ_PREFIXES:
        if core.startswith(p) or name.startswith(p):
            return "read"
    for p in WRITE_PREFIXES:
        if core.startswith(p) or name.startswith(p):
            return "write"
    return "other"


def forms(src, start):
    """[(kind, name, a, b)] -- paren-balanced spans of every module-level definition."""
    out = []
    rx = re.compile(r'\n    \((defun|defcap|defpact)\s+([A-Za-z0-9|_\->\.]+)')
    for m in rx.finditer(src, start):
        i = m.start() + 1                      # the '(' of the form
        d, j, instr = 0, i, False
        while j < len(src):
            c = src[j]
            if instr:
                if c == "\\":
                    j += 2
                    continue
                if c == '"':
                    instr = False
            elif c == '"':
                instr = True
            elif c == ";":
                nl = src.find("\n", j)
                j = len(src) if nl < 0 else nl
                continue
            elif c == "(":
                d += 1
            elif c == ")":
                d -= 1
                if d == 0:
                    j += 1
                    break
            j += 1
        out.append((m.group(1), m.group(2), i, j))
    return out



def emit_interface(path, new_name, old_name):
    """Build the ARCHIVE interface: the surviving schemas plus every surviving READ function.

    WHY A NEW INTERFACE RATHER THAN AN EDITED ONE (owner ruling, 2026-09-21). The module now
    has far fewer functions, and an interface is a PUBLISHED CONTRACT -- the thing a reader
    consults to learn what a module offers. Editing the old one in place would be a lie about
    a version that may already be deployed, and a deployed interface cannot be changed. So the
    suffix bumps by exactly one, per the cascade rule, and the new version declares only what
    the archived module actually has.

    THE OLD INTERFACE IS NOT DELETED FROM THE CHAIN -- nothing can delete it. It is removed from
    the SOURCE, because carrying a declaration of 95 functions that no longer exist is the
    "reads as verified and is false" failure this whole exercise keeps running into.

    Note what is NOT carried over: the module's OWN schemas stay module-side per CLAUDE.md's
    interface object-return rule (an interface loads before module schemas exist), so a reader
    returning `object{DPMF|PropertiesSchema}` cannot be declared here.
    """
    src = open(path, encoding="utf8").read()
    mi = src.index("\n(module ")
    body = src[mi:]
    mod_schemas = set(re.findall(r'\n    \(defschema ([A-Za-z0-9|_\-]+)', body))

    # schemas from the OLD interface -- these are load-bearing return types for the readers
    a = src.index("\n(interface " + old_name)
    b = src.index("\n(module ", a)
    old_if = src[a:b]
    schemas = []
    for m in re.finditer(r'\n    \(defschema ([A-Za-z0-9|_\-]+)', old_if):
        i = m.start() + 1
        d, j, instr = 0, i, False
        while j < len(old_if):
            c = old_if[j]
            if instr:
                if c == "\\":
                    j += 2
                    continue
                if c == '"':
                    instr = False
            elif c == '"':
                instr = True
            elif c == "(":
                d += 1
            elif c == ")":
                d -= 1
                if d == 0:
                    j += 1
                    break
            j += 1
        schemas.append(old_if[i:j])

    decls, skipped = [], []
    for m in re.finditer(r'\n    \(defun ([A-Za-z0-9|_\-]+)(:[A-Za-z0-9{}\.\[\]|_\-]+)?\s*\(([^)]*)\)', body):
        name, rt, params = m.group(1), m.group(2) or "", m.group(3)
        sm = re.search(r'object\{([A-Za-z0-9|_\-\.]+)\}', rt)
        if sm and "." not in sm.group(1) and sm.group(1) in mod_schemas:
            skipped.append(name)
            continue
        decls.append(f"    (defun {name}{rt} ({params}))")
    return schemas, decls, skipped



def verify_governance(path):
    """Refuse to leave a module that cannot be UPGRADED. Returns [] when sound.

    THIS EXISTS BECAUSE THE FAILURE IS UNRECOVERABLE. `(module X GOVCAP)` names the capability
    that authorises replacing the module's code. Sever any link in that chain and the module is
    BRICKED -- it keeps running, it just can never be changed again, and the only way out is to
    deploy a differently-named V2 and abandon the original. The owner has had that happen on a
    Kadena module; it is the single highest-consequence thing an archiving pass can break,
    because archiving is precisely the act of deleting definitions in bulk.

    The chain for DPMF, as an example of what is walked:

        (module DPMF GOV)
          -> (defcap GOV ()             (compose-capability (GOV|DPMF_ADMIN)))
          -> (defcap GOV|DPMF_ADMIN ()  (enforce-guard GOV|MD_DPMF))
          -> (defconst GOV|MD_DPMF      (keyset-ref-guard (GOV|Demiurgoi)))
          -> (defun GOV|Demiurgoi ...)

    Every name reached must still be defined. A `defconst` is safe by construction here (this
    tool only ever removes defun/defcap/defpact), but it is walked anyway rather than assumed,
    because "safe by construction" is a property of today's code, not a guarantee.
    """
    src = open(path, encoding="utf8").read()
    m = re.search(r'^\(module\s+(\S+)\s+(\S+?)\)?\s*$', src, re.M)
    if not m:
        return ["cannot find the (module ...) declaration"]
    gov = m.group(2).strip("()")
    defined = set(re.findall(r'\n    \(def(?:un|cap|const|pact|schema)\s+([A-Za-z0-9|_\->\.]+)', src))
    problems, seen, stack = [], set(), [gov]
    while stack:
        name = stack.pop()
        if name in seen:
            continue
        seen.add(name)
        if name not in defined:
            problems.append(f"governance chain references {name!r}, which is NOT defined")
            continue
        b = re.search(r'\n    \(def(?:un|cap|const|pact)\s+' + re.escape(name) + r'[\s(]', src)
        if not b:
            continue
        i = b.start() + 1
        d, j, instr = 0, i, False
        while j < len(src):
            c = src[j]
            if instr:
                if c == "\\":
                    j += 2
                    continue
                if c == '"':
                    instr = False
            elif c == '"':
                instr = True
            elif c == "(":
                d += 1
            elif c == ")":
                d -= 1
                if d == 0:
                    break
            j += 1
        # STRIP CROSS-MODULE MODREF BINDINGS before looking for references. A governance
        # function routinely binds a PEER module -- `(ref-U|CT:module{OuronetConstantsV2} U|CT)`
        # -- and neither the alias nor the target is defined in THIS file, nor should it be.
        # Without this the guard reported 14 sound modules as bricked, every one of them for
        # `U|CT`. A check that cries wolf on a seventh of the tree is a check nobody reads.
        chunk = re.sub(r'\(ref-[^\s:()]+:module\{[^}]*\}\s+[^\s()]+\)', " ", src[i:j])
        for ref in re.findall(r'[\s(]([A-Za-z][A-Za-z0-9|_\->\.]*)', chunk):
            if ref.startswith("ref-"):
                continue
            # PUSH EVERY PLAUSIBLE OURONET NAME, defined or not. The first version pushed only
            # refs already in `defined`, which meant a MISSING one was filtered out before it
            # could be reported -- the check was structurally incapable of failing. Caught by
            # deleting GOV|DPMF_ADMIN from a copy and watching it report SOUND.
            #
            # The discriminator is naming, and it is reliable in this tree: Ouronet identifiers
            # use `|` and `_`, Pact natives use `-` (compose-capability, enforce-guard,
            # keyset-ref-guard, create-capability-guard). So a reference carrying `|` or `_` is
            # ours and must resolve; anything else is a native or a local binding and is ignored.
            if "|" in ref or "_" in ref:
                stack.append(ref)
    return problems


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not args:
        print(__doc__)
        return 1
    path = args[0]
    apply_ = "--apply" in sys.argv
    keep_extra = {sys.argv[i + 1] for i, a in enumerate(sys.argv) if a == "--keep"}

    src = open(path, encoding="utf8").read()
    mstart = src.index("\n(module ")
    defs = forms(src, mstart)

    drop = [(k, n, a, b) for k, n, a, b in defs
            if band(n) == "write" and n not in keep_extra]
    impl = list(re.finditer(r'\n\s*\(implements\s+[A-Za-z0-9_\-]+\)', src[mstart:]))

    print(f"archive mode -- {os.path.relpath(path)}")
    print(f"  {len(defs)} definition(s): "
          f"{sum(1 for k,n,_,_ in defs if band(n)=='read')} read, "
          f"{sum(1 for k,n,_,_ in defs if band(n)=='write')} write, "
          f"{sum(1 for k,n,_,_ in defs if band(n)=='other')} other")
    print(f"  DROP {len(drop)} write-band definition(s), {len(impl)} implements clause(s)")
    if keep_extra:
        print(f"  --keep override: {', '.join(sorted(keep_extra))}")
    if not apply_:
        print("\n  (report only -- pass --apply to rewrite)")
        for k, n, _, _ in drop[:10]:
            print(f"     {k:7s} {n}")
        if len(drop) > 10:
            print(f"     ... and {len(drop)-10} more")
        return 0

    for k, n, a, b in sorted(drop, key=lambda x: -x[2]):
        src = src[:a] + src[b:]
    src = re.sub(r'\n\s*\(implements\s+[A-Za-z0-9_\-]+\)', "", src)
    open(path, "w", encoding="utf8").write(src)
    print(f"  rewrote {path}")
    gov_problems = verify_governance(path)
    if gov_problems:
        print("\n  !! GOVERNANCE CHAIN BROKEN -- the module would be UNUPGRADEABLE:")
        for g in gov_problems:
            print(f"     {g}")
        print("  !! Restore the named definitions with --keep and re-run. A bricked module")
        print("  !! cannot be repaired in place; the only exit is a renamed redeploy.")
        return 1
    print("  governance chain verified: the module can still be upgraded.")
    print("  NOW COMPILE. An unresolved name is a LOAD error, so the compiler enumerates")
    print("  anything the readers still needed; put each back with --keep and re-run.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
