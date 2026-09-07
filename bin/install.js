#!/usr/bin/env node
'use strict';

// Instalador do ll-skills.
//
//   npx ll-skills@latest            instala/atualiza em ~/.claude (ou $CLAUDE_CONFIG_DIR)
//   npx ll-skills@latest --local    instala em ./.claude do diretório atual
//   npx ll-skills@latest --uninstall
//
// Copia skills/ll-*, agents/ll-* e o hook de aviso de atualização para o diretório
// de configuração do Claude Code, registra o hook em settings.json, grava
// VERSION + manifesto com sha256 por arquivo e limpa o que ficou de instalações
// anteriores (plugin legado por marketplace, arquivos órfãos, cache antigo).
//
// Sem dependências, sem prompts. Tudo relativo ao próprio pacote (__dirname),
// nunca ao cwd.

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
const HOOK_FILE = 'll-skills-check-update.js';
const HOOK_MATCHER = 'startup|resume';
const PREFIXOS_PROPRIOS = ['skills/ll-', 'agents/ll-', 'hooks/ll-skills-', 'll-skills/'];

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
  const args = { uninstall: false, local: false, help: false };
  for (const a of argv) {
    if (a === '--uninstall') args.uninstall = true;
    else if (a === '--local') args.local = true;
    else if (a === '--help' || a === '-h') args.help = true;
    else fail(`argumento desconhecido: ${a} (use --help)`);
  }
  return args;
}

function usage() {
  log(`ll-skills ${PKG.version}

Uso:
  npx ll-skills@latest              instala ou atualiza em $CLAUDE_CONFIG_DIR ou ~/.claude
  npx ll-skills@latest --local      instala em ./.claude (só este projeto)
  npx ll-skills@latest --uninstall  remove tudo que este pacote instalou
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

function writeJsonAtomic(file, obj) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  const tmp = `${file}.tmp.${process.pid}`;
  fs.writeFileSync(tmp, JSON.stringify(obj, null, 2) + '\n');
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

// Lista de arquivos do pacote a instalar: [{ src, rel }], rel relativo ao configDir.
function planFiles(pkgRoot) {
  const plan = [];
  const skillsDir = path.join(pkgRoot, 'skills');
  for (const name of fs.readdirSync(skillsDir)) {
    if (!name.startsWith('ll-')) continue;
    const dir = path.join(skillsDir, name);
    if (!fs.statSync(dir).isDirectory()) continue;
    for (const rel of walk(dir)) {
      plan.push({ src: path.join(dir, rel), rel: path.posix.join('skills', name, rel.split(path.sep).join('/')) });
    }
  }
  const agentsDir = path.join(pkgRoot, 'agents');
  if (fs.existsSync(agentsDir)) {
    for (const name of fs.readdirSync(agentsDir)) {
      if (name.startsWith('ll-') && name.endsWith('.md')) {
        plan.push({ src: path.join(agentsDir, name), rel: `agents/${name}` });
      }
    }
  }
  const hooksDir = path.join(pkgRoot, 'hooks');
  if (fs.existsSync(hooksDir)) {
    for (const name of fs.readdirSync(hooksDir)) {
      if (name.startsWith('ll-skills-') && name.endsWith('.js')) {
        plan.push({ src: path.join(hooksDir, name), rel: `hooks/${name}`, mode: 0o755 });
      }
    }
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

function pruneStale(configDir, oldManifest, newFiles) {
  const removed = [];
  const old = (oldManifest && oldManifest.files) || {};
  for (const rel of Object.keys(old)) {
    if (rel in newFiles) continue;
    if (removeManagedFile(configDir, rel)) removed.push(rel);
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

function hookCommand(configDir) {
  const hookPath = path.join(configDir, 'hooks', HOOK_FILE);
  // `node` bare: com nvm, um caminho absoluto para o binário quebra no próximo `nvm install`.
  return `command -v node >/dev/null 2>&1 && node "${hookPath}" || true`;
}

function buildHookEntry(configDir) {
  return {
    matcher: HOOK_MATCHER,
    hooks: [{ type: 'command', command: hookCommand(configDir), timeout: 5 }],
  };
}

function isOwnHook(h) {
  return Boolean(h && typeof h.command === 'string' && h.command.includes(HOOK_FILE));
}

function stripOwnHooks(settings) {
  const ss = settings.hooks && settings.hooks.SessionStart;
  if (!Array.isArray(ss)) return;
  settings.hooks.SessionStart = ss
    .map((e) => (e && Array.isArray(e.hooks) ? { ...e, hooks: e.hooks.filter((h) => !isOwnHook(h)) } : e))
    .filter((e) => !(e && Array.isArray(e.hooks) && e.hooks.length === 0));
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
  if (settings.hooks && Array.isArray(settings.hooks.SessionStart) && settings.hooks.SessionStart.length === 0) {
    delete settings.hooks.SessionStart;
  }
  if (settings.hooks && Object.keys(settings.hooks).length === 0) delete settings.hooks;
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

function registerHook(configDir) {
  return updateSettings(configDir, (s) => {
    if (!s.hooks || typeof s.hooks !== 'object') s.hooks = {};
    if (!Array.isArray(s.hooks.SessionStart)) s.hooks.SessionStart = [];
    stripOwnHooks(s);
    s.hooks.SessionStart.push(buildHookEntry(configDir));
    stripLegacyPluginKeys(s);
  });
}

function unregisterHook(configDir) {
  return updateSettings(configDir, (s) => {
    stripOwnHooks(s);
    pruneEmptyHooks(s);
  });
}

function printManualHookSnippet(configDir) {
  log('');
  log(`AVISO: ${path.join(configDir, 'settings.json')} não é um JSON válido; não foi alterado.`);
  log('Corrija o arquivo e adicione manualmente em "hooks" > "SessionStart":');
  log('');
  log(JSON.stringify(buildHookEntry(configDir), null, 2));
  log('');
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
  const agentNames = Object.keys(files).filter((r) => r.startsWith('agents/')).map((r) => path.basename(r, '.md'));
  log(`• ${skillNames.length} skills: ${skillNames.join(', ')}`);
  if (agentNames.length) log(`• ${agentNames.length} agente: ${agentNames.join(', ')}`);

  // 4. poda
  const pruned = pruneStale(configDir, oldManifest, files);
  if (pruned.length) log(`• ${pruned.length} arquivo(s) órfão(s) removido(s) da instalação anterior`);

  // 5. estado
  writeState(configDir, files, detectInstallSource(PKG_ROOT));

  // 6. hook
  const hookResult = registerHook(configDir);
  if (hookResult === 'written') log('• hook de aviso de atualização registrado em settings.json');
  else if (hookResult === 'unchanged') log('• hook de aviso de atualização já registrado');

  // 7. cache antigo
  clearOldCache();

  log('');
  if (legacy.manual.length) {
    log('Para concluir a remoção do plugin legado, rode dentro do Claude Code ou no terminal:');
    for (const c of legacy.manual) log(`  ${c}`);
    log('');
  }
  if (hookResult === 'invalid') {
    printManualHookSnippet(configDir);
    log('Reinicie o Claude Code para que as skills ll-* apareçam.');
    process.exit(1);
  }
  log('Pronto. Reinicie o Claude Code para que as skills ll-* apareçam (ex.: /ll-decidir-antes).');
}

function uninstall(args) {
  const configDir = resolveConfigDir(args);
  log(`ll-skills --uninstall → ${configDir}`);

  const manifest = readJson(path.join(stateDir(configDir), 'manifest.json'), null);
  const rels = manifest && manifest.files ? Object.keys(manifest.files) : planFiles(PKG_ROOT).map((p) => p.rel);
  let n = 0;
  for (const rel of rels) if (removeManagedFile(configDir, rel)) n++;
  log(`• ${n} arquivo(s) removido(s)`);

  try {
    fs.rmSync(stateDir(configDir), { recursive: true, force: true });
  } catch {
    /* melhor esforço */
  }

  const hookResult = unregisterHook(configDir);
  if (hookResult === 'written') log('• hook removido de settings.json');
  else if (hookResult === 'invalid') log(`• AVISO: settings.json inválido; remova o hook "${HOOK_FILE}" manualmente`);

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
