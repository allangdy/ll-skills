#!/usr/bin/env node
'use strict';

// Hook SessionStart do ll-skills. Instalado em <configDir>/hooks/ pelo bin/install.js.
//
// Modo leitor (sem argumentos, foreground, sem rede):
//   reads the cache of the previous run and, when a newer version is recorded for the
//   version installed now, emits a short systemMessage. Then it starts the worker mode
//   em background e sai.
//
// Modo worker (--worker, background, com rede):
//   consulta a versão publicada (`npm view ll-skills version`); se o pacote ainda não
//   está no registro e a instalação veio de `npx github:`, cai para `git ls-remote` e
//   compara o SHA. Regrava o cache.
//
// Golden rule: never delay the session start, nothing on stderr, nothing outside
// its own cache. Any failure ends silently with exit 0.

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn, execFileSync } = require('child_process');

const PKG_NAME = 'll-skills';
const REPO_URL = 'https://github.com/allangdy/ll-skills.git';
const CONFIG_DIR = path.dirname(__dirname); // <configDir>/hooks/<este arquivo>
const STATE_DIR = path.join(CONFIG_DIR, 'll-skills');
const CACHE_DIR = path.join(process.env.XDG_CACHE_HOME || path.join(os.homedir(), '.cache'), 'll-skills');
const CACHE_FILE = path.join(CACHE_DIR, 'update-check.json');
const CHECK_INTERVAL = 6 * 60 * 60; // segundos entre consultas de rede
const NET_TIMEOUT = 10000;

function readText(file) {
  try {
    return fs.readFileSync(file, 'utf8').trim();
  } catch {
    return null;
  }
}

function readJson(file) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return null;
  }
}

function parseSemver(v) {
  const m = /^v?(\d+)\.(\d+)\.(\d+)/.exec(String(v || ''));
  return m ? [Number(m[1]), Number(m[2]), Number(m[3])] : null;
}

function semverNewer(candidate, current) {
  const a = parseSemver(candidate);
  const b = parseSemver(current);
  if (!a || !b) return false;
  for (let i = 0; i < 3; i++) {
    if (a[i] > b[i]) return true;
    if (a[i] < b[i]) return false;
  }
  return false;
}

function writeCache(obj) {
  fs.mkdirSync(CACHE_DIR, { recursive: true });
  const tmp = `${CACHE_FILE}.tmp.${process.pid}`;
  fs.writeFileSync(tmp, JSON.stringify(obj) + '\n');
  fs.renameSync(tmp, CACHE_FILE);
}

function npmLatest() {
  try {
    const out = execFileSync('npm', ['view', PKG_NAME, 'version'], {
      timeout: NET_TIMEOUT,
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8',
      env: { ...process.env, GIT_TERMINAL_PROMPT: '0', npm_config_update_notifier: 'false' },
    }).trim();
    return parseSemver(out) ? out : null;
  } catch {
    return null;
  }
}

function gitRemoteSha() {
  try {
    const out = execFileSync('git', ['ls-remote', REPO_URL, 'HEAD'], {
      timeout: NET_TIMEOUT,
      stdio: ['ignore', 'pipe', 'ignore'],
      encoding: 'utf8',
      env: { ...process.env, GIT_TERMINAL_PROMPT: '0' },
    });
    const sha = out.split(/\s/)[0];
    return /^[0-9a-f]{40}$/.test(sha) ? sha : null;
  } catch {
    return null;
  }
}

function worker(installed) {
  const now = Math.floor(Date.now() / 1000);
  const cache = { checked: now, installed, latest: null, update_available: false, method: null };

  const latest = npmLatest();
  if (latest) {
    cache.latest = latest;
    cache.method = 'npm';
    cache.update_available = semverNewer(latest, installed);
    writeCache(cache);
    return;
  }

  // Package not published yet: a remote reference is reliable only when installed from GitHub.
  const info = readJson(path.join(STATE_DIR, 'install.json'));
  if (info && info.source === 'github' && info.sha) {
    const remote = gitRemoteSha();
    if (remote) {
      cache.method = 'git';
      cache.latest = remote.slice(0, 7);
      cache.update_available = !remote.startsWith(info.sha);
    }
  }
  writeCache(cache);
}

function reader(installed) {
  const cache = readJson(CACHE_FILE);
  if (cache && cache.update_available && cache.installed === installed && cache.latest) {
    process.stdout.write(
      JSON.stringify({
        systemMessage: `ll-skills desatualizado (instalado ${installed}, disponível ${cache.latest}) — rode /ll-update`,
      }) + '\n'
    );
  }

  const now = Math.floor(Date.now() / 1000);
  const checked = cache && Number.isFinite(cache.checked) ? cache.checked : 0;
  if (now - checked >= CHECK_INTERVAL) {
    const child = spawn(process.execPath, [__filename, '--worker'], { detached: true, stdio: 'ignore' });
    child.unref();
  }
}

function main() {
  const installed = readText(path.join(STATE_DIR, 'VERSION'));
  if (!installed) return;
  if (process.argv[2] === '--worker') worker(installed);
  else reader(installed);
}

try {
  main();
} catch {
  /* silence */
}
process.exit(0);
