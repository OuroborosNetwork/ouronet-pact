#!/usr/bin/env python3
"""Carry the two cross-cutting tree figures (contract lines, defun forms) into the prose.

They move on EVERY source change, and `_docsfigures.py` is a checker with no --write by
design ("both need a human"). This is that human step, mechanised safely:

  * digit-BOUNDARY regex only, so `[6.1]_DPDC.repl:125,356,130` -- a line-number LIST --
    is never touched. A blanket replace corrupted exactly that site earlier in this work.
  * the OLD value is read from the front-page table rather than remembered, so the script
    cannot drift from the docs it edits.
  * the LOGICAL line count (wc -l + files lacking a final newline) is carried too, because
    one row quotes both and its arithmetic has to keep working.
"""
import io, os, re, subprocess, sys
ROOT = "/home/ancientbox/ClaudeWS/OuroborosNetwork/_onchain/Ouronet"
os.chdir(ROOT)

def sh(c): return subprocess.run(c, shell=True, capture_output=True, text=True).stdout.strip()

lines  = int(sh(r"""find 1_SOVEREIGN 2_CITIZEN -name '*.pact' -exec cat {} + | wc -l"""))
defuns = int(sh(r"""grep -rhoE '^\s*\(defun ' --include=*.pact 1_SOVEREIGN 2_CITIZEN | wc -l"""))
nonl   = int(sh(r"""n=0; for f in $(find 1_SOVEREIGN 2_CITIZEN -name '*.pact'); do [ -n "$(tail -c 1 "$f")" ] && n=$((n+1)); done; echo $n"""))
logical = lines + nonl

FRONT = "OuronetDocumentation/00-orientation/01-what-ouronet-is.md"
src = io.open(FRONT, encoding="utf-8").read()
old_lines  = int(re.search(r"\| lines of Pact \| ([\d,]+) \|", src).group(1).replace(",", ""))
old_defuns = int(re.search(r"\| `defun` forms \| ([\d,]+) \|", src).group(1).replace(",", ""))
old_logical = old_lines + nonl   # the row derives it the same way

pairs = [(old_lines, lines), (old_defuns, defuns), (old_logical, logical)]
pairs = [(a, b) for a, b in pairs if a != b]
if not pairs:
    print("figures: already current (%d lines, %d defun, %d logical)" % (lines, defuns, logical))
    sys.exit(0)

def fmt(n): return "{:,}".format(n)
touched = 0
for root in ("OuronetDocumentation", "OuronetInformational", "Audit"):
    for dp, _, fns in os.walk(root):
        for fn in fns:
            if not fn.endswith(".md"): continue
            p = os.path.join(dp, fn)
            s0 = io.open(p, encoding="utf-8").read(); s1 = s0
            for a, b in pairs:
                # comma-formatted ("8,973") AND bare ("8973") -- `03-how-these-figures-were-
                # obtained.md` quotes the raw command output, which has no thousands separator,
                # and missing that variant left a NEAR-MISS the gate reported but no edit fixed.
                s1 = re.sub(r"(?<![\d,])" + re.escape(fmt(a)) + r"(?![\d,])", fmt(b), s1)
                s1 = re.sub(r"(?<![\d,])" + str(a) + r"(?![\d,])", str(b), s1)
            if s1 != s0:
                io.open(p, "w", encoding="utf-8").write(s1); touched += 1
print("figures: %s -> %s lines, %s -> %s defun, logical %s (%d file(s))"
      % (fmt(old_lines), fmt(lines), fmt(old_defuns), fmt(defuns), fmt(logical), touched))
