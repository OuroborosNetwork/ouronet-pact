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
    # CC_OpenAgency: the OPERATOR. All four uses took `patron`, and operator-konto is PERSISTED --
    # a sponsored open would have recorded the sponsor as the operator permanently.
    "AQP-DSA|CC_OpenAgency":           (8, "{0}"),
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
    # IssueMultipletFamily reached NO ownership enforce at all; the executor is simply the creator,
    # so the fixtures keep the account they used -- what changes is that it must now be OWNED.
    "AQP-FVT|C_IssueMultipletFamily":   (7, "{0}"),
    # ---- 05_DPTF (sweep 4/46) -------------------------------------------------------------
    # Every one of these is owner-gated: the entrypoint's capability reaches CAP_Owner <id>,
    # which enforces ownership of (UR_Konto id). So the executor IS the token owner, read at
    # the call site. The branding pair is gated on the PARENT's owner instead -- an f|/r| variant
    # is branded by the pure token's owner -- which is why they read through URCv_Parent.
    "DPTF|C_UpdatePendingBranding": (7, "(DPTF.UR_Konto (DPTF.URCv_Parent {1}))"),
    "DPTF|C_UpgradeBranding":      (4, "(DPTF.UR_Konto (DPTF.URCv_Parent {1}))"),
    "DPTF|C_Control":              (9, "(DPTF.UR_Konto {1})"),
    "DPTF|C_TogglePause":          (4, "(DPTF.UR_Konto {1})"),
    "DPTF|C_ToggleReservation":    (4, "(DPTF.UR_Konto {1})"),
    "DPTF|C_ToggleFee":            (4, "(DPTF.UR_Konto {1})"),
    "DPTF|C_SetMinMove":           (4, "(DPTF.UR_Konto {1})"),
    "DPTF|C_SetFee":               (4, "(DPTF.UR_Konto {1})"),
    "DPTF|C_SetFeeTarget":         (4, "(DPTF.UR_Konto {1})"),
    "DPTF|C_DonateFees":           (3, "(DPTF.UR_Konto {1})"),
    "DPTF|C_ResetFeeTarget":       (3, "(DPTF.UR_Konto {1})"),
    "DPTF|C_ToggleFeeLock":        (4, "(DPTF.UR_Konto {1})"),
    # ---- the BrandingUsagePrimaryV2 cascade (sweep 4/46). DPTF's branding pair gained an
    # executor, and the interface is shared, so DPOF / ATS / SWP moved with it. The authority
    # differs per module and so does the reader: DPOF brands through the PARENT token's owner
    # (an f|/r| variant is the pure parent's right), ATS and SWP through the entity owner.
    "DPOF|C_UpdatePendingBranding": (7, "(DPOF.URC_BrandingKonto {1})"),
    "DPOF|C_UpgradeBranding":       (4, "(DPOF.URC_BrandingKonto {1})"),
    "ATS|C_UpdatePendingBranding":  (7, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_UpgradeBranding":        (4, "(ATS.UR_OwnerKonto {1})"),
    "SWP|C_UpdatePendingBranding":  (7, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_UpgradeBranding":        (4, "(SWP.UR_OwnerKonto {1})"),
    # the HOT-RBT pair delegates into DPOF's branding, so the authority is DPOF's parent owner
    "ATS|HOT-RBT|C_UpdatePendingBranding": (7, "(DPOF.URC_BrandingKonto {1})"),
    "ATS|HOT-RBT|C_UpgradeBranding":       (4, "(DPOF.URC_BrandingKonto {1})"),
    # ---- 08_ATS (sweep 7/46). Every atspair-keyed entrypoint resolves to CAP_Owner <atspair>,
    # so the executor is the POOL OWNER, read at the call site. These are INSERTS (arity grows by
    # one), which makes them self-protecting: a second run cannot re-match.
    "ATS|C_Control":                (6, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_UpdateRoyalty":          (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_UpdateSyphon":           (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SetHibernationFees":     (5, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_ToggleParameterLock":    (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_AddSecondary":           (5, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_ControlColdRecoveryFees":(5, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SetColdRecoveryFees":    (6, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SetColdRecoveryDuration":(6, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_ToggleElite":            (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_ToggleUpgrade":          (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SwitchColdRecovery":     (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_AddHotRBT":              (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_ControlHotRecoveryFee":  (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SetHotRecoveryFee":      (5, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SwitchHotRecovery":      (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SetDirectRecoveryFee":   (4, "(ATS.UR_OwnerKonto {1})"),
    "ATS|C_SwitchDirectRecovery":   (4, "(ATS.UR_OwnerKonto {1})"),
    # THE EXECUTEE GROUP IS NOT HERE, and cannot be. This tool only INSERTS after slot 0.
    # C_Wipe / C_WipeSlim / C_RotateOwnership / the four role toggles / C_ToggleFreezeAccount
    # all gained a third-position `executee`, which MOVES the entity id to slot 4 -- a reorder.
    # C_Mint and C_Burn are renames: their `account` WAS the executor, so it moves to slot 2
    # rather than a new argument being added. And the three DPTF|A_ wrappers have no patron in
    # slot 0 at all. Each of those is a different edit; they get their own pass.
    # RotateOwnership: the executor is the CURRENT owner. `new-owner-konto` is the RECIPIENT --
    # naming it `executor` was the error a blind Band 2 rename would have made here.
    "AQP-FVT|C_RotateOwnership":        (4, "(AQP-FVT.UR_FVT|OwnerKonto {1})"),
    # ---- 15_SWP (sweep 13/46). Identical shape to the ATS block above and for the identical
    # reason: every swpair-keyed entrypoint reaches CAP_Owner <swpair>, which enforces ownership
    # of the DERIVED (UR_OwnerKonto swpair). So the executor is the POOL OWNER, read at the call
    # site, and SWP's own UEV_ExecutorIsOwnerKonto binds the named account to that same value.
    # INSERTS, therefore self-protecting against a second run.
    #
    # NOT HERE, and each for a different reason:
    #   * the six SWP|A_ admin wrappers -- a Talos A_ has NO patron, so the executor goes in
    #     slot 0 and this tool only inserts AFTER slot 0.
    #   * SWP|C_ChangeOwnership -- gained an `executee` in slot 2, which MOVES the swpair to
    #     slot 3. That is a reorder, not an insert.
    #   * SWP|C_ToggleAddOrSwap -- has no Talos wrapper at all; its only two callers are peer
    #     CORE modules (SWPU, SWPLC), which this tool does not scan.
    "SWP|C_EnableFrozenLP":          (3, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_EnableSleepingLP":        (3, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_ModifyCanChangeOwner":    (4, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_ModifyWeights":           (4, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_ToggleFeeLock":           (4, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_UpdateAmplifier":         (4, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_UpdateFee":               (5, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_UpdateSpecialFeeTargets": (4, "(SWP.UR_OwnerKonto {1})"),
    # ---- 18_SWPLC (sweep 15/46). Same POOL-OWNER authority as 15_SWP -- SWPLC has no ownership
    # helper of its own; its two branding caps call SWP::CAP_Owner <swpair> directly, and the
    # other eight prove nothing locally at all (the account never enters their capability graph)
    # and rely on a downstream TFT/DPOF debit. Either way the executor IS the pool owner for the
    # branding pair and the toggle, so the call sites read it the same way.
    #
    # ONLY THREE ARE HERE. The other seven changed NO arity at the Talos boundary: C_Fuel,
    # C_RemoveLiquidity and the five STOA-PID adds renamed `account` -> `executor` in the CORE
    # only, and a rename is positionally invisible to a caller. That asymmetry is the point of
    # running _callarity after this tool rather than trusting either alone.
    "SWP|C_UpdatePendingBrandingLPs": (8, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_UpgradeBrandingLPs":       (5, "(SWP.UR_OwnerKonto {1})"),
    "SWP|C_ToggleAddLiquidity":       (4, "(SWP.UR_OwnerKonto {1})"),
    # ---- 19_SWPU (sweep 16/46). The toggle's twin: same pool-owner authority, proven in the
    # same place (SWP::C_ToggleAddOrSwap). The three SWAP entrypoints are NOT here -- they
    # renamed `account` -> `executor` in the core only, no arity change at the Talos boundary.
    "SWP|C_ToggleSwapCapability":     (4, "(SWP.UR_OwnerKonto {1})"),
    # ---- 02_DPDC (sweep 25/46). Collectable ownership, and <son> is part of the KEY: DPSF and
    # DPNF are separate tables and the same id can exist in both, so an owner lookup without it
    # is a lookup of a different token. DPSF|* is son=true, DPNF|* is son=false -- the two
    # families therefore need two different readers even though the Talos signatures match.
    "DPSF|C_UpdatePendingBranding": (7, "(DPDC.UR_OwnerKonto {1} true)"),
    "DPSF|C_UpgradeBranding":       (4, "(DPDC.UR_OwnerKonto {1} true)"),
    "DPNF|C_UpdatePendingBranding": (7, "(DPDC.UR_OwnerKonto {1} false)"),
    "DPNF|C_UpgradeBranding":       (4, "(DPDC.UR_OwnerKonto {1} false)"),
    # ---- 03_DPDC-C (sweep 26/46). The executor is the CREATE-ROLE account, not the owner --
    # DPDC-C|C>REGISTER-NONCES enforces on (UR_Verum5 id son), a DIFFERENT derived account from
    # the UR_OwnerKonto the branding pair uses. Same module, same id, two distinct authorities;
    # reading the wrong one would produce a binder that refuses every legitimate call.
    "DPSF|C_Create":                (5, "(DPDC.UR_Verum5 {1} true)"),
    "DPNF|C_Create":                (4, "(DPDC.UR_Verum5 {1} false)"),

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
    """Top-level argument spans of the s-expression whose '(' is at open_idx.

    BRACES COUNT AS NESTING, fixed 2026-09-21. This tracked `(` `[` but not `{`, so an OBJECT
    LITERAL argument was not one argument -- its keys and values were counted as top-level
    arguments of the enclosing call. `(ref-IGNIS::XE_CollectIgnis KST.EMMA {...})` read as TEN
    arguments instead of two.

    That is not cosmetic. Every rule in RULES is keyed on `len(vals)`, so any call site passing
    an object literal was silently skipped (wrong arity -> no match) or, worse, matched a rule
    meant for a different shape. Found by `_callarity.py` reporting a mismatch that turned out
    to be the parser's, not the code's -- which is the second time today a tool that approximates
    s-expression structure was wrong in a way that looked like a finding."""
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
        if c in "([{":
            if d == 1 and start is None:
                start = i
            d += 1
            i += 1
            continue
        if c in ")]}":
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
            # NAME BOUNDARY. `s.find` is substring matching, and these names nest:
            # `DPTF|C_SetFee` is a PREFIX of `DPTF|C_SetFeeTarget`, `DPTF|C_ToggleFee` of
            # `DPTF|C_ToggleFeeLock` and `DPTF|C_ToggleFeeExemptionRole`. With both rules
            # present the shorter one fired inside the longer one and BOTH inserted an
            # executor -- 31 call sites got two. Found by the compiler ("apply a closure to
            # too many arguments"), not by the tool, which is the whole reason this parses
            # instead of approximating. Requiring a delimiter after the name closes it.
            if j + len(fn) < len(s) and s[j + len(fn)] not in " \n\t)":
                i = j + 1
                continue
            op = s.rfind("(", 0, j)
            if op < 0:
                i = j + 1
                continue
            # A DEFINITION IS NOT A CALL SITE. `(defun DPTF|C_Mint (patron:string executor:string
            # id:string ...) @doc "..." (with-capability ...))` splits into a head plus N forms,
            # and N can equal the arity a rule expects -- so a rule could rewrite the FUNCTION
            # DEFINITION, reordering its parameter list and body. Found 2026-09-21 while dry-
            # running the DPTF reorder pass, which matched all four of its targets' `defun`s and
            # not one real call. The head text is the discriminator: a call is `(fn ...)` or
            # `(ref-M::fn ...)`, a definition is `(defun fn ...)`.
            if s[op + 1:j].strip() in ("defun", "defcap", "defpact", "defschema", "defconst"):
                i = j + 1
                continue
            args, end = split_form(s, op)
            vals = [s[a:b] for a, b in args][1:]
            if len(vals) == arity - 1:
                edits.append((args[1][1], None, " " + tmpl.format(*vals), fn, "missing"))
            elif len(vals) == arity and vals[1] == vals[0] and not vals[1].startswith("("):
                shifted = [vals[0]] + vals[2:]
                a, b = args[2]
                new = tmpl.format(*shifted)
                # Skip when the replacement is IDENTICAL -- an already-migrated call whose rule
                # template is "{0}" (executor == patron) re-matches this branch forever and
                # rewrites itself to the same bytes. Harmless, but it inflated the reported count:
                # one new rule appeared to touch 50 sites when it touched 6. A tool that
                # over-reports its own effect is the same defect class as a stale figure.
                if new != s[a:b]:
                    edits.append((a, b, new, fn, "patron-as-executor"))
            i = end
    if not edits:
        return 0
    if apply_:
        for a, b, txt, _, _ in sorted(edits, key=lambda e: -e[0]):
            s = s[:a] + txt + s[(b if b is not None else a):]
        open(path, "w", encoding="utf8").write(s)
    return len(edits)


def check_rule_arities():
    """Every RULES arity must equal the function's REAL parameter count.

    A rule whose arity is wrong matches NOTHING -- `scan` fires on `len(vals) == arity - 1`, so
    an off-by-one rule silently skips every call site while the tool reports success. That is the
    same failure shape as an incomplete registry: not an error, just a rule that quietly does not
    apply. `ATS|C_Control` was entered as 7 against a real 6 and skipped 16 call sites, found only
    because `_callarity` flagged them afterwards. Checked here so the tool cannot lie about its
    own coverage.
    """
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "_ca", os.path.join(ROOT, "REPL", "tools", "_callarity.py"))
    ca = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(ca)
    sigs, owners = ca.signatures()
    bad = []
    for fn, (arity, _t) in RULES.items():
        mods = [m for m in owners.get(fn, ()) if fn in sigs[m]]
        if not mods:
            continue
        real = sigs[mods[0]][fn]
        if real != arity:
            bad.append((fn, arity, real))
    return bad


def main():
    apply_ = "--apply" in sys.argv
    _bad = check_rule_arities()
    if _bad:
        print("RULE ARITY MISMATCH -- these rules would silently match nothing:")
        for fn, declared, real in _bad:
            print(f"   {fn:36s} rule says {declared}, real signature is {real}")
        sys.exit("refusing to run with rules that cannot fire")
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
