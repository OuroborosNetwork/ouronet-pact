#!/usr/bin/env python3
"""Insert the patron/executor refactor's `executor` argument at call sites -- BY PARSING.

WHY THIS EXISTS. The 03_AQP call-site migration took SIX passes over ~250 fixture sites, and the
first five were regexes. Each one missed a different call shape and each miss cost a full ~9-minute
gate run to discover:

    1  multi-line calls (arguments on the following line)
    2  string-literal arguments ("DHCD-..." rather than a bound id)
    3  owner bindings hoisted into a `let` that lacked a token they referenced
    4  eager owner reads on entities created LATER in the same transaction
    5  direct CORE calls (ref-AQP::C_Issue) rather than the Talos `MOD|C_Fn` wrapper
    6  right arity, WRONG executor -- `patron patron` left behind by an earlier pass

A regex approximating s-expression structure will be wrong in a way that looks like success. This
parses instead: it splits a call into its top-level arguments and answers the only question that
matters -- how many are there, and what is in slot 1?

AND THE PARSER BIT TOO, ONCE, which is why `in_string` exists. Its first version searched for the
literal text `AQP-POOL|` and matched inside a STRING:

    (ref-IGNIS::UC_IgnisPrice "AQP-POOL|C_AddScore" "add-score")

-- a price-table KEY. Rewriting there wrecked an unrelated `expect` in [6.2.16]. A structure-aware
tool still has to know what is NOT structure.

USAGE
    python3 REPL/tools/_executormigrate.py            report call sites needing an executor
    python3 REPL/tools/_executormigrate.py --apply    rewrite them (REQUIRED to write -- the
                                                      2026-09-15 rule for source-rewriting tools)

RULES maps a function to (expected arity AFTER the refactor, executor expression template). The
template may reference the call's CURRENT arguments positionally as {0}, {1}, ... where {0} is the
patron. Add an entry per module as that module's Band 1 pass is done; a function with no entry is
ignored entirely, so this tool can never touch code outside the band it was pointed at.
"""
import os, re, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCAN = [os.path.join(ROOT, "REPL", "**", "*.repl"),
        os.path.join(ROOT, "2_CITIZEN", "**", "*.pact")]

# fn -> (arity after refactor, executor expression template over CURRENT args)
RULES = {
    "AQP-POOL|C_Issue":           (5, "(AQP-POOL.URC_AqpOwnerKontoFromClassAndAsset {3} {2})"),
    "AQP-POOL|C_AddScore":        (4, "(AQP-POOL.URC_AqpOwnerKonto {1})"),
    "AQP-POOL|C_RevokeScore":     (4, "(AQP-POOL.URC_AqpOwnerKonto {1})"),
    "AQP-POOL|C_DisablePoolStake":(3, "(AQP-POOL.URC_AqpOwnerKonto {1})"),
    "AQP-POOL|C_EnablePoolStake": (3, "(AQP-POOL.URC_AqpOwnerKonto {1})"),
    # 08_DSA -- these SIX conflated patron and executor outright: `(enforce (= patron fvt-owner))`
    # forced the gas payer to BE the FVT owner, so no sponsor could ever pay for a vault owner's
    # operation. The executor IS the fvt-owner, so the fixtures pass the same account they always
    # did; what changes is that the PATRON no longer has to be it.
    "AQP-DSA|C_DefineDelegationVault": (5, "{0}"),
    "AQP-DSA|C_SetOracleAuth":         (4, "{0}"),
    "AQP-DSA|C_WithdrawRoyalty":       (4, "{0}"),
    "AQP-DSA|C_BurnRoyalty":           (4, "{0}"),
    "AQP-DSA|C_FuelRoyalty":           (5, "{0}"),
    "AQP-DSA|C_SetAgencyFee":          (5, "{0}"),
    # 05_FVT -- owner-gated config surface. The executor IS the FVT owner, read from the vault.
    "AQP-FVT|C_Control":                (5, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_SetCommonDenominator":   (4, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_SetMosaic":              (4, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_SetSplitMode":           (4, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_AddScoreEntity":         (5, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_ToggleScoreEntityLink":  (6, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_AddRewardLink":          (6, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_ToggleRewardLink":       (5, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    "AQP-FVT|C_SetQualitySplit":        (8, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    # the sweep pair: authority is the ANCHOR's (owner OR creator of the anchored asset), so the
    # executor is read through ANK rather than the FVT.
    "AQP-FVT|CC_SweepRevokeAnchor":     (3, "(AQP-ANK.URC_AnchorableAssetOwner (AQP-ANK.UR_ANK|AnchoredAsset {1}) (AQP-ANK.UR_ANK|Fungibility {1}))"),
    "AQP-FVT|CC_SweepBegin":            (3, "(AQP-ANK.URC_AnchorableAssetOwner (AQP-ANK.UR_ANK|AnchoredAsset {1}) (AQP-ANK.UR_ANK|Fungibility {1}))"),
}


def in_string(txt, pos):
    """True when pos sits inside a string literal or a `;` comment."""
    i = 0
    instr = False
    while i < pos:
        c = txt[i]
        if instr:
            if c == "\\":
                i += 2
                continue
            if c == '"':
                instr = False
        elif c == '"':
            instr = True
        elif c == ";":
            j = txt.find("\n", i)
            if j < 0 or j > pos:
                return True
            i = j
        i += 1
    return instr


def split_form(txt, open_idx):
    """Top-level argument spans of the s-expression whose '(' is at open_idx."""
    i = open_idx + 1
    d = 1
    args = []
    start = None
    instr = False
    while i < len(txt) and d > 0:
        c = txt[i]
        if instr:
            if c == "\\":
                i += 2
                continue
            if c == '"':
                instr = False
                if d == 1:
                    args.append((start, i + 1))
                    start = None
            i += 1
            continue
        if c == ";":
            j = txt.find("\n", i)
            i = len(txt) if j < 0 else j
            continue
        if c == '"':
            if d == 1 and start is None:
                start = i
            instr = True
            i += 1
            continue
        if c in "([":
            if d == 1 and start is None:
                start = i
            d += 1
            i += 1
            continue
        if c in ")]":
            d -= 1
            if d == 1 and start is not None:
                args.append((start, i + 1))
                start = None
            elif d == 0 and start is not None:
                args.append((start, i))
                start = None
            i += 1
            continue
        if c in " \n\t\r":
            if d == 1 and start is not None:
                args.append((start, i))
                start = None
            i += 1
            continue
        if d == 1 and start is None:
            start = i
        i += 1
    return args, i


def scan(path, apply_):
    s = open(path, encoding="utf8").read()
    edits = []
    for fn, (arity, tmpl) in RULES.items():
        key = fn.split("|")[0] + "|"
        i = 0
        while True:
            j = s.find(fn, i)
            if j < 0:
                break
            if in_string(s, j):
                i = j + 1
                continue
            op = s.rfind("(", 0, j)
            if op < 0:
                i = j + 1
                continue
            args, end = split_form(s, op)
            vals = [s[a:b] for a, b in args][1:]
            if len(vals) == arity - 1:
                edits.append((args[1][1], None, " " + tmpl.format(*vals), fn, "missing"))
            elif len(vals) == arity and vals[1] == vals[0] and not vals[1].startswith("("):
                shifted = [vals[0]] + vals[2:]
                a, b = args[2]
                edits.append((a, b, tmpl.format(*shifted), fn, "patron-as-executor"))
            i = end
    if not edits:
        return 0
    if apply_:
        for a, b, txt, _, _ in sorted(edits, key=lambda e: -e[0]):
            s = s[:a] + txt + s[(b if b is not None else a):]
        open(path, "w", encoding="utf8").write(s)
    return len(edits)


def main():
    apply_ = "--apply" in sys.argv
    total = 0
    files = 0
    for pat in SCAN:
        for f in sorted(glob.glob(pat, recursive=True)):
            n = scan(f, apply_)
            if n:
                print(f"  {n:3d}  {os.path.relpath(f, ROOT)}")
                total += n
                files += 1
    verb = "rewrote" if apply_ else "would rewrite (pass --apply)"
    print(f"executor migrate: {verb} {total} call site(s) across {files} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
