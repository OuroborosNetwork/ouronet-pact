#!/usr/bin/env python3
"""_liveinterfaces.py -- is every interface in the tree in the right state to SHIP?

    python3 REPL/tools/_liveinterfaces.py --probe   ask the chain, rewrite the registry (slow)
    python3 REPL/tools/_liveinterfaces.py --check   offline; fatal inside _gate.py

WHY THIS EXISTS, and it is the third time the same lesson has been paid for.

Pact CANNOT UPGRADE AN INTERFACE. Not to a changed body, not even to a byte-identical one. So a
round that emits an interface already on chain does not degrade -- the whole transaction aborts
before anything in it runs. On 2026-11-10 the V26 round died at transaction 01 with
"Interface cannot be upgraded: ouronet-ns.AcquisitionAnchorsV3", having deployed nothing.

THE EMISSION IS NOT A MISTAKE ANYONE MAKES ON PURPOSE. `_deploybundle.py` ships whole FILES, and
an interface bump drags its file into the round along with every interface CO-HOSTED in it.
`01_ANK.pact` holds AcquisitionAnchorsV3 beside the AQP-ANK module; `04b_RPSC.pact` holds
AcquisitionRewardCostsV1 beside AQP-RPSC. Neither interface changed; both shipped because their
neighbours had to. `LIVE_INTERFACES` in `_deploybundle.py` exists to strip exactly these -- and it
is HAND-MAINTAINED, so it is complete only until the next file enters a round for the first time.
Six of the eight co-hosted interfaces in V26 were pinned. Two were not. That was the outage.

AND NO GATE COULD SEE IT, which is why this is a separate tool rather than another assertion. The
gate builds a chain FROM SCRATCH, where declaring any interface for the first time is CORRECT.
Only a comparison against LIVE state can answer "that one is already there". The registry's own
comments record the same discovery being made in PureV10 and again in PureV20, both times by a
round dying live rather than by anything in this repo.

THREE FAILURE MODES, and the tool checks all three because only the first one is obvious:

  1] LIVE BUT NOT PINNED  -> the round emits it and the transaction ABORTS. The V26 outage.
  2] LIVE AND SIGNATURES DIFFER -> it needs a VERSION BUMP and a consumer cascade. Pinning it
     instead would strip it from the round, and every module in that round would then deploy
     against a contract the chain does not have -- which fails later, at call time, in
     production, rather than at deploy time.
  3] PINNED BUT NOT LIVE  -> the mirror hazard, and the quiet one. A stale pin makes the bundler
     comment the interface out as "already deployed", so it is NEVER SENT; the modules that
     implement it then fail with "Cannot find module". A pin is a claim about the chain, and an
     unverified claim about the chain is how all three of these start.

TEXT DIFFERENCE IS NOT CONTRACT DIFFERENCE, and conflating them would make this tool cry wolf.
Three live interfaces differ from the tree in comments or a description string while every member
signature matches (AgeOfZalmoxis, Bloodshed, OUiThirteenV1, measured 2026-11-10). Those need no
bump. `--check` therefore fails on SIGNATURE drift and merely reports text drift.

The registry is EVIDENCE: written only by `--probe`, which talks to the chain. Editing it by hand
to make the gate pass reintroduces precisely the assumption that caused the outage.

NOT TO BE CONFUSED WITH `OuronetInformational/.../LIVE-INTERFACE-VERSIONS.md`, a cached prose
snapshot whose own header records that a wrong bump map was once built from it. This is generated,
dated, and compared against the chain.
"""
import base64, glob, hashlib, io, json, os, re, sys, time, urllib.request

ROOT     = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REGISTRY = os.path.join(ROOT, "Deploy", "LIVE-INTERFACES.json")
BUNDLER  = os.path.join(ROOT, "REPL", "tools", "_deploybundle.py")
NODE     = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
            "?signatureVerification=false&preflight=false")
SRC_GLOBS = ("1_SOVEREIGN/**/*.pact", "2_CITIZEN/**/*.pact")


def balanced(code, start):
    """End index of the form opening at `start`, ignoring strings and `;;` comments."""
    depth, i = 0, start
    while i < len(code):
        c = code[i]
        if c == '"':
            i += 1
            while i < len(code) and code[i] != '"':
                i += 2 if code[i] == "\\" else 1
        elif c == ";" and code[i + 1:i + 2] == ";":
            while i < len(code) and code[i] != "\n":
                i += 1
            continue
        elif c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return i
        i += 1
    return -1


def tree_interfaces():
    """name -> (source text of the interface block, repo-relative file)."""
    out = {}
    for pat in SRC_GLOBS:
        for path in sorted(glob.glob(os.path.join(ROOT, pat), recursive=True)):
            text = io.open(path, encoding="utf8").read()
            for m in re.finditer(r'^\(interface\s+([A-Za-z0-9_]+)', text, re.M):
                end = balanced(text, m.start())
                if end < 0:
                    sys.exit(f"live interfaces: unbalanced interface {m.group(1)} in {path}")
                out[m.group(1)] = (text[m.start():end + 1], os.path.relpath(path, ROOT))
    return out


def pinned():
    """The LIVE_INTERFACES dict, parsed TEXTUALLY rather than imported.

    `_deploybundle.py` rewrites files at module level under some flags, and CLAUDE.md's standing
    rule is to never run a tool to find out what it does. Reading the literal is enough here.
    """
    s = io.open(BUNDLER, encoding="utf8").read()
    i = s.index("LIVE_INTERFACES = {")
    depth = 0
    for j in range(i, len(s)):
        if s[j] == "{":
            depth += 1
        elif s[j] == "}":
            depth -= 1
            if depth == 0:
                break
    block = s[i:j + 1]
    return dict(re.findall(r'^\s*"([A-Za-z0-9_]+)"\s*:\s*(?:"([0-9a-f]{32})"|None)',
                           block, re.M))


def signatures(code):
    """Member signatures -- what `implements` compatibility actually depends on."""
    return sorted(" ".join(x.split())
                  for x in re.findall(r'\(def(?:un|cap|pact|schema|const)\s+[^\n]*', code))


def live_code(name):
    code = f'(at "code" (describe-module "ouronet-ns.{name}"))'
    cmd = json.dumps({
        "networkId": "stoa", "payload": {"exec": {"data": {}, "code": code}}, "signers": [],
        "meta": {"gasLimit": 1000000, "chainId": "0", "gasPrice": 1e-8, "sender": "",
                 "ttl": 600, "creationTime": int(time.time()) - 60},
        "nonce": str(time.time())}, separators=(",", ":"))
    digest = hashlib.blake2b(cmd.encode(), digest_size=32).digest()
    payload = json.dumps({"cmd": cmd,
                          "hash": base64.urlsafe_b64encode(digest).decode().rstrip("="),
                          "sigs": []}).encode()
    req = urllib.request.Request(NODE, data=payload,
                                 headers={"Content-Type": "application/json"})
    try:
        res = json.load(urllib.request.urlopen(req, timeout=45)).get("result", {})
    except Exception:
        return "ERROR"
    if res.get("status") == "success":
        return res["data"]
    msg = str(res.get("error", {}).get("message", ""))
    if "Cannot find module" in msg or "No such module" in msg:
        return None
    return "ERROR"


def probe():
    tree, rows, unknown = tree_interfaces(), {}, []
    for name, (block, src) in sorted(tree.items()):
        got = live_code(name)
        if got == "ERROR":
            unknown.append(name)
            continue
        if got is None:
            rows[name] = {"live": False, "source": src}
            continue
        rows[name] = {
            "live": True, "source": src,
            "identical": got == block,
            "signatures_match": signatures(got) == signatures(block),
            "live_bytes": len(got), "repo_bytes": len(block),
        }
    io.open(REGISTRY, "w", encoding="utf8").write(json.dumps({
        "probed": time.strftime("%Y-%m-%d"),
        "node": NODE.split("/chainweb")[0],
        "note": "Written ONLY by _liveinterfaces.py --probe. Hand-editing reintroduces the "
                "assumption that aborted the V26 round at transaction 01.",
        "interfaces": dict(sorted(rows.items())),
    }, indent=1) + "\n")
    n_live = sum(1 for v in rows.values() if v["live"])
    print(f"probed {len(tree)} interface(s): {n_live} live, {len(tree) - n_live} not on chain")
    for u in unknown:
        print(f"  inconclusive  {u}")
    print(f"wrote {os.path.relpath(REGISTRY, ROOT)}")
    return 0


def active_round():
    """The highest-numbered Deploy/PureV<n>/ -- the round about to reach mainnet.

    SCOPE IS THE WHOLE POINT OF THIS FUNCTION. 56 interfaces in the tree are already on chain and
    unpinned, and that is NOT 56 defects: an unpinned live interface is harmless until a round
    ships the FILE that declares it. `Deploy/1_Pure/` is the FROM-SCRATCH round, which emits them
    all correctly, because on a virgin chain declaring each one for the first time is right.
    Failing on those would make this tool noise, and a noisy gate check gets disabled.

    What actually reaches mainnet is the upgrade round, so that is what is fatal here. The rest
    is reported as a BACKLOG -- each entry becomes fatal the moment its file enters a round, which
    is exactly how AcquisitionAnchorsV3 went from dormant to an aborted transaction.
    """
    dirs = sorted(glob.glob(os.path.join(ROOT, "Deploy", "PureV*")),
                  key=lambda d: int(re.search(r'PureV(\d+)', d).group(1)))
    return dirs[-1] if dirs else None


def check():
    if not os.path.exists(REGISTRY):
        print(f"live interfaces: {os.path.relpath(REGISTRY, ROOT)} is absent. Nothing has "
              f"verified which interfaces are already on chain. Run --probe.")
        return 1
    reg = json.load(io.open(REGISTRY, encoding="utf8"))
    rows, pins, tree = reg["interfaces"], pinned(), tree_interfaces()
    rnd = active_round()
    if rnd is None:
        print("live interfaces: no Deploy/PureV*/ round found; nothing to check.")
        return 0

    # what the ACTIVE round emits, and which sources it carries
    emitted, carried = {}, set()
    for f in sorted(glob.glob(os.path.join(rnd, "*_deploy.pact"))):
        text = io.open(f, encoding="utf8").read()
        for n in re.findall(r'^\(interface\s+([A-Za-z0-9_]+)', text, re.M):
            emitted[n] = os.path.basename(f)
        carried |= set(re.findall(r'^;;   (\S+\.pact)', text, re.M))

    fatal_emit, fatal_bump, fatal_stale = [], [], []
    backlog_unpinned, backlog_bump, textdrift, missing = [], [], [], []
    for name, info in sorted(rows.items()):
        if name not in tree:
            continue
        src = info["source"]
        if info["live"]:
            if name in emitted:
                fatal_emit.append((name, emitted[name]))
            elif name not in pins:
                backlog_unpinned.append((name, src))
            if not info.get("signatures_match", True):
                (fatal_bump if src in carried else backlog_bump).append((name, src))
            elif not info.get("identical", True):
                textdrift.append((name, info.get("live_bytes"), info.get("repo_bytes")))
        elif name in pins and src in carried:
            fatal_stale.append((name, src))
    missing = sorted(set(tree) - set(rows))

    for n, f in fatal_emit:
        print(f"  EMITTED BUT LIVE  {n}  ({os.path.basename(rnd)}/{f})")
        print(f"      It is ALREADY on chain, and Pact cannot upgrade an interface even to an")
        print(f"      identical body. THIS TRANSACTION WILL ABORT AND DEPLOY NOTHING. Pin it in")
        print(f"      LIVE_INTERFACES in _deploybundle.py and regenerate the round.")
    for n, s in fatal_bump:
        print(f"  SIGNATURES DIFFER {n}  ({s}) -- carried by this round")
        print(f"      Live and tree disagree on member signatures: this needs a VERSION BUMP and")
        print(f"      a consumer cascade. Do NOT pin it -- that ships modules against a contract")
        print(f"      the chain does not have.")
    for n, s in fatal_stale:
        print(f"  PINNED, NOT LIVE  {n}  ({s}) -- carried by this round")
        print(f"      The pin strips it as 'already deployed', so it is NEVER SENT, and its")
        print(f"      implementors then fail with 'Cannot find module'.")
    for n in missing:
        print(f"  NOT PROBED        {n} -- declared in the tree, absent from the registry; "
              f"re-run --probe")

    bad = len(fatal_emit) + len(fatal_bump) + len(fatal_stale) + len(missing)
    if bad:
        print(f"live interfaces: {len(fatal_emit)} emitted-but-already-live, {len(fatal_bump)} "
              f"needing a bump, {len(fatal_stale)} stale pin(s), {len(missing)} unprobed "
              f"-- in {os.path.basename(rnd)}.")
        return 1
    n_live = sum(1 for v in rows.values() if v["live"])
    print(f"live interfaces: clean -- {os.path.basename(rnd)} emits {len(emitted)} interface(s), "
          f"none already on chain ({len(tree)} in tree, {n_live} live, probe dated "
          f"{reg['probed']})")
    if backlog_unpinned or backlog_bump or textdrift:
        print(f"   backlog, not blocking this round: {len(backlog_unpinned)} live interface(s) "
              f"are unpinned in files no round currently ships")
        for n, s in backlog_bump:
            print(f"      WILL NEED A BUMP when shipped: {n}  ({s})")
        for n, lb, rb in textdrift:
            print(f"      comment-only drift: {n} live {lb}B vs tree {rb}B, signatures match")
    return 0


if __name__ == "__main__":
    if "--probe" in sys.argv:
        sys.exit(probe())
    if "--check" in sys.argv:
        sys.exit(check())
    print(__doc__)
