#!/usr/bin/env node
'use strict';
// ll-precompact.js — ll-skills PreCompact hook. Stamps PROGRESS.md so the
// post-compaction session knows the disk is the truth. Reads stdin {cwd, trigger}.
// Silent without PROGRESS.md; any failure ends in silence with exit 0.

const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

function main() {
  let input = {};
  try { input = JSON.parse(fs.readFileSync(0, 'utf8')); } catch { input = {}; }
  const cwd = typeof input.cwd === 'string' && input.cwd ? input.cwd : process.cwd();
  const trigger = typeof input.trigger === 'string' && input.trigger ? input.trigger : 'auto';

  const file = path.join(cwd, 'PROGRESS.md');
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
