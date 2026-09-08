#!/usr/bin/env bash
# Smoke test do ll-skills: gate estático, hooks, helper, instalador, preâmbulo,
# poda de skills antigas e uninstall. Tudo num CLAUDE_CONFIG_DIR isolado.
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

N=0
check() { N=$((N + 1)); if ! eval "$2"; then echo "FALHOU: $1"; exit 1; fi; }

HELPER="node $ROOT/scripts/ll-tools.js"
region() { awk '/^\/\/ <ll-shared:state>$/,/^\/\/ <\/ll-shared:state>$/' "$1"; }

# ---------------------------------------------------------------------------
# 1. gate estático
# ---------------------------------------------------------------------------
for f in bin/*.js hooks/*.js scripts/*.js; do node --check "$f"; done

check "helper ≤700 linhas"            '[ "$(wc -l < scripts/ll-tools.js)" -le 700 ]'
check "helper ≤32768 bytes"           '[ "$(wc -c < scripts/ll-tools.js)" -le 32768 ]'

npm pack --dry-run --json > "$TMP/pack.json" 2>/dev/null
check "tarball inclui o helper"       'grep -q "scripts/ll-tools.js" "$TMP/pack.json"'
check "tarball inclui o preâmbulo"    'grep -q "assets/preamble.md" "$TMP/pack.json"'

region scripts/ll-tools.js > "$TMP/shared-tools.txt"
region hooks/ll-state.js   > "$TMP/shared-hook.txt"
check "região ll-shared:state existe"    '[ -s "$TMP/shared-tools.txt" ] && [ -s "$TMP/shared-hook.txt" ]'
check "região ll-shared:state idêntica"  'cmp -s "$TMP/shared-tools.txt" "$TMP/shared-hook.txt"'

# ---------------------------------------------------------------------------
# 2. hooks silenciosos fora de um projeto
# ---------------------------------------------------------------------------
EMPTY="$TMP/empty"
mkdir -p "$EMPTY"
cp -R scripts/fixtures/empty/. "$EMPTY/"
BEFORE_FILES="$(find "$EMPTY" | wc -l)"

silent_hook() { # silent_hook <hook.js> <json>
  local t0 t1
  t0="$(date +%s%N)"
  printf '%s' "$2" | node "$ROOT/hooks/$1" > "$TMP/hook.out" 2> "$TMP/hook.err"
  echo $? > "$TMP/hook.code"
  t1="$(date +%s%N)"
  echo $(((t1 - t0) / 1000000)) > "$TMP/hook.ms"
}

for h in ll-state.js ll-precompact.js; do
  silent_hook "$h" "{\"cwd\":\"$EMPTY\",\"source\":\"startup\",\"trigger\":\"auto\"}"
  check "$h silencioso no vazio (stdout)" '[ ! -s "$TMP/hook.out" ]'
  check "$h silencioso no vazio (stderr)" '[ ! -s "$TMP/hook.err" ]'
  check "$h exit 0 no vazio"              '[ "$(cat "$TMP/hook.code")" = "0" ]'
  check "$h <300 ms no vazio"             '[ "$(cat "$TMP/hook.ms")" -lt 300 ]'
done
check "hooks não criaram arquivos no vazio" '[ "$(find "$EMPTY" | wc -l)" -eq "$BEFORE_FILES" ]'

# ---------------------------------------------------------------------------
# 3. hooks no fixture
# ---------------------------------------------------------------------------
FIX="$TMP/fix"
bash scripts/fixtures/git-history.sh "$FIX" > /dev/null

printf '{"cwd":"%s","source":"startup"}' "$FIX" | node hooks/ll-state.js > "$TMP/state.json"
CTX="$TMP/state.ctx"
node -e '
const o = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
if (o.hookSpecificOutput.hookEventName !== "SessionStart") process.exit(3);
require("fs").writeFileSync(process.argv[2], o.hookSpecificOutput.additionalContext + "\n");
' "$TMP/state.json" "$CTX"
check "ll-state emite JSON com hookEventName" '[ -s "$CTX" ]'
check "additionalContext ≤60 linhas"          '[ "$(wc -l < "$CTX")" -le 60 ]'
check "additionalContext traz o epílogo"      'grep -q "Epilogue" "$CTX"'
check "additionalContext traz o placar"       'grep -q "milestones 1/" "$CTX"'

printf '{"cwd":"%s","source":"compact"}' "$FIX" | node hooks/ll-state.js > "$TMP/state-c.json"
node -e '
const o = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
require("fs").writeFileSync(process.argv[2], o.hookSpecificOutput.additionalContext.split("\n")[0] + "\n");
' "$TMP/state-c.json" "$TMP/state-c.first"
check "source compact começa com [post-compaction]" 'grep -q "^\[post-compaction\]" "$TMP/state-c.first"'

C0="$(grep -c '^- \[compaction' "$FIX/PROGRESS.md")"
printf '{"cwd":"%s","trigger":"manual"}' "$FIX" | node hooks/ll-precompact.js > "$TMP/pre.out"
check "precompact avisa a sessão"    'grep -q "compaction marked in PROGRESS.md" "$TMP/pre.out"'
check "precompact inseriu 1 linha"   '[ "$(grep -c "^- \[compaction" "$FIX/PROGRESS.md")" -eq "$((C0 + 1))" ]'
check "linha nova fica acima do epílogo" \
  'grep -n "^## Epilogue" "$FIX/PROGRESS.md" | head -1 | cut -d: -f1 | xargs -I{} sh -c "sed -n \"\$(({} - 2))p\" \"$FIX/PROGRESS.md\"" | grep -q "^- \[compaction .* manual "'

# ---------------------------------------------------------------------------
# 4. os 12 comandos do helper
# ---------------------------------------------------------------------------
cd "$FIX"
$HELPER waves phases/07/PLAN.md --json > "$TMP/waves.json"
check "waves: 4 ondas"                'grep -q "\"wave\":4" "$TMP/waves.json"'
check "waves: M9 vira defeito"        'grep -q "unknown_depends_on" "$TMP/waves.json"'
check "waves: colisão M5/M6 em src/pay.ts" 'grep -q "file_overlap" "$TMP/waves.json" && grep -q "src/pay.ts" "$TMP/waves.json"'
check "waves: bloqueio propaga de M3" 'grep -q "\"M5\":\[\"M3\",\"M5\"\]" "$TMP/waves.json"'

$HELPER tdd-gate M1 --json > "$TMP/tdd1.json"
check "tdd-gate M1 passa"             'grep -q "\"tdd\":\"pass\"" "$TMP/tdd1.json"'
check "tdd-gate M1 ignora M10"        '! grep -q "M10" "$TMP/tdd1.json"'
check "tdd-gate M2 reprova"           '$HELPER tdd-gate M2 --json | grep -q "\"tdd\":\"fail\""'

check "spot-check M1 passa"           '$HELPER spot-check M1 --files src/a.ts,test/a.test.ts --json | grep -q "\"verdict\":\"pass\""'
check "state: fase 07, 1/3"           '$HELPER state --json | grep -q "\"total\":3,\"passed\":1"'
check "ledger: 1 FRESH 1 STALE 1 UNKNOWN" '$HELPER ledger --json | grep -q "\"FRESH\":1,\"STALE\":1,\"UNKNOWN\":1"'
check "epilogue 07 aponta a fase 8"   '$HELPER epilogue 07 --json | grep -q "\"next_command\":\"ll-implement 8\""'
check "phase-stats: 5 dias com trabalho" '$HELPER phase-stats --json | grep -q "\"days_with_work\":5"'
check "phase-stats: fase 07 com questions/owner_prompts" \
  '$HELPER phase-stats --json | grep -q "\"phase\":\"07\"" && $HELPER phase-stats --json | grep -q "\"questions\":3" && $HELPER phase-stats --json | grep -q "\"owner_prompts\":2"'
check "phase-stats: targets presente"   '$HELPER phase-stats --json | grep -q "\"targets\""'
check "epilogue 07 humano traz targets" '$HELPER epilogue 07 | grep -q "targets:"'
check "plan-lint reprova o PLAN"      '$HELPER plan-lint phases/07/PLAN.md --json | grep -q "\"verdict\":\"fail\""'
check "plan-lint acusa acceptance-missing em M6" '$HELPER plan-lint phases/07/PLAN.md --json | grep -q "acceptance-missing"'
check "plan-lint aceita o número da fase"  '$HELPER plan-lint 7 --json | grep -q "\"verdict\":\"fail\"" && $HELPER waves 07 --json | grep -q "\"waves\""'

cp PROGRESS.md "$TMP/progress-before"
$HELPER passes M2 true --json > "$TMP/passes.json"
check "passes M2 true grava"          'grep -q "\"passes\":true" "$TMP/passes.json"'
check "passes muda exatamente 2 linhas" \
  '[ "$(diff "$TMP/progress-before" PROGRESS.md | grep -c "^[<>]")" -eq 2 ]'
check "passes M9 cria a linha"        '$HELPER passes M9 true --json | grep -q "\"created\":true"'
mkdir -p "$TMP/emptymap" && sed 's/^milestones:$/milestones: {}/' "$TMP/progress-before" | awk '/^milestones: \{\}$/{print; skip=1; next} skip && /^  (M[0-9]+|G-[0-9]+):/{next} {skip=0; print}' > "$TMP/emptymap/PROGRESS.md"
check "passes com milestones: {} cria a entrada" \
  '$HELPER passes M1 true --cwd "$TMP/emptymap" --json | grep -q "\"created\":true" && grep -q "^milestones:$" "$TMP/emptymap/PROGRESS.md" && grep -q "^  M1: {" "$TMP/emptymap/PROGRESS.md"'

check "dec-reserve 2 → 0042/0043"     '$HELPER dec-reserve 2 --json | grep -q "\"DEC-0042\",\"DEC-0043\""'
check "dec-reserve 2 → 0044/0045"     '$HELPER dec-reserve 2 --json | grep -q "\"DEC-0044\",\"DEC-0045\""'

FIXDECF="$TMP/fix-decf"
cp -R "$FIX" "$FIXDECF"
rm -f "$FIXDECF"/decisions/*.md
touch "$FIXDECF/decisions/DEC-X-001-a.md" "$FIXDECF/decisions/DEC-X-002-b.md"
(cd "$FIXDECF" && $HELPER dec-reserve 1 --json) > "$TMP/dec-x.json"
check "dec-reserve sem --prefix detecta DEC-X → 003" 'grep -q "\"ids\":\[\"DEC-X-003\"\]" "$TMP/dec-x.json"'
check "dec-reserve sem --prefix retorna prefix DEC-X" 'grep -q "\"prefix\":\"DEC-X\"" "$TMP/dec-x.json"'

check "heartbeat escreve no PROGRESS" '$HELPER heartbeat "smoke test ran" --json | grep -q "\"ok\":true"'
check "heartbeat acima do epílogo"    'grep -q "smoke test ran" PROGRESS.md'

$HELPER backlog-reconcile --run --json > "$TMP/backlog.json"
check "backlog-reconcile fecha só B-014" 'grep -q "\"closed\":\[\"B-014\"\]" "$TMP/backlog.json"'
check "B-014 virou CLOSED no arquivo"    'grep "B-014" BACKLOG.md | grep -q "CLOSED"'
check "B-015 continua OPEN"              'grep "B-015" BACKLOG.md | grep -q "OPEN"'

# comandos de leitura fora de um projeto: ok:false e exit 0
cd "$EMPTY"
for cmd in waves tdd-gate spot-check state ledger backlog-reconcile epilogue phase-stats plan-lint; do
  check "$cmd fora de projeto imprime ok:false e sai 0" \
    "$HELPER $cmd M1 > \"$TMP/r.out\" 2>/dev/null; [ \$? -eq 0 ] && grep -q '\"ok\":false' \"$TMP/r.out\""
done
cd "$ROOT"

# ---------------------------------------------------------------------------
# 4b. nested state root (PROGRESS.md/phases/ under docs/state/, sources at git top)
# ---------------------------------------------------------------------------
NEST="$TMP/nest"
bash scripts/fixtures/git-history.sh "$NEST" > /dev/null
mkdir -p "$NEST/docs/state"
mv "$NEST/PROGRESS.md" "$NEST/ROADMAP.md" "$NEST/PLAN.md" "$NEST/VERIFICATION.md" "$NEST/BACKLOG.md" \
   "$NEST/phases" "$NEST/decisions" "$NEST/docs/state/"

$HELPER spot-check M1 --files src/a.ts,test/a.test.ts --cwd "$NEST/docs/state" --json > "$TMP/nest-spot.json"
check "nested spot-check M1 passa"       'grep -q "\"verdict\":\"pass\"" "$TMP/nest-spot.json"'
check "nested spot-check acha os 2 arquivos no topo do git" 'grep -q "\"found\":2" "$TMP/nest-spot.json"'

$HELPER state --cwd "$NEST/docs/state" --json > "$TMP/nest-state.json"
check "nested state: git_top aponta ao topo do git" \
  'grep -q "\"git_top\":\"'"$NEST"'\"" "$TMP/nest-state.json"'

check "nested ledger: FRESH/STALE/UNKNOWN iguais ao topo" \
  '$HELPER ledger --cwd "$NEST/docs/state" --json | grep -q "\"FRESH\":1,\"STALE\":1,\"UNKNOWN\":1"'

printf '{"cwd":"%s","source":"compact"}' "$NEST" | node hooks/ll-state.js > "$TMP/nest-hook.json"
check "nested hook ll-state acha o PROGRESS em docs/state" 'grep -q "post-compaction" "$TMP/nest-hook.json" && grep -q "milestones [0-9]/3" "$TMP/nest-hook.json"'
printf '{"cwd":"%s","trigger":"auto"}' "$NEST" | node hooks/ll-precompact.js > "$TMP/nest-pre.out"
check "nested hook precompact carimba docs/state/PROGRESS.md" 'grep -q "compaction marked" "$TMP/nest-pre.out" && grep -q "^- \[compaction " "$NEST/docs/state/PROGRESS.md"'

$HELPER backlog-reconcile --run --cwd "$NEST/docs/state" --json > "$TMP/nest-backlog.json"
check "nested backlog-reconcile fecha B-014 (comando roda no topo do git)" \
  'grep -q "\"closed\":\[\"B-014\"\]" "$TMP/nest-backlog.json"'

# invocado a partir do topo do git (sem PROGRESS.md/phases ali): acha a raiz deslocada por busca descendente
NEST_REAL="$(realpath "$NEST")"
$HELPER state --cwd "$NEST" --json > "$TMP/nest-top-state.json"
check "state do topo acha root deslocado" \
  'grep -q "\"root\":\"'"$NEST_REAL"'/docs/state\"" "$TMP/nest-top-state.json"'
check "state do topo reporta git_top correto" \
  'grep -q "\"git_top\":\"'"$NEST_REAL"'\"" "$TMP/nest-top-state.json"'

$HELPER spot-check M1 --files src/a.ts,test/a.test.ts --cwd "$NEST" --json > "$TMP/nest-top-spot.json"
check "spot-check do topo acha a raiz deslocada" \
  'grep -q "\"verdict\":\"pass\"" "$TMP/nest-top-spot.json"'

# ---------------------------------------------------------------------------
# 5. instalador
# ---------------------------------------------------------------------------
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

node bin/install.js < /dev/null > "$TMP/install1.log"

check "11 skills ll-* instaladas"     '[ "$(ls "$CLAUDE_CONFIG_DIR/skills" | grep -c "^ll-")" -eq 11 ]'
for s in ll-brainstorm ll-research ll-decide ll-goal ll-implement ll-verify ll-close ll-resume ll-refine ll-oncall ll-update; do
  check "skill $s instalada"          '[ -f "$CLAUDE_CONFIG_DIR/skills/'"$s"'/SKILL.md" ]'
done
for a in ll-executor ll-scout ll-verifier ll-reviewer; do
  check "agente $a instalado"         '[ -f "$CLAUDE_CONFIG_DIR/agents/'"$a"'.md" ]'
done
check "agente legado não instalado"   '[ ! -e "$CLAUDE_CONFIG_DIR/agents/ll-implementador.md" ]'
check "manifesto não lista nada 1.x"  '! grep -qE "(skills/ll-(atualizar|decidir-antes|desarmar|orquestrar|pesquisar|pesquisar-mercado|verificar-entrega|voltar-do-futuro)/|agents/ll-implementador)" "$CLAUDE_CONFIG_DIR/ll-skills/manifest.json"'
for h in ll-skills-check-update.js ll-state.js ll-precompact.js; do
  check "hook $h instalado e executável" '[ -x "$CLAUDE_CONFIG_DIR/hooks/'"$h"'" ]'
done
check "VERSION bate com package.json" '[ "$(cat "$CLAUDE_CONFIG_DIR/ll-skills/VERSION")" = "$(node -p "require(\"./package.json\").version")" ]'
check "órfão próprio podado"          '[ ! -e "$CLAUDE_CONFIG_DIR/skills/ll-antiga" ]'
check "arquivo alheio preservado"     '[ -f "$CLAUDE_CONFIG_DIR/skills/alheia/SKILL.md" ]'
check "hook alheio preservado"        'grep -q "echo alheio" "$CLAUDE_CONFIG_DIR/settings.json"'
check "hook próprio registrado 1x"    '[ "$(grep -c ll-skills-check-update "$CLAUDE_CONFIG_DIR/settings.json")" -eq 1 ]'
check "chave do plugin legado removida" '! grep -q "ll-skills@ll-skills" "$CLAUDE_CONFIG_DIR/settings.json"'
check "outro plugin preservado"       'grep -q "outro@x" "$CLAUDE_CONFIG_DIR/settings.json"'
check "matcher startup|resume|compact" 'grep -q "startup|resume|compact" "$CLAUDE_CONFIG_DIR/settings.json"'
check "PreCompact registrado"         'grep -q "PreCompact" "$CLAUDE_CONFIG_DIR/settings.json" && grep -q "ll-precompact.js" "$CLAUDE_CONFIG_DIR/settings.json"'
check "ll-state registrado no SessionStart" 'grep -q "ll-state.js" "$CLAUDE_CONFIG_DIR/settings.json"'
check "diagnóstico de limpeza não executa nada" '[ -d "$CLAUDE_CONFIG_DIR" ]'
check "política sugerida impressa"    'grep -q "Política sugerida" "$TMP/install1.log"'

SHA_SRC="$(sha256sum scripts/ll-tools.js | cut -d" " -f1)"
for s in ll-implement ll-verify ll-close; do
  check "helper copiado em $s"        '[ -x "$CLAUDE_CONFIG_DIR/skills/'"$s"'/scripts/ll-tools.js" ]'
  check "helper de $s com sha idêntico" \
    '[ "$(sha256sum "$CLAUDE_CONFIG_DIR/skills/'"$s"'/scripts/ll-tools.js" | cut -d" " -f1)" = "$SHA_SRC" ]'
done

cp "$CLAUDE_CONFIG_DIR/settings.json" "$TMP/s1.json"
node bin/install.js < /dev/null > /dev/null
check "segunda instalação sem diff no settings" 'cmp -s "$CLAUDE_CONFIG_DIR/settings.json" "$TMP/s1.json"'

# --no-settings + --no-preamble num diretório limpo
CFG_NS="$TMP/cfg-ns"
mkdir -p "$CFG_NS"
echo '{"hooks":{}}' > "$CFG_NS/settings.json"
cp "$CFG_NS/settings.json" "$TMP/ns-before.json"
CLAUDE_CONFIG_DIR="$CFG_NS" node bin/install.js --no-settings --no-preamble < /dev/null > "$TMP/nosettings.log"
check "--no-settings não toca settings.json" 'cmp -s "$CFG_NS/settings.json" "$TMP/ns-before.json"'
check "--no-settings imprime o JSON dos hooks" 'grep -q "\"PreCompact\"" "$TMP/nosettings.log" && grep -q "\"SessionStart\"" "$TMP/nosettings.log"'
check "--no-preamble não cria CLAUDE.md"     '[ ! -e "$CFG_NS/CLAUDE.md" ]'

# hook de atualização: silencioso sem cache, avisa com cache indicando versão nova
check "leitor sem cache é silencioso" '[ -z "$(node "$CLAUDE_CONFIG_DIR/hooks/ll-skills-check-update.js")" ]'
mkdir -p "$XDG_CACHE_HOME/ll-skills"
V="$(cat "$CLAUDE_CONFIG_DIR/ll-skills/VERSION")"
printf '{"checked":%s,"installed":"%s","latest":"99.0.0","update_available":true,"method":"npm"}' "$(date +%s)" "$V" > "$XDG_CACHE_HOME/ll-skills/update-check.json"
check "leitor avisa versão nova" 'node "$CLAUDE_CONFIG_DIR/hooks/ll-skills-check-update.js" | grep -q "/ll-update"'

# ---------------------------------------------------------------------------
# 6. preâmbulo
# ---------------------------------------------------------------------------
check "não-TTY sem --yes não escreve CLAUDE.md" '[ ! -e "$CLAUDE_CONFIG_DIR/CLAUDE.md" ]'
check "não-TTY imprime o diff e a dica --yes"   'grep -q -- "--yes" "$TMP/install1.log"'

CMD="$CLAUDE_CONFIG_DIR/CLAUDE.md"
printf 'SENTINEL-TOP\n' > "$CMD"
node bin/install.js --yes < /dev/null > /dev/null
check "preâmbulo escrito com --yes"   'grep -q "ll-skills:preamble v1" "$CMD"'
check "sentinela de cima sobrevive"   'grep -q "SENTINEL-TOP" "$CMD"'

printf '\nSENTINEL-BOTTOM\n' >> "$CMD"
cp "$CMD" "$TMP/claudemd-1"
node bin/install.js --yes < /dev/null > /dev/null
check "preâmbulo idempotente"         'cmp -s "$CMD" "$TMP/claudemd-1"'
check "sentinela de baixo sobrevive"  'grep -q "SENTINEL-BOTTOM" "$CMD"'

rm -f "$CMD.ll-skills.bak"
sed -i 's/^## Skills$/## Skills MEXIDO A MAO/' "$CMD"
node bin/install.js --yes < /dev/null > /dev/null
check "corpo alterado à mão é restaurado" 'cmp -s "$CMD" "$TMP/claudemd-1"'
check "backup .ll-skills.bak existe"      '[ -f "$CMD.ll-skills.bak" ]'

# ---------------------------------------------------------------------------
# 7. poda das skills 1.x (com e sem manifesto)
# ---------------------------------------------------------------------------
LEGACY_SKILLS="ll-atualizar ll-decidir-antes ll-desarmar ll-orquestrar ll-pesquisar ll-pesquisar-mercado ll-verificar-entrega ll-voltar-do-futuro"
CFG_L="$TMP/cfg-legacy"
seed_legacy() {
  mkdir -p "$CFG_L/agents" "$CFG_L/skills/alheia"
  echo y > "$CFG_L/skills/alheia/SKILL.md"
  for s in $LEGACY_SKILLS; do mkdir -p "$CFG_L/skills/$s"; echo x > "$CFG_L/skills/$s/SKILL.md"; done
  echo x > "$CFG_L/agents/ll-implementador.md"
}
assert_pruned() {
  for s in $LEGACY_SKILLS; do
    check "$1: skill 1.x $s removida" '[ ! -e "$CFG_L/skills/'"$s"'" ]'
  done
  check "$1: agente 1.x removido"     '[ ! -e "$CFG_L/agents/ll-implementador.md" ]'
  check "$1: skills/alheia sobrevive" '[ -f "$CFG_L/skills/alheia/SKILL.md" ]'
}

mkdir -p "$CFG_L/ll-skills"
seed_legacy
{
  printf '{"version":"1.0.1","files":{'
  sep=""
  for s in $LEGACY_SKILLS; do printf '%s"skills/%s/SKILL.md":"a"' "$sep" "$s"; sep=","; done
  printf ',"agents/ll-implementador.md":"a"}}'
} > "$CFG_L/ll-skills/manifest.json"
CLAUDE_CONFIG_DIR="$CFG_L" node bin/install.js --no-preamble < /dev/null > /dev/null
assert_pruned "com manifesto"

seed_legacy   # agora o manifesto atual (2.x) não lista nada disso: só KNOWN_LEGACY resolve
CLAUDE_CONFIG_DIR="$CFG_L" node bin/install.js --no-preamble < /dev/null > /dev/null
assert_pruned "sem manifesto"

# ---------------------------------------------------------------------------
# 8. uninstall
# ---------------------------------------------------------------------------
node bin/install.js --uninstall < /dev/null > /dev/null
check "uninstall removeu skills"      '[ -z "$(ls "$CLAUDE_CONFIG_DIR/skills" | grep "^ll-" || true)" ]'
check "uninstall removeu as cópias do helper" '[ ! -e "$CLAUDE_CONFIG_DIR/skills/ll-implement" ]'
check "uninstall removeu os hooks do SessionStart" '! grep -q "ll-state.js" "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall removeu o PreCompact" '! grep -q "ll-precompact.js" "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall removeu o check-update" '! grep -q "ll-skills-check-update" "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall preservou alheios"   'grep -q "echo alheio" "$CLAUDE_CONFIG_DIR/settings.json" && [ -f "$CLAUDE_CONFIG_DIR/skills/alheia/SKILL.md" ]'
check "uninstall removeu o preâmbulo" '! grep -q "ll-skills:preamble" "$CMD"'
check "uninstall preservou as sentinelas" 'grep -q "SENTINEL-TOP" "$CMD" && grep -q "SENTINEL-BOTTOM" "$CMD"'

# ---------------------------------------------------------------------------
# 9. lint dos prompts (uma checagem por regra de scripts/lint-prompts.sh)
# ---------------------------------------------------------------------------
lint() { # lint <n>: roda uma regra e só imprime a saída quando ela falha
  bash "$ROOT/scripts/lint-prompts.sh" --rule "$1" > "$TMP/lint-$1.txt" 2>&1 \
    || { cat "$TMP/lint-$1.txt"; return 1; }
}

check "lint 1: frontmatter das skills"  'lint 1'
check "lint 2: frontmatter dos agentes" 'lint 2'
check "lint 3: tetos de linhas"         'lint 3'
check "lint 4: forma das SKILL.md"      'lint 4'
check "lint 5: strings proibidas"       'lint 5'
check "lint 6: cópias idênticas"        'lint 6'
check "lint 7: idioma"                  'lint 7'
check "lint 8: lista privada"           'lint 8'

# 10. lint de contrato entre as peças (uma checagem por regra de scripts/lint-contract.cjs)
contract() { node "$ROOT/scripts/lint-contract.cjs" --rule "$1" >/dev/null 2>&1; }
check "contrato 1: references citadas existem e são citadas"  'contract 1'
check "contrato 2: comandos do helper definidos e citados"     'contract 2'
check "contrato 3: agentes, modelos e campos do brief"         'contract 3'
check "contrato 4: vocabulário de veredito e estados"          'contract 4'
check "contrato 5: arquivos de estado nas tabelas de entregáveis" 'contract 5'
check "contrato 6: alvos do ▶ Next existem"                    'contract 6'
check "contrato 7: instalador × pacote"                        'contract 7'

# --- optional private word list (never shipped): LL_FORBIDDEN_FILE=<path> enables the check
if [ -n "${LL_FORBIDDEN_FILE:-}" ] && [ -f "$LL_FORBIDDEN_FILE" ]; then
  check "no private terms in tracked files" '! git ls-files | grep -v "^\.gitignore$" | xargs grep -n -i -w -E -f "$LL_FORBIDDEN_FILE" 2>/dev/null | grep -q .'
fi
echo "smoke test OK — $N checks"
