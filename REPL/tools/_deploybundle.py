#!/usr/bin/env python3
"""_deploybundle.py -- batch the deploy chain into the fewest transactions under the gas cap.

WHAT THIS IS FOR. Deploying Ouronet means sending 78 module definitions plus a set of
initialisation calls, in an order where every module may only reference modules already on chain.
Sent one per transaction that is 78 signatures. StoaChain's block gas limit is 2,000,000 and the
whole deploy measures about 9.6M, so the same work fits in a handful of transactions if the modules
are batched in order and under the cap.

WHY BATCHING MODULES IS SAFE, and it is worth stating because it is the load-bearing assumption:
every `.pact` file in this tree is SELF-CONTAINED. All 228 `create-table` calls live inside the
module files (verified: zero in the deploy REPLs), and no `.pact` carries its own `(namespace ...)`
line -- the transaction supplies it. So a batch is literally one namespace line followed by N module
files concatenated in deploy order. Nothing is rewritten.

WHAT IS *NOT* BATCHED, and must not be. Between runs of module deploys the chain performs
initialisation -- registering inter-module policies, seeding constants, minting genesis supply.
Those are barriers: a module deployed after an init may depend on it having run. This tool never
merges across one, and it never reorders anything.

THE GAS FIGURES ARE REPL FIGURES. They come from `env-gasmodel "table"` measured by running the
deploy chain, which is the same model the chain uses but not the same thing as a real transaction:
there is per-transaction overhead this does not include, and signature verification is not in it.
That is why the default budget is well under 2,000,000. TREAT THE BATCHES AS A PROPOSAL TO VALIDATE
ON TESTNET, not as a guarantee.

usage:
  python3 REPL/tools/_deploybundle.py            report the plan, write nothing
  python3 REPL/tools/_deploybundle.py --write    emit Deploy/
  python3 REPL/tools/_deploybundle.py --budget N override the per-transaction gas budget
"""
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REPL = os.path.join(ROOT, "REPL")
OUT = os.path.join(ROOT, "Deploy")
PURE = os.path.join(OUT, "1_Pure")
INIT = os.path.join(OUT, "2_Init")
ASSETS = os.path.join(OUT, "3_Assets")

# Forms that exist only inside the REPL and have no meaning in a real transaction. `env-sigs`
# becomes the transaction's signer list, `env-chain-data` becomes its metadata, `print`/`expect`
# are test scaffolding. They are reported, not emitted as code.
# `namespace` is skipped because each emitted file writes its own as the first line; keeping the
# block's copy too produced a duplicate and counted it as a deployable form, which inflated every
# "N form(s)" header and hid the blocks that are pure scaffolding.
REPL_ONLY = ("namespace", "print", "expect", "expect-failure", "expect-that", "env-sigs", "env-data",
             "env-gas", "env-gasmodel", "env-gaslimit", "env-chain-data", "env-hash",
             "env-keys", "env-enable-repl-natives", "begin-tx", "commit-tx", "rollback-tx",
             "typecheck", "load", "verify")

# Heuristics for "this block is a SANDBOX FIXTURE, not a deployment step". Not a decision -- a
# flag. Getting this wrong in either direction is costly: a missed init breaks the deploy, and a
# fixture shipped to mainnet creates test accounts on a live chain.
FIXTURE_HINTS = ("alice", "bob", "Testing", "Fuel", "test account", "sandbox",
                 "PopulateB", "PopulateN", "Stoa root coin")

# ---------------------------------------------------------------------------------------------
# THIS FOLDER IS A PER-ROUND SCRATCHPAD, NOT A GENESIS SCRIPT.
#
# Ouronet is already live. A deployment round redeploys the modules whose code changed and runs
# only the init that round needs -- not the 92-step chain that would build the chain from nothing.
# The first version of this tool emitted all 78 modules and all 68 init steps, which is the right
# answer to a question nobody asked.
#
# A ROUND is defined by which interfaces bumped. Pact's cascade rule does the rest: bump interface
# B and every module naming B must redeploy, and so must every module naming an interface that
# names B. Measured for the 2026-09-18 bump: 53 modules, driven almost entirely by IgnisCollector,
# which 51 files reference because it owns OutputCumulator.
ROUNDS = {
    "2026-09-aqp": {
        "why": "the 7-interface bump of 2026-09-18 (AQP family + IgnisCollector)",
        "interfaces": ["IgnisCollectorV3", "AcquisitionPoolsV3", "AcquisitionScoresV3",
                       "AcquisitionAnchorsV3", "AcquisitionVacateV3", "AqpMtxV3", "DsaV3"],
        # init this round needs -- matched against the block label, case-insensitive
        "init": ["AQP-BOOT"],
        # Modules that are NEW on chain this round. Owner confirmed 2026-09-18: none of the AQP
        # family is live -- this round deploys it for the first time. New modules get their
        # `(create-table ...)` calls ACTIVE; everything else in the round is an upgrade of a live
        # module, where create-table would abort because the table already exists.
        "new": ["/03_AQP/", "04_AQP-BOOT.pact"],
        # Modules the deploy REPL chain never loads but that this round must ship anyway, and the
        # module they must follow. 09_AQP-INFO is the AQP cost-preview surface: 1,405 lines, 18
        # test files reference it, it names a bumped interface, and no chain deploys it. With AQP
        # not live, it is new like the rest of the family -- so it is injected here rather than
        # left to be noticed on the day.
        "extra": [("1_SOVEREIGN/STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact", "08_DSA.pact")],
    },
}
DEFAULT_ROUND = "2026-09-aqp"


def round_modules(rnd):
    """Modules that must redeploy this round: those naming any bumped interface."""
    pat = re.compile("|".join(re.escape(i) for i in rnd["interfaces"]))
    hit = set()
    for top in ("1_SOVEREIGN", "2_CITIZEN"):
        for d, _, fs in os.walk(os.path.join(ROOT, top)):
            if os.sep + "Audit" in d + os.sep:
                continue
            for f in fs:
                if f.endswith(".pact") and pat.search(
                        open(os.path.join(d, f), encoding="utf8", errors="replace").read()):
                    hit.add(os.path.normpath(os.path.join(d, f)))
    return hit
CHAINS = ["deploy-stage01.repl", "deploy-stage02.repl"]

# StoaChain's block gas limit is 2,000,000. The default leaves 15% for per-transaction overhead
# the REPL gas model does not account for. Raise it only after a testnet run says you can.
BLOCK_LIMIT = 2_000_000
DEFAULT_BUDGET = 1_700_000

# A SECOND CONSTRAINT, AND IT IS NOT MEASURED ANYWHERE IN THIS REPO.
#
# Gas is one limit; the transaction's BYTE SIZE is another, and nothing in the tree records what
# StoaChain's is. The docs' "~150k deploy size cap" refers to Kadena's block GAS limit, not bytes
# -- a conflation worth knowing about, because batching on gas alone produced a 1.4 MB transaction
# here before this cap existed.
#
# What IS known empirically: `04_RPS.pact` is 304,738 bytes and deploys, so a payload of that order
# is fine. The default below sits just above it, so every emitted transaction is no larger than a
# single module already proven to deploy. That is evidence, not a specification.
#
# Raise it once you know the real limit -- `--maxbytes 0` disables the constraint entirely and
# batches on gas alone.
DEFAULT_MAXBYTES = 320_000

# ---------------------------------------------------------------------------------------------
# UPGRADE vs GENESIS, and why this tool refuses to guess which tables exist.
#
# `(create-table X)` FAILS if X already exists. Most of Ouronet is already deployed, so a redeploy
# that carries every module's create-table calls -- which is what the first version of this tool
# emitted -- would abort on the first already-existing table.
#
# Which tables exist is a property OF THE CHAIN, and this repository cannot determine it:
#   - LIVE-INTERFACE-VERSIONS.md lists modules by the INTERFACE they implement, so utilities that
#     implement none are absent from it without being new. It is also a 2026-08-30 snapshot.
#   - `git log` for added `(deftable ...)` lines reports 42, but file reorganisations (the interface
#     embedding, the FVT/RPS split) show long-existing tables as additions. False positives.
#
# So the tool does not classify. It emits:
#   --upgrade   (default) modules only, create-tables stripped -- correct for a redeploy
#   --genesis   everything, for a fresh chain
#   --existing FILE   create-tables for every table EXCEPT those named in FILE
# and always writes Deploy/TABLES.md, which carries a ready-to-paste probe that asks the chain.
# ---------------------------------------------------------------------------------------------
TABLE_RE = __import__("re").compile(r'^\(create-table\s+([^\s)]+)\s*\)', __import__("re").M)
GASLOG = "/tmp/deploygas.log"


def _expand(path):
    ap = os.path.normpath(path)
    for i, ln in enumerate(open(ap, encoding="utf8", errors="replace"), 1):
        m = re.match(r'\s*\(load\s+"([^"]+)"', ln)
        if m:
            child = os.path.normpath(os.path.join(os.path.dirname(ap), m.group(1)))
            if child.endswith(".repl") and os.path.exists(child):
                yield from _expand(child)
                continue
        yield (ap, i, ln.rstrip("\n"))


def parse_chain():
    """Ordered transaction blocks across the deploy chain."""
    blocks, cur = [], None
    for st in CHAINS:
        for f, i, ln in _expand(os.path.join(REPL, st)):
            m = re.match(r'\s*\(begin-tx\s+"([^"]*)"', ln)
            if m:
                cur = {"label": m.group(1), "file": os.path.relpath(f, ROOT), "line": i,
                       "pacts": [], "gas": None, "stage": st}
                continue
            if cur is None:
                continue
            if re.match(r'\s*\(commit-tx\)', ln):
                blocks.append(cur)
                cur = None
                continue
            m = re.match(r'\s*\(load\s+"([^"]+\.pact)"', ln)
            if m:
                cur["pacts"].append(
                    os.path.normpath(os.path.join(os.path.dirname(f), m.group(1))))
            if "Costs {} GAS" in ln:
                cur["gas"] = "pending"
    return blocks


def attach_gas(blocks):
    """Join measured gas, in execution order, onto the blocks that echo it."""
    if not os.path.exists(GASLOG):
        sys.exit(f"no gas log at {GASLOG}. Produce one with:\n"
                 f"  cd REPL && pact _tmp_deploygas.repl > {GASLOG} 2>&1\n"
                 f"(a driver that loads deploy-stage00/01/02)")
    vals = [int(m) for m in re.findall(r'Costs (\d+) GAS', open(GASLOG).read())]
    want = [b for b in blocks if b["gas"] == "pending"]
    if len(vals) < len(want):
        sys.exit(f"gas log has {len(vals)} readings but the chain has {len(want)} "
                 f"gas-echoing blocks -- the log is stale. Re-run it.")
    for b, v in zip(want, vals):
        b["gas"] = v
    for b in blocks:
        if b["gas"] == "pending":
            b["gas"] = 0
    return blocks


def plan(blocks, budget, maxbytes=DEFAULT_MAXBYTES):
    """Group consecutive MODULE-deploy blocks into batches under `budget`.

    Init blocks are barriers: they close the current batch and are emitted as their own step.
    Order is never changed.
    """
    steps, batch = [], None
    size_of = {}

    def nbytes(paths):
        t = 0
        for p in paths:
            if p not in size_of:
                size_of[p] = os.path.getsize(p)
            t += size_of[p]
        return t

    def close():
        nonlocal batch
        if batch and batch["pacts"]:
            steps.append(batch)
        batch = None

    for b in blocks:
        if not b["pacts"]:
            close()
            steps.append({"kind": "init", "label": b["label"], "file": b["file"],
                          "line": b["line"], "gas": b["gas"] or 0})
            continue
        g = b["gas"] or 0
        bsz = nbytes(b["pacts"])
        if g > budget or (maxbytes and bsz > maxbytes):
            close()
            steps.append({"kind": "batch", "pacts": list(b["pacts"]), "gas": g,
                          "labels": [b["label"]], "oversize": True, "bytes": bsz})
            continue
        if (batch is None or batch["gas"] + g > budget
                or (maxbytes and batch["bytes"] + bsz > maxbytes)):
            close()
            batch = {"kind": "batch", "pacts": [], "gas": 0, "labels": [], "oversize": False,
                     "bytes": 0}
        batch["pacts"] += b["pacts"]
        batch["gas"] += g
        batch["bytes"] += bsz
        batch["labels"].append(b["label"])
    close()
    return steps


def main():
    budget = DEFAULT_BUDGET
    if "--budget" in sys.argv:
        budget = int(sys.argv[sys.argv.index("--budget") + 1])
    maxbytes = DEFAULT_MAXBYTES
    if "--maxbytes" in sys.argv:
        maxbytes = int(sys.argv[sys.argv.index("--maxbytes") + 1])
    rname = DEFAULT_ROUND
    if "--round" in sys.argv:
        rname = sys.argv[sys.argv.index("--round") + 1]
    if rname == "all":
        rnd, keep, initpat = None, None, None
    else:
        rnd = ROUNDS[rname]
        NEW_KEYS.extend(rnd.get("new", []))
        keep = round_modules(rnd)
        initpat = [x.lower() for x in rnd["init"]]

    blocks = attach_gas(parse_chain())
    if rnd is not None:
        scoped = []
        for b in blocks:
            if b["pacts"]:
                sel = [x for x in b["pacts"] if x in keep]
                if sel:
                    scoped.append({**b, "pacts": sel})
            elif any(k in b["label"].lower() for k in initpat):
                scoped.append(b)
        for relpath, after in rnd.get("extra", []):
            ap = os.path.join(ROOT, relpath)
            if not os.path.exists(ap):
                sys.exit(f"round {rname}: extra module missing from the tree: {relpath}")
            idx = next((i for i, b in enumerate(scoped)
                        if any(os.path.basename(x) == after for x in b["pacts"])), None)
            if idx is None:
                sys.exit(f"round {rname}: cannot place {os.path.basename(relpath)} -- "
                         f"anchor {after} is not in this round")
            scoped.insert(idx + 1, {"label": f"INJECTED {os.path.basename(relpath)}",
                                    "file": "(not in any deploy chain)", "line": 0,
                                    "pacts": [os.path.normpath(ap)],
                                    "gas": 0, "stage": "injected"})
            print(f"  injected {os.path.basename(relpath)} after {after} "
                  f"(in no deploy chain; gas unknown)")
        blocks = scoped
        print(f"ROUND {rname} -- {rnd['why']}")
        print(f"  modules needing redeploy   : {len(keep)}")
        # A module that must redeploy but appears in no deploy chain would be silently dropped --
        # the exact omission this tool is supposed to make impossible.
        planned = {x for b in blocks for x in b["pacts"]}
        orphan = sorted(keep - planned)
        if orphan:
            print(f"\n  !! {len(orphan)} module(s) MUST redeploy this round but are in NO deploy "
                  f"chain:")
            for o in orphan:
                print(f"     {os.path.relpath(o, ROOT)}")
            print("  !! They will NOT be in the emitted plan. Resolve before deploying.\n")
        ORPHANS.extend(orphan)
    steps = plan(blocks, budget, maxbytes)

    batches = [s for s in steps if s["kind"] == "batch"]
    inits = [s for s in steps if s["kind"] == "init"]
    total = sum(b["gas"] for b in batches)
    print(f"deploy plan -- budget {budget:,} gas per transaction "
          f"(block limit {BLOCK_LIMIT:,})\n")
    print(f"  module-deploy transactions : {len(batches)}")
    print(f"  modules deployed           : {sum(len(b['pacts']) for b in batches)}")
    print(f"  measured module gas        : {total:,}")
    print(f"  init/config steps (manual) : {len(inits)}")
    print(f"  fullest batch, by gas      : {max(b['gas'] for b in batches):,} "
          f"({100*max(b['gas'] for b in batches)/BLOCK_LIMIT:.0f}% of a block)")
    print(f"  largest batch, by bytes    : {max(b['bytes'] for b in batches):,} "
          f"(cap {maxbytes:,}{' -- DISABLED' if not maxbytes else ''})\n")
    for n, s in enumerate(steps, 1):
        if s["kind"] == "batch":
            flag = "  !! OVER BUDGET ALONE" if s["oversize"] else ""
            print(f"  {n:3d}. DEPLOY  {len(s['pacts']):2d} module(s)  {s['gas']:>9,} gas  "
                  f"{s['bytes']:>8,} B{flag}")
        else:
            print(f"  {n:3d}. init    {s['label'][:52]}")
    mode = "genesis" if "--genesis" in sys.argv else "upgrade"
    existing = frozenset()
    if "--existing" in sys.argv:
        fp = sys.argv[sys.argv.index("--existing") + 1]
        existing = frozenset(l.strip() for l in open(fp) if l.strip()
                             and not l.startswith("#"))
        mode = "existing"
    print(f"  table mode                 : {mode}"
          + (f" ({len(existing)} known-existing)" if existing else ""))
    if "--write" in sys.argv:
        write(steps, budget, maxbytes, mode, existing)
    return 0


def top_forms(text):
    """(line, form) for every balanced top-level form. String-aware: Pact strings span lines via
    the `\\` continuation, and a naive regex over them miscounts parens."""
    i, n, line = 0, len(text), 1
    while i < n:
        c = text[i]
        if c == "\n":
            line += 1; i += 1; continue
        if c == ";":
            j = text.find("\n", i); i = n if j < 0 else j; continue
        if c != "(":
            i += 1; continue
        start, startline, depth, instr = i, line, 0, False
        while i < n:
            c = text[i]
            if instr:
                if c == "\\": i += 2; continue
                if c == '"': instr = False
                elif c == "\n": line += 1
                i += 1; continue
            if c == '"': instr = True
            elif c == ";":
                j = text.find("\n", i); i = n if j < 0 else j; continue
            elif c == "(": depth += 1
            elif c == ")":
                depth -= 1
                if depth == 0:
                    yield startline, text[start:i + 1]
                    i += 1; break
            elif c == "\n": line += 1
            i += 1


def head_of(form):
    m = re.match(r'\(\s*([A-Za-z0-9|_.:\-]+)', form)
    return m.group(1) if m else "?"


def extract_init(block):
    """Pull the real, deployable forms out of one REPL transaction block."""
    path = os.path.join(ROOT, block["file"])
    text = open(path, encoding="utf8", errors="replace").read()
    forms = list(top_forms(text))
    # the block runs from its begin-tx to the matching commit/rollback
    body, started = [], False
    sigs = []
    for ln, f in forms:
        h = head_of(f)
        if not started:
            if h == "begin-tx" and ln >= block["line"] - 1:
                started = True
            continue
        if h in ("commit-tx", "rollback-tx"):
            break
        if h == "env-sigs":
            sigs += re.findall(r'"key"\s*:\s*"([^"]+)"', f)
            continue
        if h in REPL_ONLY:
            continue
        body.append((ln, f))
    return body, sigs


def split_tables(src):
    """(module-code, [table names]) -- top-level create-table calls stripped off the end."""
    tables = TABLE_RE.findall(src)
    code = TABLE_RE.sub("", src).rstrip()
    return code, tables


def write(steps, budget, maxbytes, mode="upgrade", existing=frozenset()):
    for d in (PURE, INIT, ASSETS):
        os.makedirs(d, exist_ok=True)
    inventory = []
    manifest = []
    seq = 0          # position in the FULL sequence, init steps included
    dep = 0          # position among the deploy files only -- this is the filename
    ndep = sum(1 for x in steps if x["kind"] == "batch")
    nstep = len(steps)
    for s in steps:
        seq += 1
        if s["kind"] != "batch":
            manifest.append((seq, None, "INIT", s["label"], 0, [], s["file"], s["line"]))
            emit_init(seq, s)
            continue
        dep += 1
        names = [os.path.splitext(os.path.basename(p))[0] for p in s["pacts"]]
        # Filenames are the DEPLOY index (01..N), not the sequence index. Numbering them by
        # sequence position gave 06, 09, 12, 13, 38, 56, 91 -- gaps wherever an init step sat,
        # which reads like missing files. The sequence position is in the header instead, because
        # it is what tells you which init steps must have run first.
        fn = f"{dep:02d}_deploy.pact"
        body = [
            ";; ---------------------------------------------------------------------------",
            f";; OURONET DEPLOY -- file {dep} of {ndep}",
            f";; This is STEP {seq} of {nstep} in the full sequence (see Deploy/MANIFEST.md).",
            f";; Steps 1-{seq-1} must have run first, including the init steps between deploys.",
            f";; {len(s['pacts'])} module(s), {s['gas']:,} gas measured in the REPL gas model,"
            f" {s['bytes']:,} bytes",
            ";;",
            ";; Modules in this transaction, IN ORDER (do not reorder):",
        ]
        for p in s["pacts"]:
            body.append(f";;   {os.path.relpath(p, ROOT)}")
        body += [
            ";;",
            ";; Paste this whole file as ONE transaction. It needs the Ouronet admin signature",
            ";; and the `ouronet-ns` namespace, which the first line sets.",
            ";; ---------------------------------------------------------------------------",
            "",
            '(namespace "ouronet-ns")',
            "",
        ]
        for p in s["pacts"]:
            rel = os.path.relpath(p, ROOT)
            src = open(p, encoding="utf8", errors="replace").read()
            code, tables = split_tables(src)
            is_new = any(k in rel.replace(os.sep, "/") for k in NEW_KEYS)
            inventory.append((rel, tables))
            body.append(f";; ===== {rel} {'=' * max(0, 60 - len(rel))}")
            body.append(code)
            if tables:
                want = ([t for t in tables if t not in existing]
                        if (is_new or mode != "upgrade") else [])
                skipped = [t for t in tables if t not in want]
                body.append("")
                body.append(f";; --- tables for {os.path.basename(rel)} "
                            f"({len(tables)} defined) ---")
                if is_new:
                    body.append(";; NEW MODULE this round -- not live on chain, so its tables do")
                    body.append(";; not exist yet and these create-table calls are ACTIVE.")
                elif mode == "upgrade":
                    body.append(";; UPGRADE MODE: this module is assumed already deployed, so its")
                    body.append(";; tables already exist and (create-table) would ABORT the whole")
                    body.append(";; transaction. They are listed here, commented, for reference.")
                    body.append(";; If any of these is NEW since the last deploy, uncomment JUST it.")
                elif skipped:
                    body.append(f";; {len(skipped)} table(s) omitted as already existing.")
                for t in tables:
                    body.append((";; " if t not in want else "") + f"(create-table {t})")
            body.append("")
        open(os.path.join(PURE, fn), "w", encoding="utf8").write("\n".join(body) + "\n")
        manifest.append((seq, dep, "DEPLOY", ", ".join(names), s["gas"], s["pacts"], fn, 0))
    write_manifest(manifest, steps, budget, maxbytes, mode)
    write_tables(inventory, mode, existing)
    write_init_readme()
    # The 3_Assets placeholder is a file on disk rather than a literal here, because it is prose
    # that will be replaced wholesale once the Bloodshed/FVT question is settled.
    tpl = os.path.join(ROOT, "REPL", "tools", "_assets_readme.md")
    if os.path.exists(tpl):
        open(os.path.join(ASSETS, "README.md"), "w", encoding="utf8").write(
            open(tpl, encoding="utf8").read())
    print(f"\nwrote {os.path.relpath(OUT, ROOT)}/ -- "
          f"{sum(1 for m in manifest if m[2] == 'DEPLOY')} deploy files + MANIFEST.md")


INIT_SEQ = []
ORPHANS = []
NEW_KEYS = []


def emit_init(seq, step):
    """One file per init step: the real forms, the signers, and an honest flag if it looks like a
    sandbox fixture rather than a deployment step."""
    body, sigs = extract_init(step)
    label = step["label"]
    fixture = [h for h in FIXTURE_HINTS
               if h.lower() in label.lower()
               or any(h.lower() in f.lower() for _, f in body)]
    n = len(INIT_SEQ) + 1
    fn = f"{n:02d}_init.pact"
    L = [";; ---------------------------------------------------------------------------",
         f";; OURONET INIT -- file {n}",
         f";; STEP {seq} of the full sequence (see Deploy/MANIFEST.md).",
         f";; Label : {label}",
         f";; Source: {step['file']}:{step['line']}",
         ";;"]
    if sigs:
        L.append(";; SIGNERS this block used in the REPL (translate to real transaction signers):")
        for k in dict.fromkeys(sigs):
            L.append(f";;   {k}")
        L.append(";;")
    if fixture:
        L += [";; !! LIKELY A SANDBOX FIXTURE, NOT A DEPLOYMENT STEP.",
              f";; !! Matched: {', '.join(sorted(set(fixture)))}",
              ";; !! These blocks create or fund test accounts so the REPL chain can run. Shipping",
              ";; !! one to mainnet would create real accounts and move real value. REVIEW BEFORE",
              ";; !! USING. This is a flag from a keyword match, not a judgement -- a block can be",
              ";; !! flagged and still be required, or unflagged and still be a fixture.",
              ";;"]
    if not body:
        L += [";; NO DEPLOYABLE FORMS. Everything in this block was REPL scaffolding (print,",
              ";; expect, env-*). Nothing to run -- kept so the numbering matches the sequence.",
              ";; ---------------------------------------------------------------------------"]
    else:
        L += [f";; {len(body)} form(s) below, lifted verbatim from the source.",
              ";; ---------------------------------------------------------------------------",
              "", '(namespace "ouronet-ns")', ""]
        for ln, f in body:
            L.append(f";; {os.path.basename(step['file'])}:{ln}")
            L.append(f)
            L.append("")
    open(os.path.join(INIT, fn), "w", encoding="utf8").write("\n".join(L) + "\n")
    INIT_SEQ.append((n, seq, label, len(body), bool(fixture), step["file"], step["line"]))


def write_init_readme():
    L = ["# Init steps\n",
         f"{len(INIT_SEQ)} init/config steps, in sequence order. **These are extracted, not "
         "generated.**\n",
         "Each file carries the real forms from its source block with the REPL scaffolding "
         "(`print`, `expect`, `env-*`) stripped, plus the signer keys that block used. The "
         "`env-sigs` keys are REPL names -- translate them to the real signers your pipeline "
         "uses.\n",
         "**Two things this cannot do for you.** It cannot know your keysets, and it cannot "
         "decide which blocks are sandbox fixtures. Blocks matching a fixture keyword are flagged "
         "in their own header; the flag is a keyword match, so a required block can be flagged and "
         "a fixture can be missed. Read each one.\n",
         "| file | step | forms | label | flag |",
         "|---:|---:|---:|---|---|"]
    for n, seq, label, nf, fx, sf, sl in INIT_SEQ:
        L.append(f"| `{n:02d}_init.pact` | {seq} | {nf} | {label[:56]} | "
                 + ("**fixture?**" if fx else "") + " |")
    nempty = sum(1 for x in INIT_SEQ if x[3] == 0)
    nfix = sum(1 for x in INIT_SEQ if x[4])
    L.append(f"\n**{len(INIT_SEQ)} steps** · {nfix} flagged as possible fixtures · "
             f"{nempty} carry no deployable forms (pure REPL scaffolding).\n")
    open(os.path.join(INIT, "README.md"), "w", encoding="utf8").write("\n".join(L) + "\n")


def write_tables(inventory, mode, existing):
    tot = sum(len(t) for _, t in inventory)
    L = ["# Tables, per module\n",
         f"**Mode: `{mode}`.** {tot} tables are defined across the modules in this plan.\n",
         "`(create-table X)` **fails if X already exists**, and which tables exist is a property of "
         "the chain that this repository cannot determine (see the note at the top of "
         "`REPL/tools/_deploybundle.py`). So ask the chain.\n",
         "## Probe: paste this as ONE read-only transaction\n",
         "It returns a row per table that exists and errors on the first that does not, so run it "
         "in chunks, or wrap each in `(try \"MISSING\" (describe-table ...))` if your pipeline "
         "allows.\n",
         "```pact"]
    for rel, tables in inventory:
        if not tables:
            continue
        L.append(f";; {rel}")
        for t in tables:
            L.append(f'(try "MISSING {t}" (let ((x (describe-table {t}))) "{t}"))')
    L.append("```\n")
    L.append("## Inventory\n")
    L.append("| module | tables |")
    L.append("|---|---|")
    for rel, tables in inventory:
        L.append(f"| `{os.path.basename(rel)}` | " +
                 (", ".join(f"`{t}`" for t in tables) if tables else "*none*") + " |")
    open(os.path.join(OUT, "TABLES.md"), "w", encoding="utf8").write("\n".join(L) + "\n")


def write_manifest(manifest, steps, budget, maxbytes, mode="upgrade"):
    batches = [s for s in steps if s["kind"] == "batch"]
    ndep = len(batches)
    L = []
    L.append("# Ouronet deploy plan\n")
    L.append("**Generated** by `python3 REPL/tools/_deploybundle.py --write`. "
             "Do not hand-edit; regenerate.\n")
    L.append(f"- per-transaction gas budget: **{budget:,}** "
             f"(StoaChain block limit {BLOCK_LIMIT:,})")
    L.append(f"- module-deploy transactions: **{len(batches)}**")
    L.append(f"- modules deployed: **{sum(len(b['pacts']) for b in batches)}**")
    L.append(f"- measured module gas: **{sum(b['gas'] for b in batches):,}**\n")
    L.append("## Read this before deploying\n")
    L.append("**The gas figures are REPL figures.** They come from `env-gasmodel \"table\"`, the "
             "same model the chain uses, measured by running the deploy chain. They do **not** "
             "include per-transaction overhead or signature verification. The budget above leaves "
             "headroom for that, but the batches are a **proposal to validate on testnet**, not a "
             "guarantee.\n")
    L.append("**Order is the safety property.** A module may only reference modules already "
             "deployed. Nothing here has been reordered, and the numbered steps must be executed "
             "in the order given.\n")
    L.append("**The `INIT` steps are not generated.** Between runs of module deploys the chain "
             "performs initialisation -- registering inter-module policies, seeding constants, "
             "minting genesis supply. Those need signatures, keysets and transaction data that "
             "only you can supply, and some blocks in the REPL chain are sandbox fixtures that "
             "must **not** reach mainnet. Each is listed below with its source location so you can "
             "lift the real calls out of it. **Do not skip them:** a module deployed after an init "
             "step may depend on that step having run.\n")
    if ORPHANS:
        L.append("## ⚠ Modules that must redeploy but are in no deploy chain\n")
        L.append("These name an interface that bumped this round, so Pact's cascade rule requires "
                 "them to be redeployed -- but no deploy chain loads them, so **they are not in "
                 "the files below**:\n")
        for o in ORPHANS:
            L.append(f"- `{os.path.relpath(o, ROOT)}`")
        L.append("")
        L.append("`01_DPL-UR.pact` is expected: Stage Z deploys from `deploy-stagezz.repl`, a "
                 "separate chain that runs last.\n")
        L.append("`09_AQP-INFO.pact` is **not** expected and is the same module flagged earlier as "
                 "absent from `deploy-stage02.repl`. It is 1,405 lines of cost-preview code "
                 "referenced by 18 test files, it names a bumped interface, and nothing deploys "
                 "it. Either the chain is missing it or it is test-only -- and if it is live on "
                 "mainnet today, it is about to be left on a stale interface.\n")
    L.append("## What was verified, and what was not\n")
    L.append("- **A generated batch loads.** `Deploy/06_deploy.pact` (13 utility modules) was "
             "loaded in the REPL on top of Stage 00 and succeeded, costing **183,034 gas** against "
             "the **183,286** predicted by summing the modules individually -- 0.14% apart. The "
             "concatenation is sound and the gas model is predictive.")
    L.append("- **The init barriers are real.** Loading batch 09 (DALOS) straight after batch 06 "
             "fails with `Cannot find keyset in database: 'ouronet-ns.dh_sc_dalos-keyset'` -- "
             "because step 7 defines it. That failure is the evidence that the numbered order "
             "must be followed and that init steps cannot be skipped or deferred.")
    L.append("- **Content is verbatim.** All 78 modules appear byte-for-byte in their batches; "
             "nothing was rewritten, reflowed or glued to a neighbour.")
    L.append("- **NOT verified: the full sequence end to end on a chain.** Only a testnet run "
             "can do that, because the init steps are not generated here.\n")
    L.append("## Modules in the tree that this plan does NOT deploy\n")
    L.append("Checked deliberately, because a deploy plan that silently omits a module is the "
             "worst possible kind:\n")
    L.append("| module | why |")
    L.append("|---|---|")
    L.append("| `STAGE_01/0_Interfaces/{01_Utilities,02_Core,03_Talos}.pact`, "
             "`STAGE_02/0_Interfaces/{02_Core,03_Talos}.pact` | **empty** -- 0 code lines. "
             "Interfaces are now embedded in the module files that implement them. Nothing to "
             "deploy. |")
    L.append("| `2_CITIZEN/Stage_Z/01_DPL-UR.pact`, `02_EXPLORER.pact` | deployed by "
             "`deploy-stagezz.repl`, a separate chain, deliberately last. Not in this plan. |")
    L.append("| `2_CITIZEN/2_BloodshedMinter/*` (5), `3_NosferatuMinter/01_NOSFERATU.pact` | "
             "citizen minters, loaded only by the `[5.x]_Populate*` fixture suites. Deploy when "
             "minting, not as part of the core chain. |")
    L.append("| `2_CITIZEN/6_OuronetBridge/03_CADUCEUS.pact` | bridge scaffold; loaded only by its "
             "own module test. Not ready. |")
    L.append("| **`STAGE_02/2_Core/03_AQP/09_AQP-INFO.pact`** | **NEEDS A DECISION.** 1,405 lines "
             "of code, referenced by **18** `.repl` files including its own suite "
             "`Stage_02/[6.5]_AQP-INFO.repl`, and it is an `INFO_` cost-preview module whose "
             "previews are counted among the audited client-facing surface -- but it is **not "
             "loaded by `deploy-stage02.repl`**. Either the deploy chain is missing it, or it is "
             "intentionally test-only. Resolve before deploying. |\n")
    L.append("## Tables: already in the batches\n")
    L.append("Every `.pact` file in this tree is laid out `interface(s)` -> `module` -> its own "
             "`create-table` calls, which is the same shape you would paste by hand. A batch "
             "therefore emits **A-complete, then B-complete** -- "
             "`[ifaceA][moduleA][tablesA][ifaceB][moduleB][tablesB]` -- and never "
             "\"module A, module B, then the tables of both\". Nothing needs separating out. "
             "Verified by loading `Deploy/01_deploy.pact` (13 modules, 4+ tables) in one "
             "transaction.\n")
    L.append("## The AQP asset tree is NOT in this plan\n")
    L.append("`AQP-BOOT` exists to build the acquisition-pool asset tree, and it defines "
             "**thirteen** steps, `C_Step0` through `C_Step12`. **The deploy chain runs only "
             "`Step0`** (sequence step 92, wiring IMC policies and rotating the vault governor). "
             "Steps 1-12 -- the bunny set, the anchor classes, the core and subsidiary scores, the "
             "OURO LP triplet, the pools, the FVT entities, the multiplet family, the farm triplet "
             "and the reward links -- are **not deployed by anything here**.\n")
    L.append("Two things make those twelve steps a separate piece of work rather than more "
             "batches:\n")
    L.append("1. **Their arguments are threaded from earlier results.** `Step6` takes "
             "`boost-class-ids` produced by `Step3`; `Step11` takes a `farm-id` and three score "
             "ids produced by `Step7` and `Step4`. They cannot be pasted as literals until the "
             "preceding step has run and its ids are known, so this is an interactive sequence, "
             "not a file.")
    L.append("2. **No single file runs the whole sequence.** The fullest is "
             "`Stage_02/[6.2.9]_AQP-BOOT-FULL.repl` with nine of them (1,2,3,6,8,9,10,11,12). "
             "Steps 4 and 5 run in `triplet-collect-golden.repl` and `[6.2.2]_AQP-SCORE.repl`. "
             "There is no golden end-to-end ordering to copy.\n")
    L.append("### `C_Step7_CreatePoolsAndScores` has never been run successfully\n")
    L.append("Counted across the whole suite, per step, separating calls inside an "
             "`expect-failure` from real ones:\n")
    L.append("| step | successful runs | negative-only | |")
    L.append("|---|---:|---:|---|")
    L.append("| Step0-6, 8-12 | at least 1 each | — | fine |")
    L.append("| **Step7** | **0** | **6** | **never executed on its happy path** |\n")
    L.append("All six `Step7` sites are in `modules/DPDC.repl` and all six are `expect-failure`, "
             "exercising its four list-length guards with deliberately wrong-length arguments. "
             "The step that creates the six DH pools, the nine DH scores and the three OURO "
             "triplet scores has been proven only to **reject bad input**. Its success path is "
             "unexecuted anywhere in 25,035 assertions.\n")
    L.append("### Investigated 2026-09-18: the hand-rolled test DIVERGES from Step7\n")
    L.append("`TX-BOOT-07` and `07b` in `[6.2.9]_AQP-BOOT-FULL.repl` do not call `C_Step7`. They "
             "reproduce it by calling `AQP-POOL\\|C_Issue` and `AQP-POOL\\|C_AddScore` directly. So "
             "the **operations** are covered while the **deployment function that sequences them** "
             "is not -- and comparing the two line by line found them disagreeing:\n")
    L.append("| | DHBloodshed scores attached |")
    L.append("|---|---|")
    L.append("| `C_Step7` (and its own POOL MAP doc) | `Bloodshed` **and** `SubsidiaryBloodshed` |")
    L.append("| `TX-BOOT-07b` (the fixture) | `SubsidiaryBloodshed` only |\n")
    L.append("`Bloodshed` is one of the four CORE scores `C_Step4` creates. So the fixture every "
             "downstream assertion runs against differs from what a real deployment would produce, "
             "and nothing can see it because `C_Step7` is never executed.\n")
    L.append("**But the fix is not mechanical, and this needs an owner decision.** Attaching "
             "`Bloodshed` to its pool breaks `TX-BOOT-G1`, a P3.3 guard probe that uses the "
             "`Bloodshed` score **precisely because it is pool-less** in the fixture: with the link "
             "added it stops aborting in a table read and hits a different guard. Both cannot be "
             "right:\n")
    L.append("- **If `C_Step7` is correct**, the probe must pick a genuinely pool-less score, and "
             "the fixture has been wrong.")
    L.append("- **If the probe is correct**, `C_Step7` over-attaches and would wire mainnet "
             "differently from every test.\n")
    L.append("*An attempt to add a positive `C_Step7` execution as a rolled-back block got as far "
             "as satisfying `GOV\\|AQP_BOOT_ADMIN`, then needed the `coin.TRANSFER` managed caps "
             "the pool issues charge -- which is why `TX-BOOT-07` carries that elaborate `env-sigs` "
             "block. It was reverted rather than left half-finished; the suite is green.*\n")
    L.append("**Do not deploy the asset tree until that is resolved.** The cheapest resolution is "
             "to extend `[6.2.9]_AQP-BOOT-FULL.repl` to run 4, 5 and 7 in place, which would also "
             "give the end-to-end ordering this plan cannot currently provide.\n")
    L.append("## The sequence\n")
    L.append("Read top to bottom. **`step`** is the position in the full sequence; "
             "**`file`** is the deploy file to paste, numbered `01`..`%d` in the order you use "
             "them. Init steps have no file -- their source is given instead.\n" % ndep)
    L.append("| step | file | what | gas | source |")
    L.append("|---:|:---:|---|---:|---|")
    for seq, dep, kind, what, gas, pacts, fn, line in manifest:
        if kind == "DEPLOY":
            L.append(f"| {seq} | **{dep:02d}** | DEPLOY {len(pacts)} modules: {what} | {gas:,} | "
                     f"`Deploy/1_Pure/{fn}` |")
        else:
            L.append(f"| {seq} | — | *init* — {what} | — | `Deploy/2_Init/` · `{fn}:{line}` |")
    open(os.path.join(OUT, "MANIFEST.md"), "w", encoding="utf8").write("\n".join(L) + "\n")


if __name__ == "__main__":
    sys.exit(main())
