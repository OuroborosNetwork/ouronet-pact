#!/bin/bash
# Full generated-artefact cascade, in dependency order. Run from the Ouronet repo root.
cd /home/ancientbox/ClaudeWS/OuroborosNetwork/_onchain/Ouronet || exit 1
set -e
python3 REPL/tools/_xprotect.py   --write >/dev/null 2>&1 || true
python3 REPL/tools/_pricesync.py  --write >/dev/null 2>&1 || true
python3 REPL/tools/_deploybundle.py --write >/dev/null 2>&1 || true
python3 REPL/tools/_talosabi.py   --write >/dev/null 2>&1 || true
python3 REPL/tools/_docspages.py  --write >/dev/null 2>&1 || true
python3 REPL/tools/_docsmodules.py --write >/dev/null 2>&1 || true
(cd REPL && python3 tools/_suite_stats.py >/dev/null 2>&1) || true
python3 /tmp/fixfigs.py >/dev/null 2>&1 || true
python3 REPL/tools/_docsall.py    --write >/dev/null 2>&1 || true
python3 REPL/tools/_purev6.py --write >/dev/null 2>&1 || true
python3 /tmp/fixpricing.py >/dev/null 2>&1 || true
python3 /tmp/fixround.py >/dev/null 2>&1 || true
python3 REPL/tools/_auditbook.py  --docx  >/dev/null 2>&1 || true
echo "cascade done"
