#!/usr/bin/env bash
# Smoke test do instalador num CLAUDE_CONFIG_DIR isolado. Usado pela CI e localmente.
set -euo pipefail
cd "$(dirname "$0")/.."

node --check bin/install.js
node --check hooks/ll-skills-check-update.js

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export CLAUDE_CONFIG_DIR="$TMP/cfg" XDG_CACHE_HOME="$TMP/cache"
mkdir -p "$CLAUDE_CONFIG_DIR"

# settings.json com um hook alheio que precisa sobreviver intacto
cat > "$CLAUDE_CONFIG_DIR/settings.json" <<'JSON'
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "echo alheio" } ] }
    ]
  },
  "enabledPlugins": { "ll-skills@ll-skills": true, "outro@x": true }
}
JSON

# manifesto antigo com um órfão próprio e um arquivo alheio
mkdir -p "$CLAUDE_CONFIG_DIR/ll-skills" "$CLAUDE_CONFIG_DIR/skills/ll-antiga" "$CLAUDE_CONFIG_DIR/skills/alheia"
echo x > "$CLAUDE_CONFIG_DIR/skills/ll-antiga/SKILL.md"
echo y > "$CLAUDE_CONFIG_DIR/skills/alheia/SKILL.md"
echo '{"version":"0.0.1","files":{"skills/ll-antiga/SKILL.md":"a","skills/alheia/SKILL.md":"b"}}' > "$CLAUDE_CONFIG_DIR/ll-skills/manifest.json"

node bin/install.js >/dev/null

check() { if ! eval "$2"; then echo "FALHOU: $1"; exit 1; fi; }
check "skills ll-* instaladas"        '[ "$(ls "$CLAUDE_CONFIG_DIR/skills" | grep -c "^ll-")" -ge 8 ]'
check "agente instalado"              '[ -f "$CLAUDE_CONFIG_DIR/agents/ll-implementador.md" ]'
check "hook instalado e executável"   '[ -x "$CLAUDE_CONFIG_DIR/hooks/ll-skills-check-update.js" ]'
check "VERSION bate com package.json" '[ "$(cat "$CLAUDE_CONFIG_DIR/ll-skills/VERSION")" = "$(node -p "require(\"./package.json\").version")" ]'
check "órfão próprio podado"          '[ ! -e "$CLAUDE_CONFIG_DIR/skills/ll-antiga" ]'
check "arquivo alheio preservado"     '[ -f "$CLAUDE_CONFIG_DIR/skills/alheia/SKILL.md" ]'
check "hook alheio preservado"        'grep -q "echo alheio" "$CLAUDE_CONFIG_DIR/settings.json"'
check "hook próprio registrado 1x"    '[ "$(grep -c ll-skills-check-update "$CLAUDE_CONFIG_DIR/settings.json")" -eq 1 ]'
check "chave do plugin legado removida" '! grep -q "ll-skills@ll-skills" "$CLAUDE_CONFIG_DIR/settings.json"'
check "outro plugin preservado"       'grep -q "outro@x" "$CLAUDE_CONFIG_DIR/settings.json"'

cp "$CLAUDE_CONFIG_DIR/settings.json" "$TMP/s1.json"
node bin/install.js >/dev/null
check "segunda instalação sem diff no settings" 'cmp -s "$CLAUDE_CONFIG_DIR/settings.json" "$TMP/s1.json"'

# hook: leitor silencioso sem cache, aviso com cache indicando versão nova
check "leitor sem cache é silencioso" '[ -z "$(node "$CLAUDE_CONFIG_DIR/hooks/ll-skills-check-update.js")" ]'
mkdir -p "$XDG_CACHE_HOME/ll-skills"
V="$(cat "$CLAUDE_CONFIG_DIR/ll-skills/VERSION")"
printf '{"checked":%s,"installed":"%s","latest":"99.0.0","update_available":true,"method":"npm"}' "$(date +%s)" "$V" > "$XDG_CACHE_HOME/ll-skills/update-check.json"
check "leitor avisa versão nova" 'node "$CLAUDE_CONFIG_DIR/hooks/ll-skills-check-update.js" | grep -q "/ll-atualizar"'

node bin/install.js --uninstall >/dev/null
check "uninstall removeu skills"     '[ -z "$(ls "$CLAUDE_CONFIG_DIR/skills" | grep "^ll-")" ]'
check "uninstall removeu hook"       '! grep -q ll-skills-check-update "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall preservou alheios"  'grep -q "echo alheio" "$CLAUDE_CONFIG_DIR/settings.json" && [ -f "$CLAUDE_CONFIG_DIR/skills/alheia/SKILL.md" ]'

echo "smoke test OK"
