#!/usr/bin/env node
'use strict';
// lint-contract.cjs — deterministic contract lint between the pieces of the package.
// Node >= 18, no dependencies, runs from any cwd.
//
//   node scripts/lint-contract.cjs            all rules
//   node scripts/lint-contract.cjs --rule 2   one rule
//   node scripts/lint-contract.cjs --json     machine output
//
// Checks the seams that no test covers: SKILL.md <-> references/, helper commands <-> ll-tools.js,
// skills <-> agents, verdict vocabulary, state-file names, `Next` targets, installer <-> package.
// Exit 1 when any rule FAILs; WARN never changes the exit code.

const fs = require('fs');
const path = require('path');

const ROOT = path.resolve(__dirname, '..');
const J = path.join;
const NEXT_MARK = '▶ Next';
const MODELS = 'opus|sonnet|haiku|fable';

// ---------------------------------------------------------------------------
// filesystem, read once per file
// ---------------------------------------------------------------------------

const TEXT = new Map();
function text(file) {
  if (!TEXT.has(file)) {
    let v = null;
    try { v = fs.readFileSync(file, 'utf8'); } catch { v = null; }
    TEXT.set(file, v);
  }
  return TEXT.get(file);
}
function isDir(p) { try { return fs.statSync(p).isDirectory(); } catch { return false; } }
function ls(p) { try { return fs.readdirSync(p).sort(); } catch { return []; } }
function walk(dir, out = []) {
  for (const name of ls(dir)) {
    const full = J(dir, name);
    if (isDir(full)) walk(full, out); else out.push(full);
  }
  return out;
}
function rel(p) { return path.relative(ROOT, p).split(path.sep).join('/'); }
function uniq(a) { return Array.from(new Set(a)); }
function esc(s) { return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); }
function word(token) { return new RegExp('\\b' + esc(token).replace(/\\?\s+/g, '\\s+') + '\\b'); }
function matches(re, s) { return uniq((s || '').match(re) || []); }
function captures(re, s, group = 1) {
  const out = []; let m;
  const r = new RegExp(re.source, re.flags.includes('g') ? re.flags : re.flags + 'g');
  while ((m = r.exec(s || '')) !== null) out.push(m[group]);
  return out;
}

// ---------------------------------------------------------------------------
// the pieces of the package
// ---------------------------------------------------------------------------

const SKILL_NAMES = ls(J(ROOT, 'skills')).filter((n) => isDir(J(ROOT, 'skills', n)));
const SKILL_DOCS = SKILL_NAMES.map((n) => J(ROOT, 'skills', n, 'SKILL.md')).filter((f) => text(f) !== null);
const SKILL_TREE = walk(J(ROOT, 'skills')).filter((f) => f.endsWith('.md'));
const AGENT_FILES = ls(J(ROOT, 'agents')).filter((n) => n.endsWith('.md')).map((n) => J(ROOT, 'agents', n));
const HOOK_FILES = ls(J(ROOT, 'hooks')).filter((n) => n.endsWith('.js')).map((n) => J(ROOT, 'hooks', n));
const ASSET_FILES = walk(J(ROOT, 'assets'));
const README = J(ROOT, 'README.md');
const TOOLS = J(ROOT, 'scripts', 'll-tools.js');
const INSTALLER = J(ROOT, 'bin', 'install.js');
const PREAMBLE = J(ROOT, 'assets', 'preamble.md');
const BRIEFS = J(ROOT, 'skills', 'll-implement', 'references', 'briefs.md');

function joined(files) { return files.map((f) => text(f) || '').join('\n'); }

// One row per SKILL.md and per agent: how many of its outbound references resolve.
const PIECES = new Map();
function piece(file) {
  const key = rel(file);
  if (!PIECES.has(key)) PIECES.set(key, { ok: 0, total: 0 });
  return PIECES.get(key);
}
for (const f of SKILL_DOCS.concat(AGENT_FILES)) piece(f);
function refCount(file, ok) {
  const key = rel(file);
  if (!PIECES.has(key)) return;
  const row = PIECES.get(key);
  row.total += 1;
  if (ok) row.ok += 1;
}

// ---------------------------------------------------------------------------
// rules
// ---------------------------------------------------------------------------

function result() { return { checked: 0, fails: [], warns: [] }; }

// 1. Every references/<x>.md cited by a SKILL.md exists; every reference file is cited.
function rule1() {
  const r = result();
  for (const name of SKILL_NAMES) {
    const doc = J(ROOT, 'skills', name, 'SKILL.md');
    const body = text(doc);
    if (body === null) { r.fails.push(`skills/${name}/SKILL.md is missing`); continue; }
    // `references/x.md` belongs to this skill; `ll-other/references/x.md` is a cross-skill pointer
    // and is resolved against the skill it names.
    const cites = new RegExp('(?:(ll-[a-z][a-z-]*)/)?references/([A-Za-z0-9._-]+\\.md)', 'g');
    let m;
    const seen = new Set();
    while ((m = cites.exec(body)) !== null) {
      const owner = m[1] || name;
      const key = owner + '/' + m[2];
      if (seen.has(key)) continue;
      seen.add(key);
      r.checked += 1;
      const ok = text(J(ROOT, 'skills', owner, 'references', m[2])) !== null;
      refCount(doc, ok);
      if (!ok) r.fails.push(`skills/${name}/SKILL.md cites ${key.replace(name + '/', '')}, which does not exist`);
    }
    const dir = J(ROOT, 'skills', name, 'references');
    for (const file of ls(dir).filter((f) => f.endsWith('.md'))) {
      r.checked += 1;
      if (!body.includes(file)) r.fails.push(`skills/${name}/references/${file} is not mentioned in SKILL.md`);
    }
  }
  return r;
}

// The command surface of the helper.
function helperSurface() {
  const src = text(TOOLS) || '';
  const defined = uniq(
    captures(/^C\['([a-z][a-z-]*)'\]\s*=/gm, src).concat(captures(/^C\.([a-z][a-zA-Z-]*)\s*=/gm, src))
  );
  const fmt = uniq(captures(/^\s{2}'?([a-z][a-z-]*)'?:\s*\(/gm, literal(src, 'FMT') || ''));
  return { defined, fmt };
}

// 2. Helper commands cited anywhere are defined; every command is cited and has a formatter.
function rule2() {
  const r = result();
  const { defined, fmt } = helperSurface();
  if (!defined.length) { r.fails.push('no command found in scripts/ll-tools.js'); return r; }

  const sources = SKILL_TREE.concat(AGENT_FILES, HOOK_FILES, [README]);
  const citedIn = new Map(); // command -> [file]
  for (const file of sources) {
    for (const cmd of captures(/ll-tools\.js\s+([a-z-]+)/g, text(file))) {
      if (!citedIn.has(cmd)) citedIn.set(cmd, []);
      citedIn.get(cmd).push(file);
      r.checked += 1;
      const ok = defined.includes(cmd);
      refCount(file, ok);
      if (!ok) r.fails.push(`${rel(file)} cites \`ll-tools.js ${cmd}\`, which is not a defined command`);
    }
  }
  const docs = new Set(SKILL_TREE.map(rel));
  for (const cmd of defined) {
    r.checked += 2;
    const where = (citedIn.get(cmd) || []).map(rel);
    if (!where.some((f) => docs.has(f))) r.fails.push(`command \`${cmd}\` is defined but no SKILL.md or reference cites it`);
    if (!fmt.includes(cmd)) r.fails.push(`command \`${cmd}\` has no FMT formatter`);
  }
  return r;
}

// The fixed fields of the executor brief, read from briefs.md itself.
function executorBriefFields() {
  const body = text(BRIEFS);
  if (body === null) return null;
  const lines = body.split('\n');
  const head = lines.findIndex((l) => /^##\s/.test(l) && l.includes('ll-executor'));
  if (head < 0) return null;
  let open = -1, close = -1;
  for (let i = head + 1; i < lines.length; i++) {
    if (/^\s*```/.test(lines[i])) { if (open < 0) open = i; else { close = i; break; } }
    if (/^##\s/.test(lines[i])) break;
  }
  if (open < 0 || close < 0) return null;
  const fields = [];
  for (const line of lines.slice(open + 1, close)) {
    const m = /^([A-Z]{2,}(?: [A-Z]{2,})*)\s{2,}\S/.exec(line);
    if (m) fields.push(m[1]);
  }
  return uniq(fields);
}

// The model a line declares for an agent, looked for right after the agent name only.
function declaredModel(line, agent) {
  const at = line.indexOf(agent);
  if (at < 0) return null;
  const win = line.slice(at + agent.length, at + agent.length + 60);
  const re = [
    new RegExp('`?model:\\s*`?(' + MODELS + ')'),
    new RegExp('\\((' + MODELS + ')[,/)\\s]'),
    new RegExp('`?(' + MODELS + ')`?\\s*/\\s*(?:high|medium|low)'),
  ];
  for (const p of re) { const m = p.exec(win); if (m) return m[1]; }
  return null;
}

// 3. Agents cited by the skills exist; the models the skills declare match; the brief fields land.
function rule3() {
  const r = result();
  const names = ['ll-executor', 'll-scout', 'll-verifier', 'll-reviewer'];
  const nameRe = new RegExp('\\b(' + names.join('|') + ')\\b', 'g');

  for (const file of SKILL_TREE) {
    const body = text(file) || '';
    for (const agent of matches(nameRe, body)) {
      r.checked += 1;
      const ok = text(J(ROOT, 'agents', agent + '.md')) !== null;
      refCount(file, ok);
      if (!ok) r.fails.push(`${rel(file)} cites agent ${agent}, but agents/${agent}.md does not exist`);
    }
    for (const line of body.split('\n')) {
      for (const agent of matches(nameRe, line)) {
        const declared = declaredModel(line, agent);
        if (!declared) continue;
        const agentBody = text(J(ROOT, 'agents', agent + '.md'));
        if (agentBody === null) continue;
        r.checked += 1;
        const own = (/^model:\s*(\S+)/m.exec(agentBody) || [])[1];
        const overrides = /override|overridden|passed on the call/i.test(line);
        if (declared !== own && !overrides) {
          r.fails.push(`${rel(file)} declares \`${agent}\` as ${declared}, agents/${agent}.md is ${own} (no override stated)`);
        }
      }
    }
  }

  const fields = executorBriefFields();
  if (fields === null) {
    r.fails.push('could not read the executor brief block in skills/ll-implement/references/briefs.md');
    return r;
  }
  if (fields.length !== 12) r.warns.push(`the executor brief declares ${fields.length} fields, the contract says 12: ${fields.join(', ')}`);
  const agentBody = text(J(ROOT, 'agents', 'll-executor.md'));
  // A field is acknowledged when the agent names it at all; the brief writes it uppercase, the
  // agent body may name it as a heading or a plan key, so the FAIL is on absence, not on case.
  for (const field of fields) {
    r.checked += 1;
    if (agentBody === null) { r.fails.push(`brief field ${field} does not appear in agents/ll-executor.md`); continue; }
    const strict = word(field);
    const loose = new RegExp(strict.source, 'i');
    if (!loose.test(agentBody)) r.fails.push(`brief field ${field} does not appear in agents/ll-executor.md`);
    else if (!strict.test(agentBody)) r.warns.push(`brief field ${field} appears in agents/ll-executor.md only in another case`);
  }
  return r;
}

// 4. The verdict vocabulary the skills use is emitted by the agents; the board states exist in the helper.
function rule4() {
  const r = result();
  const verdicts = ['APPROVED', 'APPROVED_WITH_RESERVATIONS', 'REJECTED', 'DEFERRED', 'BLOCKED'];
  const skillsText = joined(SKILL_TREE);
  const agentsText = joined(AGENT_FILES);
  for (const token of verdicts) {
    if (!word(token).test(skillsText)) continue;
    r.checked += 1;
    if (!word(token).test(agentsText)) r.fails.push(`verdict ${token} is used in skills/ but no agent emits it`);
  }
  const board = ['ANSWERED_NO', 'BLOCKED', 'WAITING', 'passes:'];
  const preambleText = joined([PREAMBLE].concat(SKILL_TREE));
  const toolsText = text(TOOLS) || '';
  for (const token of board) {
    const re = token.endsWith(':') ? new RegExp(esc(token)) : word(token);
    if (!re.test(preambleText)) continue;
    r.checked += 1;
    if (!re.test(toolsText)) r.fails.push(`board state ${token} is used in the preamble/skills but not in scripts/ll-tools.js`);
  }
  return r;
}

// 5. Every state path is declared in a `## Deliverables` table; a name used exactly once is suspect.
function rule5() {
  const r = result();
  const paths = ['PLAN.md', 'ROADMAP.md', 'PROGRESS.md', 'BACKLOG.md', 'VERIFICATION.md', 'decisions/',
    'phases/NN/', 'docs/decide/', 'docs/GOAL.md', 'docs/REQUESTS.md', 'docs/DELIVERY.md',
    'CODE-CONTEXT.md', 'PLAN-REVIEW.md', 'DECISIONS.md'];

  const rows = [];
  for (const doc of SKILL_DOCS) {
    const body = text(doc) || '';
    const section = /^##\s+Deliverables\s*$([\s\S]*?)(?=^##\s|\Z)/m.exec(body);
    if (!section) continue;
    for (const line of section[1].split('\n')) if (/^\s*\|/.test(line)) rows.push(line);
  }
  const table = rows.join('\n');
  for (const p of paths) {
    r.checked += 1;
    if (!table.includes(p)) r.fails.push(`${p} is in no \`## Deliverables\` table`);
  }

  const corpus = SKILL_TREE.concat(AGENT_FILES, ASSET_FILES);
  const seen = new Map();
  for (const file of corpus) {
    for (const token of captures(/\b([A-Z][A-Z-]{3,}\.md)\b/g, text(file))) {
      if (!seen.has(token)) seen.set(token, []);
      seen.get(token).push(rel(file));
    }
  }
  for (const [token, where] of seen) {
    r.checked += 1;
    if (where.length === 1) r.warns.push(`${token} appears exactly once (${where[0]}) — likely a misspelling or a leftover`);
  }
  return r;
}

// 6. Every `Next` line points at an existing skill, /clear, /goal or a placeholder.
function rule6() {
  const r = result();
  for (const file of SKILL_TREE) {
    const body = text(file);
    if (body === null) continue;
    for (const line of body.split('\n')) {
      // The marker only opens a handoff when the em dash follows; prose *about* the line does not.
      const hit = /▶ Next\s*—/.exec(line);
      if (!hit) continue;
      r.checked += 1;
      const tail = line.slice(hit.index + hit[0].length);
      const cited = matches(/\bll-[a-z]+(?:-[a-z]+)*\b/g, tail).filter((c) => c !== 'll-tools');
      let ok = true;
      for (const cmd of cited) {
        if (!text(J(ROOT, 'skills', cmd, 'SKILL.md'))) {
          ok = false;
          r.fails.push(`${rel(file)}: Next names \`${cmd}\`, which is not a skill`);
        }
      }
      const anchored = cited.length > 0 || /\/clear|\/goal|<[^>]+>/.test(tail);
      if (!anchored) { ok = false; r.fails.push(`${rel(file)}: Next names no command —${tail.trim().slice(0, 60)}`); }
      refCount(file, ok);
    }
  }
  return r;
}

// Balanced array/object literal that follows `const <name>`.
function literal(src, name) {
  const start = src.indexOf('const ' + name);
  if (start < 0) return null;
  const eq = src.indexOf('=', start);
  if (eq < 0) return null;
  let depth = 0;
  for (let i = eq; i < src.length; i++) {
    const c = src[i];
    if (c === '[' || c === '{') depth += 1;
    else if (c === ']' || c === '}') { depth -= 1; if (depth === 0) return src.slice(eq + 1, i + 1); }
  }
  return null;
}
function quoted(block) { return uniq(captures(/'([^'\n]*)'/g, block || '')); }

// 7. The installer names only things the package ships, and `files` covers every shipped directory.
function rule7() {
  const r = result();
  const src = text(INSTALLER);
  if (src === null) { r.fails.push('bin/install.js is missing'); return r; }

  for (const skill of quoted(literal(src, 'HELPER_SKILLS'))) {
    r.checked += 1;
    if (!isDir(J(ROOT, 'skills', skill))) r.fails.push(`HELPER_SKILLS names ${skill}, missing under skills/`);
  }
  const hooks = captures(/file:\s*'([^']+)'/g, literal(src, 'SESSION_HOOKS') || '')
    .concat(captures(/file:\s*'([^']+)'/g, literal(src, 'PRECOMPACT_HOOK') || ''));
  for (const hook of uniq(hooks)) {
    r.checked += 1;
    if (text(J(ROOT, 'hooks', hook)) === null) r.fails.push(`hook ${hook} is registered by the installer but missing under hooks/`);
  }
  if (!hooks.length) r.fails.push('no hook file found in SESSION_HOOKS/PRECOMPACT_HOOK');

  for (const legacy of quoted(literal(src, 'KNOWN_LEGACY'))) {
    r.checked += 1;
    if (fs.existsSync(J(ROOT, legacy))) r.fails.push(`KNOWN_LEGACY names ${legacy}, which still exists in the tree`);
  }

  let pkg = null;
  try { pkg = JSON.parse(text(J(ROOT, 'package.json')) || '{}'); } catch { pkg = null; }
  const shipped = Array.isArray(pkg && pkg.files) ? pkg.files.map((f) => f.replace(/\/+$/, '')) : [];
  for (const dir of ['skills', 'agents', 'hooks', 'scripts', 'assets', 'bin']) {
    r.checked += 1;
    if (!shipped.includes(dir)) r.fails.push(`package.json "files" does not cover ${dir}/`);
  }
  return r;
}

const RULES = [
  { id: 1, name: 'references', run: rule1 },
  { id: 2, name: 'helper-commands', run: rule2 },
  { id: 3, name: 'agents', run: rule3 },
  { id: 4, name: 'verdict-vocabulary', run: rule4 },
  { id: 5, name: 'state-files', run: rule5 },
  { id: 6, name: 'next-targets', run: rule6 },
  { id: 7, name: 'installer-package', run: rule7 },
];

// ---------------------------------------------------------------------------
// main
// ---------------------------------------------------------------------------

function main() {
  const argv = process.argv.slice(2);
  const json = argv.includes('--json');
  const at = argv.indexOf('--rule');
  const only = at >= 0 ? Number(argv[at + 1]) : null;
  if (at >= 0 && !RULES.some((r) => r.id === only)) {
    process.stderr.write(`lint-contract: --rule takes one of 1..${RULES.length}\n`);
    process.exit(2);
  }
  const selected = only === null ? RULES : RULES.filter((r) => r.id === only);

  const report = [];
  let failed = 0;
  for (const rule of selected) {
    const out = rule.run();
    failed += out.fails.length;
    report.push({ rule: `${rule.id} ${rule.name}`, checked: out.checked, fails: out.fails, warns: out.warns });
  }
  // The table is built from every rule, so it is only complete on a full run.
  const table = Array.from(PIECES.entries())
    .map(([name, row]) => ({ piece: name, ok: row.ok, total: row.total }))
    .sort((a, b) => a.piece.localeCompare(b.piece));

  if (json) {
    process.stdout.write(JSON.stringify({ ok: failed === 0, root: ROOT, rules: report, pieces: table }) + '\n');
    process.exit(failed ? 1 : 0);
  }

  for (const rule of report) {
    if (!rule.fails.length) process.stdout.write(`ok   ${rule.rule} (${rule.checked} checked)\n`);
    for (const f of rule.fails) process.stdout.write(`FAIL ${rule.rule}: ${f}\n`);
    for (const w of rule.warns) process.stdout.write(`WARN ${rule.rule}: ${w}\n`);
  }
  if (only === null) {
    const width = table.reduce((n, row) => Math.max(n, row.piece.length), 5);
    process.stdout.write('\npiece' + ' '.repeat(width - 4) + 'refs ok/total\n');
    for (const row of table) {
      process.stdout.write(row.piece + ' '.repeat(width - row.piece.length + 1) + `${row.ok}/${row.total}\n`);
    }
  }
  process.stdout.write(`\n${failed ? 'FAIL' : 'ok'} — ${selected.length} rule(s), ${failed} violation(s)\n`);
  process.exit(failed ? 1 : 0);
}

main();
