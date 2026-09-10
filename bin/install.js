#!/usr/bin/env node
'use strict';

// Instalador do ll-skills.
//
//   npx ll-skills@latest              instala/atualiza em ~/.claude (ou $CLAUDE_CONFIG_DIR)
//   npx ll-skills@latest --local      instala em ./.claude do diretório atual
//   npx ll-skills@latest --no-settings   só imprime os hooks, não toca em settings.json
//   npx ll-skills@latest --no-preamble   não escreve o bloco do preâmbulo no CLAUDE.md
//   npx ll-skills@latest --yes           aprova o preâmbulo sem perguntar
//   npx ll-skills@latest --uninstall
//
// Copia skills/ll-*, agents/ll-*, os 3 hooks e o helper ll-tools.js para o diretório
// de configuração do Claude Code, registra os hooks em settings.json (SessionStart +
// PreCompact), escreve o bloco do preâmbulo no CLAUDE.md entre marcadores, grava
// VERSION + manifesto com sha256 por arquivo e limpa o que ficou de instalações
// anteriores (plugin legado por marketplace, skills 1.x, arquivos órfãos, cache antigo).
//
// Sem dependências. Tudo relativo ao próprio pacote (__dirname), nunca ao cwd.

const fs = require('fs');
const path = require('path');
const os = require('os');
const crypto = require('crypto');
const { spawnSync } = require('child_process');

const PKG_ROOT = path.resolve(__dirname, '..');
const PKG = require(path.join(PKG_ROOT, 'package.json'));
const PKG_NAME = PKG.name;
const REPO_URL = 'https://github.com/allangdy/ll-skills.git';
const LEGACY_PLUGIN_ID = 'll-skills@ll-skills';
const LEGACY_MARKETPLACE = 'll-skills';

// hooks registrados em settings.json
const SESSION_HOOKS = [
  { file: 'll-skills-check-update.js', timeout: 5 },
  { file: 'll-state.js', timeout: 3 },
];
const PRECOMPACT_HOOK = { file: 'll-precompact.js', timeout: 3 };
const SESSION_MATCHER = 'startup|resume|compact';
const HOOK_EVENTS = ['SessionStart', 'PreCompact'];
const OWN_HOOK_FILES = SESSION_HOOKS.map((h) => h.file).concat([PRECOMPACT_HOOK.file]);

// helper copiado para dentro das skills que o usam (caminho relativo com --local quebraria require)
const HELPER_SKILLS = ['ll-implement', 'll-verify', 'll-close'];
const HELPER_SRC = path.join(PKG_ROOT, 'scripts', 'll-tools.js');

// preâmbulo
const PREAMBLE_SRC = path.join(PKG_ROOT, 'assets', 'preamble.md');
const PREAMBLE_OPEN = '<!-- ll-skills:preamble v1 -->';
const PREAMBLE_CLOSE = '<!-- /ll-skills:preamble -->';
const POLICY_SRC = path.join(PKG_ROOT, 'assets', 'settings.suggested.json');

const PREFIXOS_PROPRIOS = ['skills/ll-', 'agents/ll-', 'hooks/ll-', 'll-skills/'];

// removidos mesmo sem manifesto (instalações 1.x e cópias manuais)
const KNOWN_LEGACY = [
  'skills/ll-atualizar',
  'skills/ll-decidir-antes',
  'skills/ll-desarmar',
  'skills/ll-orquestrar',
  'skills/ll-pesquisar',
  'skills/ll-pesquisar-mercado',
  'skills/ll-verificar-entrega',
  'skills/ll-voltar-do-futuro',
  'agents/ll-implementador.md',
];
const LEGACY_BASENAMES = new Set(KNOWN_LEGACY.map((r) => r.split('/')[1]));

const CACHE_DIR = path.join(process.env.XDG_CACHE_HOME || path.join(os.homedir(), '.cache'), 'll-skills');

// ---------------------------------------------------------------------------
// utilitários
// ---------------------------------------------------------------------------

function log(msg) {
  process.stdout.write(msg + '\n');
}

function fail(msg, code = 1) {
  process.stderr.write('ll-skills: ' + msg + '\n');
  process.exit(code);
}

function parseArgs(argv) {
  const args = { uninstall: false, local: false, help: false, settings: true, preamble: true, yes: false };
  for (const a of argv) {
    if (a === '--uninstall') args.uninstall = true;
    else if (a === '--local') args.local = true;
    else if (a === '--no-settings') args.settings = false;
    else if (a === '--no-preamble') args.preamble = false;
    else if (a === '--yes' || a === '-y') args.yes = true;
    else if (a === '--help' || a === '-h') args.help = true;
    else fail(`argumento desconhecido: ${a} (use --help)`);
  }
  return args;
}

function usage() {
  log(`ll-skills ${PKG.version}

Uso:
  npx ll-skills@latest                instala ou atualiza em $CLAUDE_CONFIG_DIR ou ~/.claude
  npx ll-skills@latest --local        instala em ./.claude (só este projeto)
  npx ll-skills@latest --no-settings  não toca em settings.json; imprime os hooks
  npx ll-skills@latest --no-preamble  não escreve o bloco do preâmbulo no CLAUDE.md
  npx ll-skills@latest --yes          aprova o preâmbulo sem perguntar (-y)
  npx ll-skills@latest --uninstall    remove tudo que este pacote instalou
  npx ll-skills@latest --help`);
}

function resolveConfigDir(args) {
  if (args.local) return path.resolve(process.cwd(), '.claude');
  if (process.env.CLAUDE_CONFIG_DIR) return path.resolve(process.env.CLAUDE_CONFIG_DIR);
  return path.join(os.homedir(), '.claude');
}

function sha256(buf) {
  return crypto.createHash('sha256').update(buf).digest('hex');
}

// Retorna `fallback` se o arquivo não existe; `null` se existe mas não é JSON válido.
function readJson(file, fallback) {
  let raw;
  try {
    raw = fs.readFileSync(file, 'utf8');
  } catch (e) {
    if (e.code === 'ENOENT') return fallback;
    throw e;
  }
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

function readText(file) {
  try {
    return fs.readFileSync(file, 'utf8');
  } catch {
    return null;
  }
}

function writeJsonAtomic(file, obj) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const tmp = `${file}.tmp.${process.pid}`;
  fs.writeFileSync(tmp, JSON.stringify(obj, null, 2) + '\n');
  fs.renameSync(tmp, file);
}

function writeTextAtomic(file, text) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const tmp = `${file}.tmp.${process.pid}`;
  fs.writeFileSync(tmp, text);
  fs.renameSync(tmp, file);
}

function insideDir(base, target) {
  const rel = path.relative(base, target);
  return rel !== '' && !rel.startsWith('..') && !path.isAbsolute(rel);
}

function isOwnRel(rel) {
  return PREFIXOS_PROPRIOS.some((p) => rel.startsWith(p));
}

function walk(dir, base = dir, out = []) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, base, out);
    else if (entry.isFile()) out.push(path.relative(base, full));
  }
  return out;
}

// Lista de arquivos do pacote a instalar: [{ src, rel, mode }], rel relativo ao configDir.
function planFiles(pkgRoot) {
  const plan = [];
  const skillsDir = path.join(pkgRoot, 'skills');
  for (const name of fs.readdirSync(skillsDir)) {
    if (!name.startsWith('ll-') || LEGACY_BASENAMES.has(name)) continue;
    const dir = path.join(skillsDir, name);
    if (!fs.statSync(dir).isDirectory()) continue;
    for (const rel of walk(dir)) {
      const relPosix = rel.split(path.sep).join('/');
      const item = { src: path.join(dir, rel), rel: path.posix.join('skills', name, relPosix) };
      if (/^scripts\/[^/]+\.js$/.test(relPosix)) item.mode = 0o755;
      plan.push(item);
    }
  }
  const agentsDir = path.join(pkgRoot, 'agents');
  if (fs.existsSync(agentsDir)) {
    for (const name of fs.readdirSync(agentsDir)) {
      if (name.startsWith('ll-') && name.endsWith('.md') && !LEGACY_BASENAMES.has(name)) {
        plan.push({ src: path.join(agentsDir, name), rel: `agents/${name}` });
      }
    }
  }
  const hooksDir = path.join(pkgRoot, 'hooks');
  if (fs.existsSync(hooksDir)) {
    for (const name of fs.readdirSync(hooksDir)) {
      if (name.startsWith('ll-') && name.endsWith('.js')) {
        plan.push({ src: path.join(hooksDir, name), rel: `hooks/${name}`, mode: 0o755 });
      }
    }
  }
  if (fs.existsSync(HELPER_SRC)) {
    const installed = new Set(plan.map((p) => p.rel.split('/')[1]));
    for (const name of HELPER_SKILLS) {
      if (!installed.has(name)) continue;
      plan.push({ src: HELPER_SRC, rel: `skills/${name}/scripts/ll-tools.js`, mode: 0o755 });
    }
  } else {
    log(`• AVISO: ${HELPER_SRC} não existe no pacote; as skills ficam sem o helper ll-tools.js`);
  }
  return plan;
}

// ---------------------------------------------------------------------------
// origem da instalação (registry npm, github: ou clone local)
// ---------------------------------------------------------------------------

function detectInstallSource(pkgRoot) {
  const npxRoot = path.resolve(pkgRoot, '..', '..');
  const key = `node_modules/${PKG_NAME}`;
  const lock =
    readJson(path.join(npxRoot, 'node_modules', '.package-lock.json'), null) ||
    readJson(path.join(npxRoot, 'package-lock.json'), null);
  const resolved = (lock && lock.packages && lock.packages[key] && lock.packages[key].resolved) || '';
  if (/^git\+/.test(resolved)) {
    return { source: 'github', resolved, sha: resolved.split('#')[1] || null };
  }
  if (/registry\.npmjs\.org/.test(resolved)) {
    return { source: 'registry', resolved, sha: null };
  }
  const outer = readJson(path.join(npxRoot, 'package.json'), null);
  const pkgs = (outer && outer._npx && outer._npx.packages) || [];
  const gh = pkgs.find((p) => /^(github:|git\+|git:)/.test(p));
  if (gh) return { source: 'github', resolved: gh, sha: null };
  if (fs.existsSync(path.join(pkgRoot, '.git'))) {
    const r = spawnSync('git', ['-C', pkgRoot, 'rev-parse', 'HEAD'], { encoding: 'utf8' });
    const sha = r.status === 0 ? r.stdout.trim() : null;
    return { source: 'local', resolved: pkgRoot, sha };
  }
  return { source: 'local', resolved: pkgRoot, sha: null };
}

// ---------------------------------------------------------------------------
// plugin legado (marketplace)
// ---------------------------------------------------------------------------

function removeLegacyPlugin(configDir) {
  const registry = readJson(path.join(configDir, 'plugins', 'installed_plugins.json'), {});
  const entries = registry && registry.plugins && registry.plugins[LEGACY_PLUGIN_ID];
  if (!Array.isArray(entries) || entries.length === 0) return { found: false, removed: false, manual: [] };

  const cmds = [];
  for (const e of entries) {
    const scope = e.scope || 'user';
    const cwd = scope === 'project' && e.projectPath ? e.projectPath : process.cwd();
    cmds.push({ args: ['plugin', 'uninstall', LEGACY_PLUGIN_ID, '-s', scope], cwd });
  }
  cmds.push({ args: ['plugin', 'marketplace', 'remove', LEGACY_MARKETPLACE], cwd: process.cwd() });

  const manual = [];
  let cliMissing = false;
  for (const c of cmds) {
    if (cliMissing) {
      manual.push(`claude ${c.args.join(' ')}`);
      continue;
    }
    const r = spawnSync('claude', c.args, { cwd: c.cwd, stdio: 'pipe', encoding: 'utf8', timeout: 60000 });
    if (r.error && r.error.code === 'ENOENT') {
      cliMissing = true;
      manual.push(`claude ${c.args.join(' ')}`);
      continue;
    }
    // Falhas de "já removido" são esperadas e ignoradas.
  }
  return { found: true, removed: !cliMissing, manual };
}

// ---------------------------------------------------------------------------
// cópia, poda e estado
// ---------------------------------------------------------------------------

function copyFiles(configDir, plan) {
  const files = {};
  for (const item of plan) {
    const dest = path.join(configDir, item.rel);
    try {
      fs.mkdirSync(path.dirname(dest), { recursive: true });
      const buf = fs.readFileSync(item.src);
      fs.writeFileSync(dest, buf);
      if (item.mode) fs.chmodSync(dest, item.mode);
      files[item.rel] = sha256(buf);
    } catch (e) {
      fail(`não consegui gravar ${dest}: ${e.message}`);
    }
  }
  return files;
}

function removeEmptyDirsUpTo(dir, stopAt) {
  let cur = dir;
  while (insideDir(stopAt, cur)) {
    try {
      if (fs.readdirSync(cur).length > 0) return;
      fs.rmdirSync(cur);
    } catch {
      return;
    }
    cur = path.dirname(cur);
  }
}

function removeManagedFile(configDir, rel) {
  if (!isOwnRel(rel)) return false;
  const full = path.resolve(configDir, rel);
  if (!insideDir(configDir, full)) return false;
  try {
    fs.unlinkSync(full);
  } catch (e) {
    if (e.code !== 'ENOENT') return false;
  }
  removeEmptyDirsUpTo(path.dirname(full), configDir);
  return true;
}

// Remove um caminho gerenciado que pode ser diretório (skills 1.x) ou arquivo.
function removeManagedPath(configDir, rel) {
  if (!isOwnRel(rel)) return false;
  const full = path.resolve(configDir, rel);
  if (!insideDir(configDir, full)) return false;
  if (!fs.existsSync(full)) return false;
  try {
    fs.rmSync(full, { recursive: true, force: true });
  } catch {
    return false;
  }
  removeEmptyDirsUpTo(path.dirname(full), configDir);
  return true;
}

function pruneStale(configDir, oldManifest, newFiles) {
  const removed = [];
  const old = (oldManifest && oldManifest.files) || {};
  for (const rel of Object.keys(old)) {
    if (rel in newFiles) continue;
    if (removeManagedFile(configDir, rel)) removed.push(rel);
  }
  for (const rel of KNOWN_LEGACY) {
    if (rel in newFiles) continue;
    if (removeManagedPath(configDir, rel)) removed.push(rel);
  }
  return removed;
}

function stateDir(configDir) {
  return path.join(configDir, 'll-skills');
}

function writeState(configDir, files, sourceInfo) {
  const dir = stateDir(configDir);
  fs.mkdirSync(dir, { recursive: true });
  fs.writeFileSync(path.join(dir, 'VERSION'), PKG.version + '\n');
  writeJsonAtomic(path.join(dir, 'manifest.json'), {
    version: PKG.version,
    timestamp: new Date().toISOString(),
    files,
  });
  writeJsonAtomic(path.join(dir, 'install.json'), {
    version: PKG.version,
    installedAt: new Date().toISOString(),
    repo: REPO_URL,
    ...sourceInfo,
  });
}

function clearOldCache() {
  try {
    fs.rmSync(CACHE_DIR, { recursive: true, force: true });
  } catch {
    /* melhor esforço */
  }
}

// ---------------------------------------------------------------------------
// settings.json
// ---------------------------------------------------------------------------

function hookCommand(configDir, file) {
  const hookPath = path.join(configDir, 'hooks', file);
  // `node` bare: com nvm, um caminho absoluto para o binário quebra no próximo `nvm install`.
  return `command -v node >/dev/null 2>&1 && node "${hookPath}" || true`;
}

function buildHookEntries(configDir) {
  return {
    SessionStart: {
      matcher: SESSION_MATCHER,
      hooks: SESSION_HOOKS.map((h) => ({ type: 'command', command: hookCommand(configDir, h.file), timeout: h.timeout })),
    },
    PreCompact: {
      hooks: [{ type: 'command', command: hookCommand(configDir, PRECOMPACT_HOOK.file), timeout: PRECOMPACT_HOOK.timeout }],
    },
  };
}

function isOwnHook(h) {
  return Boolean(h && typeof h.command === 'string' && OWN_HOOK_FILES.some((f) => h.command.includes(f)));
}

function stripOwnHooks(settings) {
  if (!settings.hooks || typeof settings.hooks !== 'object') return;
  for (const ev of HOOK_EVENTS) {
    const list = settings.hooks[ev];
    if (!Array.isArray(list)) continue;
    settings.hooks[ev] = list
      .map((e) => (e && Array.isArray(e.hooks) ? { ...e, hooks: e.hooks.filter((h) => !isOwnHook(h)) } : e))
      .filter((e) => !(e && Array.isArray(e.hooks) && e.hooks.length === 0));
  }
}

function stripLegacyPluginKeys(settings) {
  if (settings.enabledPlugins && Object.prototype.hasOwnProperty.call(settings.enabledPlugins, LEGACY_PLUGIN_ID)) {
    delete settings.enabledPlugins[LEGACY_PLUGIN_ID];
    if (Object.keys(settings.enabledPlugins).length === 0) delete settings.enabledPlugins;
  }
  if (settings.extraKnownMarketplaces && Object.prototype.hasOwnProperty.call(settings.extraKnownMarketplaces, LEGACY_MARKETPLACE)) {
    delete settings.extraKnownMarketplaces[LEGACY_MARKETPLACE];
    if (Object.keys(settings.extraKnownMarketplaces).length === 0) delete settings.extraKnownMarketplaces;
  }
}

function pruneEmptyHooks(settings) {
  if (!settings.hooks || typeof settings.hooks !== 'object') return;
  for (const ev of HOOK_EVENTS) {
    if (Array.isArray(settings.hooks[ev]) && settings.hooks[ev].length === 0) delete settings.hooks[ev];
  }
  if (Object.keys(settings.hooks).length === 0) delete settings.hooks;
}

// Lê, aplica `mutate(settings)`, grava só se mudou. Retorna 'unchanged' | 'written' | 'invalid'.
function updateSettings(configDir, mutate) {
  const file = path.join(configDir, 'settings.json');
  const settings = readJson(file, {});
  if (settings === null || typeof settings !== 'object' || Array.isArray(settings)) return 'invalid';
  const before = JSON.stringify(settings);
  mutate(settings);
  if (JSON.stringify(settings) === before) return 'unchanged';
  if (fs.existsSync(file)) fs.copyFileSync(file, `${file}.ll-skills.bak`);
  writeJsonAtomic(file, settings);
  return 'written';
}

// Registra os 3 hooks (SessionStart + PreCompact) numa única mutação.
function registerHooks(configDir) {
  const entries = buildHookEntries(configDir);
  return updateSettings(configDir, (s) => {
    if (!s.hooks || typeof s.hooks !== 'object') s.hooks = {};
    stripOwnHooks(s);
    for (const ev of HOOK_EVENTS) {
      if (!Array.isArray(s.hooks[ev])) s.hooks[ev] = [];
      s.hooks[ev].push(entries[ev]);
    }
    stripLegacyPluginKeys(s);
  });
}

function unregisterHooks(configDir) {
  return updateSettings(configDir, (s) => {
    stripOwnHooks(s);
    pruneEmptyHooks(s);
  });
}

function printHookSnippet(configDir) {
  const entries = buildHookEntries(configDir);
  log('');
  log('Adicione manualmente em "hooks" de ' + path.join(configDir, 'settings.json') + ':');
  log('');
  log(JSON.stringify({ hooks: { SessionStart: [entries.SessionStart], PreCompact: [entries.PreCompact] } }, null, 2));
  log('');
}

// Política sugerida da máquina: sempre impressa, nunca escrita.
function printPolicy() {
  const raw = readText(POLICY_SRC);
  if (raw === null) return;
  log('');
  log('Política sugerida (NÃO foi escrita; aplique você mesmo em settings.json):');
  log(raw.trimEnd());
  log('');
}

// Diagnóstico de limpeza da máquina — só imprime, nunca executa.
function diagnoseCleanup(configDir) {
  const items = [];
  const cache = path.join(os.homedir(), '.claude', 'plugins', 'cache', 'll-skills');
  if (fs.existsSync(cache)) items.push(`rm -rf ${cache}   # cache do plugin legado`);

  if (!items.length) return;
  log('');
  log('Limpeza sugerida (diagnóstico; nada foi executado):');
  for (const i of items) log(`  • ${i}`);
}

// ---------------------------------------------------------------------------
// preâmbulo no CLAUDE.md
// ---------------------------------------------------------------------------

function preambleFile(configDir) {
  return path.join(configDir, 'CLAUDE.md');
}

// Texto canônico do bloco, com marcadores, sem newline final.
function preambleText() {
  const raw = readText(PREAMBLE_SRC);
  if (raw === null) return null;
  const lines = raw.replace(/\n+$/, '').split('\n');
  if (lines[0].trim() !== PREAMBLE_OPEN || lines[lines.length - 1].trim() !== PREAMBLE_CLOSE) return null;
  return lines.join('\n');
}

// Localiza o bloco: null (ausente), {start,end} ou {half:true}.
function readPreambleBlock(text) {
  const all = text.split('\n');
  let start = -1, end = -1;
  for (let i = 0; i < all.length; i++) {
    if (start < 0 && all[i].trim() === PREAMBLE_OPEN) start = i;
    else if (start >= 0 && all[i].trim() === PREAMBLE_CLOSE) { end = i; break; }
  }
  if (start < 0 && end < 0) return null;
  if (start < 0 || end < 0) return { half: true };
  return { start, end, all };
}

function diffLines(oldText, newText) {
  const a = oldText === null ? [] : oldText.split('\n');
  const b = newText.split('\n');
  const setB = new Set(b), setA = new Set(a);
  const out = [];
  for (const l of a) if (!setB.has(l)) out.push('- ' + l);
  for (const l of b) if (!setA.has(l)) out.push('+ ' + l);
  return out;
}

function askTty(question) {
  let fd = null;
  try {
    fd = fs.openSync('/dev/tty', 'r+');
    fs.writeSync(fd, question);
    const buf = Buffer.alloc(64);
    const n = fs.readSync(fd, buf, 0, buf.length, null);
    return buf.slice(0, n).toString('utf8').trim().toLowerCase();
  } catch {
    return null;
  } finally {
    if (fd !== null) try { fs.closeSync(fd); } catch { /* nada */ }
  }
}

// 'skipped' | 'unchanged' | 'written' | 'declined' | 'invalid'
function writePreamble(configDir, opts) {
  if (opts.skip) return 'skipped';
  const block = preambleText();
  if (block === null) return 'invalid';

  const file = preambleFile(configDir);
  const cur = readText(file);
  let next;
  if (cur === null) {
    next = block + '\n';
  } else {
    const loc = readPreambleBlock(cur);
    if (loc && loc.half) return 'invalid';
    if (loc) {
      const all = loc.all.slice();
      all.splice(loc.start, loc.end - loc.start + 1, ...block.split('\n'));
      next = all.join('\n');
    } else {
      next = cur.replace(/\n*$/, '\n\n') + block + '\n';
    }
  }
  if (cur !== null && next === cur) return 'unchanged';

  if (!opts.yes) {
    const interactive = process.stdin.isTTY === true && process.stdout.isTTY === true;
    const answer = interactive ? askTty(`\nEscrever o bloco do preâmbulo em ${file}? [s/N] `) : null;
    if (!answer || !/^(s|sim|y|yes)$/.test(answer)) {
      log('');
      log(`Preâmbulo NÃO escrito em ${file}. Diff proposto:`);
      for (const l of diffLines(cur, next).slice(0, 80)) log('  ' + l);
      log('  (rode de novo com --yes para aplicar, ou --no-preamble para nunca perguntar)');
      return 'declined';
    }
  }
  if (cur !== null) fs.copyFileSync(file, `${file}.ll-skills.bak`);
  writeTextAtomic(file, next);
  return 'written';
}

// 'missing' | 'unchanged' | 'written' | 'invalid'
function stripPreamble(configDir) {
  const file = preambleFile(configDir);
  const cur = readText(file);
  if (cur === null) return 'missing';
  const loc = readPreambleBlock(cur);
  if (!loc) return 'unchanged';
  if (loc.half) return 'invalid';
  const all = loc.all.slice();
  all.splice(loc.start, loc.end - loc.start + 1);
  while (all.length && all[0].trim() === '') all.shift();
  const next = all.join('\n').replace(/\n{3,}/g, '\n\n');
  fs.copyFileSync(file, `${file}.ll-skills.bak`);
  writeTextAtomic(file, next);
  return 'written';
}

// ---------------------------------------------------------------------------
// fluxos
// ---------------------------------------------------------------------------

function install(args) {
  const configDir = resolveConfigDir(args);
  log(`ll-skills ${PKG.version} → ${configDir}`);

  // 1. plugin legado, ANTES de tocar em settings.json (o CLI `claude` reescreve o arquivo).
  const legacy = removeLegacyPlugin(configDir);
  if (legacy.found) {
    if (legacy.removed) log('• plugin legado ll-skills@ll-skills desinstalado (marketplace removido)');
    else log('• plugin legado detectado, mas o CLI `claude` não está no PATH');
  }

  // 2. instalação standalone anterior
  const oldManifest = readJson(path.join(stateDir(configDir), 'manifest.json'), null);

  // 3. cópia
  const plan = planFiles(PKG_ROOT);
  const files = copyFiles(configDir, plan);
  const skillNames = [...new Set(Object.keys(files).filter((r) => r.startsWith('skills/')).map((r) => r.split('/')[1]))].sort();
  const agentNames = Object.keys(files).filter((r) => r.startsWith('agents/')).map((r) => path.basename(r, '.md')).sort();
  const hookNames = Object.keys(files).filter((r) => r.startsWith('hooks/')).map((r) => path.basename(r));
  log(`• ${skillNames.length} skills: ${skillNames.join(', ')}`);
  if (agentNames.length) log(`• ${agentNames.length} agentes: ${agentNames.join(', ')}`);
  if (hookNames.length) log(`• ${hookNames.length} hooks: ${hookNames.join(', ')}`);

  // 4. poda (manifesto antigo + skills 1.x conhecidas)
  const pruned = pruneStale(configDir, oldManifest, files);
  if (pruned.length) log(`• ${pruned.length} caminho(s) de instalação anterior removido(s)`);

  // 5. estado
  writeState(configDir, files, detectInstallSource(PKG_ROOT));

  // 6. hooks
  let hookResult = 'skipped';
  if (!args.settings) {
    log('• --no-settings: settings.json não foi alterado');
    printHookSnippet(configDir);
  } else {
    hookResult = registerHooks(configDir);
    if (hookResult === 'written') log('• 3 hooks registrados em settings.json (SessionStart, PreCompact)');
    else if (hookResult === 'unchanged') log('• hooks já registrados em settings.json');
  }

  // 7. política sugerida (impressa, nunca escrita) + diagnóstico de limpeza
  printPolicy();
  diagnoseCleanup(configDir);

  // 8. cache antigo
  clearOldCache();

  // 9. preâmbulo
  const pre = writePreamble(configDir, { yes: args.yes, skip: !args.preamble });
  if (pre === 'written') log(`• preâmbulo escrito em ${preambleFile(configDir)}`);
  else if (pre === 'unchanged') log('• preâmbulo já atualizado');
  else if (pre === 'skipped') log('• --no-preamble: CLAUDE.md não foi tocado');
  else if (pre === 'invalid') log(`• AVISO: bloco do preâmbulo pela metade em ${preambleFile(configDir)}; corrija os marcadores à mão`);

  log('');
  if (legacy.manual.length) {
    log('Para concluir a remoção do plugin legado, rode dentro do Claude Code ou no terminal:');
    for (const c of legacy.manual) log(`  ${c}`);
    log('');
  }
  if (hookResult === 'invalid') {
    log(`AVISO: ${path.join(configDir, 'settings.json')} não é um JSON válido; não foi alterado.`);
    printHookSnippet(configDir);
    log('Reinicie o Claude Code para que as skills ll-* apareçam.');
    process.exit(1);
  }
  log('Pronto. Reinicie o Claude Code para que as skills ll-* apareçam (ex.: /ll-implement).');
}

function uninstall(args) {
  const configDir = resolveConfigDir(args);
  log(`ll-skills --uninstall → ${configDir}`);

  const manifest = readJson(path.join(stateDir(configDir), 'manifest.json'), null);
  const rels = manifest && manifest.files ? Object.keys(manifest.files) : planFiles(PKG_ROOT).map((p) => p.rel);
  let n = 0;
  for (const rel of rels) if (removeManagedFile(configDir, rel)) n++;
  for (const rel of KNOWN_LEGACY) if (removeManagedPath(configDir, rel)) n++;
  log(`• ${n} arquivo(s) removido(s)`);

  try {
    fs.rmSync(stateDir(configDir), { recursive: true, force: true });
  } catch {
    /* melhor esforço */
  }

  const hookResult = unregisterHooks(configDir);
  if (hookResult === 'written') log('• hooks removidos de settings.json');
  else if (hookResult === 'invalid') log('• AVISO: settings.json inválido; remova os hooks ll-* manualmente');

  const pre = stripPreamble(configDir);
  if (pre === 'written') log('• bloco do preâmbulo removido do CLAUDE.md');
  else if (pre === 'invalid') log('• AVISO: bloco do preâmbulo pela metade no CLAUDE.md; remova à mão');

  clearOldCache();
  log('');
  log('ll-skills removido. Reinicie o Claude Code.');
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) return usage();
  if (args.uninstall) return uninstall(args);
  return install(args);
}

main();
