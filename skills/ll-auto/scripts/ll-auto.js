#!/usr/bin/env node
// ll-auto helper — reads the cycle state from disk. Self-contained: `fs` and `path` only.
// Read commands never fail: on a broken input they print {"ok":false,"reason":…} and exit 0.
'use strict';
const fs = require('fs');
const path = require('path');
const J = path.join;
function readText(f) { try { return fs.readFileSync(f, 'utf8'); } catch { return null; } }
function isDir(p) { try { return fs.statSync(p).isDirectory(); } catch { return false; } }
function exists(p) { try { fs.statSync(p); return true; } catch { return false; } }
function ls(d) { try { return fs.readdirSync(d).sort(); } catch { return []; } }
function nn(v) { return String(v).trim().padStart(2, '0'); }

// --- state block reader, copied from scripts/ll-tools.js (<ll-shared:state>) -----------------
function readAnchoredBlock(file, name) {
  let txt;
  try { txt = fs.readFileSync(file, 'utf8'); } catch { return null; }
  const all = txt.split('\n');
  const open = new RegExp('^<!--\\s*' + name + '\\s*-->\\s*$');
  const close = new RegExp('^<!--\\s*/' + name + '\\s*-->\\s*$');
  let start = -1, end = -1;
  for (let i = 0; i < all.length; i++) {
    if (start < 0) { if (open.test(all[i])) start = i; } else if (close.test(all[i])) { end = i; break; }
  }
  if (start < 0 || end < 0) return null;
  return { file, start, end, all, lines: all.slice(start + 1, end) };
}
function llSplitFlow(str) { // top-level commas only
  const out = [];
  let cur = '', depth = 0, q = null;
  for (const ch of str) {
    if (q) { cur += ch; if (ch === q) q = null; continue; }
    if (ch === '"' || ch === "'") { q = ch; cur += ch; continue; }
    if (ch === '[' || ch === '{') depth++;
    else if (ch === ']' || ch === '}') depth--;
    else if (ch === ',' && depth === 0) { out.push(cur); cur = ''; continue; }
    cur += ch;
  }
  if (cur.trim() !== '') out.push(cur);
  return out;
}
function llScalar(raw) {
  const s = String(raw).trim();
  if (/^\[[\s\S]*\]$/.test(s)) return llSplitFlow(s.slice(1, -1)).map(llScalar);
  if (/^\{[\s\S]*\}$/.test(s)) {
    const o = {};
    for (const part of llSplitFlow(s.slice(1, -1))) {
      const m = /^\s*([A-Za-z_][\w-]*)\s*:\s*([\s\S]*)$/.exec(part);
      if (m) o[m[1]] = llScalar(m[2]);
    }
    return o;
  }
  if (/^(true|yes)$/i.test(s)) return true;
  if (/^(false|no)$/i.test(s)) return false;
  if (/^".*"$/.test(s) || /^'.*'$/.test(s)) return s.slice(1, -1);
  return s;
}
function parseStateBlockLite(bl) {
  const st = { phase: null, milestones: {}, order: [] };
  let inM = false;
  for (let i = 0; i < bl.length; i++) {
    const line = bl[i].replace(/\s+$/, '');
    if (!line.trim() || /^\s*#/.test(line)) continue;
    let m = /^phase:\s*(.*)$/.exec(line);
    if (m) { st.phase = String(llScalar(m[1])); inM = false; continue; }
    if (/^milestones:\s*(\{\s*\})?$/.test(line)) { inM = true; continue; }
    m = /^(\s*)(M\d+|G-\d+):\s*\{(.*)\}\s*$/.exec(line);
    if (m && inM) {
      st.milestones[m[2]] = llScalar('{' + m[3] + '}');
      st.order.push({ id: m[2], index: i, indent: m[1] });
    } else if (/^\S/.test(line)) inM = false;
  }
  return st;
}

// --- phase rows ------------------------------------------------------------------------------
// Rows of the ROADMAP phase table: a header carrying `phase` and numeric first cells.
function phaseRows(md) {
  const rows = [], seen = new Set();
  let cols = null;
  for (const line of String(md || '').split('\n')) {
    if (!/^\s*\|/.test(line)) { cols = null; continue; }
    const cells = line.trim().replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
    if (/^:?-{2,}/.test(cells[0] || '')) continue; // separator row
    if (!/^\d{1,3}$/.test(cells[0] || '')) { cols = cells.map((c) => c.toLowerCase()); continue; }
    if (!cols || cols.indexOf('phase') < 0) continue;
    const i = cols.indexOf('state');
    const id = nn(cells[0]);
    if (seen.has(id)) continue;
    seen.add(id);
    rows.push({ nn: id, state: (i >= 0 ? cells[i] : cells[cells.length - 1]) || '' });
  }
  return rows;
}
// Without ROADMAP.md the rows live in the `## §8 Phases` table of PLAN.md (`| NN | name | … |`,
// a header cell `phase` and, when there is one, a `state` cell); without PLAN.md there are no
// phases at all. The §8 slice runs to the next `## ` heading — `$` under /m ends at every line.
function rowsOf(root) {
  const rm = readText(J(root, 'ROADMAP.md'));
  if (rm !== null) return phaseRows(rm);
  const plan = readText(J(root, 'PLAN.md'));
  if (plan === null) return [];
  const h = /^##\s*§?8\b[^\n]*\n/m.exec(plan);
  if (!h) return [];
  const rest = plan.slice(h.index + h[0].length);
  const next = rest.search(/^##\s/m);
  return phaseRows(next < 0 ? rest : rest.slice(0, next));
}

// --- detect ----------------------------------------------------------------------------------
function phaseStage(root, row, ctx) {
  if (/^DONE/.test(row.state)) return { status: 'done', evidence: 'ROADMAP row: ' + row.state };
  const plan = 'phases/' + row.nn + '/PLAN.md';
  if (ctx.epilogues.has(row.nn)) {
    const own = ctx.state && nn(ctx.state.phase || '') === row.nn;
    const red = own ? Object.keys(ctx.state.milestones).filter((k) => ctx.state.milestones[k].passes !== true) : [];
    if (!own || red.length === 0) return { status: 'done', evidence: 'PROGRESS.md: ## Epilogue — phase ' + row.nn };
    if (exists(J(root, 'phases', row.nn, 'PLAN.md'))) {
      return { status: 'half', evidence: 'epilogue over a board with ' + red.join(', ') + ' not passing' };
    }
  }
  if (exists(J(root, 'phases', row.nn, 'PLAN.md'))) return { status: 'half', evidence: plan };
  return { status: 'todo', evidence: 'ROADMAP row: ' + (row.state || '-') };
}

function detect(root) {
  const stages = [];
  const add = (id, status, evidence) => stages.push({ id, status, evidence });
  const research = ls(J(root, 'docs')).filter((n) => /^research-/.test(n) && exists(J(root, 'docs', n, 'SUMMARY.md')));
  add('research', research.length ? 'done' : 'todo',
    research.length ? 'docs/' + research[0] + '/SUMMARY.md' : 'no docs/research-*/SUMMARY.md');

  const opening = exists(J(root, 'docs', 'decide', 'OPENING.md'));
  const decided = ls(J(root, 'phases')).filter((n) => exists(J(root, 'phases', n, 'DECISIONS.md')));
  add('brainstorm', opening || decided.length ? 'done' : 'todo',
    opening ? 'docs/decide/OPENING.md'
      : decided.length ? 'phases/' + decided[0] + '/DECISIONS.md' : 'no docs/decide/OPENING.md');

  const progress = J(root, 'PROGRESS.md');
  const block = readAnchoredBlock(progress, 'll-state');
  const state = block ? parseStateBlockLite(block.lines) : null;
  const hasPlan = exists(J(root, 'PLAN.md'));
  add('decide', hasPlan && state ? 'done' : 'todo',
    hasPlan && state ? 'PLAN.md + PROGRESS.md ll-state block'
      : hasPlan ? 'PROGRESS.md carries no ll-state block' : 'no PLAN.md at the root');
  const epilogues = new Set();
  for (const line of (readText(progress) || '').split('\n')) {
    const h = /^## Epilogue — phase (\S+)/.exec(line);
    if (h) epilogues.add(nn(h[1]));
  }
  const rows = rowsOf(root);
  const ctx = { epilogues, state };
  for (const row of rows) {
    const s = phaseStage(root, row, ctx);
    add('phase-' + row.nn, s.status, s.evidence);
  }
  for (const row of rows) {
    const v = 'phases/' + row.nn + '/VERIFICATION.md';
    const ok = exists(J(root, v));
    add('verify-' + row.nn, ok ? 'done' : 'todo', ok ? v : 'no ' + v);
  }
  const last = rows.length ? rows[rows.length - 1].nn : null;
  const delivery = exists(J(root, 'docs', 'DELIVERY.md'));
  const closed = delivery && last !== null && epilogues.has(last);
  add('close', closed ? 'done' : 'todo',
    closed ? 'docs/DELIVERY.md + epilogue for phase ' + last
      : delivery ? 'docs/DELIVERY.md without an epilogue for the last phase' : 'no docs/DELIVERY.md');
  return { ok: true, root, stages };
}

// --- next-cmd --------------------------------------------------------------------------------
// The handoff grammar of lint-contract rule 6: `▶ Next — /clear, then <cmd> (alternatives)`.
// Backticks are decoration; one trailing parenthetical is dropped. The last line in the file wins.
function nextCmdOf(txt) {
  let out = '';
  for (const line of String(txt || '').split('\n')) {
    const m = /▶ Next\s*—(.*)$/.exec(line);
    if (!m) continue;
    const hand = m[1].replace(/`/g, '').trim();
    const o = /^\/clear\s*,\s*then\s+(.*)$/.exec(hand);
    if (o) out = o[1].replace(/\([^()]*\)\s*$/, '').trim();
  }
  return out;
}
// The slice of PROGRESS.md owned by phase NN's epilogue; the whole file when it has none.
function epilogueText(root, id) {
  const txt = readText(J(root, 'PROGRESS.md')) || '';
  const lines = txt.split('\n');
  let start = -1;
  for (let i = 0; i < lines.length; i++) {
    const h = /^## Epilogue — phase (\S+)/.exec(lines[i]);
    if (h && nn(h[1]) === id) start = i;
  }
  if (start < 0) return txt;
  let end = lines.length;
  for (let i = start + 1; i < lines.length; i++) if (/^## /.test(lines[i])) { end = i; break; }
  return lines.slice(start, end).join('\n');
}

// --- roteiro ---------------------------------------------------------------------------------
const FLAG_ONE = { '--research': 'research', '--brainstorm': 'brainstorm', '--interactive': 'interactive',
  '--auto-decision': 'auto_decision', '--dry-run': 'dry_run', '--resume': 'resume' };
const FLAG_VAL = { '--pause-at': 'pause_at', '--redo': 'redo', '--from': 'from', '--to': 'to',
  '--only': 'only', '--verify': 'verify' };
// A stage reference in --pause-at / --redo: an id, a bare phase number, or `phase 7`.
function stageId(x) {
  const s = String(x || '').trim();
  if (/^\d{1,3}$/.test(s)) return 'phase-' + nn(s);
  const m = /^(phase|verify)[\s-]*(\d{1,3})$/.exec(s);
  return m ? m[1] + '-' + nn(m[2]) : s;
}
function parseFlags(str) {
  const f = { pause_at: [], redo: [], from: null, to: null, only: null, verify: null };
  for (const k of Object.values(FLAG_ONE)) f[k] = false;
  const t = String(str || '').trim().split(/\s+/).filter(Boolean);
  for (let i = 0; i < t.length; i++) {
    if (FLAG_ONE[t[i]]) { f[FLAG_ONE[t[i]]] = true; continue; }
    const k = FLAG_VAL[t[i]];
    if (!k) continue;
    const v = i + 1 < t.length && !/^--/.test(t[i + 1]) ? t[++i] : null;
    if (k === 'pause_at' || k === 'redo') { if (v !== null) f[k].push(v); } else f[k] = v;
  }
  if (f.only !== null) { f.from = f.only; f.to = f.only; } // --only N implies from = to = N
  return f;
}
const num = (x) => Number(String(x).replace(/[^\d.]/g, '')) || 0;
const talk = (interactive) => (interactive ? '' : ' --no-talk'); // --interactive drops --no-talk

function roteiro(root, flagStr, objective) {
  const d = detect(root);
  const f = parseFlags(flagStr);
  const st = {};
  for (const s of d.stages) st[s.id] = s;
  const redo = new Set(f.redo.map(stageId));
  const pause = new Set(f.pause_at.map(stageId));
  const obj = String(objective || '').trim();
  // Empty repository per D-03-06: no research, no OPENING.md, no PLAN.md.
  const bare = st.research.status === 'todo' && st.brainstorm.status === 'todo' && !exists(J(root, 'PLAN.md'));
  if (bare && !obj) return { ok: true, root, needs_objective: true, roteiro: [] };
  const out = [];
  const want = (id) => redo.has(id) || !st[id] || st[id].status !== 'done';
  const push = (id, command) => out.push({ stage: id, command,
    status: st[id] ? st[id].status : 'todo', pause_after: pause.has(id) });
  if (f.research && want('research')) push('research', 'll-research "' + (obj || '<objective>') + '"');
  if (f.brainstorm && want('brainstorm')) push('brainstorm', 'll-brainstorm project' + talk(f.interactive));
  if (want('decide')) push('decide', 'll-decide project --no-talk');
  const rows = rowsOf(root);
  const pend = rows.filter((r) => want('phase-' + r.nn));
  const inRange = (r) => (f.from === null || num(r.nn) >= num(f.from))
    && (f.to === null || num(r.nn) <= num(f.to));
  const kept = pend.filter(inRange);
  const half = (r) => st['phase-' + r.nn].status === 'half';
  for (const r of kept.filter(half).concat(kept.filter((r) => !half(r)))) { // a half phase resumes first
    push('phase-' + r.nn, 'll-implement ' + r.nn + talk(f.interactive));
    const asked = new RegExp('^ll-verify\\s+0*' + num(r.nn) + '$').test(nextCmdOf(epilogueText(root, r.nn)));
    if ((f.verify === 'all' || asked) && want('verify-' + r.nn)) push('verify-' + r.nn, 'll-verify ' + r.nn);
  }
  // Close only when the roteiro covers every phase still open: --only, --from or --to cut it out.
  if (f.only === null && kept.length === pend.length && want('close')) push('close', 'll-close --no-talk');
  return { ok: true, root, needs_objective: false, roteiro: out };
}

// --- report ----------------------------------------------------------------------------------
const MARK = '[decided by absence — revisable]';
function report(root) {
  const dir = J(root, 'decisions'), out = [];
  for (const name of ls(dir)) {
    if (!/\.md$/.test(name)) continue;
    const lines = (readText(J(dir, name)) || '').split('\n');
    const i = lines.findIndex((l) => l.indexOf(MARK) >= 0);
    if (i < 0) continue;
    const h = lines.find((l) => /^#\s+/.test(l)) || '';
    out.push({ file: 'decisions/' + name, title: h.replace(/^#\s+/, '').trim(), line: i + 1 });
  }
  return { ok: true, root, decisions: out };
}

// --- auto-md ---------------------------------------------------------------------------------
// The docs/AUTO.md body of D-03-07: objective, flags, the roteiro table, then two empty sections.
function autoMd(root, objective, flagStr) {
  const ev = {};
  for (const s of detect(root).stages) ev[s.id] = s.evidence;
  const r = roteiro(root, flagStr, objective);
  const L = ['# AUTO — autonomous run', '',
    '## Objective', '', String(objective || '').trim() || '<objective>', '',
    '## Flags', '', String(flagStr || '').trim() || '(none)', '',
    '## Roteiro', '', '| # | stage | command | status | evidence |', '|---|---|---|---|---|'];
  r.roteiro.forEach((e, i) => L.push('| ' + (i + 1) + ' | ' + e.stage + ' | ' + e.command + ' | '
    + e.status + ' | ' + (ev[e.stage] || '—') + ' |'));
  if (!r.roteiro.length) {
    L.push('| — | — | — | — | ' + (r.needs_objective ? 'no objective given' : 'nothing left to run') + ' |');
  }
  L.push('', '## Decisions taken alone', '', '(filled at the end of the run)', '',
    '## Log', '', '(one dated line per stage transition)');
  return { ok: true, root, markdown: L.join('\n') };
}

// --- cli -------------------------------------------------------------------------------------
function parseArgv(argv) {
  const flags = {}, pos = [];
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const kv = /^--([^=]+)=([\s\S]*)$/.exec(a);
    if (kv) { flags[kv[1]] = kv[2]; continue; }
    if (a === '--cwd' || a === '--flags' || a === '--objective') { flags[a.slice(2)] = argv[++i]; continue; }
    if (/^--/.test(a)) { flags[a.slice(2)] = true; continue; }
    pos.push(a);
  }
  return { flags, pos };
}
function rootOf(a) {
  const r = path.resolve(String(a.flags.cwd || process.cwd()));
  if (!isDir(r)) throw new Error('not a directory: ' + r);
  return r;
}
const C = {
  detect: (a) => detect(rootOf(a)),
  roteiro: (a) => roteiro(rootOf(a), a.flags.flags, a.flags.objective),
  'next-cmd': (a) => ({ ok: true, command: nextCmdOf(readText(path.resolve(a.pos[0] || ''))) }),
  report: (a) => report(rootOf(a)),
  'auto-md': (a) => autoMd(rootOf(a), a.flags.objective, a.flags.flags),
};
const FMT = {
  detect: (r) => r.stages.map((s) => s.id.padEnd(12) + ' ' + s.status.padEnd(5) + ' ' + s.evidence).join('\n'),
  roteiro: (r) => (r.needs_objective ? 'needs_objective'
    : r.roteiro.map((e, i) => (i + 1) + '. ' + e.stage.padEnd(12) + ' ' + e.command
      + (e.pause_after ? '  [pause]' : '')).join('\n')),
  'next-cmd': (r) => r.command,
  report: (r) => r.decisions.map((d) => d.file + ':' + d.line + '  ' + d.title).join('\n'),
  'auto-md': (r) => r.markdown,
};

function main() {
  const argv = process.argv.slice(2), cmd = argv[0];
  try {
    if (!C[cmd]) throw new Error('usage: ll-auto.js <' + Object.keys(C).join('|') + '> [args] [--cwd <dir>] [--json]');
    const a = parseArgv(argv.slice(1));
    const res = C[cmd](a);
    process.stdout.write((a.flags.json || !FMT[cmd] ? JSON.stringify(res) : FMT[cmd](res)) + '\n');
  } catch (e) {
    process.stdout.write(JSON.stringify({ ok: false, reason: (e && e.message) || String(e) }) + '\n');
  }
  process.exit(0);
}
main();
