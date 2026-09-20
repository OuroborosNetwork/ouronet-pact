#!/usr/bin/env python3
"""_policyimp.py -- bring every OuronetPolicyV2 implementor to the canonical IMP guard-chain API.

WHAT IT WRITES, and why each piece exists.

  P|A_AddIMP     made IDEMPOTENT. It used to end in `UC_AppL` = `(+ in [item])` -- a blind append
                 with no dedupe. Measured 2026-09-20: re-running ONE module's `P|A_Define` took
                 IGNIS' IMP from 16 entries to 17. Since `P|UEV_IMC` -> `U|G::UEV_Any` maps
                 `UC_Try` over the WHOLE chain with no short-circuit, a duplicate is not inert --
                 it costs gas on every IMC-gated call, forever, and nothing reports it. Making the
                 add idempotent means `P|A_Define` can be replayed safely, which retires that
                 whole class of deploy hazard rather than routing around it.

  P|A_RemoveIMP  NEW. There was no way to revoke a guard. Not a tidiness gap: a retired or
                 compromised peer could not be taken off the chain by any means short of a module
                 upgrade. Uses `UC_RemoveItem` = `(filter (!= item) in)`, which drops EVERY
                 occurrence -- so it is also the cleanup for duplicates already on a live chain.

  P|A_SetIMP     NEW. Replaces the chain in one write; the recovery hatch. Deduplicates, and
                 enforces the module's own SECURE seed survives -- that seed is how a module
                 reaches its OWN `P|UEV_IMC`-gated functions, so dropping it would wall the module
                 off from itself.

All three are admin-gated by whatever capability that module's existing `P|A_AddIMP` already used.
The cap is READ FROM THE SOURCE, never derived from the module name: `TS01-C2` guards its policy
writes with `GOV|TS01-C1_ADMIN`, and a name-derived cap would silently change who may call it.

SCOPE. 59 implementations + the interface declaration in `01_DALOS.pact`. The interface is
edited too, because `implements` is a lower bound -- a module may carry extra functions without
declaring them -- but the whole point of `OuronetPolicyV2` is that EVERY module has these for
intermodule communication. A revocation path present on only some modules is discovered on the
day you need it. Live on chain is `OuronetPolicyV1` (owner-confirmed), so V2 is undeployed and
editable in place: no suffix bump, no cascade.

usage: python3 REPL/tools/_policyimp.py [--check | --apply]
  --check   report which files are already canonical and which are not; exit 1 if any differ
  --apply   rewrite them
(no flag behaves as --check, per the repo rule that tools which rewrite source require --apply)
"""
import os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TOPS = ("1_SOVEREIGN", "2_CITIZEN")

IMPL = '''    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Registers <policy-guard> as a trusted inter-module caller of this module. \\
            \\ IDEMPOTENT: a guard already in the chain is left alone rather than appended \\
            \\ a second time. See OuronetPolicyV2 for why that is load-bearing."
        (with-capability (%CAP%)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" :
                            (if (contains policy-guard mp)
                                mp
                                (ref-U|LST::UC_AppL mp policy-guard)
                            )
                        }
                    )
                )
            )
        )
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revokes <policy-guard> from this module's guard chain. Removes EVERY occurrence, so \\
            \\ it doubles as the cleanup for duplicates left behind by the pre-idempotence append. \\
            \\ Refuses to drop this module's own SECURE seed -- see OuronetPolicyV2."
        (with-capability (%CAP%)
            (let
                (
                    (ref-U|LST:module{StringProcessorV2} U|LST)
                    ;;
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (!= policy-guard dg) "The module's own SECURE seed cannot be revoked")
                (with-default-read P|MT P|I
                    {"m-policies" : [dg]}
                    {"m-policies" := mp}
                    (write P|MT P|I
                        {"m-policies" : (ref-U|LST::UC_RemoveItem mp policy-guard)}
                    )
                )
            )
        )
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replaces this module's whole guard chain in one write -- the recovery hatch. \\
            \\ Deduplicates, and enforces that the module's own SECURE seed survives: without it \\
            \\ the module can no longer reach its own P|UEV_IMC-gated functions."
        (with-capability (%CAP%)
            (let
                (
                    (dg:guard (create-capability-guard (SECURE)))
                )
                (enforce (contains dg policy-guards) "The module's own SECURE seed must be present")
                (write P|MT P|I
                    {"m-policies" : (distinct policy-guards)}
                )
            )
        )
    )
'''

IFACE = '''    (defun P|A_AddIMP (policy-guard:guard)
        @doc "Add a Policy in the local Policy Guard Chain. IDEMPOTENT: adding a guard that is \\
            \\ already present is a no-op, so `P|A_Define` is safe to replay."
    )
    (defun P|A_RemoveIMP (policy-guard:guard)
        @doc "Revoke a Policy from the local Policy Guard Chain. Removes every occurrence, and \\
            \\ refuses to drop the module's own SECURE seed."
    )
    (defun P|A_SetIMP (policy-guards:[guard])
        @doc "Replace the whole local Policy Guard Chain. Deduplicates; enforces that the \\
            \\ module's own SECURE seed is present."
    )
'''


def forms(text, needle):
    """Start/end offsets of every paren-balanced top-level form beginning with `needle`."""
    out, at = [], 0
    while True:
        i = text.find(needle, at)
        if i < 0:
            return out
        d, j, instr = 0, i, False
        while j < len(text):
            c = text[j]
            if instr:
                if c == '\\':
                    j += 2
                    continue
                if c == '"':
                    instr = False
            elif c == '"':
                instr = True
            elif c == ';' and text[j:j + 2] == ';;':
                k = text.find('\n', j)
                if k < 0:
                    break
                j = k
                continue
            elif c == '(':
                d += 1
            elif c == ')':
                d -= 1
                if d == 0:
                    out.append((i, j + 1))
                    break
            j += 1
        at = i + 1


def pact_files():
    for top in TOPS:
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in sorted(fs):
                if f.endswith(".pact"):
                    yield os.path.join(d, f)


def rewrite(text):
    """-> (new_text, n_impl, n_iface). Rewrites LAST-to-FIRST so earlier offsets stay valid."""
    spots = forms(text, "(defun P|A_AddIMP ")
    ni = nf = 0
    for start, end in reversed(spots):
        body = text[start:end]
        cap = re.search(r'with-capability \((GOV\|[^\s)]+)\)', body)
        # An interface declaration has no body beyond its @doc -- that is what distinguishes the
        # ONE declaration in 01_DALOS.pact from the 59 implementations in the same scan.
        block = IFACE if cap is None else IMPL.replace("%CAP%", cap.group(1))
        if cap is None:
            nf += 1
        else:
            ni += 1
        # absorb any already-present Remove/Set so the tool is re-runnable
        tail = end
        for nxt in ("(defun P|A_RemoveIMP ", "(defun P|A_SetIMP "):
            f = forms(text[tail:tail + 4000], nxt)
            if f and text[tail:tail + f[0][0]].strip() == "":
                tail = tail + f[0][1]
        line_start = text.rfind('\n', 0, start) + 1
        after = tail
        while after < len(text) and text[after] in " \t":
            after += 1
        if after < len(text) and text[after] == '\n':
            after += 1
        text = text[:line_start] + block + text[after:]
    return text, ni, nf


def main():
    apply_ = "--apply" in sys.argv
    changed, impl, iface = [], 0, 0
    for path in pact_files():
        src = open(path, encoding="utf8").read()
        if "(defun P|A_AddIMP " not in src:
            continue
        new, ni, nf = rewrite(src)
        impl += ni
        iface += nf
        if new != src:
            changed.append(path)
            if apply_:
                open(path, "w", encoding="utf8").write(new)
    verb = "rewrote" if apply_ else "WOULD rewrite"
    print(f"{verb} {len(changed)} file(s)  --  {impl} implementation(s), "
          f"{iface} interface declaration(s)")
    for p in changed[:6]:
        print(f"    {os.path.relpath(p, ROOT)}")
    if len(changed) > 6:
        print(f"    ... and {len(changed) - 6} more")
    if not apply_:
        if changed:
            print("\nre-run with --apply to write. (Tools that rewrite source require it.)")
            return 1
        print("  all canonical.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
