// Generate OuronetInformational/MODULE-INDEX.md — a one-page map of every Pact module so an agent
// gets instant codebase-shape recall (then scans the one module it needs for detail).
// Run: node OuronetInformational/tools/gen-module-index.mjs   (no deps). Re-run whenever modules change.
import { readdirSync, readFileSync, statSync, writeFileSync } from "node:fs";
import { join, resolve, relative, dirname, basename } from "node:path";
import { fileURLToPath } from "node:url";

const __dir = dirname(fileURLToPath(import.meta.url));
const REPO = resolve(__dir, "..", "..");            // …/Ouronet
const OUT = resolve(__dir, "..", "MODULE-INDEX.md"); // …/OuronetInformational/MODULE-INDEX.md
const SKIP = new Set([".git", "node_modules", "OuronetInformational", "REPL"]);

function walk(dir, acc = []) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    if (e.name.startsWith(".") || SKIP.has(e.name)) continue;
    const p = join(dir, e.name);
    if (e.isDirectory()) walk(p, acc);
    else if (e.name.endsWith(".pact")) acc.push(p);
  }
  return acc;
}
const all = (re, s) => { const out = []; let m; const r = new RegExp(re, "g"); while ((m = r.exec(s))) out.push(m[1]); return out; };
const uniq = (a) => [...new Set(a)];

function parse(file) {
  const s = readFileSync(file, "utf8");
  const modM = /\(module\s+([^\s)]+)\s+(\S+)/.exec(s);
  const ifaces = all("\\(interface\\s+([^\\s)]+)", s);
  const implic = uniq(all("\\(implements\\s+([^\\s)]+)", s));
  const tables = uniq(all("\\(deftable\\s+([^\\s:)]+)", s));
  const schemas = uniq(all("\\(defschema\\s+([^\\s)]+)", s));
  const entry = uniq(all("\\(defun\\s+((?:C_|A_|XI_|XE_|XB_)[^\\s:(]+)", s));
  // one-line purpose: first @doc string anywhere near the top, else first ;; comment, else name
  const doc = /@doc\s+"([^"]{4,160})/.exec(s);
  const cmt = /^\s*;;\s*([^\n]{6,110})/m.exec(s.slice(0, 1200));
  const purpose = (doc?.[1] || cmt?.[1] || "")
    .replace(/[\r\n\\]+/g, " ").replace(/\s+/g, " ").replace(/\|/g, "\\|").trim().slice(0, 90);
  return { file: relative(REPO, file), module: modM?.[1] || null, gov: modM?.[2] || null,
    ifaces, implic, tables, schemas, entry, purpose };
}

const mods = walk(REPO).map(parse).sort((a, b) => a.file.localeCompare(b.file));
const withMod = mods.filter((m) => m.module || m.ifaces.length);

const rows = withMod.map((m) => {
  const name = m.module || (m.ifaces.length ? `${m.ifaces.length}× iface (latest: ${m.ifaces[m.ifaces.length - 1]})` : "?");
  const tbl = m.tables.length ? m.tables.join(", ") : "—";
  const ent = m.entry.length ? m.entry.slice(0, 12).join(", ") + (m.entry.length > 12 ? ` …(+${m.entry.length - 12})` : "") : "—";
  return `| \`${name}\` | \`${m.file}\` | ${m.schemas.length}/${m.tables.length} | ${tbl} | ${ent} | ${m.purpose || ""} |`;
});

const totals = {
  files: mods.length, modules: mods.filter((m) => m.module).length,
  tables: mods.reduce((n, m) => n + m.tables.length, 0),
  schemas: mods.reduce((n, m) => n + m.schemas.length, 0),
  entrypoints: mods.reduce((n, m) => n + m.entry.length, 0),
};

const md = `# MODULE-INDEX — every Pact module at a glance

> **Generated** by \`OuronetInformational/tools/gen-module-index.mjs\` — do not hand-edit; re-run after module changes.
> Read this for instant codebase-shape recall, then open the one module you need (its \`.pact\` + interface + \`.repl\`)
> for detail. "Make an info function for module X" → find X below, open it, mirror its \`UR_\`/\`INFO-\` reader shape.

**Totals:** ${totals.modules} modules across ${totals.files} \`.pact\` files · ${totals.schemas} schemas · ${totals.tables} tables · ${totals.entrypoints} public entrypoints (\`C_\`/\`A_\`/\`X*\`).

| Module | File | schemas/tables | Tables | Public entrypoints (C_/A_/X) | Purpose |
|--------|------|----------------|--------|------------------------------|---------|
${rows.join("\n")}
`;
writeFileSync(OUT, md);
console.log(`wrote ${relative(REPO, OUT)} — ${withMod.length} modules/interfaces, ${totals.tables} tables, ${totals.entrypoints} entrypoints`);
