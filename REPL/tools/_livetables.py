#!/usr/bin/env python3
"""Which declared tables actually EXIST on chain -- and refuse to suppress a create-table
without evidence for it.

WHY THIS EXISTS.  `_deploybundle.py` emits a module's `(create-table ...)` calls COMMENTED OUT
when it believes the module is already live, because re-creating an existing table aborts the
whole transaction.  That belief came from `NEW_KEYS`, a hand-maintained list of "modules new
this round", which for round V1 held two entries.  Everything else was assumed live, 161
create-table calls shipped commented, and EIGHT of them were for tables that did not exist:

    DALOS      DALOS|StoaLedger
    SWPT       SWPT|Graph, SWPT|PathCache, SWPT|TopologyVersion
    TS02-C3    P|T, P|MT
    TS02-CPAD  P|T, P|MT

The SWPT three took every token price down with them -- `SWPI::URC_TokenDollarPrice` reads the
path cache, so the True Fungibles and Orto Fungibles pages showed no amounts at all.  A
missing-table error is not catchable, so the read failed outright rather than degrading.

THE GATE COULD NOT HAVE CAUGHT IT, AND THAT IS THE REAL DEFECT.  Every REPL fixture loads
modules in GENESIS mode, where every create-table runs; the deploy round runs in UPGRADE mode,
where none of them does.  The tables therefore always exist in test and the pricing path is
always healthy there.  Nothing compared the two worlds, so an assumption about the chain was
never once checked against the chain.

HOW THIS CLOSES IT.  `--probe` asks mainnet, per table, whether it exists, and writes the answer
to a checked-in registry.  `--check` -- fatal inside `_gate.py`, and offline -- requires every
table whose create-table the round SUPPRESSES to be recorded in that registry as EXISTING.
Suppressing one that is not recorded is now a gate failure rather than a silent omission.

The registry is EVIDENCE, not a wish: it is only ever written by `--probe`, which talks to the
chain.  Editing it by hand to make the gate pass reintroduces exactly the assumption that
caused this.

  python3 REPL/tools/_livetables.py --probe    ask mainnet, rewrite the registry (slow, ~2 min)
  python3 REPL/tools/_livetables.py --check    offline; fatal inside _gate.py
"""
import base64
import glob
import hashlib
import io
import json
import os
import re
import sys
import time
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PURE = os.path.join(ROOT, "Deploy", "1_Pure")
REGISTRY = os.path.join(ROOT, "Deploy", "LIVE-TABLES.json")
NODE = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
        "?signatureVerification=false&preflight=false")

# A table the probe found ABSENT is a real defect, so `--check` fails on one -- unless the fix
# is already written and waiting to be sent, which is recorded here with the file that sends it.
# This is a QUEUE, not an excuse list: once the table is created and re-probed, the entry must
# be deleted, and the tool reports a stale entry rather than letting it rot into a permanent
# waiver.
SHIPPING = {
    "DALOS.DALOS|StoaLedger":        "Deploy/PureV2/15_deploy.pact",
    "SWPT.SWPT|Graph":               "Deploy/PureV2/15_deploy.pact",
    "SWPT.SWPT|PathCache":           "Deploy/PureV2/15_deploy.pact",
    "SWPT.SWPT|TopologyVersion":     "Deploy/PureV2/15_deploy.pact",
    "TS02-C3.P|T":                   "Deploy/PureV2/15_deploy.pact",
    "TS02-C3.P|MT":                  "Deploy/PureV2/15_deploy.pact",
    "TS02-CPAD.P|T":                 "Deploy/PureV2/15_deploy.pact",
    "TS02-CPAD.P|MT":                "Deploy/PureV2/15_deploy.pact",
}


def suppressed():
    """Every (module, table) whose create-table the emitted round ships commented out."""
    out = []
    for deploy in sorted(glob.glob(os.path.join(PURE, "*.pact"))):
        text = io.open(deploy, encoding="utf8").read()
        for block in re.finditer(
                r';; --- tables for (\S+) \(\d+ defined\) ---(.*?)(?=\n;; ---|\n;; =====|\Z)',
                text, re.S):
            path, body = block.group(1), block.group(2)
            tables = re.findall(r';; \(create-table ([^)]+)\)', body)
            if not tables:
                continue
            src = glob.glob(os.path.join(ROOT, "**", path), recursive=True)
            if not src:
                continue
            module = re.search(r'^\(module\s+([A-Za-z0-9|_-]+)\s',
                               io.open(src[0], encoding="utf8").read(), re.M)
            if module:
                out += [(module.group(1), t) for t in tables]
    return sorted(set(out))


def exists_on_chain(module, table):
    code = f"(length (keys ouronet-ns.{module}.{table}))"
    cmd = json.dumps({
        "networkId": "stoa", "payload": {"exec": {"data": {}, "code": code}}, "signers": [],
        "meta": {"gasLimit": 1000000, "chainId": "0", "gasPrice": 1e-8, "sender": "",
                 "ttl": 600, "creationTime": int(time.time()) - 60},
        "nonce": str(time.time())}, separators=(",", ":"))
    digest = hashlib.blake2b(cmd.encode(), digest_size=32).digest()
    payload = json.dumps({"cmd": cmd,
                          "hash": base64.urlsafe_b64encode(digest).decode().rstrip("="),
                          "sigs": []}).encode()
    request = urllib.request.Request(NODE, data=payload,
                                     headers={"Content-Type": "application/json"})
    result = json.load(urllib.request.urlopen(request, timeout=45)).get("result", {})
    if result.get("status") == "success":
        return True
    message = str(result.get("error", {}).get("message", ""))
    if "Table access failed" in message and "was not found" in message:
        return False
    return None   # inconclusive -- do not record either way


def probe():
    rows, unknown = {}, []
    targets = suppressed()
    for module, table in targets:
        state = exists_on_chain(module, table)
        if state is None:
            unknown.append(f"{module}.{table}")
        else:
            rows[f"{module}.{table}"] = state
    io.open(REGISTRY, "w", encoding="utf8").write(json.dumps({
        "probed": time.strftime("%Y-%m-%d"),
        "node": NODE.split("/chainweb")[0],
        "note": "Written ONLY by _livetables.py --probe. Editing by hand reintroduces the "
                "assumption that lost eight tables in round V1.",
        "tables": dict(sorted(rows.items())),
    }, indent=1) + "\n")
    missing = sorted(k for k, v in rows.items() if not v)
    print(f"probed {len(targets)} suppressed table(s) against mainnet")
    for m in missing:
        print(f"  MISSING ON CHAIN  {m}")
    for u in unknown:
        print(f"  inconclusive      {u}")
    print(f"wrote {os.path.relpath(REGISTRY, ROOT)} -- "
          f"{sum(rows.values())} exist, {len(missing)} missing")
    return 0


def check():
    if not os.path.exists(REGISTRY):
        print(f"live tables: {os.path.relpath(REGISTRY, ROOT)} is absent. The round suppresses "
              f"create-table calls on an unverified assumption. Run --probe.")
        return 1
    known = json.load(io.open(REGISTRY, encoding="utf8"))["tables"]
    unverified, absent, queued = [], [], []
    for module, table in suppressed():
        key = f"{module}.{table}"
        if key not in known:
            unverified.append(key)
        elif not known[key]:
            (queued if key in SHIPPING else absent).append(key)
    stale = sorted(k for k in SHIPPING if known.get(k) is True)
    for k in unverified:
        print(f"  UNVERIFIED  {k} -- its create-table is suppressed and no probe covers it")
    for k in absent:
        print(f"  ABSENT      {k} -- suppressed, but the last probe found NO such table on "
              f"chain. It will never be created.")
    for k in queued:
        print(f"  queued      {k} -- absent on chain, created by {SHIPPING[k]}")
    for k in stale:
        print(f"  STALE QUEUE {k} now EXISTS on chain; remove it from SHIPPING")
    if stale:
        print("live tables: the remediation queue names tables that are already created.")
        return 1
    if unverified or absent:
        print(f"live tables: {len(unverified)} unverified, {len(absent)} known-absent. "
              f"A suppressed create-table needs evidence; run --probe, and ship the absent "
              f"ones (Deploy/PureV2/15_deploy.pact is the pattern).")
        return 1
    dated = json.load(io.open(REGISTRY, encoding="utf8"))["probed"]
    print(f"live tables: clean -- {len(suppressed())} suppressed create-table(s), "
          f"{len(suppressed()) - len(queued)} confirmed on chain, {len(queued)} queued for "
          f"repair (probe dated {dated})")
    return 0


if __name__ == "__main__":
    if "--probe" in sys.argv:
        sys.exit(probe())
    if "--check" in sys.argv:
        sys.exit(check())
    print(__doc__)
