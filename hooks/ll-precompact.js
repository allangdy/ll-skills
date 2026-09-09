#!/usr/bin/env node
'use strict';
// ll-precompact.js — ll-skills PreCompact hook. Stamps PROGRESS.md so the
// post-compaction session knows the disk is the truth. Reads stdin {cwd, trigger}.
// Silent without PROGRESS.md; any failure ends in silence with exit 0.

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

// State root: PROGRESS.md at cwd, else the single one found up to 3 levels down
// (skipping node_modules/.git/dist/build/vendor and docs/history).
function stateRoot(cwd) {
  if (fs.existsSync(path.join(cwd, 'PROGRESS.md'))) return cwd;
  const skip = new Set(['node_modules', '.git', 'dist', 'build', 'vendor']);
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
  let input = {};
  try { input = JSON.parse(fs.readFileSync(0, 'utf8')); } catch { input = {}; }
  const cwd = typeof input.cwd === 'string' && input.cwd ? input.cwd : process.cwd();
  const trigger = typeof input.trigger === 'string' && input.trigger ? input.trigger : 'auto';

  const file = path.join(stateRoot(cwd), 'PROGRESS.md');
  let body;
  try { body = fs.readFileSync(file, 'utf8'); } catch { return; }

  let phase = 'NN';
  const m = /^<!--\s*ll-state\s*-->\s*$[\s\S]*?^phase:\s*(\S+)\s*$/m.exec(body);
  if (m) phase = m[1].replace(/^["']|["']$/g, '');

  let head = '';
  try {
    head = execFileSync('git', ['rev-parse', '--short=7', 'HEAD'],
      { cwd, timeout: 3000, encoding: 'utf8', stdio: ['ignore', 'pipe', 'ignore'] }).trim();
  } catch { head = ''; }

  const stamp = new Date().toISOString().replace(/\.\d+Z$/, 'Z');
  const line = '- [compaction ' + stamp + ' · ' + trigger + ' · HEAD ' + (head || 'unknown') + '] '
    + 're-read phases/' + phase + '/PLAN.md and the milestone board before continuing.';

  const out = body.split('\n');
  const at = out.findIndex((l) => /^## Epilogue/.test(l));
  if (at >= 0) out.splice(at, 0, line, '');
  else {
    while (out.length && out[out.length - 1].trim() === '') out.pop();
    out.push(line, '');
  }
  const tmp = file + '.ll-tmp-' + process.pid;
  fs.writeFileSync(tmp, out.join('\n'));
  fs.renameSync(tmp, file);
  process.stdout.write(JSON.stringify({ systemMessage: '[ll-skills] compaction marked in PROGRESS.md' }) + '\n');
}

try { main(); } catch { /* silence */ }
process.exit(0);
