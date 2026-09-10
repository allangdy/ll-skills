#!/usr/bin/env node
'use strict';
// ll-state.js — ll-skills SessionStart hook. Injects the epilogue and the live
// state of the project into the new session. Reads stdin {cwd, source}.
// Never writes, never touches stderr, always exits 0.

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const MAX_LINES = 60;
const J = path.join;

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
    if (/^milestones:\s*(\{\s*\})?$/.test(line)) { inM = true; continue; }
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

function git(args, cwd) {
  try {
    return execFileSync('git', args, { cwd, timeout: 3000, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] });
  } catch { return ''; }
}
function nonEmpty(s) { return s.split('\n').filter((l) => l.trim() !== ''); }

function readStdin() {
  try { return JSON.parse(fs.readFileSync(0, 'utf8')); } catch { return {}; }
}

// Last `## Epilogue` section of PROGRESS.md: {head: linesBefore, body: sectionLines}.
function splitEpilogue(all) {
  let at = -1;
  for (let i = 0; i < all.length; i++) if (/^## Epilogue/.test(all[i])) at = i;
  if (at < 0) return { head: all, body: [] };
  let end = all.length;
  for (let i = at + 1; i < all.length; i++) if (/^## /.test(all[i])) { end = i; break; }
  return { head: all.slice(0, at), body: nonEmpty(all.slice(at, end).join('\n')).slice(0, 25) };
}

function build(cwd, source) {
  const progress = J(cwd, 'PROGRESS.md');
  let raw = null;
  try { raw = fs.readFileSync(progress, 'utf8'); } catch { raw = null; }
  if (raw === null && !fs.existsSync(J(cwd, 'phases'))) return null;

  const out = [];
  const st = raw === null ? null : parseStateBlockLite((readAnchoredBlock(progress, 'll-state') || { lines: [] }).lines);
  const board = boardFromState(st);
  const phase = (st && st.phase) || 'NN';

  if (source === 'compact') {
    out.push('[post-compaction] re-read phases/' + phase + '/PLAN.md and the milestone board below before continuing; the files on disk are the truth, not the summary.');
  }

  const all = raw === null ? [] : raw.split('\n');
  const { head, body } = splitEpilogue(all);
  if (body.length) out.push('', ...body);
  const recent = nonEmpty(head.join('\n')).slice(-15);
  if (recent.length) out.push('', 'recent PROGRESS:', ...recent);

  const status = nonEmpty(git(['status', '--short'], cwd));
  if (status.length) {
    out.push('', 'git status:', ...status.slice(0, 20));
    if (status.length > 20) out.push('  (+' + (status.length - 20) + ' more)');
  }
  const wt = nonEmpty(git(['worktree', 'list'], cwd));
  if (wt.length > 1) out.push('', 'worktrees:', ...wt);

  let waiting = [];
  try {
    waiting = fs.readdirSync(J(cwd, 'decisions')).sort()
      .filter((n) => /\.md$/.test(n) && /WAITING/.test(fs.readFileSync(J(cwd, 'decisions', n), 'utf8')))
      .slice(0, 8);
  } catch { waiting = []; }
  if (waiting.length) out.push('', 'WAITING on you: ' + waiting.join(', '));

  out.push('', board.text);
  if (out.length <= MAX_LINES) return out;
  return out.slice(0, MAX_LINES - 2).concat(['', board.text]);
}

// State root: PROGRESS.md at cwd, else the single one found up to 3 levels down
// (skipping node_modules/.git/dist/build/vendor and docs/history).
function stateRoot(cwd) {
  if (fs.existsSync(path.join(cwd, 'PROGRESS.md'))) return cwd;
  const skip = new Set(['node_modules', '.git', 'dist', 'build', 'vendor', 'fixtures', 'fixture', 'test', 'tests']);
  const found = [];
  const walk = (dir, depth) => {
    if (depth > 3 || found.length > 1) return;
    let ents;
    try { ents = fs.readdirSync(dir, { withFileTypes: true }); } catch { return; }
    for (const e of ents) {
      if (!e.isDirectory() || skip.has(e.name)) continue;
      const sub = path.join(dir, e.name);
      if (path.relative(cwd, sub) === path.join('docs', 'history')) continue;
      if (fs.existsSync(path.join(sub, 'PROGRESS.md'))) found.push(sub); else walk(sub, depth + 1);
    }
  };
  walk(cwd, 1);
  if (found.length > 1) {
    // several candidates: keep those with an ll-state block, then the most recently written
    const stamp = (d) => { try { return fs.statSync(path.join(d, 'PROGRESS.md')).mtimeMs; } catch { return 0; } };
    const withState = found.filter((d) => { try { return /<!--\s*ll-state\s*-->/.test(fs.readFileSync(path.join(d, 'PROGRESS.md'), 'utf8')); } catch { return false; } });
    const pool = withState.length ? withState : found;
    return pool.sort((a, b) => stamp(b) - stamp(a))[0];
  }
  return found.length === 1 ? found[0] : cwd;
}

function main() {
  const input = readStdin();
  const cwd = typeof input.cwd === 'string' && input.cwd ? input.cwd : process.cwd();
  const lines = build(stateRoot(cwd), input.source);
  if (!lines || !lines.length) return;
  process.stdout.write(JSON.stringify({
    hookSpecificOutput: { hookEventName: 'SessionStart', additionalContext: lines.join('\n').trim() },
  }) + '\n');
}

try { main(); } catch { /* silence */ }
process.exit(0);
