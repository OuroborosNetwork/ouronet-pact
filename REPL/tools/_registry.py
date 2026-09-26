#!/usr/bin/env python3
"""Build the Ouronet consumer registry: every callable function, its shape, and how to call it.

WHAT THIS IS.  A machine-readable description of the protocol's callable surface, so that a
consumer supplies VALUES and never types a function name.  Three consumers -- OuronetUI, the
Codex package, Pythia -- each hardcoded names and argument orders as strings, each drifted
independently, and every drift was found by a user rather than a test: 30 cost previews left on
the wrong side of an `INFO_` rename, five builders one argument short after the patron/executor
sweep, a nonce reader that made Awake and Slumber report "no nonces" against three live ones.
A missing member is a RESOLUTION error, so `try` cannot catch it and consumers render it as a
default -- which is exactly why these read as missing DATA rather than as broken calls.

It is not an ABI in the Ethereum sense.  There is no binary: Pact returns its own source, so the
deployed code IS the interface and can be read directly.

DEPLOYED CODE WINS.  `describe-module` returns the live source; the repo is consulted only for
modules not yet on chain, and those entries are marked `repo-only` and flagged NOT CALLABLE.
Generating from the repo alone would advertise functions that exist in files nobody has deployed
-- the same `no such member` failure, arriving from the other direction.

THE AUTHORED LAYER IS NEVER OVERWRITTEN.  Ghost values are example data; they cannot be derived
from a contract and must be written by a human.  They live in a separate file that is merged in,
so regenerating can never destroy them.

  python3 REPL/tools/_registry.py --probe   read the chain, rebuild (slow, needs network)
  python3 REPL/tools/_registry.py --check   offline; fatal inside _gate.py
"""
import base64
import hashlib
import io
import json
import os
import re
import sys
import time
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.json")
AUTHORED = os.path.join(ROOT, "Deploy", "OURONET-REGISTRY.authored.json")
AUTH_SURFACE = os.path.join(ROOT, "OuronetInformational", "ARCHITECTURE", "AUTH-SURFACE.md")
NODE = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
        "?signatureVerification=false&preflight=false")

ENTRYPOINT = re.compile(r'^[A-Za-z0-9|_-]*\|C{1,2}p?_[A-Za-z0-9]+$')
PREVIEW = re.compile(r'^INFO_[A-Za-z0-9|_-]+$')
# A read that RETURNS the external capabilities a call needs, rather than a value. All five
# launchpads share the shape: `:[string]` of `(coin.TRANSFER from to amount)` forms, padded by
# slippage. The contract owns the formula; the registry only has to point at it, which is why
# no formula is encoded here.
CAPS_READ = re.compile(r'\(defun\s+(URC[a-z]?_[A-Za-z]+):\[string\]')


def rpc(code, gas=10_000_000):
    cmd = json.dumps({
        "networkId": "stoa", "payload": {"exec": {"data": {}, "code": code}}, "signers": [],
        "meta": {"gasLimit": gas, "chainId": "0", "gasPrice": 1e-8, "sender": "",
                 "ttl": 600, "creationTime": int(time.time()) - 60},
        "nonce": str(time.time())}, separators=(",", ":"))
    digest = hashlib.blake2b(cmd.encode(), digest_size=32).digest()
    body = json.dumps({"cmd": cmd,
                       "hash": base64.urlsafe_b64encode(digest).decode().rstrip("="),
                       "sigs": []}).encode()
    req = urllib.request.Request(NODE, data=body, headers={"Content-Type": "application/json"})
    result = json.load(urllib.request.urlopen(req, timeout=60)).get("result", {})
    return result.get("data") if result.get("status") == "success" else None


def params_at(text, idx):
    i = text.index("(", idx)
    depth, j = 0, i
    while j < len(text):
        if text[j] == "(":
            depth += 1
        elif text[j] == ")":
            depth -= 1
            if depth == 0:
                break
        j += 1
    return [{"name": m.group(1), "type": m.group(2)}
            for m in re.finditer(r'([a-z][A-Za-z0-9-]*)\s*:\s*([A-Za-z0-9\[\]{}.|_-]+)',
                                 text[i:j + 1])]


def functions_in(code):
    """{name: params} for every entrypoint and preview in one module's source."""
    out = {}
    for d in re.finditer(r'\n\s{1,8}\(defun\s+([^\s:(]+)', code):
        name = d.group(1)
        if ENTRYPOINT.match(name) or PREVIEW.match(name):
            out.setdefault(name, params_at(code, d.end()))
    return out


def repo_modules():
    """{module: (source, relpath)} for every module in the tree."""
    out = {}
    for base, _d, files in os.walk(ROOT):
        if os.sep + "Deploy" in base or os.sep + "REPL" in base:
            continue
        for fn in files:
            if not fn.endswith(".pact"):
                continue
            path = os.path.join(base, fn)
            text = io.open(path, encoding="utf8", errors="replace").read()
            for m in re.finditer(r'^\(module\s+([A-Za-z0-9|_-]+)\s', text, re.M):
                out.setdefault(m.group(1), (text[m.start():], os.path.relpath(path, ROOT)))
    return out


def ownership_map():
    """entrypoint -> the PARAMETERS whose ownership is enforced in its call tree.

    `_authsurface.py` already computes this. Its cell mixes parameter names with the readers
    used to derive them (`UR_OwnerKonto`, `DALOS|SC_NAME`) and with `name:type` forms, so it is
    filtered against the real parameter list by the caller -- an unfiltered list would tell a
    consumer to prove ownership of a function name.
    """
    out = {}
    if not os.path.exists(AUTH_SURFACE):
        return out
    for line in io.open(AUTH_SURFACE, encoding="utf8"):
        m = re.match(r'\|\s*`[^`]+`\s*\|\s*`([^`]+)`\s*\|\s*(.+?)\s*\|\s*$', line)
        if m:
            out[m.group(1)] = {t.strip(" `") for t in m.group(2).split(",")}
    return out


def caps_reads(source):
    """Reads in this module that return external capability descriptions."""
    found = []
    for m in CAPS_READ.finditer(source):
        tail = source[m.end():m.end() + 700]
        if "coin.TRANSFER" in tail or re.search(r'cap(abilit(y|ies))?', tail, re.I):
            found.append(m.group(1))
    return found


def build(probe):
    repo = repo_modules()
    owners = ownership_map()
    entries, previews, divergences, unreachable = {}, {}, [], []

    for module, (repo_src, relpath) in sorted(repo.items()):
        live_src, module_hash, source = None, None, "repo-only"
        if probe:
            described = rpc(f'(describe-module "ouronet-ns.{module}")')
            if isinstance(described, dict) and described.get("code"):
                live_src, module_hash, source = described["code"], described.get("hash"), "deployed"

        chosen = live_src or repo_src
        fns = functions_in(chosen)
        if not fns:
            continue
        if source == "repo-only" and probe:
            unreachable.append(module)

        # DIVERGENCE is recorded, never silently resolved. A deployed module whose source has
        # moved on is exactly the state that produced `kadena-konto` and the missing tables.
        if live_src:
            a, b = functions_in(live_src), functions_in(repo_src)
            for name in sorted(set(a) | set(b)):
                if a.get(name) != b.get(name):
                    divergences.append({
                        "module": module, "function": name,
                        "deployed": a.get(name), "repo": b.get(name),
                    })

        module_caps = caps_reads(chosen)
        for name, params in sorted(fns.items()):
            key = f"{module}.{name}"
            record = {"params": params, "source": source, "modulePath": relpath}
            if module_hash:
                record["moduleHash"] = module_hash
            if source == "repo-only":
                record["callable"] = False
                record["note"] = ("not callable -- no live code deployed yet; the shape of a "
                                  "work-in-progress function")
            if PREVIEW.match(name):
                previews[key] = record
                continue
            # OWNERSHIP IS DELIBERATELY NOT EMITTED YET, and the reason matters more than the
            # field would. `_authsurface.py` walks the call tree correctly, but its artefact is
            # a prose cell that mixes parameter names with the READERS used to derive them
            # (`UR_OwnerKonto`, `DALOS|SC_NAME`) and with `name:type` forms. Intersecting it
            # with the parameter list yields e.g. ["patron", "swpair"] for
            # SWP|C_ToggleSwapCapability -- and `swpair` is a POOL ID, not an account.
            #
            # That field tells a consumer which account to ready a signature for. A wrong
            # answer there is worse than a missing one: the consumer prepares the wrong
            # signature and the transaction fails at the far end, looking like a contract
            # problem. So it is omitted, and its absence is explicit rather than silent.
            #
            # Resolving it properly means teaching _authsurface.py to emit structured
            # per-entrypoint data -- which parameter each CAP_EnforceAccountOwnership in the
            # tree resolves to -- rather than a flattened set of every token it saw.
            if name in owners:
                record["ownership"] = {
                    "resolved": False,
                    "reason": "requires structured output from _authsurface.py; the current "
                              "artefact cannot distinguish an account parameter from a pool id",
                    "candidates": sorted({p["name"] for p in params} & owners[name]),
                }
            # sponsorship: a Talos client entrypoint is the gas-funded path, by definition
            record["sponsorship"] = {
                "sponsored": module.startswith("TS0"),
                "sponsor": "Ouronet gas station" if module.startswith("TS0") else None,
                "cap": "ouronet-ns.DALOS.GAS_PAYER" if module.startswith("TS0") else None,
                "capArgs": [{"name": "user", "type": "string"},
                            {"name": "limit", "type": "integer"},
                            {"name": "price", "type": "decimal"}] if module.startswith("TS0") else [],
                "suppliedBy": ("a signer on the caps key, alongside the guard public keys"
                               if module.startswith("TS0") else None),
                "conditional": ("GAS_PAYER inspects `exec-code` from the message, so sponsorship "
                                "depends on what the transaction actually contains"
                                if module.startswith("TS0") else None),
            }
            if module_caps:
                record["externalCaps"] = {
                    "computedBy": [f"{module}.{c}" for c in module_caps],
                    "note": "returns [string] of (coin.TRANSFER from to amount); amounts are "
                            "padded by (1 + slippage). Call it -- do not recompute the amount.",
                }
            entries[key] = record

    # pair each entrypoint with its preview, by CATEGORY and ACTION. They live in different
    # modules by design, and assuming they share one is how codex ended up calling INFO-ZERO
    # for previews that live on INFO-ONE.
    by_action = {}
    for key in previews:
        mod, fn = key.split(".", 1)
        m = re.match(r'^INFO_([A-Za-z0-9-]+)\|(.+)$', fn)
        if m:
            by_action[(m.group(1), m.group(2))] = key
    for key, record in entries.items():
        mod, fn = key.split(".", 1)
        m = re.match(r'^([A-Za-z0-9-]+)\|C{1,2}p?_(.+)$', fn)
        if m:
            hit = by_action.get((m.group(1), m.group(2)))
            if hit:
                record["preview"] = hit

    # the authored layer -- ghost values. Merged in, never generated, never overwritten.
    if os.path.exists(AUTHORED):
        for key, extra in json.load(io.open(AUTHORED, encoding="utf8")).get("ghost", {}).items():
            if key in entries:
                entries[key]["ghost"] = extra

    doc = {
        "note": "GENERATED by REPL/tools/_registry.py. Deployed code wins; the repo is the "
                "fallback and those entries are marked not callable. Ghost values come from "
                "OURONET-REGISTRY.authored.json and are never overwritten.",
        "namespace": "ouronet-ns",
        "generatedFrom": "chain+repo" if probe else "repo-only",
        "entrypoints": dict(sorted(entries.items())),
        "previews": dict(sorted(previews.items())),
        "divergences": divergences,
        "notDeployed": sorted(unreachable),
    }
    body = json.dumps({"entrypoints": doc["entrypoints"], "previews": doc["previews"]},
                      sort_keys=True)
    doc["surfaceHash"] = hashlib.sha256(body.encode()).hexdigest()[:16]
    return doc


def main():
    if "--probe" in sys.argv:
        doc = build(probe=True)
        io.open(OUT, "w", encoding="utf8").write(json.dumps(doc, indent=1) + "\n")
        ghosts = sum(1 for e in doc["entrypoints"].values() if "ghost" in e)
        print(f"wrote Deploy/OURONET-REGISTRY.json")
        print(f"  {len(doc['entrypoints'])} entrypoints, {len(doc['previews'])} previews")
        print(f"  {sum(1 for e in doc['entrypoints'].values() if e.get('preview'))} paired, "
              f"{ghosts} with ghost values")
        print(f"  {sum(1 for e in doc['entrypoints'].values() if e['source'] == 'repo-only')} "
              f"repo-only (not callable)")
        print(f"  {len(doc['divergences'])} deployed/repo divergence(s)")
        for d in doc["divergences"][:10]:
            print(f"      {d['module']}.{d['function']}")
        print(f"  surface {doc['surfaceHash']}")
        return 0
    if "--check" in sys.argv:
        if not os.path.exists(OUT):
            print("registry: Deploy/OURONET-REGISTRY.json is absent. Run --probe.")
            return 1
        doc = json.load(io.open(OUT, encoding="utf8"))
        # Offline: the committed file must be internally consistent and non-empty. Whether it
        # matches the CHAIN needs --probe, exactly as _livetables.py splits the same way.
        bad = [k for k, v in doc["entrypoints"].items()
               if v.get("preview") and v["preview"] not in doc["previews"]]
        if not doc["entrypoints"]:
            print("registry: no entrypoints -- every check below would pass vacuously.")
            return 1
        if bad:
            print(f"registry: {len(bad)} entrypoint(s) point at a preview that is not in the file")
            for k in bad[:10]:
                print(f"    {k} -> {doc['entrypoints'][k]['preview']}")
            return 1
        print(f"registry: clean -- {len(doc['entrypoints'])} entrypoints, "
              f"{len(doc['previews'])} previews, surface {doc['surfaceHash']} "
              f"({doc['generatedFrom']})")
        return 0
    print(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main())
