#!/usr/bin/env python3
"""_livesandbox.py -- build a VIRTUAL CHAIN from live state, then replay a round on top of it.

    python3 REPL/tools/_livesandbox.py --round Deploy/PureV13
    python3 REPL/tools/_livesandbox.py --round Deploy/PureV13 --progress   (emit @@PROGRESS lines)

Implements OuronetInformational/SPEC-round-simulator.md S1+S2. Replaces `_chaintxsim.py`'s
git-worktree bootstrap, which is the architectural defect that cost 2026-10-24:

    owner: "The practice copy has to be built from live chain data, not from my git commit ...
            what's live is what matters for the simulation, not what my git head has or hasn't,
            which might not be actual."

WHY THE OLD ONE WAS WRONG. It created a `git worktree` at HEAD and patched live content into only
the files a round "touched". That assumes HEAD is what is deployed. In this repo commits LAG
deploys -- HEAD still declared `IgnisCollectorV3` while the chain ran V4 -- so the sandbox was a
hybrid of two eras and failed on its own seams. Those failures looked exactly like defects in the
round being tested, and were diagnosed as such three separate times before anyone checked the
bootstrap. Nothing here reads git.

HOW ORDER IS RECOVERED, since the chain does not hand it back. `list-modules` returns names, not
a load order, and a Pact source cannot load before the modules it references. So the order is
DERIVED: each fetched source is scanned for the INTERFACES it depends on (`implements X`,
`module{X}`, `object{X.Schema}`) and the set is topologically sorted. Qualified `Other.fn` calls
are deliberately NOT edges -- see deps_of(); counting them produced a 370-way false cycle on the
first attempt, because every module dot-mentions its neighbours somewhere.
A cycle is reported rather than guessed at -- this graph cannot have one, so a cycle means the
scan is wrong and silently picking an order would hide that.

WHAT IS DELIBERATELY NOT HERE. No `NEW_TO_OLD` map, no `--base-commit`, no hardcoded namespace.
Every one of those is a cached belief about chain state, and each had already gone stale by the
time it mattered. The chain is asked instead.
"""
import os, re, sys, glob, json, time, importlib.util

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if not os.path.isdir(os.path.join(ROOT, "REPL")):
    ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, "REPL", "tools")
SRC_CACHE = os.path.join(ROOT, "Deploy", ".live-source-cache.json")

PROGRESS = "--progress" in sys.argv


def _imp(name, path):
    sp = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(sp)
    sys.modules[name] = m
    sp.loader.exec_module(m)
    return m


def progress(phase, done, total, label=""):
    """SPEC S2 -- one JSON object per line, flushed, so a UI can render a real bar.

    Additive: the human-readable prints stay exactly as they were, because the terminal output is
    still what a person reads. A run that takes minutes and says nothing is indistinguishable
    from a hang, and the operator cannot tell whether to wait or kill it."""
    if PROGRESS:
        sys.stdout.write("@@PROGRESS " + json.dumps(
            {"phase": phase, "done": done, "total": total, "label": label}) + "\n")
        sys.stdout.flush()


STOA_NS_INIT = os.path.join(ROOT, "00_StoaSandbox", "stoa-env", "init-phase-01-ns.repl")


def sandbox_signer():
    """The pubkey the Stoa sandbox signs namespace operations with.

    READ FROM THE TREE, NOT HARDCODED, and not from the chain either -- this is the sandbox
    ENVIRONMENT's key, the same split as loading Stage00 rather than reimplementing it. Copying
    the literal here would be a third copy of a value that already exists in two places.

    WHY IT MATTERS THAT THIS IS THE *SAME* KEY THE PLACEHOLDER KEYSETS USE. The first attempt
    invented a separate `"sandbox"` key and signed with that, which REPLACED the environment's
    signature set -- `env-sigs` overwrites, it does not append. Every interface in the chain then
    failed its namespace guard ("Keyset failure (keys-any): [10b99804..., 1a4e15d3...]") and the
    heal loop dutifully excluded 28 interfaces as "broken on chain". They were not broken; they
    were unsigned. Using one key for both the namespace guard and the placeholder admin keysets
    removes the possibility of that conflict instead of balancing two signature sets."""
    try:
        txt = open(STOA_NS_INIT, encoding="utf-8").read()
        m = re.search(r'\(env-sigs\s*\[\s*\{\s*"key"\s*:\s*"([0-9a-f]{64})"', txt)
        if m:
            return m.group(1)
    except OSError:
        pass
    sys.exit(f"cannot read the sandbox signer key from {STOA_NS_INIT}")


def round_namespace(round_dir):
    """SPEC S1.1 -- the namespace comes FROM THE ROUND, never from a constant.

    A deploy file opens with `(namespace "x")`; that is the namespace the round targets, so it is
    the one whose live surface the sandbox must be built from. Hardcoding it makes this tool
    silently wrong for any round aimed elsewhere."""
    for p in sorted(glob.glob(os.path.join(round_dir, "*.pact"))):
        m = re.search(r'^\(namespace\s+"([^"]+)"\)', open(p, encoding="utf-8", errors="ignore").read(), re.M)
        if m:
            return m.group(1)
    sys.exit(f"no (namespace \"...\") found in any file under {round_dir} -- cannot target a chain")


def enumerate_live(ns, rpc):
    r = rpc("(list-modules)")
    if not isinstance(r, list):
        sys.exit(f"list-modules did not return a list: {str(r)[:200]}")
    pre = ns + "."
    return sorted({n[len(pre):] for n in map(str, r) if str(n).startswith(pre)})


def fetch_sources(ns, names, rpc):
    """-> {name: source}. Hash-keyed cache: a Pact module hash changes on ANY redeploy, so an
    unchanged hash means byte-identical source and a cache hit is exact, not a guess."""
    cache = {}
    if os.path.exists(SRC_CACHE):
        try:
            cache = json.load(open(SRC_CACHE, encoding="utf-8"))
        except (OSError, ValueError):
            cache = {}
    out, fetched, hits = {}, 0, 0
    total = len(names)
    for i, n in enumerate(names, 1):
        r = rpc(f'(describe-module "{ns}.{n}")')
        if not (r and r.get("code")):
            progress("fetch", i, total, f"{n} (absent)")
            continue
        h = r.get("hash")
        key = f"{n}@{h}" if h else None
        if key and key in cache:
            out[n] = cache[key]; hits += 1
        else:
            out[n] = r["code"]; fetched += 1
            if key:
                cache[key] = r["code"]
        progress("fetch", i, total, f"{n} ({hits} cached)")
    try:
        json.dump(cache, open(SRC_CACHE, "w", encoding="utf-8"))
    except OSError:
        pass
    return out, fetched, hits


DECL_RE = re.compile(r'^\((?:module|interface)\s+([\w|-]+)', re.M)
DEP_PATTERNS = (
    re.compile(r'\(implements\s+([\w|-]+)\)'),
    re.compile(r'module\{([\w|-]+)\}'),
    re.compile(r'object\{([\w|-]+)\.'),
)


QUALIFIED_RE = re.compile(r'(?<![\w|.\-])([A-Za-z][\w|-]*)\.[A-Za-z]')


def strip_noise(src):
    """Source with `;` comments and double-quoted strings removed. A SCANNER, NOT A REGEX.

    THIS IS WHAT MAKES QUALIFIED-CALL EDGES SAFE. The first version of deps_of() counted every
    `Other.fn` mention and produced a 370-way false cycle -- because modules dot-mention their
    neighbours constantly in @doc strings and section comments ("Executes via
    TS02-C3.AQP-SCR|C_RotateScoreOwnership." is PROSE, not a dependency).

    A regex was tried first and WAS NOT GOOD ENOUGH, in a way worth recording: this repo's
    @doc convention uses Pact string continuation --

        @doc "first clause \\
             \\ second clause mentioning AQP-POOL.something"

    -- and `"(?:[^"\\\\]|\\\\.)*"` mis-paired the quotes across those continuations, leaving
    prose behind as if it were code. That manufactured a single false `AQP-ANK -> AQP-POOL`
    edge, which was enough to turn the graph cyclic and send the whole design toward
    "cycles are inherent in live state". They are not; the scan was wrong. Character-level
    scanning has no pairing to get wrong."""
    out, i, n = [], 0, len(src)
    while i < n:
        c = src[i]
        if c == ';':                                   # comment -> end of line
            j = src.find('\n', i)
            i = n if j < 0 else j
        elif c == '"':                                 # string -> collapse to ""
            out.append('""')
            i += 1
            while i < n:
                if src[i] == '\\':
                    i += 2                             # escape: skip the escaped char
                elif src[i] == '"':
                    i += 1
                    break
                else:
                    i += 1
        else:
            out.append(c)
            i += 1
    return "".join(out)


def deps_of(src, universe, interfaces):
    """Names that must be loaded BEFORE this source.

    ONLY INTERFACE DEPENDENCIES, and that is the whole trick. Ouronet reaches across modules
    through MODREFS -- `(ref-X:module{SomeIfaceV3} X)` -- precisely so a module depends on the
    INTERFACE's shape, not on the other module being loaded first. So `implements`, `module{I}`
    and `object{I.Schema}` are real load-order edges; a qualified `Other.fn` call is not, and
    treating it as one is what produced a 370-way "cycle" on the first attempt: every module
    dot-mentions its neighbours somewhere, so everything depended on everything.

    Interfaces cannot reference modules, so this graph is acyclic by construction."""
    found = set()
    for pat in DEP_PATTERNS:
        found |= set(pat.findall(src))
    ifaces_needed = {d for d in found if d in universe and d in interfaces}

    # AND THE MODULE EACH MODREF BINDS. Corrected 2026-10-24 by the replay itself:
    # `BRD.pact:364: Cannot find module: ouronet-ns.DALOS` on the line
    #     (ref-DALOS:module{OuronetDalosV3} DALOS)
    # A modref names an interface as the TYPE and a concrete module as the VALUE, and Pact needs
    # BOTH loaded -- the interface for the shape, the module because it is being bound. The first
    # version here took only the interface, on the theory that modrefs decouple load order. They
    # decouple the SHAPE, not the binding.
    #
    # Narrow on purpose: only the name in binding position, never every `Other.fn` mention. That
    # wider scan is what produced a 370-way false cycle, because modules dot-mention each other
    # inside doc strings and comments.
    bound = set(re.findall(r'module\{[\w|-]+\}\s+([\w|-]+)\)', src))
    mods_needed = {d for d in bound if d in universe and d not in interfaces}

    # AND DIRECT QUALIFIED CALLS -- `(AQP-SCORE.URCi_RotateOwnership score-id)`.
    #
    # Corrected 2026-10-24 by the replay, again, and this one was diagnosed WRONG first. Live
    # AQP-INFO makes that call and the sort placed it at index 104 with AQP-SCORE at 107, so the
    # load failed with "Module AQP-SCORE has no such member: URCi_RotateOwnership" -- which reads
    # exactly like a module missing a function. It is not: live AQP-SCORE defines it. The member
    # was absent only because the module had not been loaded YET.
    #
    # The first fix attempt accepted that message at face value and excluded 14 "modules broken
    # on chain", every one of which was fine. CHECK THE CLAIM BEFORE REPORTING IT: grepping the
    # fetched source for the supposedly-missing member took one command and refuted the whole
    # diagnosis.
    #
    # The docstring's reason for excluding these edges was sound but the remedy was too broad.
    # Modrefs decouple the SHAPE; a qualified call needs the module itself, so it IS an edge.
    # strip_noise() is what makes it usable -- the false cycle came from prose, not from code.
    qualified = {d for d in QUALIFIED_RE.findall(strip_noise(src))
                 if d in universe and d not in interfaces}
    return ifaces_needed | mods_needed | qualified


def write_chain(cat_path, order, sources):
    """Concatenate every live source in dependency order into ONE file, and return the line spans.

    ONE CONCATENATED FILE, NOT N SEPARATE LOADS. These modules were DEPLOYED with their interface
    and module in the same transaction, and live sources rely on that: `SWPT` says
    `object{RawGraphNode}` unqualified for a schema that lives in `SwapTracerV4`. Loading the two
    as separate files -- even in the correct order -- leaves the module unable to resolve it
    ("Cannot find module: ouronet-ns.RawGraphNode"), because the unqualified form resolves only
    within the declaring scope. So the sandbox reproduces the deploy SHAPE, which is also closer
    to what actually happened on chain.

    THE SPANS ARE THE POINT. Pact reports a load failure as `_chain.pact:54235:109`, and a line
    number in a 60,000-line concatenation names no module to a human. Recording which range of
    lines each source occupies turns that back into "live module AQP-SCORE is broken", which is
    the difference between a diagnosis and a dead end."""
    spans, parts, line = [], [], 1
    for n in order:
        chunk = f"\n;; ===== {n} =====\n{sources[n]}\n"
        nl = chunk.count("\n")
        spans.append((line, line + nl, n))
        line += nl
        parts.append(chunk)

    # AND THEN CREATE THE TABLES, because code is not all the chain has.
    #
    # `describe-module` returns the source AS DEPLOYED, and what was deployed was an UPGRADE --
    # whose `create-table` forms were stripped, since `create-table` aborts when the table
    # already exists. So every live source here declares its `deftable`s and creates none of
    # them. On chain that is right: the tables were created by a genesis deploy months ago and
    # have held rows ever since. In a blank sandbox it means the tables simply do not exist, and
    # the first function that touches storage dies with
    #
    #     Error during database operation: Table ouronet-ns.RPS_FVT|T|RPS|Global not found
    #
    # which is the sandbox being incomplete, not the round being wrong. The round's own MANUAL
    # backfill step is exactly the kind of thing that hits this, because a backfill's whole job
    # is to walk existing rows.
    #
    # So the declarations are read back out of the live sources and created explicitly. The
    # tables come up EMPTY, and that is the honest limit of this tool: it proves the round loads
    # and its migrations execute, not that they transform real rows correctly. Row-level
    # behaviour is what the REPL suites are for, and they have fixtures.
    tables = []
    for n in order:
        if re.search(r'^\(interface\s', sources[n], re.M):
            continue
        for t in re.findall(r'^\s*\(deftable\s+([\w|.\-]+)', strip_noise(sources[n]), re.M):
            tables.append((n, t.split(":")[0]))
    if tables:
        parts.append("\n;; ===== tables (declared by the live sources, created here) =====\n")
        for mod, tbl in tables:
            parts.append(f"(create-table {mod}.{tbl})\n")

    with open(cat_path, "w", encoding="utf-8") as fh:
        fh.write("".join(parts))
    return spans


ORIGIN_RE = re.compile(r'^(\S+\.pact):(\d+):(\d+): (.+)$', re.M)


def error_origin(combined):
    """-> (path, lineno, message) of where the failure ACTUALLY happened, or None.

    THE DISTINCTION THIS DRAWS IS THE WHOLE REASON IT EXISTS. A Pact failure prints the origin
    first and then a stack of `at(...)` frames, and those frames name the files of every function
    on the way in:

        .../PureV13/04_deploy.pact:325:16: Error during database operation: Table ... not found
          at(ouronet-ns.RPS.AA_MigrateMinInject...):.../PureV13/05_backfill.pact:71:0-71:36

    A plain search for `_chain.pact:\\d+` anywhere in that output matches the FRAMES as readily as
    the origin -- so a failure in the round's own file, passing through a live module, looked like
    a broken live module. The heal loop then excluded it, which moved the failure one frame along,
    and excluded that one too: twenty-odd modules "broken on chain" from a single round-level
    error, DALOS first. Matching only the origin line makes that impossible."""
    hits = ORIGIN_RE.findall(combined)
    if not hits:
        return None
    p, ln, _col, msg = hits[-1]
    return p, int(ln), msg


def module_at_line(spans, lineno):
    for a, b, n in spans:
        if a <= lineno <= b:
            return n
    return None


def toposort(sources):
    """Dependency order. A CYCLE IS REPORTED, NOT BROKEN: Pact cannot have one, so a cycle means
    the dependency scan is wrong, and quietly picking an order would hide that defect."""
    uni = set(sources)
    # WHICH NAMES ARE INTERFACES -- determined from the fetched source itself, not from a naming
    # convention. `describe-module` returns interfaces too, and only an interface can be a
    # load-order dependency here (see deps_of).
    interfaces = {n for n, src in sources.items()
                  if re.search(r'^\(interface\s', src, re.M)}
    deps = {n: deps_of(s, uni, interfaces) - {n} for n, s in sources.items()}
    out, done = [], set()
    while len(out) < len(sources):
        ready = sorted(n for n in sources if n not in done and deps[n] <= done)
        if not ready:
            stuck = sorted(n for n in sources if n not in done)
            sys.exit("dependency cycle or unresolved reference among: "
                     + ", ".join(stuck[:12]) + (" ..." if len(stuck) > 12 else "")
                     + "\n(a cycle is impossible in Pact -- the scan in deps_of() is wrong)")
        for n in ready:
            out.append(n); done.add(n)
    return out


def main():
    if "--round" not in sys.argv:
        sys.exit(__doc__)
    round_dir = sys.argv[sys.argv.index("--round") + 1]
    t0 = time.time()
    reg = _imp("registry_livesandbox", os.path.join(TOOLS, "_registry.py"))

    rfiles_pre = sorted(glob.glob(os.path.join(round_dir, "*.pact")),
                        key=lambda q: int(re.match(r"(\d+)", os.path.basename(q)).group(1))
                        if re.match(r"(\d+)", os.path.basename(q)) else 0)
    ns = round_namespace(round_dir)
    progress("namespace", 1, 1, ns)
    print(f"namespace (from the round): {ns}")

    names = enumerate_live(ns, reg.rpc)
    progress("enumerate", len(names), len(names), f"{len(names)} names")
    print(f"live surface: {len(names)} modules + interfaces")

    sources, fetched, hits = fetch_sources(ns, names, reg.rpc)
    print(f"sources: {len(sources)} usable ({fetched} fetched, {hits} from cache)")

    # ---- CLOSURE: load only what the ROUND needs -----------------------------------------
    #
    # Loading every live name was the first design and it was wrong twice over.
    #
    # It is UNNECESSARY: a round touches a few dozen modules; the rest cannot affect whether it
    # composes. And it is ACTIVELY HARMFUL, because the live chain is HISTORICAL, not
    # simultaneously consistent -- modules deployed at different times reference interface
    # versions that later moved, so some live modules no longer bind. `DPL-UR` is one: it names
    # `OuronetDalosV2` while live DALOS implements V3, a breakage already on chain and already
    # recorded in CLAUDE.md. Replaying all 370 into one blank database hits that and dies BEFORE
    # reaching the round -- reporting a failure that has nothing to do with what is being tested.
    #
    # So the sandbox is the round's dependency closure: the modules and interfaces the round
    # declares, plus everything those transitively need. Anything outside it is irrelevant by
    # construction, and an unrelated module that is broken on chain stays out of the way.
    round_declares = set()
    for p_ in rfiles_pre:
        txt_ = open(p_, encoding="utf-8", errors="ignore").read()
        round_declares |= set(re.findall(r'^\((?:module|interface)\s+([\w|-]+)', txt_, re.M))
    uni_all = set(sources)
    ifaces_all = {n for n, src in sources.items() if re.search(r'^\(interface\s', src, re.M)}
    seed = {n for n in round_declares if n in uni_all}
    # also seed from what the round's files REFERENCE, not only what they declare
    for p_ in rfiles_pre:
        txt_ = open(p_, encoding="utf-8", errors="ignore").read()
        seed |= deps_of(txt_, uni_all, ifaces_all)
    closure, frontier = set(seed), list(seed)
    while frontier:
        nxt = frontier.pop()
        for d in deps_of(sources.get(nxt, ""), uni_all, ifaces_all):
            if d not in closure:
                closure.add(d); frontier.append(d)
    if closure:
        skipped = len(sources) - len(closure)
        sources = {n: v for n, v in sources.items() if n in closure}
        print(f"closure: {len(sources)} live name(s) this round depends on "
              f"({skipped} unrelated live name(s) not loaded)")
        progress("closure", len(sources), len(sources), f"{len(sources)} needed, {skipped} skipped")

    order = toposort(sources)
    progress("sandbox", len(order), len(order), "virtual chain assembled")
    print(f"load order derived: {len(order)} entries "
          f"(first: {', '.join(order[:3])} ... last: {', '.join(order[-3:])})")

    out_dir = os.path.join(ROOT, "Deploy", ".livesandbox")
    os.makedirs(out_dir, exist_ok=True)
    for n in order:
        with open(os.path.join(out_dir, f"{n.replace('|','_')}.pact"), "w", encoding="utf-8") as fh:
            fh.write(sources[n])
    manifest = {"namespace": ns, "order": order, "built": time.time()}
    json.dump(manifest, open(os.path.join(out_dir, "MANIFEST.json"), "w"), indent=1)

    print(f"\nvirtual chain written to {os.path.relpath(out_dir, ROOT)} "
          f"({len(order)} sources, {time.time()-t0:.0f}s)")

    # ---- SPEC S1.5 -- replay the round ON TOP of the virtual chain -------------------------
    rfiles = sorted(glob.glob(os.path.join(round_dir, "*.pact")),
                    key=lambda p: int(re.match(r"(\d+)", os.path.basename(p)).group(1))
                    if re.match(r"(\d+)", os.path.basename(p)) else 0)
    names = [os.path.basename(p) for p in rfiles]
    result = {"namespace": ns, "live": len(order), "files": names,
              "ok": False, "failed_file": None, "message": ""}
    signer = sandbox_signer()

    # THE ENVIRONMENT COMES FROM THE TREE; THE MODULES COME FROM THE CHAIN.
    #
    # A bare REPL has no namespaces, no keysets and no `coin`, so loading a live module into it
    # fails with "Namespace not found" before any of this round is reached. Stage00 is the tree's
    # own proven bootstrap for exactly that environment -- it registers the namespace, the
    # keysets and the sandbox coin contracts, and deploys NO ouronet module.
    #
    # So the split is deliberate and is the whole design: the ENVIRONMENT is the tree's (it is
    # infrastructure, identical everywhere, and reproducing it here would be a second copy to
    # drift), while every MODULE AND INTERFACE is the chain's. Nothing about what is deployed
    # comes from git.
    preamble = [f'(env-gasmodel "table")(env-gaslimit 900000000)',
            # ABSOLUTE PATH: Pact resolves `load` relative to the file CONTAINING it, and this
            # replay script is written into Deploy/.livesandbox/, not REPL/.
            f'(load "{os.path.join(ROOT, "REPL", "Stage00_Sanboxes.repl")}")',
            # SIGN AS THE SANDBOX NAMESPACE KEY, for the whole replay.
            #
            # Needed because an admin-gated step in the round -- `RPS::AA_MigrateMinInject` is
            # one, and a schema backfill is ALWAYS admin-gated -- otherwise fails
            # `enforce-guard` with "Keyset failure" before the composition is ever reached.
            #
            # CORRECT FOR THIS CHECK, and the distinction matters. The question a round simulator
            # answers is "does this compose against live code", not "is the operator authorised":
            # authorisation is proven by the real signature on the real send, which the owner
            # supplies through the Codex. A verify-only tool holding real signing keys would
            # itself be the security problem. So the sandbox signs with the sandbox's own key to
            # get PAST authorisation and reach the composition, which is the only thing it can
            # actually judge.
            f'(env-sigs [{{"key": "{signer}", "caps": []}}])']
    cat_path = os.path.join(out_dir, "_chain.pact")
    spans = write_chain(cat_path, order, sources)

    # GRANT MODULE ADMIN FOR EVERY MODULE THIS ROUND UPGRADES.
    #
    # Pact EVALUATES a module's governance capability when the module is redeployed, and several
    # Ouronet `GOV|*_ADMIN` caps authorise against a DALOS account guard rather than a keyset:
    #
    #     (defcap GOV|DSA_ADMIN () ... (ref-DALOS::UR_AccountGuard ...) ...)
    #
    # which bottoms out in `(read DALOS|AccountTable account ["guard"])`. On chain that row has
    # existed since genesis. In this sandbox the tables come up EMPTY, so the upgrade fails with
    # "No value found in table ouronet-ns.DALOS_DALOS|AccountTable for key: Ѻ..." -- a fact about
    # the sandbox's emptiness, not about the round.
    #
    # Seeding that account row was the alternative, and it is worse: the row's guard is the real
    # admin's, so it would have to be forged, and forging a governance guard to test governance
    # is circular. `env-module-admin` is the REPL's own sanctioned way to say "treat the upgrade
    # as authorised" -- the same bypass, declared rather than faked. Consistent with the
    # placeholder keysets: this tool judges COMPOSITION, and the real signature on the real send
    # is what judges authority.
    # `uni_all` / `ifaces_all` are the FULL live surface, captured before the closure filter --
    # a module is an upgrade (and so needs admin) only if it already exists on chain.
    # GRANTED PER TRANSACTION, not once: `env-module-admin` scopes to the current transaction,
    # which is why the repo's own uses (`[6.1.1]_EQUITY.repl`) sit immediately before the
    # operation that needs it. Granted in its own tx it silently does nothing, and the failure
    # looks identical to not having tried.
    upgrades = sorted(n for n in round_declares if n in uni_all and n not in ifaces_all)
    if upgrades:
        print(f"granting module admin for {len(upgrades)} upgraded module(s) in each tx")

    def build_replay(discovered_ks, present):
        """The whole replay script, REBUILT from current state on every pass.

        BUILT RATHER THAN PATCHED, because the heal loop changes state the replay depends on and
        a spliced string cannot track that. Concretely: `env-module-admin ouronet-ns.DPL-UR` is
        only valid while DPL-UR is in the sandbox. When the loop excluded it -- correctly, live
        DPL-UR expects `OuronetDalosV2` against a live DALOS implementing V3 -- the stale admin
        line was still emitted into EVERY transaction, so the round died at file 01 on a module
        that has nothing to do with file 01. The failure pointed at the first transaction and the
        cause was the last one.
        """
        out = list(preamble)
        if discovered_ks:
            # INSIDE THE NAMESPACE: these keyset names are namespaced (`ouronet-ns.dh_sc_...`),
            # so `define-keyset` needs the namespace entered and its guard signed -- which is why
            # this sits after the `env-sigs` line in the preamble, not before it.
            out.append('(begin-tx "sandbox keysets")')
            out.append(f'(namespace "{ns}")')
            out.append(f'(env-data {{"sandbox-any": ["{signer}"]}})')
            out += [f'(define-keyset "{k}" (read-keyset "sandbox-any"))' for k in discovered_ks]
            out.append("(commit-tx)")
        out.append(f'(begin-tx "virtual chain from live {ns}")')
        out.append(f'(namespace "{ns}")')
        out.append(f'(load "{cat_path}")')
        out.append("(commit-tx)")
        # ONLY MODULES STILL IN THE SANDBOX. A grant for an absent module is itself an error.
        admin = [f'(env-module-admin {ns}.{u})' for u in upgrades if u in present]
        for p_, n_ in zip(rfiles, names):
            out.append(f'(print "--- [{n_}] ---")')
            out.append(f'(begin-tx "{n_}")')
            out += admin
            out.append(f'(load "{os.path.abspath(p_)}")')
            out.append("(commit-tx)")
        return "\n".join(out) + "\n"

    repl_path = os.path.join(out_dir, "_replay.repl")

    progress("replay", 0, len(names), "starting replay")
    print(f"\nreplaying {len(names)} transaction(s) on the virtual chain...")
    import shutil, subprocess
    # Resolved the same way `_gate.py` does it, and for the same reason: a PATH without
    # ~/.local/bin is a common way for this to "fail" for a reason unrelated to the round.
    pact = (os.environ.get("PACT") or shutil.which("pact")
            or os.path.expanduser("~/.local/bin/pact"))
    if not os.path.exists(pact) and not shutil.which(pact):
        sys.exit("cannot find the `pact` binary. Set PACT=/path/to/pact.")

    # SELF-HEALING KEYSET DISCOVERY.
    #
    # Live modules reference keysets by names their own CONSTS compute
    # (`(keyset-ref-guard DALOS|SC_KEY)` where the key is `(GOV|DalosKey)`), so the names cannot
    # be extracted statically -- there is no literal to grep. On the real chain those keysets
    # already exist; in a fresh sandbox they do not, and the load stops at the first one.
    #
    # So the replay ASKS THE FAILURE. Pact names the missing keyset exactly
    # ("Cannot find keyset in database: 'ouronet-ns.dh_sc_dalos-keyset"), that name is defined,
    # and the replay is retried until no keyset is missing. Converges in as many passes as there
    # are distinct keysets, and needs no list to maintain.
    #
    # THESE ARE PLACEHOLDER GUARDS, AND THAT IS CORRECT FOR THIS CHECK. The question here is
    # "does this round COMPOSE against live code", not "is the operator authorised" -- the real
    # signature proves that on the real send, and a verify-only tool holding real signing keys
    # would itself be the security problem. The owner supplies real keys through the Codex when
    # sending; the sandbox only needs the NAMES to resolve.
    #
    # AND SELF-HEALING EXCLUSION OF MODULES THAT ARE ALREADY BROKEN ON CHAIN.
    #
    # THE LIVE CHAIN IS HISTORICAL, NOT SIMULTANEOUSLY CONSISTENT. A module deployed months ago
    # may name a function or interface version that a later redeploy of its neighbour removed.
    # On chain that costs nothing until someone calls it -- the module sits there, loaded,
    # unusable. But replaying every such source into ONE blank database evaluates all of them at
    # once, so the first stale reference stops the whole sandbox:
    #
    #     Runtime typecheck failure, argument is modref, but expected module{...OuronetDalosV2}
    #
    # -- which is live `DPL-UR`, naming `OuronetDalosV2` while live DALOS implements V3. That is
    # real, pre-existing chain breakage and NOT a defect in the round being tested; treating it
    # as one is the exact failure mode this tool was written to end. It cannot be the only such
    # module either, and a hardcoded skip-list would be one more cached belief about chain state
    # -- the thing this file refuses to keep.
    #
    # So the broken ones are DISCOVERED the same way the keysets are: the failure names a line,
    # the line spans name the owning module, that module is dropped, and the chain is rebuilt.
    # Each pass removes one; dependents of a dropped module surface on later passes and are
    # dropped in turn. What remains is the largest subset of live state that actually loads, and
    # every exclusion is REPORTED -- a silent drop would hide real chain breakage.
    discovered, excluded, combined, r = [], [], "", None
    cur_order = list(order)
    for _ in range(80):
        open(repl_path, "w", encoding="utf-8").write(build_replay(discovered, set(cur_order)))
        r = subprocess.run([pact, repl_path], capture_output=True, text=True,
                           cwd=os.path.join(ROOT, "REPL"))
        combined = r.stdout + r.stderr
        if r.returncode == 0:
            break

        # (a) a keyset the live modules expect but a fresh database has no row for
        mk = re.search(r"Cannot find keyset in database: '([\w.\-]+)", combined)
        if mk and mk.group(1) not in discovered:
            discovered.append(mk.group(1))
            progress("replay", 0, len(names), f"defining sandbox keyset {mk.group(1)}")
            continue

        # (b) a failure INSIDE the virtual chain -> whichever live module owns that line is
        #     broken on chain. Drop it, rebuild, retry. Only `_chain.pact` lines qualify: a
        #     failure in one of the round's own files is the ANSWER, not something to heal.
        origin = error_origin(combined)
        in_chain = bool(origin) and os.path.basename(origin[0]) == "_chain.pact"

        # ...AND ONLY FOR A GENUINE RESOLUTION FAILURE.
        #
        # Two classes of error name a live module while saying nothing about it:
        #
        #   Keyset failure      -- the SANDBOX's signing setup is wrong. On the first attempt one
        #                          overwritten `env-sigs` made every interface in the namespace
        #                          fail its namespace guard, and the loop excluded 28 of them in
        #                          alphabetical order, reporting that as a finding about the chain.
        #   database not found  -- the sandbox's tables are empty where the chain's hold rows.
        #                          That is this tool's known limit, not module breakage.
        #
        # Excluding on either produces confident nonsense, so both stop the loop instead.
        if in_chain and re.search(r'Keyset failure|not found|No value found', origin[2]):
            print(f"\n  NOT excluding anything -- this failure is a gap in the SANDBOX, not in "
                  f"the live\n  module it points at: {origin[2][:140]}")
            break
        if in_chain:
            owner = module_at_line(spans, origin[1])
            if owner and owner not in excluded:
                excluded.append(owner)
                sources.pop(owner, None)
                cur_order = [n for n in cur_order if n != owner]
                spans = write_chain(cat_path, cur_order, sources)
                why = re.sub(r"\s+", " ", origin[2])[:120].strip()
                progress("heal", len(excluded), len(excluded), f"excluding {owner}")
                print(f"  excluding live module {owner} -- will not load: {why}")
                continue
        break
    if discovered:
        print(f"  (defined {len(discovered)} placeholder keyset(s) the live modules expect)")
    # THE COUNT MUST REFLECT WHAT ACTUALLY LOADED. `len(order)` is what was PLANNED; after any
    # exclusion the sandbox is smaller, and reporting the planned number would overstate how much
    # live state the round was checked against -- in the one direction that matters.
    result["live"] = len(cur_order)
    if excluded:
        result["excluded_broken_on_chain"] = excluded
        # WHICH OF THEM THIS ROUND FIXES -- carried in the result, not just printed here.
        #
        # The two cases deserve opposite reactions and must not be reported as one. A module
        # excluded because it is broken on chain AND redeployed by this round is the round doing
        # its job: the exclusion is expected, and shipping is what ends it. A module excluded that
        # the round does NOT touch is a real caveat -- it means the round was verified against
        # less than live state and nothing here will fix that.
        #
        # Without this field a consumer can only show the pessimistic reading, which is how a
        # green 13/13 round came to carry a red line about the very module its last transaction
        # repairs.
        result["excluded_fixed_by_round"] = sorted(set(excluded) & round_declares)
        print(f"\n  {len(excluded)} live module(s) are ALREADY BROKEN ON CHAIN and were excluded "
              f"from the sandbox:\n    " + "\n    ".join(excluded)
              + "\n  (these are pre-existing, NOT caused by this round -- each names a member or "
                "interface\n   version a later redeploy of a neighbour removed.)")
        if set(excluded) & round_declares:
            print("  NOTE: this round REDEPLOYS " + ", ".join(sorted(set(excluded) & round_declares))
                  + " -- the round is what fixes them.")
    seen = re.findall(r'--- \[([\w.\-]+)\] ---', combined)
    reached = len([n for n in names if n in seen])
    if r.returncode == 0:
        result["ok"] = True
        result["message"] = "round composes clean on the live-built chain"
        progress("done", len(names), len(names), result["message"])
        print(f"\nROUND OK -- {len(names)} transaction(s) composed clean against live content.")
    else:
        # ATTRIBUTE THE FAILURE. Prefer the path Pact itself names; fall back to the last banner
        # that printed. A failure nobody can pin to a file sends people hunting the wrong thing --
        # that is exactly what happened on 2026-10-24.
        paths = re.findall(r'([^\s:()"]+\.pact):\d+:\d+', combined)
        failed = next((n for n in reversed(seen) if n in names), None)
        if not failed and paths:
            b = os.path.basename(paths[-1])
            failed = b if b in names else None
            if not failed:
                result["failed_in_live_source"] = paths[-1]
        result["failed_file"] = failed
        result["message"] = combined[-3000:]
        progress("done", reached, len(names), f"failed at {failed or 'an unattributed file'}")
        print(f"\nROUND FAILED at {failed or 'an unattributed file'} "
              f"({reached}/{len(names)} reached)\n")
        print(combined[-2500:])

    if "--json" in sys.argv:
        print("@@RESULT " + json.dumps(result))
    return 0 if result["ok"] else 1


if __name__ == "__main__":
    sys.exit(main())
