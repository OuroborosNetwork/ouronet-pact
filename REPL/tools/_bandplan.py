#!/usr/bin/env python3
"""The patron/executor refactor's BAND MEMBERSHIP -- one source of truth, consumed by every script.

WHY THIS EXISTS. Band 3 shipped a defect because two scripts each carried their own idea of which
functions were in the band: the call-site transformer added an argument to CCp_InjectFixChunk at 7
sites, while the core-signature script -- correctly -- never added the parameter, because that
function fixes stale debs and moves no tokens. Two lists that must agree, with nothing enforcing
it, is the same defect class as the DSP deploy/test coupling and the price-sheet drift before it
was gated. There are 55 functions left in Band 1; the lists must not be written twice.

CLASSIFICATION, by following the capability chain (NOT the defun body -- this codebase puts
authorisation in the defcap, so a body-only scan reports almost nothing):

    B2  the executor is ALREADY a named parameter (account / konto / owner / sender / ...)
        -> rename it to `executor`. No behaviour change; AUTH-SURFACE must be byte-identical.
    B3  `patron` IS the executor -- ownership is enforced on the patron itself.
        -> a real defect: the gas payer and the actor cannot be separated.
    B1  the executor is DERIVED from the entity and never named.
        -> add `executor`, enforce its ownership, AND enforce it equals the derived owner.
           NEVER replace the derived check: that is the one edit that turns this refactor into an
           authorisation hole, and it reads as a tidy diff.

  python3 REPL/tools/_bandplan.py            summary + per-module Band 1 worklist
  python3 REPL/tools/_bandplan.py --band 1   just that band, as a flat list
  python3 REPL/tools/_bandplan.py --module 05_FVT.pact
"""
import os, re, sys, glob, collections

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SRC  = os.path.join(ROOT, "1_SOVEREIGN")
ACCT = re.compile(r'\b(account|konto|owner|beneficiary|sender|receiver|executor|staker|user|'
                  r'operator|holder|injector|collector)[-a-z]*:string')


def _forms(s, kw):
    out = []
    for m in re.finditer(r'^[ \t]*\(' + kw + r'\s+(\S+?)[\s(:]', s, re.M):
        i = m.start(); d = 0; j = i; instr = False
        while j < len(s):
            c = s[j]
            if instr:
                if c == "\\": j += 2; continue
                if c == '"': instr = False
            elif c == '"': instr = True
            elif c == ";":
                k = s.find("\n", j); j = len(s) if k < 0 else k; continue
            elif c == "(": d += 1
            elif c == ")":
                d -= 1
                if d == 0: j += 1; break
            j += 1
        out.append((m.group(1), s[i:j]))
    return out


def _params(body):
    """The PARAMETER LIST only -- not the first N chars of the body.

    Band 2's whole premise is "the executor is already a named parameter", and its prescribed
    action is a no-op rename. Deciding that from a 400-char slice of the BODY let seven
    `C_UpgradeBranding` functions in as Band 2 on the strength of a LET BINDING
    (`parent-owner:string`, derived from the entity) -- so the refactor would have renamed
    nothing, changed nothing, and marked them done while `patron` stayed the de-facto actor.
    Same failure direction as every other gap in these tools: a classifier that is confidently
    wrong about who is checked. Read the signature, and only the signature.
    """
    m = re.match(r'\s*\((?:defun|defcap)\s+\S+\s*\(', body)
    if not m:
        return ""
    i = m.end(); d = 1; j = i
    while j < len(body) and d > 0:
        if body[j] == '(': d += 1
        elif body[j] == ')': d -= 1
        j += 1
    return re.sub(r'\s+', ' ', body[i:j - 1])


def plan():
    caps, funs, helpers = {}, [], {}
    for p in sorted(glob.glob(os.path.join(SRC, "**", "*.pact"), recursive=True)):
        s = open(p, encoding="utf8", errors="replace").read()
        mi = s.find("\n(module ")
        mod = s[mi:] if mi > 0 else s
        for n, b in _forms(mod, "defcap"):
            caps[n] = b
        for n, b in _forms(mod, "defun"):
            if n.startswith("UEV_") or n.startswith("CAP_"):
                helpers[n] = b
            if re.match(r'^(A|AA|C|CC)_|\|(A|AA|C|CC)_', n):
                funs.append((os.path.basename(p), n, b))
    rows = []
    for f, n, b in funs:
        sig = _params(b)
        if 'patron:string' not in sig:
            continue
        # TRANSITIVE, and it has to be. A first version read only the defcap's own body and
        # classified C_SetMosaic as "derived, unnamed" -- but its enforce is one level further
        # down, in UEV_SetMosaicContext which the defcap CALLS (05_FVT.pact:1368). A non-transitive
        # classifier would have sent that function into the wrong band and the edit would have
        # added an executor with nothing to check it against. Exactly the mistake _authsurface.py
        # was built to avoid, repeated in a second tool an hour later.
        owns = []
        seen = set()

        def walk(body, depth=0):
            if depth > 6:
                return
            # Strip the defun/defcap SIGNATURE line before scanning. Without this the walk
            # descends into the CAP_Owner DEFINITION and captures its own parameter -- which is
            # why targets came back as `['account:string', 'id:string', ...]`, i.e. type
            # annotations masquerading as accounts. A capability's definition is not a call to it.
            body = re.sub(r'^[ \t]*\((?:defun|defcap)\s+\S+[^\n]*\n(?:\s*\([^\n]*\n)?', '', body, count=1)
            owns.extend(re.findall(r'(?:CAP_EnforceAccountOwnership|CAP_Owner|CAP_StakeOwner|CAP_PoolOwner|CAP_VctVacatePoolOwner|CAP_TF\|Owner|CAP_AqpAssetOwner|CAP_Creator)\s+\(?([A-Za-z0-9|_.:-]+)', body))
            # Follow BOTH routes an authorisation can hide behind:
            #   * a UEV_/CAP_ helper the defcap calls   (C_SetMosaic -> UEV_SetMosaicContext)
            #   * a composed CAPABILITY                  (VST|C>VESTING-LINK -> VST|C>LINK -> CAP_Owner)
            # The second was the third transitivity gap found in these tools in one session. Each
            # time the symptom was identical -- a function reported as enforcing nothing while its
            # check sat one hop further down -- and each time a classifier that stopped early would
            # have sent the function into the wrong band.
            # `(UEV_x ...)` AND `(ref-MOD::UEV_x ...)` -- the fourth transitivity gap found in
            # these tools today, and the same symptom every time: C_AddRewardLink DOES enforce
            # ownership (04_RPS.pact:2800) but its defcap reaches the helper cross-module, so a
            # regex anchored on `(UEV_` saw nothing. Four gaps, four identical shapes: bare name,
            # UEV_ helper, compose-capability, cross-module ref. A call-graph tool on this codebase
            # must handle ALL FOUR or it under-reports, and under-reporting is the dangerous
            # direction -- it says "no check here" about code that is checked.
            nxt = re.findall(r'\((?:ref-[A-Za-z0-9|_-]+::)?(UEV_[A-Za-z0-9|_-]+|CAP_[A-Za-z0-9|_-]+)', body)
            nxt += re.findall(r'compose-capability\s+\(([A-Za-z0-9|>_-]+)', body)
            for nm in nxt:
                if nm in seen:
                    continue
                seen.add(nm)
                if nm in helpers:
                    walk(helpers[nm], depth + 1)
                elif nm in caps:
                    walk(caps[nm], depth + 1)

        for c in re.findall(r'with-capability\s+\(([A-Za-z0-9|>_-]+)', b):
            if c in caps:
                walk(caps[c])
        targets = sorted(set(owns))
        # Is the account-ish PARAMETER the thing whose ownership is actually enforced? Band 2's
        # licence to rename rests entirely on "yes". When the answer is no, the row is NOT safely
        # renameable and the tool must say so rather than pick a band:
        #   * C_RotateOwnership  -- the param is `new-owner-konto`, the RECIPIENT; the executor is
        #     `owner-now`, derived. Renaming the recipient to `executor` would name the incoming
        #     owner as the actor. Band 2's own "no behaviour change" framing would wave it through.
        #   * CC_Inject / CC_Collect -- already done; the executor's ownership is enforced one
        #     layer DOWN, in ref-TFT::C_Transfer (`CAP_EnforceAccountOwnership sender`), which this
        #     walker does not follow because it walks capability chains, not defun bodies.
        #   * DPTF/DPMF/DPOF C_Issue -- the core enforces nothing; the Talos wrapper does. That is
        #     architecturally correct (Talos is the auth boundary) and invisible from here.
        # Three different reasons, one symptom. A classifier that cannot tell them apart must not
        # pretend to -- `verified` is reported, never silently folded into a band.
        acct_params = {q for q in re.findall(r'([A-Za-z0-9|_-]+):', sig)
                       if ACCT.search(q + ':string')}
        verified = bool(acct_params & set(targets))
        if ACCT.search(sig):
            band = 2
        elif targets and all(o == 'patron' for o in targets):
            band = 3
        else:
            band = 1
        rows.append((f, n, band, targets, verified))
    return rows


def main():
    rows = plan()
    if "--band" in sys.argv:
        want = int(sys.argv[sys.argv.index("--band") + 1])
        for f, n, b, t, v in rows:
            if b == want:
                flag = "    " if v or b != 2 else " ?? "
                print(f"{flag}{f:26s} {n:42s} {t or '(derived, unnamed)'}")
        return 0
    if "--module" in sys.argv:
        want = sys.argv[sys.argv.index("--module") + 1]
        for f, n, b, t, v in rows:
            if f == want:
                flag = "?" if (b == 2 and not v) else " "
                print(f"  B{b}{flag} {n:42s} {t or '(derived, unnamed)'}")
        return 0
    c = collections.Counter(b for _, _, b, _, _ in rows)
    print(f"patron-taking C_/A_ entrypoints: {len(rows)}")
    for b, label in [(1, "add executor"), (2, "rename only"), (3, "patron IS executor")]:
        print(f"   band {b}  {label:22s} {c[b]}")
    print("\nBand 1 worklist, smallest module first (gate after EVERY module, never batch):")
    per = collections.Counter(f for f, _, b, _, _ in rows if b == 1)
    for f, k in sorted(per.items(), key=lambda x: x[1]):
        print(f"   {f:26s} {k}")
    unver = [(f, n) for f, n, b, t, v in rows if b == 2 and not v]
    if unver:
        print(f"\nBand 2 rows the walker CANNOT license for rename ({len(unver)}) -- the account\n"
              f"parameter is not the enforced ownership target. Read each before touching it:")
        for f, n in unver:
            print(f"   ?? {f:26s} {n}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
