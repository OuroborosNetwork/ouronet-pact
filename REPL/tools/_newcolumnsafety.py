#!/usr/bin/env python3
"""_newcolumnsafety.py -- is every NEWLY-ADDED schema column read safely, everywhere?

    python3 REPL/tools/_newcolumnsafety.py --probe    ask the chain, extend the ledger (online)
    python3 REPL/tools/_newcolumnsafety.py --check    offline; fatal inside _gate.py

WHY THIS EXISTS, AND WHY IT IS NOT THE SAME TOOL AS `_coinbasesafety.py`.

On 2026-11-09 a `coin` upgrade added `dormant-claim-count` to the UrStoa vault schema and read it
on the COINBASE path. Pre-existing rows carry no such COLUMN, the read aborted, every block's
coinbase aborted, and chain 0 stopped -- taking with it the ability to submit the repair. The
braid froze for ~16h. `_coinbasesafety.py` was written that day and closes exactly that path.

Hours later the SAME round was found to repeat the SAME mistake in AQP -- four new columns on four
schemas with 52 pre-existing rows between them, and `04_RPS.pact` BOUND two of them inside the
full-row readers `UR_FVT-SEL|ScoreEntityLink` and `UR_FVT-RG|RpsGlobal`. Every other
`UR_FVT-SEL|*` and `UR_FVT-RG|*` reader fans out of those two, so the whole reward surface --
including the migration that was supposed to repair it -- would have aborted on landing.

The coinbase tool could not see it, and correctly so: AQP has no coinbase. The property it checks
is REACHABILITY FROM ONE ENTRY. The property that was actually violated is broader:

    a column that is newer than the rows must never be BOUND or `at`-ed without a `contains` test,
    ANYWHERE -- no entry point, no reachability, no exceptions.

That is what this checks. The two tools overlap on `coin` and neither subsumes the other: this one
has no notion of liveness criticality, that one has no notion of a column's age outside `coin`.

THREE IDIOMS DO NOT HELP, ALL THREE MEASURED (see the proof in `REPL/modules/S1-UNCLAIMED.repl`):
  - `with-default-read` defaults an absent ROW. The row EXISTS; the binding is what raises.
  - `(try 0 (at "f" row))` does not catch it -- the error propagates straight through.
  - `(try 0 (with-default-read ...))` does not catch it either.
Only reading the row as an OBJECT and testing `contains` before `at` survives. `try` DOES catch a
missing ROW, so `(try {} (read T k))` + `contains` is safe against both and is the idiom to use.

THE LEDGER IS EVIDENCE AND IT IS PERMANENT. `Deploy/NEW-COLUMNS.json` is written only by
`--probe`, which asks the chain which columns the DEPLOYED schema already has. Entries are never
removed: once a column has shipped into a world that contains rows without it, the guard must stay
forever, because the rows without it stay forever. A ledger that emptied itself after the
migration ran would quietly re-permit the exact deletion it exists to prevent.
"""
import base64, glob, hashlib, io, json, os, re, sys, time, urllib.request

ROOT   = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
LEDGER = os.path.join(ROOT, "Deploy", "NEW-COLUMNS.json")
NODE   = ("https://node2.stoachain.com/chainweb/0.0/stoa/chain/0/pact/api/v1/local"
          "?signatureVerification=false&preflight=false")

# Repo schema source -> the DEPLOYED interface that holds the same schemas. Probing compares the
# two. A schema file with no live counterpart yet (a brand-new interface) has no pre-existing rows
# by definition, so it is not listed and not probed.
# A value beginning with a path separator component is read as a PINNED LOCAL FILE instead of
# being fetched with `describe-module`. `coin` needs that: its schemas live in the module itself,
# not in an interface, and the baseline is the pre-upgrade copy already pinned for the canary.
#
# COIN IS LISTED HERE BECAUSE NEITHER EXISTING GUARD COVERED IT, 2026-11-09. `_coinbasesafety.py`
# checks only what is REACHABLE FROM `coinbase`, so an unguarded read of the vault's new column
# from any other function -- a client collect, an admin path -- was invisible to it; and this tool
# originally listed only the AQP schemas, so it was invisible here too. The column is currently
# read in exactly one place and it is guarded, so this closes a gap rather than reporting one.
SCHEMA_SOURCES = {
    "1_SOVEREIGN/STAGE_02/2_Core/03_AQP/00_AQP-SCHEMAS.pact": "ouronet-ns.AcquisitionSchemasV3",
    "00_StoaSandbox/coin.pact": "00_StoaSandbox/_canary/coin-pre-upgrade.pact",
}

SRC_GLOBS = ("1_SOVEREIGN/**/*.pact", "2_CITIZEN/**/*.pact", "00_StoaSandbox/coin.pact")


def strip_docs(t):
    """Remove @doc strings and ;; comments -- a field NAMED in prose is not a read."""
    t = re.sub(r'@doc\s+"(?:[^"\\]|\\.)*"', '', t, flags=re.S)
    return re.sub(r';;.*', '', t)


def schema_fields(src):
    """schema name -> [field names], for every defschema in a source."""
    out = {}
    for m in re.finditer(r'\(defschema\s+([A-Za-z0-9|_\-]+)(.*?)'
                         r'(?=\n\s*\(defschema|\n\s*\(def[a-z]|\Z)', src, re.S):
        body = strip_docs(m.group(2))
        out[m.group(1)] = re.findall(
            r'^\s*([a-z][a-z0-9\-]*):(?:string|integer|decimal|bool|time|guard|\[|object)',
            body, re.M)
    return out


def live_code(module):
    code = f'(at "code" (describe-module "{module}"))'
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
    res = json.load(urllib.request.urlopen(req, timeout=60)).get("result", {})
    if res.get("status") != "success":
        return None
    return res["data"]


def functions(src):
    """(name, text, line) for every defun/defcap -- the unit a guard must share with its read."""
    marks = [(m.start(), m.group(1)) for m in
             re.finditer(r'\n\s*\(def(?:un|cap|pact)\s+([A-Za-z0-9|_\-]+)', src)]
    out = []
    for i, (pos, name) in enumerate(marks):
        end = marks[i + 1][0] if i + 1 < len(marks) else len(src)
        out.append((name, src[pos:end], src[:pos].count("\n") + 2))
    return out


def probe():
    ledger = {"note": __doc__.strip().splitlines()[0], "columns": {}}
    if os.path.exists(LEDGER):
        ledger = json.load(io.open(LEDGER, encoding="utf8"))
    cols = ledger.setdefault("columns", {})
    added = 0
    for rel, module in SCHEMA_SOURCES.items():
        repo = schema_fields(io.open(os.path.join(ROOT, rel), encoding="utf8").read())
        if "/" in module:
            pin = os.path.join(ROOT, module)
            if not os.path.exists(pin):
                print(f"  INCONCLUSIVE  {module} -- pinned baseline missing; nothing recorded")
                continue
            code = io.open(pin, encoding="utf8").read()
        else:
            code = live_code(module)
        if code is None:
            print(f"  INCONCLUSIVE  {module} -- cannot read it from the chain; nothing recorded")
            continue
        live = schema_fields(code)
        for schema, fields in sorted(repo.items()):
            if schema not in live:
                continue           # new schema -> no pre-existing rows
            for f in fields:
                if f in live[schema]:
                    continue
                key = f"{schema}.{f}"
                if key in cols:
                    continue
                cols[key] = {"field": f, "schema": schema, "source": rel,
                             "deployed_interface": module,
                             "first_seen": time.strftime("%Y-%m-%d"),
                             "why": "added to a schema whose rows already existed on chain"}
                added += 1
                print(f"  LEDGERED  {key}")
    ledger["probed"] = time.strftime("%Y-%m-%d")
    io.open(LEDGER, "w", encoding="utf8").write(json.dumps(ledger, indent=1) + "\n")
    print(f"new columns: {added} added this probe, {len(cols)} in the ledger "
          f"-> {os.path.relpath(LEDGER, ROOT)}")
    return 0


def check():
    if not os.path.exists(LEDGER):
        print(f"new columns: {os.path.relpath(LEDGER, ROOT)} is absent -- run --probe. Without it "
              f"this check cannot tell a NEW column from an old one.")
        return 1
    cols = json.load(io.open(LEDGER, encoding="utf8"))["columns"]
    if not cols:
        print("new columns: ledger is empty -- no schema has gained a column over live rows.")
        return 0
    fields = sorted({v["field"] for v in cols.values()})
    findings = []
    scanned = 0
    for pat in SRC_GLOBS:
        for path in sorted(glob.glob(os.path.join(ROOT, pat), recursive=True)):
            scanned += 1
            src = io.open(path, encoding="utf8").read()
            rel = os.path.relpath(path, ROOT)
            for name, text, line0 in functions(src):
                body = strip_docs(text)
                for f in fields:
                    q = re.escape(f)
                    guarded = re.search(r'\(contains\s+"' + q + r'"', body)
                    for m in re.finditer(r'"' + q + r'"\s*:=', body):
                        findings.append((rel, line0 + body[:m.start()].count("\n"), name, f,
                                         "BOUND in a row-binding form"))
                    for m in re.finditer(r'\[\s*"' + q + r'"\s*\]', body):
                        findings.append((rel, line0 + body[:m.start()].count("\n"), name, f,
                                         "named in a `read` COLUMN LIST"))
                    if not guarded:
                        for m in re.finditer(r'\(\s*at\s+"' + q + r'"', body):
                            findings.append((rel, line0 + body[:m.start()].count("\n"), name, f,
                                             "`at`-ed with no `contains` guard in the same function"))
    print(f"new columns: {len(cols)} ledgered column(s) across {len(fields)} field name(s); "
          f"{scanned} source file(s) scanned")
    for key in sorted(cols):
        print(f"   {key}   (first seen {cols[key]['first_seen']})")
    if not findings:
        print("new columns: clean -- every ledgered column is read behind a `contains` test.")
        return 0
    print()
    for rel, line, fn, f, why in findings:
        print(f"   {rel}:{line}  {fn}")
        print(f"       `{f}` {why}")
    print()
    print("   A column NEWER THAN THE ROWS is read without a `contains` test. Pre-existing rows do")
    print("   not carry it, so the read ABORTS -- and neither `with-default-read` nor `try` covers")
    print("   that (both measured). Read the row as an object and test `contains` before `at`:")
    print()
    print('       (let ((row:object (try {} (read T key))))')
    print('           (if (contains "the-field" row) (at "the-field" row) <default>))')
    print()
    print("   This is the defect that halted chain 0 for ~16h on 2026-11-09.")
    return 1


if __name__ == "__main__":
    if "--probe" in sys.argv:
        sys.exit(probe())
    if "--check" in sys.argv:
        sys.exit(check())
    print(__doc__)
