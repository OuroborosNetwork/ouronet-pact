#!/usr/bin/env python3
"""_livemodules.py -- fetch the DEPLOYED source of every module, cached by module hash.

WHY THIS EXISTS.  `OuronetDocumentation/` documents what is RUNNING, and the repository is the
comparison rather than the authority (owner refinement 2026-09-29, recorded in
`OuronetDocumentation/MAINTAINING.md` §2a).  A reader of that documentation calls the chain, not
the checkout, so a page generated from a source file that has drifted ahead of mainnet describes a
system nobody can use.

THE EVIDENCE THIS IS BUILT ON is not a fear, it is a measurement.  The hand-written predecessor --
`websites/ouronetwork-website/OuronetWhitepaper/`, explicitly "code-accurate ... taken directly
from the sovereign Pact modules, not from memory" -- states 58 client signatures.  Three still
match.  One refactor (694 re-signed entrypoints) invalidated 95% of it in three and a half months,
and nothing noticed, because "kept in sync" was a promise rather than a command.

HOW IT STAYS CHEAP.  `describe-module` returns the whole deployed source -- 12,832 chars for
ELITE, 130,920 for ATS -- so fetching all of them is megabytes and slow.  A Pact module hash
changes on ANY redeploy, so the hash is a complete cache key rather than a heuristic: unchanged
hash means byte-identical source and the cached copy is not merely probably right, it is the same
bytes.  First run fetches everything; later runs fetch only what was redeployed.

  python3 REPL/tools/_livemodules.py --probe   fetch changed modules, refresh the cache
  python3 REPL/tools/_livemodules.py --check   offline: report cache coverage and staleness
  python3 REPL/tools/_livemodules.py --diff    repo vs deployed, per module (needs the cache)
"""
import io, json, os, re, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
# TWO ARTEFACTS, deliberately.
#
# `LIVE-MODULES.json` is COMMITTED and holds hashes plus the parsed shapes -- what the generator
# consumes and what a reviewer can actually read. Its diff is "ATS gained a function", which is a
# sentence worth seeing in a pull request.
#
# The raw deployed source is 5.7 MB and is NOT committed. Storing it would make the artefact's
# diff a wall of duplicated Pact nobody reads, which is how a generated file stops being reviewed
# and starts being rubber-stamped. It is regenerable from the chain in one command, and keyed by
# hash so regenerating is exact rather than hopeful.
CACHE = os.path.join(ROOT, "Deploy", "LIVE-MODULES.json")
RAW = os.path.join(ROOT, "Deploy", ".live-source-cache.json")
NS = "ouronet-ns"


def _rpc():
    """Borrow the probe that already exists rather than writing a second one."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        "_rl", os.path.join(os.path.dirname(os.path.abspath(__file__)), "_registrylive.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.rpc


def repo_modules():
    """Every module the repo declares, name -> source path. Deploy order is the file order."""
    out = {}
    for base in ("1_SOVEREIGN", "2_CITIZEN"):
        for path in sorted(glob.glob(os.path.join(ROOT, base, "**", "*.pact"), recursive=True)):
            txt = io.open(path, encoding="utf8", errors="replace").read()
            for name in re.findall(r"^\(module\s+(\S+)", txt, re.M):
                # A file may declare the same module twice (CADUCEUS does, an abandoned skeleton
                # above the real one). Last wins, which is what Pact would load.
                out[name] = os.path.relpath(path, ROOT)
    return out


# Shapes parsed out of a module source. Deliberately the same regexes for deployed and repo text,
# so a difference in the RESULT is a difference in the CODE and never in the reading of it.
SHAPES = {
    "schemas":      re.compile(r"\(defschema\s+([^\s)]+)", re.M),
    "tables":       re.compile(r"\(deftable\s+([^\s:)]+)", re.M),
    "capabilities": re.compile(r"\(defcap\s+([^\s(]+)", re.M),
    "functions":    re.compile(r"\(defun\s+([^\s:(]+)", re.M),
    "pacts":        re.compile(r"\(defpact\s+([^\s:(]+)", re.M),
    "constants":    re.compile(r"\(defconst\s+([^\s:)]+)", re.M),
}


def shapes_of(code):
    return {k: sorted(set(rx.findall(code))) for k, rx in SHAPES.items()}


def load_cache():
    if os.path.exists(CACHE):
        return json.load(io.open(CACHE, encoding="utf8"))
    return {"note": "", "modules": {}}


def load_raw():
    if os.path.exists(RAW):
        return json.load(io.open(RAW, encoding="utf8"))
    return {}


def probe():
    rpc = _rpc()
    cache = load_cache()
    raw = load_raw()
    mods = cache.setdefault("modules", {})
    repo = repo_modules()
    fetched = reused = missing = 0

    for name in sorted(repo):
        st, h = rpc(f'(at "hash" (describe-module "{NS}.{name}"))')
        if st != "OK" or not isinstance(h, str):
            # Not deployed. Recorded rather than skipped: a module the repo has and the chain does
            # not is a fact the documentation must state, not a gap to paper over.
            mods[name] = {"deployed": False, "repoPath": repo[name]}
            missing += 1
            continue
        prev = mods.get(name) or {}
        if prev.get("hash") == h and raw.get(name):
            reused += 1
            prev["repoPath"] = repo[name]
            continue
        st, code = rpc(f'(at "code" (describe-module "{NS}.{name}"))')
        if st != "OK" or not isinstance(code, str):
            print(f"  !! {name}: hash read but code did not")
            continue
        st, ifaces = rpc(f'(at "interfaces" (describe-module "{NS}.{name}"))')
        mods[name] = {
            "deployed": True, "hash": h, "repoPath": repo[name],
            "interfaces": ifaces if st == "OK" and isinstance(ifaces, list) else [],
            "chars": len(code), "shapes": shapes_of(code),
        }
        raw[name] = code
        fetched += 1
        print(f"  fetched {name:16s} {len(code):>7,} chars")

    cache["note"] = (
        "DEPLOYED module sources, cached by module hash. Generated by REPL/tools/_livemodules.py. "
        "A Pact module hash changes on any redeploy, so an unchanged hash means byte-identical "
        "source -- the cache is exact, not approximate. LIVE IS THE AUTHORITY here; the repo is "
        "the comparison. See OuronetDocumentation/MAINTAINING.md section 2a.")
    json.dump(cache, io.open(CACHE, "w", encoding="utf8"), ensure_ascii=False, indent=1)
    json.dump(raw, io.open(RAW, "w", encoding="utf8"), ensure_ascii=False)
    print(f"\n{fetched} fetched, {reused} unchanged (cache hit), {missing} not deployed")
    print(f"wrote {os.path.relpath(CACHE, ROOT)}  ({os.path.getsize(CACHE):,} bytes, committed)")
    print(f"wrote {os.path.relpath(RAW, ROOT)}  ({os.path.getsize(RAW):,} bytes, NOT committed)")
    return 0


def check():
    if not os.path.exists(CACHE):
        print("no cache -- run --probe (needs network)")
        return 1
    c = load_cache()
    mods = c.get("modules", {})
    live = [m for m, v in mods.items() if v.get("deployed")]
    nd = [m for m, v in mods.items() if not v.get("deployed")]
    repo = repo_modules()
    uncached = sorted(set(repo) - set(mods))
    print(f"cache: {len(live)} deployed, {len(nd)} declared-but-not-deployed, "
          f"{len(uncached)} never probed")
    if nd:
        print("  not deployed: " + ", ".join(sorted(nd)[:12]) + ("…" if len(nd) > 12 else ""))
    if uncached:
        print("  NEVER PROBED: " + ", ".join(uncached[:12]))
        print("  (a module the cache has never seen is not 'unchanged', it is unknown)")
        return 1
    return 0


def diff():
    """Repo vs deployed, per module. The difference is REPORTED, never reconciled."""
    if not os.path.exists(CACHE):
        print("no cache -- run --probe first")
        return 1
    mods = load_cache().get("modules", {})
    drift = 0
    for name in sorted(mods):
        v = mods[name]
        if not v.get("deployed"):
            continue
        src = io.open(os.path.join(ROOT, v["repoPath"]), encoding="utf8", errors="replace").read()
        i = src.find(f"(module {name} ")
        repo_shapes = shapes_of(src[i:] if i >= 0 else src)
        for kind in SHAPES:
            a, b = set(v["shapes"][kind]), set(repo_shapes[kind])
            only_live, only_repo = sorted(a - b), sorted(b - a)
            if only_live or only_repo:
                drift += 1
                print(f"  {name}.{kind}")
                if only_live:
                    print(f"      DEPLOYED only: {', '.join(only_live[:6])}")
                if only_repo:
                    print(f"      repo only    : {', '.join(only_repo[:6])}")
    print(f"\n{drift} module/shape pair(s) differ between the chain and the repo"
          if drift else "\nrepo and chain agree on every module's declared shapes")
    return 0


def main():
    a = sys.argv[1:]
    if "--probe" in a:
        return probe()
    if "--check" in a:
        return check()
    if "--diff" in a:
        return diff()
    print(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main())
