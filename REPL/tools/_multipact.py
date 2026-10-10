"""_multipact.py -- the OURONET MULTIPACT manifest: one file, many transactions.

WHY THIS EXISTS
  A big round is N separate `exec` payloads. Before this, shipping one meant
  pasting each body into its own tab in OuronetUI's Execute Code queue -- 23
  pastes of ~230 KB for the Arweave round, perhaps an hour of mechanical work in
  which the only thing that can go wrong is a human. Worse, the queue's crash
  protection is `sessionStorage`, whose ~5 MB quota that round EXCEEDS, so the one
  safety net stops working exactly when the queue is big enough to need it.

  A manifest moves the assembly into a tool. The constructor emits one file; the
  UI reads it, shows what it found, and runs it.

THE FORMAT, and the two decisions in it worth defending:

  {
    "format":  "ouronet-multipact",
    "version": 1,
    "name":    "...",                 human label for the round
    "created": "YYYY-MM-DD",
    "source":  "the tool + flag that produced this",
    "network": "stoa",  "chainId": "0",
    "draft":   true|false,            see DRAFT below
    "signer":  { "role": "...", "note": "..." },
    "defaults":{ "gasLimit": N },
    "integrity": { "algo": "sha256", "body": "<hex>" },
    "groups": [
      { "label": "...", "mode": "parallel"|"sequential", "note": "...",
        "transactions": [
          { "id": "...", "label": "...", "gasLimit": N, "estGas": N,
            "sha256": "<hex of code>", "code": "(let ...)" }
        ] }
    ]
  }

  1] GROUPS, not a flat list with a per-transaction flag. Groups run in array
     order and each is fully confirmed before the next starts; `mode` applies
     WITHIN a group. That expresses all three real shapes with one concept:
     a module deploy round is one SEQUENTIAL group (dependency order is
     everything); this Arweave round is one PARALLEL group (every file is
     idempotent and touches disjoint rows); and a mixed round -- interfaces, then
     the modules that implement them -- is a sequential group followed by a
     parallel one. A per-transaction boolean cannot say "these may overlap each
     other but all of them must land before that one".

  2] PER-TRANSACTION `sha256`, plus a body hash. The point is not transport
     corruption, it is that the signer CANNOT READ WHAT THEY ARE SIGNING: 230 KB
     of generated Pact per transaction, 5.3 MB a round. The only honest way to
     offer "click once" is for the artefact to carry its own integrity and for the
     reader to refuse a mismatch. A manifest whose hashes are not checked is just
     a convenient way to sign something unexamined.

DRAFT
  `draft: true` means at least one transaction is not safe to sign -- for the
  Arweave round, that the link map still holds placeholder values. The manifest is
  still emitted, because the UI reader has to be buildable and testable before the
  real links exist, and a format you cannot produce an example of is a format
  nobody can implement against. The reader LOADS a draft and REFUSES TO EXECUTE
  it. That keeps the guard in one place instead of relying on a banner inside a
  body nobody reads.
"""

import datetime
import hashlib
import json

FORMAT = "ouronet-multipact"
VERSION = 1
MODES = ("parallel", "sequential")


def _sha(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def body_hash(groups):
    """Hash of the canonical group body -- order-sensitive, whitespace-stable.

    Hashes the SEPARATELY-hashed transactions rather than the code itself, so the
    body hash stays small to compute and a single changed transaction is visible
    both locally (its own sha) and globally (here).
    """
    canon = [
        {"label": g["label"], "mode": g["mode"],
         "transactions": [{"id": t["id"], "sha256": t["sha256"]}
                          for t in g["transactions"]]}
        for g in groups
    ]
    return _sha(json.dumps(canon, sort_keys=True, separators=(",", ":")))


def transaction(tx_id, code, label="", gas_limit=None, est_gas=None):
    """One transaction entry, with its code hashed at construction time."""
    out = {"id": tx_id, "label": label or tx_id, "sha256": _sha(code),
           "bytes": len(code.encode("utf-8")), "code": code}
    if gas_limit is not None:
        out["gasLimit"] = gas_limit
    if est_gas is not None:
        out["estGas"] = int(round(est_gas))
    return out


def group(label, mode, transactions, note=""):
    if mode not in MODES:
        raise ValueError("mode must be one of %s, got %r" % (MODES, mode))
    return {"label": label, "mode": mode, "note": note,
            "transactions": list(transactions)}


def manifest(name, source, groups, draft, signer=None, defaults=None,
             network="stoa", chain_id="0", created=None):
    """Assemble a manifest. `validate` is run on the result, so a builder cannot
    emit something the reader would reject."""
    doc = {
        "format": FORMAT,
        "version": VERSION,
        "name": name,
        "created": created or datetime.date.today().isoformat(),
        "source": source,
        "network": network,
        "chainId": str(chain_id),
        "draft": bool(draft),
        "signer": signer or {},
        "defaults": defaults or {},
        "groups": list(groups),
    }
    doc["integrity"] = {"algo": "sha256", "body": body_hash(doc["groups"])}
    errs = validate(doc)
    if errs:
        raise ValueError("_multipact: refusing to emit an invalid manifest:\n  "
                         + "\n  ".join(errs))
    return doc


def validate(doc):
    """Every rule the reader enforces, in one place both sides can share.

    Returned as a LIST rather than raised, because a reader wants to show a user
    everything that is wrong with a file, not just the first thing.
    """
    e = []
    if not isinstance(doc, dict):
        return ["not a JSON object"]
    if doc.get("format") != FORMAT:
        e.append("format must be %r, got %r" % (FORMAT, doc.get("format")))
    if doc.get("version") != VERSION:
        e.append("version must be %d, got %r" % (VERSION, doc.get("version")))
    if not isinstance(doc.get("draft"), bool):
        e.append("`draft` must be present and boolean -- its absence would read "
                 "as 'not a draft', which is the unsafe default")
    groups = doc.get("groups")
    if not isinstance(groups, list) or not groups:
        e.append("`groups` must be a non-empty list")
        return e
    seen = set()
    for gi, g in enumerate(groups):
        where = "groups[%d]" % gi
        if g.get("mode") not in MODES:
            e.append("%s.mode must be one of %s, got %r"
                     % (where, MODES, g.get("mode")))
        txs = g.get("transactions")
        if not isinstance(txs, list) or not txs:
            e.append("%s.transactions must be a non-empty list" % where)
            continue
        for ti, t in enumerate(txs):
            w = "%s.transactions[%d]" % (where, ti)
            tid = t.get("id")
            if not tid:
                e.append("%s has no id" % w)
            elif tid in seen:
                e.append("%s duplicate id %r -- ids address transactions in the "
                         "run log, so a duplicate makes the log ambiguous"
                         % (w, tid))
            else:
                seen.add(tid)
            code = t.get("code")
            if not isinstance(code, str) or not code.strip():
                e.append("%s has no code" % w)
                continue
            if t.get("sha256") != _sha(code):
                e.append("%s sha256 does not match its code -- the file has been "
                         "edited or truncated since it was built" % w)
    if not e:
        want = body_hash(groups)
        got = (doc.get("integrity") or {}).get("body")
        if got != want:
            e.append("integrity.body does not match the groups (expected %s, got "
                     "%r) -- a transaction was added, removed or reordered"
                     % (want[:16] + "...", (got or "")[:16] + "..."))
    return e


def summary(doc):
    """One-line-per-group digest, for a reader to print before executing."""
    out = []
    n = 0
    for g in doc["groups"]:
        txs = g["transactions"]
        n += len(txs)
        gas = sum(t.get("estGas") or 0 for t in txs)
        out.append("%-28s %-10s %3d tx  %11s bytes  %13s est gas"
                   % (g["label"][:28], g["mode"], len(txs),
                      "{:,}".format(sum(t["bytes"] for t in txs)),
                      "{:,}".format(gas)))
    out.append("%-28s %-10s %3d tx" % ("TOTAL", "", n))
    return "\n".join(out)


# ---------------------------------------------------------------------------
# --selftest -- every `validate` branch, fired
# ---------------------------------------------------------------------------
# `validate()` is PORTED into OuronetUI's reader, so its branches are a contract
# between two languages. A rule that has never fired on either side is a rule
# neither side is really enforcing, and the expensive version of that mistake is a
# reader that accepts a manifest the constructor would have rejected.
def selftest():
    import copy
    base_tx = transaction("a", "(+ 1 2)", gas_limit=100, est_gas=90)
    base = manifest("t", "selftest", [group("g", "parallel", [base_tx])],
                    draft=False)
    fails = []

    def expect_error(label, mutate, needle):
        doc = copy.deepcopy(base)
        mutate(doc)
        errs = validate(doc)
        hit = any(needle in e for e in errs)
        print("  %-34s %s" % (label, "OK" if hit else "NOT CAUGHT"))
        if not hit:
            fails.append("%s (errors: %r)" % (label, errs))

    print("_multipact selftest -- every validate() branch:")
    expect_error("wrong format", lambda d: d.update(format="nope"), "format must be")
    expect_error("wrong version", lambda d: d.update(version=99), "version must be")
    expect_error("draft missing", lambda d: d.pop("draft"), "`draft` must be present")
    expect_error("draft not boolean", lambda d: d.update(draft="yes"),
                 "`draft` must be present")
    expect_error("no groups", lambda d: d.update(groups=[]), "non-empty list")
    expect_error("bad mode", lambda d: d["groups"][0].update(mode="whenever"),
                 "mode must be one of")
    expect_error("empty transactions",
                 lambda d: d["groups"][0].update(transactions=[]), "non-empty list")
    expect_error("transaction without id",
                 lambda d: d["groups"][0]["transactions"][0].pop("id"), "has no id")
    expect_error("duplicate id",
                 lambda d: d["groups"][0]["transactions"].append(
                     dict(d["groups"][0]["transactions"][0])), "duplicate id")
    expect_error("empty code",
                 lambda d: d["groups"][0]["transactions"][0].update(code="   "),
                 "has no code")
    expect_error("code edited after build",
                 lambda d: d["groups"][0]["transactions"][0].update(code="(+ 1 3)"),
                 "sha256 does not match")
    expect_error("transaction reordered/injected",
                 lambda d: d["groups"][0]["transactions"].append(
                     transaction("b", "(+ 2 2)")), "integrity.body does not match")
    expect_error("group reordered",
                 lambda d: d["groups"].append(group("g2", "sequential",
                                                    [transaction("c", "(+ 3 3)")])),
                 "integrity.body does not match")

    # And the positive control: the thing must still accept a correct manifest.
    # Without this, "every negative fires" is satisfiable by a validator that
    # rejects everything.
    clean = validate(copy.deepcopy(base))
    print("  %-34s %s" % ("a VALID manifest is accepted",
                          "OK" if not clean else "REJECTED: %r" % clean))
    if clean:
        fails.append("valid manifest rejected: %r" % clean)

    # The builder must refuse to emit what the reader would reject -- otherwise the
    # two halves disagree about what is shippable.
    try:
        manifest("t", "selftest", [group("g", "parallel", [])], draft=False)
        print("  %-34s NOT CAUGHT" % "builder refuses invalid output")
        fails.append("builder emitted an invalid manifest")
    except ValueError:
        print("  %-34s OK" % "builder refuses invalid output")

    if fails:
        print("\n_multipact selftest FAILED:\n  " + "\n  ".join(fails))
        return 1
    print("\n_multipact selftest: all %d branches fire, valid input accepted." % 13)
    return 0


if __name__ == "__main__":
    import sys
    sys.exit(selftest() if "--selftest" in sys.argv else
             (print(__doc__) or 0))
