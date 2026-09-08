#!/usr/bin/env node
'use strict';
// ll-tools.js — ll-skills helper. Node >= 18, no deps. Reads exit 0 with {"ok":false,...} on failure; writes exit 1 on error.

const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { execFileSync, spawnSync } = require('child_process');
const J = path.join, REL = path.relative;
const JUNK = new RegExp('[\\u0000-\\u0008\\u000B-\\u001F\\u007F-\\u009F\\u200B-\\u200F'
 + '\\u2028\\u2029\\u202A-\\u202E\\u2060-\\u2064\\uFEFF]', 'g');
const NUL = String.fromCharCode(0), DASH = '—';

function sz(v) {
 if (v === null || typeof v !== 'object') return typeof v === 'string' ? v.replace(JUNK, '').trim() : v;
 if (Array.isArray(v)) return v.map(sz);
 const o = {};
 for (const k of Object.keys(v)) o[k] = sz(v[k]);
 return o;
}
function die(m) { throw new Error(m); }
function shaFile(f) { try { return crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex'); } catch { return null; } }
function readText(f) { try { return fs.readFileSync(f, 'utf8'); } catch { return null; } }
function writeAtomic(f, t) { const p = f + '.ll-tmp-' + process.pid; fs.writeFileSync(p, t); fs.renameSync(p, f); }
function nowIso() { return new Date().toISOString().replace(/\.\d+Z$/, 'Z'); }
function uniq(a) { return Array.from(new Set(a)); }
function has(d, n) { return fs.existsSync(J(d, n)); }
function blank(s) { return !s || /^[-—]+$/.test(s); }
function lines(s) { return s.split('\n').filter((l) => l.trim()); }
function listOf(m, k) { return Array.isArray(m[k]) ? m[k].map(String) : []; }

const VALF = ['since', 'files', 'prefix', 'reason', 'commit', 'state', 'file', 'dir', 'cwd'];
const BOOLF = ['json', 'run'];
function parseArgv(argv) {
 const r = { _: [], flags: {} };
 for (let i = 0; i < argv.length; i++) {
  const t = argv[i];
  if (t === '--') { r._.push(...argv.slice(i + 1)); break; }
  if (!t.startsWith('--')) { r._.push(t); continue; }
  let k = t.slice(2), v = null;
  const eq = k.indexOf('=');
  if (eq >= 0) { v = k.slice(eq + 1); k = k.slice(0, eq); }
  if (BOOLF.indexOf(k) >= 0) r.flags[k] = true;
  else if (VALF.indexOf(k) < 0) die('unknown flag --' + k);
  else if (v === null && (v = argv[++i]) === undefined) die('flag --' + k + ' needs a value');
  else r.flags[k] = v;
 }
 return r;
}

const SKIP_DOWN = new Set(['node_modules', '.git', 'dist', 'build', 'vendor']);
function findDown(base, name, maxDepth) {
 const out = [];
 const walk = (dir, depth) => {
  if (has(dir, name)) out.push(dir);
  if (depth >= maxDepth) return;
  let ents;
  try { ents = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
  for (const e of ents) {
   if (!e.isDirectory() || SKIP_DOWN.has(e.name)) continue;
   const rel = REL(base, J(dir, e.name));
   if (rel === J('docs', 'history') || rel.indexOf(J('docs', 'history') + path.sep) === 0) continue;
   walk(J(dir, e.name), depth + 1);
  }
 };
 walk(base, 0);
 return out;
}
function rootOf(a, strict) {
 const cwd = a.flags.cwd ? path.resolve(a.flags.cwd) : process.cwd();
 const proj = (d) => d && (has(d, 'PROGRESS.md') || has(d, 'phases'));
 let dir = cwd, root = null;
 for (; !root; dir = path.dirname(dir)) {
  if (proj(dir)) root = dir;
  else if (path.dirname(dir) === dir) break;
 }
 let cands = [];
 if (!root) {
  const top = git(['rev-parse', '--show-toplevel'], cwd).trim() || null;
  cands = findDown(top || cwd, 'PROGRESS.md', 3);
  root = cands.length === 1 ? cands[0] : top || null;
 }
 if (!root || (strict && !proj(root))) {
  die(cands.length > 1 ? 'no PROGRESS.md at ' + cwd + '; displaced candidates: ' + cands.join(', ')
   : 'no PROGRESS.md and no phases/ in ' + cwd);
 }
 return root;
}
function resolveIn(root, p, fb) {
 const t = p || fb || die('missing file argument');
 return path.isAbsolute(t) ? t : J(root, t);
}

function git(args, cwd) {
 try { return execFileSync('git', args, { cwd, timeout: 3000, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }); } catch { return ''; }
}
function gitTop(root) { return git(['rev-parse', '--show-toplevel'], root).trim() || root; }
function gitLog(root, extra) {
 const args = ['log', '--no-merges', '--date=short', '--format=%H%x00%ad%x00%s'].concat(extra || []);
 return lines(git(args, root)).map((l) => l.split(NUL)).filter((p) => p.length >= 3)
  .map((p) => ({ sha7: p[0].slice(0, 7), date: p[1], subject: p.slice(2).join(NUL) }));
}
function gitInfo(root) {
 return { branch: git(['rev-parse', '--abbrev-ref', 'HEAD'], root).trim() || null,
  dirty: lines(git(['status', '--porcelain'], root)).length,
  worktrees: lines(git(['worktree', 'list'], root)).length };
}

// <ll-shared:state>
// Copied verbatim into hooks/ll-state.js. Self-contained: only `fs` and `path`.
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
    if (/^milestones:\s*$/.test(line)) { inM = true; continue; }
    m = /^(\s*)(M\d+|G-\d+):\s*\{(.*)\}\s*$/.exec(line);
    if (m && inM) {
      st.milestones[m[2]] = llScalar('{' + m[3] + '}');
      st.order.push({ id: m[2], index: i, indent: m[1] });
    } else if (/^\S/.test(line)) inM = false;
  }
  return st;
}
function boardFromState(st) {
  const ids = Object.keys((st && st.milestones) || {});
  const passed = ids.filter((i) => st.milestones[i].passes === true).length;
  return { phase: st ? st.phase : null, passed, total: ids.length, list: ids,
    text: 'phase ' + ((st && st.phase) || '?') + ' · milestones ' + passed + '/' + ids.length };
}
// </ll-shared:state>

function parseMiniYaml(src) {
 const root = {};
 let seq = null, item = null, ind = -1;
 for (let i = 0; i < src.length; i++) {
  const raw = src[i].replace(/\s+$/, '');
  if (!raw.trim() || /^\s*#/.test(raw)) continue;
  const at = raw.length - raw.replace(/^\s+/, '').length;
  const body = raw.trim(), isItem = body.startsWith('- ');
  const kv = /^([A-Za-z_][\w-]*)\s*:\s*([\s\S]*)$/.exec(isItem ? body.slice(2).trim() : body);
  if (!kv) die('yaml line ' + (i + 1) + ': unparsable');
  if (isItem) {
   if (!seq) die('yaml line ' + (i + 1) + ': item outside a key');
   item = { __line: i + 1 };
   seq.push(item); ind = at;
  } else if (at === 0) {
   seq = null; item = null;
   if (kv[2].trim() === '') { root[kv[1]] = []; seq = root[kv[1]]; } else root[kv[1]] = llScalar(kv[2]);
   continue;
  } else if (!item || at <= ind) die('yaml line ' + (i + 1) + ': bad indentation');
  item[kv[1]] = llScalar(kv[2]);
 }
 return root;
}

function loadMilestones(f) {
 const blk = readAnchoredBlock(f, 'll-milestones') || die('no ll-milestones block in ' + f);
 const list = parseMiniYaml(blk.lines).milestones;
 if (!Array.isArray(list) || !list.length) die('no milestones in the block');
 return { block: blk, milestones: list };
}
function loadStateBlock(root) {
 const file = J(root, 'PROGRESS.md');
 const blk = readAnchoredBlock(file, 'll-state');
 return blk ? { file, block: blk, state: parseStateBlockLite(blk.lines) } : null;
}
function mdTable(text) {
 let header = null;
 const rows = [];
 text.split('\n').forEach((l, i) => {
  if (!/^\s*\|/.test(l)) return;
  const cells = l.trim().replace(/^\|/, '').replace(/\|$/, '').split('|').map((c) => c.trim());
  if (cells.every((c) => /^:?-{2,}:?$/.test(c))) return;
  if (!header) header = cells.map((c) => c.toLowerCase());
  else rows.push({ cells, index: i });
 });
 return { header: header || [], rows };
}
function col(h, n) { return h.findIndex((x) => x.indexOf(n) >= 0); }
function waiting(root) {
 let names = [];
 try { names = fs.readdirSync(J(root, 'decisions')).sort(); } catch { return []; }
 return names.filter((n) => /\.md$/.test(n) && /WAITING/.test(readText(J(root, 'decisions', n)) || ''))
  .map((n) => ({ id: (/^([A-Za-z]+-\d+)/.exec(n) || [null, n])[1], file: J('decisions', n) }));
}
function commitRe(id) {
 const e = String(id).replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
 return { full: new RegExp('^(test|feat|refactor)\\(' + e + '\\): '), loose: new RegExp('\\(' + e + '\\)') };
}
function kahn(dep) {
 const layers = [], done = new Set();
 let pool = Array.from(dep.keys());
 while (pool.length) {
  const layer = pool.filter((i) => dep.get(i).every((d) => done.has(d)));
  if (!layer.length) break;
  layer.forEach((i) => done.add(i));
  layers.push(layer);
  pool = pool.filter((i) => !done.has(i));
 }
 return { layers, left: pool };
}

const C = {};

C.waves = (a) => {
 const root = rootOf(a), by = new Map(), dx = [];
 for (const m of loadMilestones(resolveIn(root, a._[0])).milestones) {
  const id = m.id === undefined ? null : String(m.id);
  if (!id) dx.push({ type: 'id-missing', line: m.__line });
  else if (by.has(id)) dx.push({ type: 'id-duplicate', milestone: id, line: m.__line });
  else by.set(id, m);
 }
 const deps = new Map();
 for (const id of by.keys()) {
  const keep = [];
  for (const d of listOf(by.get(id), 'depends_on')) {
   if (d === id) dx.push({ type: 'cycle', milestone: id, depends_on: d });
   else if (!by.has(d)) dx.push({ type: 'unknown_depends_on', milestone: id, depends_on: d });
   else keep.push(d);
  }
  deps.set(id, uniq(keep));
 }
 const { layers, left } = kahn(deps);
 if (left.length) dx.push({ type: 'cycle', milestones: left });
 const st = (loadStateBlock(root) || { state: { milestones: {} } }).state.milestones;
 const isRoot = (id) => {
  const e = st[id];
  if (e && (e.state === 'ANSWERED_NO' || e.state === 'BLOCKED')) return true;
  return by.get(id).stop === 'owner' && !(e && e.passes === true);
 };
 const bl = new Map(), blocked_by = {};
 for (const layer of layers) for (const id of layer) {
  const set = new Set();
  for (const d of deps.get(id)) for (const r of bl.get(d) || []) set.add(r);
  if (isRoot(id)) set.add(id);
  bl.set(id, Array.from(set).sort());
  if (bl.get(id).length) blocked_by[id] = bl.get(id);
 }
 const files = (m) => listOf(m, 'files').map((f) => path.posix.normalize(f.trim()));
 const waves = layers.map((layer, w) => {
  for (let x = 0; x < layer.length; x++) for (let y = x + 1; y < layer.length; y++) {
   const A = by.get(layer[x]), B = by.get(layer[y]), pair = [layer[x], layer[y]];
   const bf = files(B), sf = files(A).filter((f) => bf.indexOf(f) >= 0);
   if (sf.length) dx.push({ type: 'file_overlap', wave: w + 1, milestones: pair, files: sf });
   const be = listOf(B, 'exclusive'), se = listOf(A, 'exclusive').filter((f) => be.indexOf(f) >= 0);
   if (se.length) dx.push({ type: 'exclusive_conflict', wave: w + 1, milestones: pair, resources: se });
  }
  return { wave: w + 1, milestones: layer, builds: layer.map((id) => by.get(id).name || id),
   blocked: layer.filter((id) => blocked_by[id]) };
 });
 return { ok: true, waves, defects: dx, blocked_by, unscheduled: left };
};

C['tdd-gate'] = (a) => {
 const root = rootOf(a), id = a._[0] || die('missing milestone id'), re = commitRe(id).full;
 let test = null, feat = null;
 gitLog(root, a.flags.since ? [a.flags.since + '..HEAD'] : null).reverse().forEach((e, i) => {
  const m = re.exec(e.subject);
  if (!m) return;
  if (m[1] !== 'feat' && !test) test = { sha7: e.sha7, type: m[1], pos: i };
  if (m[1] === 'feat' && !feat) feat = { sha7: e.sha7, type: m[1], pos: i };
 });
 let tdd = 'fail', reason;
 if (!test && !feat) reason = 'no anchored commit for ' + id;
 else if (!test) reason = 'feat with no preceding test commit';
 else if (feat && feat.pos < test.pos) reason = 'feat lands before test';
 else { tdd = 'pass'; reason = feat ? 'test precedes feat' : 'test present, no feat yet'; }
 const s = (c) => (c ? { sha7: c.sha7, type: c.type } : null);
 return { ok: true, milestone: id, tdd, test: s(test), feat: s(feat), reason };
};

C['spot-check'] = (a) => {
 const root = rootOf(a), top = gitTop(root), id = a._[0] || die('missing milestone id');
 const exp = String(a.flags.files || '').split(',').map((s) => s.trim()).filter(Boolean);
 if (!exp.length) die('missing --files a,b');
 const miss = exp.filter((f) => !fs.existsSync(resolveIn(top, f))), re = commitRe(id).loose;
 const shas = gitLog(root).filter((e) => re.test(e.subject)).map((e) => e.sha7);
 return { ok: true, milestone: id, verdict: !miss.length && shas.length ? 'pass' : 'fail',
  files: { expected: exp.length, found: exp.length - miss.length, missing: miss },
  commits: { count: shas.length, shas } };
};

C['dec-reserve'] = (a) => {
 const root = rootOf(a), n = parseInt(a._[0], 10);
 if (!Number.isInteger(n) || n < 1 || n > 50) die('count must be 1..50');
 const rel = a.flags.dir || 'decisions';
 fs.mkdirSync(J(root, rel), { recursive: true });
 const names = fs.readdirSync(J(root, rel));
 let pre = a.flags.prefix;
 if (!pre) {
  const counts = new Map();
  for (const name of names) {
   const m = /^([A-Z]+(?:-[A-Z]+)*)-(\d+)/.exec(name);
   if (m) counts.set(m[1], (counts.get(m[1]) || 0) + 1);
  }
  let best = null;
  for (const [p, c] of counts) if (!best || c > best.c || (c === best.c && p.length < best.p.length)) best = { p, c };
  pre = best ? best.p : 'DEC';
 }
 const re = new RegExp('^' + pre + '-(\\d+)');
 let max = 0, width = 4, hit = false;
 for (const name of names) {
  const m = re.exec(name);
  if (!m) continue;
  const num = parseInt(m[1], 10);
  if (!hit || num >= max) { max = num; width = a.flags.prefix ? 4 : m[1].length; hit = true; }
 }
 const ids = [], files = [];
 for (let i = 1; i <= n; i++) {
  const id = pre + '-' + String(max + i).padStart(width, '0'), r = J(rel, id + '-reserved.md');
  if (has(root, r)) die('id collision: ' + r);
  writeAtomic(J(root, r), `# ${id} ${DASH} reserved\n\n- status: RESERVED at ${nowIso()}\n`);
  ids.push(id); files.push(r);
 }
 return { ok: true, ids, files, prefix: pre, width };
};

const ORDER = ['passes', 'commit', 'accepted_at', 'state', 'reason', 'propagates_to'];
function outScalar(v) {
 if (Array.isArray(v)) return '[' + v.map(outScalar).join(', ') + ']';
 if (typeof v === 'boolean') return String(v);
 return /[\s,{}[\]]/.test(String(v)) ? JSON.stringify(String(v)) : String(v);
}
function stateLine(indent, id, f) {
 const keys = ORDER.concat(Object.keys(f).filter((k) => ORDER.indexOf(k) < 0));
 return indent + id + ': { ' + keys.filter((k) => f[k] !== undefined && f[k] !== null && f[k] !== '')
  .map((k) => k + ': ' + outScalar(f[k])).join(', ') + ' }';
}

C.passes = (a) => {
 const root = rootOf(a, true), id = a._[0] || die('missing milestone id');
 if (!/^(M\d+|G-\d+)$/.test(id)) die('bad milestone id: ' + id);
 const arg = String(a._[1] || '').toLowerCase();
 if (arg !== 'true' && arg !== 'false') die('expected true|false');
 const value = arg === 'true';
 if (!value && !a.flags.reason) die('passes <M> false requires --reason');
 const { block, state } = loadStateBlock(root) || die('no ll-state block in PROGRESS.md');
 const all = block.all.slice(), old = state.order.find((o) => o.id === id);
 const f = old ? Object.assign({}, state.milestones[id]) : {};
 f.passes = value;
 if (value) {
  delete f.reason; delete f.state;
  f.commit = a.flags.commit || git(['rev-parse', '--short=7', 'HEAD'], root).trim() || 'unknown';
  f.accepted_at = nowIso();
 } else {
  delete f.commit; delete f.accepted_at;
  f.reason = a.flags.reason;
  if (a.flags.state) f.state = a.flags.state;
 }
 let created = false, at;
 if (old) {
  at = block.start + 1 + old.index;
  all[at] = stateLine(old.indent, id, f);
 } else {
  created = true;
  let anchor = -1;
  for (let i = block.start + 1; i < block.end; i++) if (/^milestones:\s*$/.test(all[i].trim())) { anchor = i; break; }
  if (anchor < 0) die('no `milestones:` key in the ll-state block');
  at = state.order.reduce((acc, o) => Math.max(acc, block.start + 2 + o.index), anchor + 1);
  all.splice(at, 0, stateLine(state.order.length ? state.order[0].indent : '  ', id, f));
 }
 writeAtomic(block.file, all.join('\n'));
 const b = boardFromState(loadStateBlock(root).state);
 return { ok: true, milestone: id, passes: value, line: at + 1, created, board: { passed: b.passed, total: b.total } };
};

C.state = (a) => {
 const root = rootOf(a, true), top = gitTop(root), sb = loadStateBlock(root);
 const b = boardFromState(sb ? sb.state : null), log = gitLog(root);
 const plan = b.phase ? J('phases', b.phase, 'PLAN.md') : null;
 return { ok: true, root, git_top: top, phase: b.phase,
  milestones: { total: b.total, passed: b.passed, list: b.list },
  last_commit: log.length ? { sha7: log[0].sha7, date: log[0].date } : null,
  git: gitInfo(root), waiting: waiting(root),
  epilogue_present: /^## Epilogue/m.test(readText(J(root, 'PROGRESS.md')) || ''),
  active_phase_plan: plan && has(root, plan) ? plan : null };
};

C.heartbeat = (a) => {
 const root = rootOf(a, true), text = sz(a._.join(' ')) || die('missing text');
 const file = J(root, a.flags.file || 'PROGRESS.md'), body = readText(file);
 if (body === null) die('cannot read ' + file);
 const out = body.split('\n'), line = '- [' + nowIso() + '] ' + text;
 let at = out.findIndex((l) => /^## Epilogue/.test(l));
 if (at >= 0) out.splice(at, 0, line, '');
 else {
  while (out.length && out[out.length - 1].trim() === '') out.pop();
  out.push(line, '');
  at = out.length - 2;
 }
 writeAtomic(file, out.join('\n'));
 return { ok: true, file: REL(root, file), line: at + 1, text };
};

C.ledger = (a) => {
 const root = rootOf(a), top = gitTop(root), file = resolveIn(root, a._[0] || a.flags.file, 'VERIFICATION.md');
 const txt = readText(file);
 if (txt === null) die('cannot read ' + file);
 const { header, rows } = mdTable(txt);
 const iF = col(header, 'file'), iS = col(header, 'sha'), iT = col(header, 'state');
 if (!rows.length || iF < 0 || iS < 0) die('no ledger table with file/sha columns');
 const criteria = [], summary = { FRESH: 0, STALE: 0, UNKNOWN: 0 };
 for (const r of rows) {
  const id = sz(r.cells[0]);
  if (blank(id)) continue;
  const ref = sz(r.cells[iF] || ''), m = /^(.*?):(\d+)$/.exec(ref);
  const rel = m ? m[1] : blank(ref) ? null : ref;
  let rec = sz(r.cells[iS] || '').replace(/^sha256:/i, '').replace(/[….]+$/, '');
  if (!/^[0-9a-f]{8,64}$/i.test(rec)) rec = null;
  const act = rel ? shaFile(resolveIn(top, rel)) : null;
  const fr = rec && act ? (act.slice(0, rec.length) === rec.toLowerCase() ? 'FRESH' : 'STALE') : 'UNKNOWN';
  summary[fr]++;
  criteria.push({ id, file: rel, line: m ? parseInt(m[2], 10) : null, recorded: rec,
   actual: act ? act.slice(0, 12) : null, freshness: fr, state: iT >= 0 ? sz(r.cells[iT]) : null });
 }
 return { ok: true, file: REL(root, file), criteria, summary };
};

C['backlog-reconcile'] = (a) => {
 const root = rootOf(a), top = gitTop(root), file = resolveIn(root, a._[0] || a.flags.file, 'BACKLOG.md');
 const txt = readText(file);
 if (txt === null) die('cannot read ' + file);
 const { header, rows } = mdTable(txt);
 const iC = col(header, 'condition'), iS = col(header, 'state');
 if (!rows.length || iC < 0 || iS < 0) die('no backlog table with condition/state cols');
 const run = !!a.flags.run, out = txt.split('\n'), items = [], closed = [];
 let spent = 0;
 for (const r of rows) {
  const id = sz(r.cells[0]);
  if (blank(id)) continue;
  const state = sz(r.cells[iS]).toUpperCase(), raw = sz(r.cells[iC]);
  const m = /^`([^`]+)`\s*(?:exit\s+(-?\d+)|=\s*(.+))$/.exec(raw);
  const it = { id, state, condition: m ? m[1] : raw, ran: false, exit: null,
   expect: m ? (m[2] !== undefined ? { kind: 'exit', value: Number(m[2]) } : { kind: 'stdout', value: sz(m[3]) }) : null,
   result: m ? null : 'unparsable-condition' };
  if (run && state === 'OPEN' && m) {
   if (spent >= 600000) it.skipped = 'budget';
   else {
    const t0 = Date.now();
    const p = spawnSync('bash', ['-c', it.condition], { cwd: top, timeout: 120000, encoding: 'utf8' });
    spent += Date.now() - t0;
    it.ran = true;
    it.exit = p.status === null ? 124 : p.status;
    const green = it.expect.kind === 'exit' ? it.exit === it.expect.value : sz(String(p.stdout || '')) === String(it.expect.value);
    it.result = green ? 'closed' : 'still-open';
    if (green) closed.push({ id, index: r.index });
   }
  }
  items.push(it);
 }
 if (run && closed.length) {
  for (const c of closed) {
   const parts = out[c.index].split('|');
   if (parts[iS + 1] !== undefined) parts[iS + 1] = parts[iS + 1].replace(/\bOPEN\b/, 'CLOSED');
   out[c.index] = parts.join('|');
  }
  writeAtomic(file, out.join('\n'));
 }
 return { ok: true, file: REL(root, file), run, items, closed: closed.map((c) => c.id),
  open: items.filter((i) => i.state === 'OPEN' && i.result !== 'closed').length };
};

C.epilogue = (a) => {
 const root = rootOf(a, true);
 const sb = loadStateBlock(root) || die('no ll-state block in PROGRESS.md');
 const phase = String(a._[0] || sb.state.phase || die('missing phase argument'));
 const ms = sb.state.milestones, pad = phase.padStart(2, '0');
 const plan = J(root, 'phases', pad, 'PLAN.md');
 let blocked_by = {}, backlog = [], next = null;
 try { if (fs.existsSync(plan)) blocked_by = C.waves({ _: [plan], flags: { cwd: root } }).blocked_by; } catch {}
 try {
  backlog = C['backlog-reconcile']({ _: [], flags: { cwd: root } }).items
   .filter((i) => i.state === 'OPEN').map((i) => i.id);
 } catch {}
 const roadmap = readText(J(root, 'ROADMAP.md'));
 if (roadmap) {
  const ns = mdTable(roadmap).rows.map((r) => Number(sz(r.cells[0]))).filter((n) => Number.isFinite(n) && n > Number(phase));
  if (ns.length) next = Math.min(...ns);
 }
 const log = gitLog(root);
 const why = (k) => sz(ms[k].state ? ms[k].state + ': ' + (ms[k].reason || '') : ms[k].reason || 'not accepted yet');
 return { ok: true, phase: pad,
  passed: Object.keys(ms).filter((k) => ms[k].passes === true),
  left: Object.keys(ms).filter((k) => ms[k].passes !== true).map((k) => ({ id: k, why: why(k) })),
  waiting: waiting(root), new_backlog: backlog, dirty: gitInfo(root).dirty,
  head: log.length ? log[0].sha7 : null, blocked_by,
  next_command: next !== null ? 'll-implement ' + next : 'll-close' };
};

const TARGETS = { questions_per_phase: 4, owner_prompts_per_phase: 1, band1_open_at_close: 0 };
function phaseEpilogues(root) {
 const all = (readText(J(root, 'PROGRESS.md')) || '').split('\n'), out = [];
 let prev = 0;
 all.forEach((l, i) => {
  const h = /^## Epilogue — phase (\S+)/.exec(l);
  if (!h) return;
  const op = all.slice(prev, i).filter((x) => /^- \[[^\]]+\] owner:/.test(x)).length; prev = i; // owner heartbeats since the prior epilogue
  const m = /milestones passed (\d+)\/(\d+) · questions asked (\d+) \/ assumptions (\d+)[^/]*\/ band-1 open (\d+)[^·]*· amendments (\d+) · verification:\s*(\S+)\s+(\S+)/.exec(all.slice(i).join('\n'));
  out.push(m ? { phase: h[1], passed: +m[1], total: +m[2], questions: +m[3], assumptions: +m[4], band1_open: +m[5],
   amendments: +m[6], verdict: m[8], verification: m[7], owner_prompts: op } : { phase: h[1], count_line: false, owner_prompts: op });
 });
 return out;
}

C['phase-stats'] = (a) => {
 const root = rootOf(a), es = gitLog(root, a.flags.since ? ['--since=' + a.flags.since] : null);
 const days = uniq(es.map((e) => e.date)).sort(), by_type = {};
 for (const e of es) {
  const m = /^([a-z]+)(\([^)]*\))?!?:/.exec(e.subject), t = m ? m[1] : 'other';
  by_type[t] = (by_type[t] || 0) + 1;
 }
 const day = (d) => Date.parse(d + 'T00:00:00Z');
 const span = days.length >= 2 ? Math.round((day(days[days.length - 1]) - day(days[0])) / 864e5) + 1 : days.length;
 const t = by_type.test || 0, f = by_type.feat || 0;
 return { ok: true, days_with_work: days.length, span_days: span, commits: es.length, by_type,
  idle_days: Math.max(0, span - days.length), test_feat_ratio: f ? Math.round((t / f) * 100) / 100 : null,
  phases: phaseEpilogues(root), targets: TARGETS };
};

const E = 'error', W = 'warn';
const CMD_RE = /^(`|\.\/|npm|pnpm|yarn|node|bash|sh |make|cargo|go |python|pytest|jest|vitest|docker|curl|git)/;
const ENUMS = { stop: 'none|owner', verification: 'internal|external' };
const RULES = [
 ['files-missing', E, (m) => m.files === undefined],
 ['files-not-list', E, (m) => m.files !== undefined && !Array.isArray(m.files)],
 ['files-too-many', W, (m) => Array.isArray(m.files) && m.files.length > 5],
 ['acceptance-missing', E, (m) => !m.acceptance],
 ['acceptance-not-command', W, (m) => m.acceptance && !CMD_RE.test(String(m.acceptance).trim())],
 ['tdd-invalid', E, (m) => m.tdd !== undefined && typeof m.tdd !== 'boolean'],
 ['model-format', W, (m) => m.model !== undefined && !/^[a-z0-9.-]+\/[a-z]+$/.test(m.model)],
 ['truths-missing', W, (m) => !Array.isArray(m.truths) || !m.truths.length],
];

C['plan-lint'] = (a) => {
 const root = rootOf(a), pf = resolveIn(root, a._[0], 'PLAN.md'), dx = [], skipped = [];
 const add = (rule, severity, milestone, line, message) => dx.push({ rule, severity, milestone, line, message });
 const done = () => {
  const error = dx.filter((d) => d.severity === E).length;
  return { ok: true, file: REL(root, pf), defects: dx, skipped,
   verdict: error ? 'fail' : dx.length ? W : 'pass', summary: { error, warn: dx.length - error } };
 };
 const blk = readAnchoredBlock(pf, 'll-milestones');
 if (!blk) { add('block-missing', E, null, null, 'no ll-milestones block'); return done(); }
 if (blk.lines.length > 80) add('block-too-long', W, null, blk.start + 1, blk.lines.length + ' lines (>80)');
 let list;
 try { list = parseMiniYaml(blk.lines).milestones; } catch (e) { add('block-unparsable', E, null, null, sz(e.message)); return done(); }
 if (!Array.isArray(list) || !list.length) { add('block-unparsable', E, null, null, 'no milestones'); return done(); }
 const body = readText(pf) || '';
 const ids = new Set(list.map((m) => String(m.id))), seen = new Set(), dep = new Map();
 for (const m of list) {
  const id = m.id === undefined ? null : String(m.id), ln = blk.start + 1 + (m.__line || 0);
  if (!id || !/^(M\d+|G-\d+)$/.test(id)) { add('id-format', E, id, ln, 'id is not M<n>/G-<n>'); continue; }
  if (seen.has(id)) add('id-duplicate', E, id, ln, 'duplicate id');
  seen.add(id);
  for (const r of RULES) if (r[2](m)) add(r[0], r[1], id, ln, r[0]);
  for (const k of Object.keys(ENUMS)) {
   if (m[k] !== undefined && !new RegExp('^(' + ENUMS[k] + ')$').test(String(m[k]))) add(k + '-invalid', E, id, ln, k + ' is not ' + ENUMS[k]);
  }
  if (m.depends_on !== undefined && !Array.isArray(m.depends_on)) add('depends_on-unknown', E, id, ln, 'depends_on not a list');
  for (const d of listOf(m, 'depends_on')) {
   if (d === id) add('depends_on-self', E, id, ln, 'depends on itself');
   else if (!ids.has(d)) add('depends_on-unknown', E, id, ln, 'unknown depends_on ' + d);
  }
  dep.set(id, listOf(m, 'depends_on').filter((d) => ids.has(d)));
  if (!new RegExp('^###\\s+' + id.replace(/-/g, '\\-') + '\\b', 'm').test(body)) add('body-section-missing', W, id, ln, 'no `### ' + id + '` section');
 }
 for (const id of kahn(dep).left) add('depends_on-cycle', E, id, null, 'inside a dependency cycle');
 const proj = readText(J(root, 'PLAN.md'));
 if (!proj || path.resolve(pf) === path.resolve(root, 'PLAN.md')) skipped.push('truth-orphan');
 else {
  const sec = /^##\s*§?1[\s\S]*?(?=^##\s)/m.exec(proj);
  const known = new Set((sec ? sec[0] : proj).match(/\bT\d+\b/g) || []);
  for (const m of list) for (const t of listOf(m, 'truths')) {
   if (!known.has(t)) add('truth-orphan', E, String(m.id), null, 'unknown truth ' + t);
  }
 }
 return done();
};

const S = ' · ';
const j = (...p) => p.filter((x) => x !== null && x !== '').join(S);
const or = (v) => (v && v.length ? v : 'none');
const FMT = {
  waves: (r) => j(`waves ${r.waves.length}`, r.waves.map((w) => `w${w.wave} ${w.milestones}`).join(S),
    `defects ${r.defects.length}`, `blocked ${Object.keys(r.blocked_by).length}`,
    r.unscheduled.length ? `unscheduled ${r.unscheduled}` : ''),
  'tdd-gate': (r) => j(`tdd ${r.tdd}`, r.milestone, `test ${r.test ? r.test.sha7 : DASH}`,
    `feat ${r.feat ? r.feat.sha7 : DASH}`, r.reason),
  'spot-check': (r) => j(r.verdict, `files ${r.files.found}/${r.files.expected}`, `commits ${r.commits.count}`,
    r.files.missing.length ? `missing ${r.files.missing}` : ''),
  'dec-reserve': (r) => `reserved ${r.ids.join(' ')}`,
  passes: (r) => j(`${r.milestone} passes ${r.passes}`, r.created ? 'created' : 'updated', `board ${r.board.passed}/${r.board.total}`),
  state: (r) => j(`phase ${r.phase || '?'}`, `milestones ${r.milestones.passed}/${r.milestones.total}`,
    `${r.git.branch || '?'} ${r.git.dirty ? r.git.dirty + ' dirty' : 'clean'}`,
    `last ${r.last_commit ? r.last_commit.sha7 : DASH}`, `WAITING ${r.waiting.length}`,
    r.git_top && r.git_top !== r.root ? `git_top ${r.git_top}` : ''),
  heartbeat: (r) => j(`heartbeat ${r.file}:${r.line}`, r.text),
  ledger: (r) => j(`ledger ${r.criteria.length}`, `FRESH ${r.summary.FRESH}`, `STALE ${r.summary.STALE}`, `UNKNOWN ${r.summary.UNKNOWN}`),
  'backlog-reconcile': (r) => j(`backlog ${r.items.length}`, `open ${r.open}`, r.run ? `closed ${or(r.closed)}` : 'dry-run'),
  epilogue: (r) => [j(`phase ${r.phase}`, `head ${r.head || DASH}`, r.dirty ? `${r.dirty} dirty` : 'clean'),
    `passed: ${or(r.passed.join(' '))}${S}left: ${or(r.left.map((l) => `${l.id} (${l.why})`).join(S))}`,
    `waiting: ${or(r.waiting.map((w) => w.id).join(' '))}${S}backlog: ${or(r.new_backlog.join(' '))}`,
    `blocked_by: ${or(Object.keys(r.blocked_by).map((k) => `${k}<-${r.blocked_by[k]}`).join(' '))}`,
    `next: ${r.next_command}`,
    'targets: q≤4/phase · owner≤1/phase · band-1=0 at close'].join('\n'),
  'phase-stats': (r) => j(`days ${r.days_with_work}/${r.span_days}`, `idle ${r.idle_days}`,
    `commits ${r.commits}`, `test/feat ${r.test_feat_ratio === null ? DASH : r.test_feat_ratio}`,
    `phases ${r.phases.length} · over target ${r.phases.filter((p) => p.questions > 4 || p.owner_prompts > 1 || p.band1_open > 0).length}`),
  'plan-lint': (r) => j(r.verdict, `errors ${r.summary.error}`, `warnings ${r.summary.warn}`)
    + r.defects.map((d) => `\n  ${d.severity} ${d.rule} ${d.milestone || '-'}` + (d.message === d.rule ? '' : ` ${DASH} ${d.message}`)).join(''),
};

const WRITE = new Set(['dec-reserve', 'passes', 'heartbeat']);

function main() {
 const argv = process.argv.slice(2), cmd = argv[0];
 let write = WRITE.has(cmd) || (cmd === 'backlog-reconcile' && argv.indexOf('--run') > 0);
 try {
  if (!C[cmd]) die('usage: ll-tools.js <' + Object.keys(C).join('|') + '> [args] [--json]');
  const a = parseArgv(argv.slice(1));
  write = WRITE.has(cmd) || (cmd === 'backlog-reconcile' && !!a.flags.run);
  const res = sz(C[cmd](a));
  process.stdout.write((a.flags.json || !FMT[cmd] ? JSON.stringify(res) : FMT[cmd](res)) + '\n');
  process.exit(0);
 } catch (e) {
  process.stdout.write(JSON.stringify({ ok: false, reason: sz((e && e.message) || String(e)) || 'error' }) + '\n');
  process.exit(write ? 1 : 0);
 }
}

main();
