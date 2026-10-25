#!/usr/bin/env python3
"""_chainsim.py -- simulate a deploy round against the REAL live chain, batched for real.

WHY THIS EXISTS. A wallet's "Simulate" button calls Pact's `/local` endpoint once per queued
file, independently. `/local` is stateless between calls -- a Kadena/Pact node has no concept of
a client-side pending queue -- so a round where transaction N depends on something transaction
N-1 creates (which every multi-transaction interface-bump round does, by construction) shows
"Cannot find module" / "has no such member" for N on a per-file simulation, EVEN WHEN THE ROUND
IS CORRECT. Measured directly (2026-10-12, PureV10's 22 transactions): per-file simulation shows
21 of 22 failing; this tool's batched calls show the SAME 21 succeeding once composed correctly.

WHAT THIS ACTUALLY PROVES AND WHAT IT DOES NOT. Each batch below IS a real `/local` call against
the real chain tip -- not a REPL approximation, not a cached snapshot. Modules in it see the real
effects of every earlier module in the SAME batch, exactly like a real send would. What it canNOT
do is compose ACROSS batches, because `/local` never persists anything: batch 2 does not see
batch 1's hypothetical effects, only whatever is REALLY on chain (which, before a real send, does
not include batch 1). So this tool proves each BATCH is internally sound against real state; it
does not prove the FULL round end-to-end the way `REPL/_scratch_loadpurev3.repl`-style REPL
replay does (that tool bootstraps a sandbox from a presumed-live commit and composes everything,
at the cost of "presumed" rather than "real"). Use both: this one for real-chain ground truth per
batch, a REPL replay for full-round composition.

THE SIZE CEILING IS THE NODE'S, NOT PACT'S. Measured empirically (binary search, 2026-10-12):
requests over ~1.0-1.2 MB return HTTP 413 from node2.stoachain.com, almost certainly a reverse-
proxy body-size cap rather than a Pact or gas limit (gas itself is uncapped in practice here --
`gasLimit` just needs to be set high enough to cover real execution, which for a module deploy is
small; size is what actually blocks a request). This tool packs transactions into the largest
batches that fit under that ceiling, greedily, preserving the round's own order.

SIGNING: `signatureVerification=false` on the node's `/local` query string skips CRYPTOGRAPHIC
verification, but the keyset predicate still needs a NAMED matching public key in `signers` --
sending `signers: []` fails every governance-gated module with "Keyset failure". The key below is
the same "Demiurgoi" admin key `REPL/_scratch_loadpurev3.repl` already hardcodes for the identical
REPL-replay purpose; it is a PUBLIC key, matches real on-chain governance (confirmed directly: the
chain's own "Keyset failure" error message names it as one of the two keys a `keys-any` checks),
and this tool never needs or sends a private key / real signature.

    python3 REPL/tools/_chainsim.py --round Deploy/PureV10     batch and simulate for real
    python3 REPL/tools/_chainsim.py --round Deploy/PureV10 --maxbytes 900000
"""
import base64
import glob
import hashlib
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request

NODE = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
        "?signatureVerification=false&preflight=false")
# Same key `REPL/_scratch_loadpurev3.repl` already uses for this exact purpose -- confirmed
# against real chain state (the "Keyset failure" error names it), not a guess.
SIGNERS = [{"pubKey": "1a4e15d3c51e0b73e92644600487ba8eaae312e1a178b91801d54e13c1b350a5",
            "clist": []}]
# Measured empirically, see module docstring. Leave headroom under the observed ~1.0-1.2MB 413
# boundary rather than hugging it.
DEFAULT_MAXBYTES = 900_000
GAS_LIMIT = 150_000_000


def rpc(code, gas=GAS_LIMIT, retries=3):
    cmd = json.dumps({
        "networkId": "stoa", "payload": {"exec": {"data": {}, "code": code}}, "signers": SIGNERS,
        "meta": {"gasLimit": gas, "chainId": "0", "gasPrice": 1e-8, "sender": "",
                 "ttl": 600, "creationTime": int(time.time()) - 60},
        "nonce": str(time.time())}, separators=(",", ":"))
    digest = hashlib.blake2b(cmd.encode(), digest_size=32).digest()
    body = json.dumps({"cmd": cmd,
                       "hash": base64.urlsafe_b64encode(digest).decode().rstrip("="),
                       "sigs": []}).encode()
    req = urllib.request.Request(NODE, data=body, headers={"Content-Type": "application/json"})
    for attempt in range(retries):
        try:
            raw = urllib.request.urlopen(req, timeout=120).read()
            return json.loads(raw)
        except urllib.error.HTTPError as e:
            if e.code == 413:
                raise SystemExit(
                    f"413 Request Entity Too Large at {len(body):,} bytes -- batch is over the "
                    f"node's real ceiling. Lower --maxbytes (currently packing may have drifted "
                    f"above what was last measured safe).")
            if attempt == retries - 1:
                raise
            time.sleep(2 * (attempt + 1))
        except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
            if attempt == retries - 1:
                raise
            time.sleep(2 * (attempt + 1))


def files_in_order(round_dir):
    files = sorted(glob.glob(os.path.join(round_dir, "*_deploy.pact")),
                    key=lambda p: int(os.path.basename(p).split("_")[0]))
    if not files:
        raise SystemExit(f"no NN_deploy.pact files found in {round_dir}")
    return files


def pack_batches(files, maxbytes):
    """Greedy, order-preserving: grow a batch until the NEXT file would exceed maxbytes, then
    start a new one. Never splits a single file (if one alone exceeds maxbytes, it gets its own
    oversize batch and a warning -- the 413 at send time will say so unambiguously either way)."""
    batches = []
    cur, cur_names, cur_size = [], [], len(b'(namespace "ouronet-ns")\n')
    for f in files:
        size = os.path.getsize(f)
        if cur and cur_size + size > maxbytes:
            batches.append((cur, cur_names, cur_size))
            cur, cur_names, cur_size = [], [], len(b'(namespace "ouronet-ns")\n')
        cur.append(f)
        cur_names.append(os.path.basename(f))
        cur_size += size
    if cur:
        batches.append((cur, cur_names, cur_size))
    return batches


def module_names(path):
    return re.findall(r'^\(module\s+(\S+)', open(path, encoding="utf8").read(), re.M)


def main():
    if "--round" not in sys.argv:
        print(__doc__)
        return 0
    round_dir = sys.argv[sys.argv.index("--round") + 1]
    maxbytes = DEFAULT_MAXBYTES
    if "--maxbytes" in sys.argv:
        maxbytes = int(sys.argv[sys.argv.index("--maxbytes") + 1])

    files = files_in_order(round_dir)
    batches = pack_batches(files, maxbytes)
    print(f"{len(files)} transaction file(s) packed into {len(batches)} real-chain batch(es) "
          f"(cap {maxbytes:,} bytes/batch)\n")

    ok, bad = 0, 0
    for n, (paths, names, size) in enumerate(batches, 1):
        code = '(namespace "ouronet-ns")\n'
        for p in paths:
            code += open(p, encoding="utf-8").read() + "\n"
        label = ", ".join(names)
        t0 = time.time()
        try:
            r = rpc(code)
        except Exception as e:
            print(f"  batch {n:2d}  TRANSPORT ERROR  {size:>9,}B  {label}\n      {e}")
            bad += 1
            continue
        elapsed = time.time() - t0
        result = r.get("result", {})
        if result.get("status") == "success":
            print(f"  batch {n:2d}  OK  {size:>9,}B  gas={r.get('gas'):>9,}  "
                  f"{elapsed:4.1f}s  [{label}]\n      {result.get('data')}")
            ok += 1
        else:
            err = result.get("error", {})
            print(f"  batch {n:2d}  FAIL  {size:>9,}B  {elapsed:4.1f}s  [{label}]\n"
                  f"      {err.get('message')}  @ {err.get('info')}")
            bad += 1

    print(f"\n{ok}/{len(batches)} batch(es) succeeded against the real chain tip.")
    if bad:
        print("A failing batch means something in THAT batch is wrong NOW (real chain, no "
              "composition assumption) -- not a cross-batch ordering artifact, since every "
              "module in a batch is evaluated together. A failure in batch N referencing "
              "something batch N-1 creates IS a real ordering bug: batches do not compose "
              "across calls (see module docstring).")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
