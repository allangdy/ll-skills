#!/usr/bin/env bash
# Smoke test do ll-skills: gate estático, hooks, helper, instalador, preâmbulo,
# poda de skills antigas e uninstall. Tudo num CLAUDE_CONFIG_DIR isolado.
# Uso: smoke-test.sh [--only <seção>]   (sem argumento roda tudo)
# As seções são os blocos numerados (1, 2, 3, 4, 4b, 4c, 4d, 5..10), lint-orquestrador,
# goal-autonomo, evals-auto, lint-scratch e no-talk; os blocos numerados montam estado uns para
# os outros, então --only puxa o pré-requisito de quem não roda sozinho (ver prereq abaixo).
set -euo pipefail
cd "$(dirname "$0")/.."
ROOT="$PWD"

ONLY=""
while [ $# -gt 0 ]; do
  case "$1" in
    --only) ONLY="${2:-}"; shift 2 ;;
    *) echo "uso: smoke-test.sh [--only <seção>]" >&2; exit 2 ;;
  esac
done
# Pré-requisitos: a seção 4 usa o $EMPTY que a 2 monta e o $FIX que a 3 monta, a 6 lê o
# CLAUDE_CONFIG_DIR e o log que a 5 monta, e a 8 desinstala o que a 5 instalou e o preâmbulo que a 6
# escreve. --only puxa essas seções antes da pedida.
prereq() { case "$1" in 4) echo "2 3" ;; 6) echo "5" ;; 8) echo "5 6" ;; *) echo "" ;; esac; }
RUN=""
[ -z "$ONLY" ] || RUN=" $(prereq "$ONLY") $ONLY "
section() { [ -z "$ONLY" ] || case "$RUN" in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

N=0
check() { N=$((N + 1)); if ! eval "$2"; then echo "FALHOU: $1"; exit 1; fi; }

HELPER="node $ROOT/scripts/ll-tools.js"
AUTO="node $ROOT/skills/ll-auto/scripts/ll-auto.js"
region() { awk '/^\/\/ <ll-shared:state>$/,/^\/\/ <\/ll-shared:state>$/' "$1"; }

# ---------------------------------------------------------------------------
# 1. gate estático
# ---------------------------------------------------------------------------
if section 1; then
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
fi

# ---------------------------------------------------------------------------
# 2. hooks silenciosos fora de um projeto
# ---------------------------------------------------------------------------
if section 2; then
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
fi

# ---------------------------------------------------------------------------
# 3. hooks no fixture
# ---------------------------------------------------------------------------
if section 3; then
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
fi

# ---------------------------------------------------------------------------
# 4. os 13 comandos do helper
# ---------------------------------------------------------------------------
if section 4; then
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
check "tdd-gate acha o id entre posicionais" '$HELPER tdd-gate phases/07/PLAN.md M1 --json | grep -q "\"tdd\":\"pass\""'

check "spot-check M1 passa"           '$HELPER spot-check M1 --files src/a.ts,test/a.test.ts --json | grep -q "\"verdict\":\"pass\""'
check "state: fase 07, 1/3"           '$HELPER state --json | grep -q "\"total\":3,\"passed\":1"'
check "ledger: 1 FRESH 1 STALE 1 UNKNOWN" '$HELPER ledger --json | grep -q "\"FRESH\":1,\"STALE\":1,\"UNKNOWN\":1"'
check "epilogue 07 aponta a fase 8"   '$HELPER epilogue 07 --json | grep -q "\"next_command\":\"ll-implement 8\""'
check "phase-stats: 5 dias com trabalho" '$HELPER phase-stats --json | grep -q "\"days_with_work\":5"'
check "phase-stats: fase 07 com questions/owner_prompts" \
  '$HELPER phase-stats --json | grep -q "\"phase\":\"07\"" && $HELPER phase-stats --json | grep -q "\"questions\":3" && $HELPER phase-stats --json | grep -q "\"owner_prompts\":2"'
check "phase-stats: targets presente"   '$HELPER phase-stats --json | grep -q "\"targets\""'
mkdir -p "$TMP/ep" && awk '/^## Epilogue — phase 07/{print "## Epilogue — phase 06 — 2026-09-08"; print "passed: M1 · left: none"; print ""} {print}' PROGRESS.md | sed 's/· amendments 1 · verification:/· amendments 1 (M3) · verification:/' > "$TMP/ep/PROGRESS.md"
$HELPER phase-stats --cwd "$TMP/ep" --json > "$TMP/ep.json"
check "phase-stats: epílogo sem linha de contagem não rouba a da fase seguinte" 'grep -q "\"phase\":\"06\",\"count_line\":false" "$TMP/ep.json"'
check "phase-stats: parêntese após amendments é aceito" 'grep -q "\"amendments\":1,\"verdict\":\"APPROVED\",\"verification\":\"phases/07/VERIFICATION.md\"" "$TMP/ep.json"'
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

BSW="$TMP/bsw"
cp -R "$FIX" "$BSW"
$HELPER board-switch 08 --milestones M1,M2 --cwd "$BSW" --json > "$TMP/bsw.json"
check "board-switch 08 troca a fase do placar" \
  'grep -q "\"phase\":\"08\"" "$TMP/bsw.json" && grep -q "\"from\":\"07\"" "$TMP/bsw.json" && grep -q "^phase: 08$" "$BSW/PROGRESS.md"'
check "board-switch semeia 2 marcos e apaga os antigos" \
  '[ "$(grep -c "^  \(M[0-9]*\|G-[0-9]*\): {" "$BSW/PROGRESS.md")" -eq 2 ] && grep -q "^  M2: { passes: false" "$BSW/PROGRESS.md" && ! grep -q "a1b2c3d" "$BSW/PROGRESS.md"'
check "board-switch na mesma fase só semeia o que falta" \
  '$HELPER board-switch 08 --milestones M1,M2,M3 --cwd "$BSW" --json | grep -q "\"seeded\":\[\"M3\"\]" && [ "$(grep -c "^  M[0-9]*: {" "$BSW/PROGRESS.md")" -eq 3 ]'
check "passes --phase 07 recusa o placar da 08" \
  '$HELPER passes M1 true --commit abc1234 --phase 07 --cwd "$BSW" > "$TMP/pw.out" 2>/dev/null; [ $? -eq 1 ] && grep -q "\"ok\":false" "$TMP/pw.out" && grep -q "board is phase 08, not 07" "$TMP/pw.out"'
check "passes --phase 08 grava no placar da 08" \
  '$HELPER passes M1 true --commit abc1234 --phase 08 --cwd "$BSW" --json | grep -q "\"passes\":true"'

check "heartbeat escreve no PROGRESS" '$HELPER heartbeat "smoke test ran" --json | grep -q "\"ok\":true"'
check "heartbeat acima do epílogo"    'grep -q "smoke test ran" PROGRESS.md'

$HELPER backlog-reconcile --run --json > "$TMP/backlog.json"
check "backlog-reconcile fecha só B-014" 'grep -q "\"closed\":\[\"B-014\"\]" "$TMP/backlog.json"'
check "B-014 virou CLOSED no arquivo"    'grep "B-014" BACKLOG.md | grep -q "CLOSED"'
check "B-015 continua OPEN"              'grep "B-015" BACKLOG.md | grep -q "OPEN"'
check "backlog-reconcile acusa B-017 unparsable" \
  '$HELPER backlog-reconcile --json > "$TMP/bk017.json"; grep -q "\"id\":\"B-017\",\"state\":\"OPEN\"" "$TMP/bk017.json" && grep -q "\"unparsable-condition\"" "$TMP/bk017.json"'
check "epilogue 07 humano lista o unparsable" '$HELPER epilogue 07 | grep -q "unparsable: B-017"'
check "epilogue 07 json traz unparsable"      '$HELPER epilogue 07 --json | grep -q "\"unparsable\":\[\"B-017\"\]"'
check "phase-stats --since do dia do último commit é inclusivo" \
  '$HELPER phase-stats --since 2026-09-09 --json | grep -q "\"commits\":1"'
mkdir -p "$TMP/oldw" && sed "s/owner decisions open/band-1 open/" PROGRESS.md > "$TMP/oldw/PROGRESS.md"
check "phase-stats aceita a redação antiga da linha de contagem" \
  '$HELPER phase-stats --cwd "$TMP/oldw" --json | grep -q "\"band1_open\":0"'

# comandos de leitura fora de um projeto: ok:false e exit 0
cd "$EMPTY"
for cmd in waves tdd-gate spot-check state ledger backlog-reconcile epilogue phase-stats plan-lint; do
  check "$cmd fora de projeto imprime ok:false e sai 0" \
    "$HELPER $cmd M1 > \"$TMP/r.out\" 2>/dev/null; [ \$? -eq 0 ] && grep -q '\"ok\":false' \"$TMP/r.out\""
done
cd "$ROOT"
fi

# ---------------------------------------------------------------------------
# 4b. nested state root (PROGRESS.md/phases/ under docs/state/, sources at git top)
# ---------------------------------------------------------------------------
if section 4b; then
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
mkdir -p "$NEST/docs/other" && printf '# other progress\n\nno state block here\n' > "$NEST/docs/other/PROGRESS.md" && touch "$NEST/docs/other/PROGRESS.md"
printf '{"cwd":"%s","source":"compact"}' "$NEST" | node hooks/ll-state.js > "$TMP/nest-hook2.json"
check "nested hook: entre vários PROGRESS.md escolhe o que tem bloco ll-state" 'grep -q "milestones [0-9]/3" "$TMP/nest-hook2.json"'
rm -rf "$NEST/docs/other"
mkdir -p "$NEST/docs/fixtures/project" && cp "$NEST/docs/state/PROGRESS.md" "$NEST/docs/fixtures/project/PROGRESS.md" && mv "$NEST/docs/state" "$TMP/state-aside"
check "hook ignora PROGRESS.md dentro de fixtures/" '[ -z "$(printf "{\"cwd\":\"%s\",\"source\":\"startup\"}" "$NEST" | node hooks/ll-state.js)" ]'
mv "$TMP/state-aside" "$NEST/docs/state"
rm -rf "$NEST/docs/fixtures"

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
fi

# ---------------------------------------------------------------------------
# 4c. helper ll-auto: detect
# ---------------------------------------------------------------------------
if section 4c; then
# ids e status exatos de um detect --json: renomear um status ou perder um estágio reprova
auto_ids() { node -e 'const o=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));console.log(o.stages.map((s)=>s.id).join(","))' "$1"; }
auto_status_set() { node -e 'const o=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));console.log([...new Set(o.stages.map((s)=>s.status))].sort().join(","))' "$1"; }
check "ll-auto detect: fixture project → decide done, 07 half" \
  '$AUTO detect --cwd "$ROOT/scripts/fixtures/project" --json > "$TMP/auto-project.json" \
   && grep -q "\"id\":\"decide\",\"status\":\"done\"" "$TMP/auto-project.json" \
   && grep -q "\"id\":\"phase-07\",\"status\":\"half\"" "$TMP/auto-project.json"'
check "ll-auto detect: fixture empty → os 4 estágios exatos, todos todo" \
  '$AUTO detect --cwd "$ROOT/scripts/fixtures/empty" --json > "$TMP/auto-empty.json" \
   && [ "$(auto_ids "$TMP/auto-empty.json")" = "research,brainstorm,decide,close" ] \
   && [ "$(auto_status_set "$TMP/auto-empty.json")" = "todo" ]'
check "ll-auto detect: sem ROADMAP.md as fases saem da tabela do §8 do PLAN" \
  '$AUTO detect --cwd "$ROOT/scripts/fixtures/auto-noroadmap" --json > "$TMP/auto-noroadmap.json" \
   && [ "$(auto_ids "$TMP/auto-noroadmap.json")" = "research,brainstorm,decide,phase-01,phase-02,verify-01,verify-02,close" ] \
   && grep -q "\"id\":\"phase-01\",\"status\":\"done\"" "$TMP/auto-noroadmap.json" \
   && grep -q "\"id\":\"phase-02\",\"status\":\"todo\"" "$TMP/auto-noroadmap.json"'
check "ll-auto detect: DELIVERY.md + epílogo da última fase → close done" \
  '$AUTO detect --cwd "$ROOT/scripts/fixtures/auto-closed" --json > "$TMP/auto-closed.json" \
   && grep -q "\"id\":\"close\",\"status\":\"done\",\"evidence\":\"docs/DELIVERY.md + epilogue for phase 02\"" "$TMP/auto-closed.json" \
   && grep -q "\"id\":\"phase-02\",\"status\":\"done\"" "$TMP/auto-closed.json" \
   && [ "$(auto_status_set "$TMP/auto-closed.json")" = "done,todo" ]'
check "ll-auto detect: diretório inexistente → ok:false e exit 0" \
  '$AUTO detect --cwd /nonexistent --json > "$TMP/auto-nodir.json" 2>/dev/null; [ $? -eq 0 ] \
   && grep -q "\"ok\":false" "$TMP/auto-nodir.json" && grep -q "not a directory" "$TMP/auto-nodir.json"'
check "ll-auto detect --json é JSON válido" \
  '$AUTO detect --cwd "$ROOT/scripts/fixtures/project" --json \
   | node -e "JSON.parse(require(\"fs\").readFileSync(0,\"utf8\"))"'
fi

# ---------------------------------------------------------------------------
# 4d. helper ll-auto: roteiro, next-cmd, report, auto-md
# ---------------------------------------------------------------------------
if section 4d; then
check "ll-auto roteiro: --verify all → 07, verify-07, 08, verify-08, close" \
  '$AUTO roteiro --cwd "$ROOT/scripts/fixtures/project" --flags "--verify all" --json > "$TMP/auto-verify-all.json" \
   && grep -q "\"stage\":\"phase-07\".*\"stage\":\"verify-07\".*\"stage\":\"phase-08\".*\"stage\":\"verify-08\".*\"stage\":\"close\"" "$TMP/auto-verify-all.json" \
   && ! grep -qE "\"stage\":\"(research|brainstorm|decide|phase-05|phase-06)\"" "$TMP/auto-verify-all.json"'
check "ll-auto roteiro: --only 8 corta o close e as outras fases" \
  '$AUTO roteiro --cwd "$ROOT/scripts/fixtures/project" --flags "--only 8" --json > "$TMP/auto-only8.json" \
   && grep -q "\"stage\":\"phase-08\",\"command\":\"ll-implement 08 --no-talk\"" "$TMP/auto-only8.json" \
   && ! grep -qE "\"stage\":\"(phase-07|close)\"" "$TMP/auto-only8.json"'
check "ll-auto roteiro: repo vazio sem objetivo pede o objetivo" \
  '$AUTO roteiro --cwd "$ROOT/scripts/fixtures/empty" --flags "" --json > "$TMP/auto-vazio.json" \
   && grep -q "\"needs_objective\":true" "$TMP/auto-vazio.json" \
   && grep -q "\"roteiro\":\[\]" "$TMP/auto-vazio.json"'
check "ll-auto roteiro: repo vazio com objetivo → research, brainstorm, decide, close" \
  '$AUTO roteiro --cwd "$ROOT/scripts/fixtures/empty" --objective "um objetivo" \
     --flags "--research --brainstorm" --json > "$TMP/auto-vazio2.json" \
   && grep -q "\"stage\":\"research\".*\"stage\":\"brainstorm\".*\"stage\":\"decide\".*\"stage\":\"close\"" "$TMP/auto-vazio2.json" \
   && grep -q "\"needs_objective\":false" "$TMP/auto-vazio2.json"'
check "ll-auto roteiro: --interactive --redo phase-05 --pause-at 8" \
  '$AUTO roteiro --cwd "$ROOT/scripts/fixtures/project" \
     --flags "--interactive --redo phase-05 --pause-at 8" --json > "$TMP/auto-redo.json" \
   && grep -q "\"stage\":\"phase-05\",\"command\":\"ll-implement 05\",\"status\":\"done\"" "$TMP/auto-redo.json" \
   && ! grep -q "ll-implement 05 --no-talk" "$TMP/auto-redo.json" \
   && grep -q "\"stage\":\"phase-08\",\"command\":\"ll-implement 08\",\"status\":\"todo\",\"pause_after\":true" "$TMP/auto-redo.json"'
check "ll-auto roteiro: epílogo que pede ll-verify 01 insere verify-01 sem --verify all" \
  '$AUTO roteiro --cwd "$ROOT/scripts/fixtures/auto-verify-next" --flags "" --json > "$TMP/auto-vnext.json" \
   && grep -q "\"stage\":\"phase-01\",\"command\":\"ll-implement 01 --no-talk\".*\"stage\":\"verify-01\",\"command\":\"ll-verify 01\"" "$TMP/auto-vnext.json" \
   && $AUTO roteiro --cwd "$ROOT/scripts/fixtures/project" --flags "" --json > "$TMP/auto-noverify.json" \
   && ! grep -q "\"stage\":\"verify-" "$TMP/auto-noverify.json"'
check "ll-auto next-cmd: o epílogo da fixture aponta ll-implement 8" \
  '[ "$($AUTO next-cmd "$ROOT/scripts/fixtures/project/PROGRESS.md")" = "ll-implement 8" ]'
check "ll-auto next-cmd: arquivo sem ▶ Next → saída vazia, exit 0" \
  '[ -z "$($AUTO next-cmd "$ROOT/scripts/fixtures/project/ROADMAP.md")" ]'
check "ll-auto report: só o DEC com a marca de decidido sozinho" \
  '$AUTO report --cwd "$ROOT/scripts/fixtures/auto-decisions" --json > "$TMP/auto-report.json" \
   && grep -q "DEC-0001-taken-alone.md" "$TMP/auto-report.json" \
   && ! grep -q "DEC-0002-owner.md" "$TMP/auto-report.json"'
check "ll-auto auto-md: as cinco seções, o objetivo e as flags" \
  '$AUTO auto-md --cwd "$ROOT/scripts/fixtures/project" --objective "um objetivo" --flags "--only 8" \
     > "$TMP/auto-md.txt" \
   && grep -q "^## Objective" "$TMP/auto-md.txt" && grep -q "^## Flags" "$TMP/auto-md.txt" \
   && grep -q "^## Roteiro" "$TMP/auto-md.txt" && grep -q "^## Decisions taken alone" "$TMP/auto-md.txt" \
   && grep -q "^## Log" "$TMP/auto-md.txt" \
   && grep -q "^um objetivo$" "$TMP/auto-md.txt" && grep -q -e "^--only 8$" "$TMP/auto-md.txt" \
   && grep -q "^| # | stage | command | status | evidence |$" "$TMP/auto-md.txt" \
   && grep -q "^| 1 | phase-08 | ll-implement 08 --no-talk | todo |" "$TMP/auto-md.txt"'
fi

# ---------------------------------------------------------------------------
# 5. instalador
# ---------------------------------------------------------------------------
if section 5; then
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

check "12 skills ll-* instaladas"     '[ "$(ls "$CLAUDE_CONFIG_DIR/skills" | grep -c "^ll-")" -eq 12 ]'
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

SHA_AUTO_SRC="$(sha256sum skills/ll-auto/scripts/ll-auto.js | cut -d" " -f1)"
check "ll-auto.js instalado executável"    '[ -x "$CLAUDE_CONFIG_DIR/skills/ll-auto/scripts/ll-auto.js" ]'
check "ll-auto.js instalado com sha idêntico" \
  '[ "$(sha256sum "$CLAUDE_CONFIG_DIR/skills/ll-auto/scripts/ll-auto.js" | cut -d" " -f1)" = "$SHA_AUTO_SRC" ]'

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
fi

# ---------------------------------------------------------------------------
# 6. preâmbulo
# ---------------------------------------------------------------------------
if section 6; then
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
fi

# ---------------------------------------------------------------------------
# 7. poda das skills 1.x (com e sem manifesto)
# ---------------------------------------------------------------------------
if section 7; then
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
fi

# ---------------------------------------------------------------------------
# 8. uninstall
# ---------------------------------------------------------------------------
if section 8; then
node bin/install.js --uninstall < /dev/null > /dev/null
check "uninstall removeu skills"      '[ -z "$(ls "$CLAUDE_CONFIG_DIR/skills" | grep "^ll-" || true)" ]'
check "uninstall removeu as cópias do helper" '[ ! -e "$CLAUDE_CONFIG_DIR/skills/ll-implement" ]'
check "uninstall removeu os hooks do SessionStart" '! grep -q "ll-state.js" "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall removeu o PreCompact" '! grep -q "ll-precompact.js" "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall removeu o check-update" '! grep -q "ll-skills-check-update" "$CLAUDE_CONFIG_DIR/settings.json"'
check "uninstall preservou alheios"   'grep -q "echo alheio" "$CLAUDE_CONFIG_DIR/settings.json" && [ -f "$CLAUDE_CONFIG_DIR/skills/alheia/SKILL.md" ]'
check "uninstall removeu o preâmbulo" '! grep -q "ll-skills:preamble" "$CMD"'
check "uninstall preservou as sentinelas" 'grep -q "SENTINEL-TOP" "$CMD" && grep -q "SENTINEL-BOTTOM" "$CMD"'
fi

# ---------------------------------------------------------------------------
# 9. lint dos prompts (uma checagem por regra de scripts/lint-prompts.sh)
# ---------------------------------------------------------------------------
if section 9; then
lint() { # lint <n>: roda uma regra e só imprime a saída quando ela falha
  bash "$ROOT/scripts/lint-prompts.sh" --rule "$1" > "$TMP/lint-$1.txt" 2>&1 \
    || { cat "$TMP/lint-$1.txt"; return 1; }
}

check "lint 1: frontmatter das skills"  'lint 1'
check "lint 2: frontmatter dos agentes" 'lint 2'
check "lint 3: tetos de linhas"         'lint 3'
printf '[{"unpackedSize":999999999}]' > "$TMP/pack-list-big.json"
check "lint 3: honra LL_PACK_JSON na forma lista (npm ≤ 11) e reprova no teto sintético" \
  '! LL_PACK_JSON="$TMP/pack-list-big.json" bash "$ROOT/scripts/lint-prompts.sh" --rule 3 > "$TMP/lint-pack-list.out" 2>&1; \
   grep -q "unpackedSize 999999999 bytes, ceiling 921600" "$TMP/lint-pack-list.out"'
printf '{"ll-skills":{"unpackedSize":999999999}}' > "$TMP/pack-object-big.json"
check "lint 3: honra LL_PACK_JSON na forma objeto (npm 12) e reprova no teto sintético" \
  '! LL_PACK_JSON="$TMP/pack-object-big.json" bash "$ROOT/scripts/lint-prompts.sh" --rule 3 > "$TMP/lint-pack-object.out" 2>&1; \
   grep -q "unpackedSize 999999999 bytes, ceiling 921600" "$TMP/lint-pack-object.out"'
check "lint 4: forma das SKILL.md"      'lint 4'
check "lint 5: strings proibidas"       'lint 5'
check "lint 6: cópias idênticas"        'lint 6'
check "lint 7: idioma"                  'lint 7'
check "lint 8: lista privada"           'lint 8'
check "lint 9: perguntas sem jargão"    'lint 9 && grep -q "^ok   9 plain questions" "$TMP/lint-9.txt"'
fi

# 10. lint de contrato entre as peças (uma checagem por regra de scripts/lint-contract.cjs)
if section 10; then
contract() { node "$ROOT/scripts/lint-contract.cjs" --rule "$1" >/dev/null 2>&1; }
check "contrato 1: references citadas existem e são citadas"  'contract 1'
check "contrato 2: comandos do helper definidos e citados"     'contract 2'
check "contrato 3: agentes, modelos e campos do brief"         'contract 3'
check "contrato 4: vocabulário de veredito e estados"          'contract 4'
check "contrato 5: arquivos de estado nas tabelas de entregáveis" 'contract 5'
check "contrato 6: alvos do ▶ Next existem"                    'contract 6'
check "contrato 7: instalador × pacote"                        'contract 7'

# regra 6 contra as fixtures da gramática do ▶ Next (bad falha, good passa, raiz sem skills falha)
contract_root() { node "$ROOT/scripts/lint-contract.cjs" --rule 6 --root "$1" >/dev/null 2>&1; }
contract_fails() { node "$ROOT/scripts/lint-contract.cjs" --rule 6 --root "$1" 2>/dev/null | grep -c "^FAIL 6 " || true; }
check "contrato 6: next-bad falha"        '! contract_root scripts/fixtures/next-bad'
# a contagem é fixa: afrouxar uma das formas rejeitadas reprova aqui, não só o exit
check "contrato 6: next-bad com 6 FAIL"   '[ "$(contract_fails scripts/fixtures/next-bad)" -eq 6 ]'
check "contrato 6: duas skills diferentes num ▶ Next fora de parêntese reprovam" \
  'node "$ROOT/scripts/lint-contract.cjs" --rule 6 --root scripts/fixtures/next-bad > "$TMP/next-bad.out" 2>/dev/null; \
   grep -q "lists alternatives outside a parenthetical —ll-bad or ll-nope" "$TMP/next-bad.out"'
check "contrato 6: next-good passa"       'contract_root scripts/fixtures/next-good'
check "contrato 6: raiz sem skills falha" '! contract_root scripts/fixtures/empty'

# --- optional private word list (never shipped): LL_FORBIDDEN_FILE=<path> enables the check
if [ -n "${LL_FORBIDDEN_FILE:-}" ] && [ -f "$LL_FORBIDDEN_FILE" ]; then
  check "no private terms in tracked files" '! git ls-files | grep -v "^\.gitignore$" | xargs grep -n -i -w -E -f "$LL_FORBIDDEN_FILE" 2>/dev/null | grep -q .'
fi
fi

# ---------------------------------------------------------------------------
# lint-orquestrador. as exceções de ll-auto valem só para ll-auto
# ---------------------------------------------------------------------------
if section lint-orquestrador; then
cd "$ROOT"
SCR="$TMP/lint-scratch"
mkdir -p "$SCR"
git ls-files -z | xargs -0 cp --parents -t "$SCR"
git -C "$SCR" init -q
git -C "$SCR" add -A
mkdir -p "$SCR/skills/ll-fake"
cat > "$SCR/skills/ll-fake/SKILL.md" <<'FAKE'
---
name: ll-fake
description: Pretends to be an orchestrator so the lint can prove the ll-auto exceptions do not leak to any other skill on the tree.
argument-hint: "[--flag]"
disable-model-invocation: true
allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)
---

# Fake

## Deliverables

| File | Role | Mutability |
|---|---|---|
| `docs/FAKE.md` | nothing | never |

## Flow

/ll-research x

## Completion criterion

▶ Next — /clear, then ll-resume
FAKE
git -C "$SCR" add -A
lint_scr() { bash "$SCR/scripts/lint-prompts.sh" --rule "$1" > "$TMP/scr-rule$1.out" 2>&1; }
lint_real() { bash "$ROOT/scripts/lint-prompts.sh" --rule "$1" >/dev/null 2>&1; }

check "orquestrador: skills/ll-auto/SKILL.md existe" '[ -f "$ROOT/skills/ll-auto/SKILL.md" ]'
check "orquestrador: regra 1 reprova o allowed-tools do ll-auto em outra skill" \
  '! lint_scr 1 && grep -q "^FAIL 1 .*skills/ll-fake/SKILL.md: allowed-tools" "$TMP/scr-rule1.out"'
check "orquestrador: regra 5 reprova a linha /ll- em outra skill" \
  '! lint_scr 5 && grep -q "^FAIL 5 .*skills/ll-fake/SKILL.md: line .* invokes a skill as a command" "$TMP/scr-rule5.out"'
check "orquestrador: regras 1 e 5 passam na árvore real (com ll-auto)" \
  'lint_real 1 && lint_real 5'
fi

# ---------------------------------------------------------------------------
# goal-autonomo. o modo --autonomous do ll-goal: hint, template e exemplo
# ---------------------------------------------------------------------------
if section goal-autonomo; then
cd "$ROOT"
GOAL_SKILL="skills/ll-goal/SKILL.md"
GOAL_TPL="skills/ll-goal/references/goal-template.md"
# primeiro bloco cercado sob "## Autonomous example", sem as cercas
goal_example() { awk '/^## Autonomous example$/{f=1;next} f&&/^```/{if(b){exit}b=1;next} f&&b' "$GOAL_TPL"; }

check "ll-goal argument-hint aceita --autonomous" \
  'sed -n "/^argument-hint:/p" "$GOAL_SKILL" | grep -q -- "--autonomous"'
check "goal-template cita ll-auto --auto-decision" \
  '[ "$(grep -c "ll-auto --auto-decision" "$GOAL_TPL")" -ge 1 ]'
check "exemplo autônomo entre 500 e 4000 bytes" \
  'n=$(goal_example | wc -c); [ "$n" -ge 500 ] && [ "$n" -le 4000 ]'
check "goal-template ≤ 150 linhas" \
  '[ "$(wc -l < "$GOAL_TPL")" -le 150 ]'
fi

# ---------------------------------------------------------------------------
# evals-auto. os asserts dos casos autônomos provados offline, sem nenhuma chamada paga
# ---------------------------------------------------------------------------
if section evals-auto; then
cd "$ROOT"
EV="$TMP/evals-auto"
mkdir -p "$EV"
# a resposta errada: não carrega nenhuma linha que os asserts exigem
printf 'I ran nothing and wrote nothing.\n' > "$EV/wrong.txt"

# a captura limpa: um evento assistant de texto (para o no_tool_use varrer algo) e o result.
CAP_CLEAN='[{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Rodei o dry run e nao escrevi nada."}]}},{"type":"result","subtype":"success","is_error":false,"result":""}]'
# a mesma captura com uma chamada de skill por tool_use: o assert tem de reprovar.
CAP_SKILL='[{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"t1","name":"Skill","input":{"command":"ll-implement"}}]}},{"type":"result","subtype":"success","is_error":false,"result":""}]'

# uma árvore de trabalho limpa por chamada (os asserts leem `git status --porcelain` dela)
auto_assert() { # auto_assert <caso> <arquivo de resposta> [captura]
  local w="$EV/$1"
  rm -rf "$w"; mkdir -p "$w"
  git -C "$w" init -q -b main
  printf '%s' "${3:-$CAP_CLEAN}" > "$w/out.json"
  bash "$ROOT/scripts/evals/cases/$1/assert.sh" "$w" "$w/out.json" "$2" > "$EV/$1.log" 2>&1
}

check "a captura offline tem ao menos um evento assistant" \
  'node -e "const a=JSON.parse(process.argv[1]);process.exit(a.filter(e=>e.type===\"assistant\").length?0:1)" "$CAP_CLEAN"'

check "assert auto-dry-run aceita a resposta boa" \
  'auto_assert auto-dry-run "$ROOT/scripts/fixtures/evals-auto/auto-dry-run/pass.txt"'
check "assert auto-dry-run rejeita resposta errada" \
  '! auto_assert auto-dry-run "$EV/wrong.txt"'
check "assert auto-empty-repo aceita a resposta boa" \
  'auto_assert auto-empty-repo "$ROOT/scripts/fixtures/evals-auto/auto-empty-repo/pass.txt"'
check "assert auto-empty-repo rejeita resposta errada" \
  '! auto_assert auto-empty-repo "$EV/wrong.txt"'
# o no_tool_use não é vazio: uma captura com tool_use Skill reprova o mesmo assert
check "assert auto-dry-run rejeita captura com tool_use Skill" \
  '! auto_assert auto-dry-run "$ROOT/scripts/fixtures/evals-auto/auto-dry-run/pass.txt" "$CAP_SKILL"'
check "assert auto-empty-repo rejeita captura com tool_use Skill" \
  '! auto_assert auto-empty-repo "$ROOT/scripts/fixtures/evals-auto/auto-empty-repo/pass.txt" "$CAP_SKILL"'

# goal-autonomous: o assert espera docs/GOAL.md já no lugar (um `ll-goal --autonomous` real
# escreve e comita o arquivo antes de imprimir o texto colável), não só o out.json do harness.
goal_autonomous_assert() { # goal_autonomous_assert <arquivo de resposta> [captura]
  local w="$EV/goal-autonomous"
  rm -rf "$w"; mkdir -p "$w/docs"
  git -C "$w" init -q -b main
  printf 'mode: autonomous\nphase: all\n' > "$w/docs/GOAL.md"
  git -C "$w" add -A && git -C "$w" -c user.email=t@t -c user.name=t commit -q -m "docs: GOAL.md"
  printf '%s' "${2:-$CAP_CLEAN}" > "$w/out.json"
  bash "$ROOT/scripts/evals/cases/goal-autonomous/assert.sh" "$w" "$w/out.json" "$1" > "$EV/goal-autonomous.log" 2>&1
}
check "assert goal-autonomous aceita a resposta boa" \
  'goal_autonomous_assert "$ROOT/scripts/fixtures/evals-auto/goal-autonomous/pass.txt"'
check "assert goal-autonomous rejeita resposta vazia" \
  '! goal_autonomous_assert "$EV/wrong.txt"'
echo "evals-auto: goal-autonomous pair asserted"

# router-large-opener: par offline (captura limpa + resposta boa/ruim), nenhuma chamada paga
rlo_assert() { # rlo_assert <arquivo de resposta>
  local w="$EV/router-large-opener"
  rm -rf "$w"; mkdir -p "$w"
  git -C "$w" init -q -b main
  bash "$ROOT/scripts/evals/cases/router-large-opener/assert.sh" "$w" \
    "$ROOT/scripts/evals/fixtures/router-large-opener/out.json" "$1" \
    > "$EV/router-large-opener.log" 2>&1
}
check "assert router-large-opener aceita a abertura que só nomeia o comando" \
  'rlo_assert "$ROOT/scripts/evals/fixtures/router-large-opener/pass.txt"'
check "assert router-large-opener rejeita a abertura que já escolhe biblioteca e layout" \
  '! rlo_assert "$ROOT/scripts/evals/fixtures/router-large-opener/fail.txt"'

# implement-stops-at-next: a linha de onda antes do epílogo e o helper chamado, nunca lido
CAP_ONDA='[{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"onda 1/2 — M1, M2 rodando (opus, sonnet)"}]}},{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"▶ Next — /clear, then /ll-implement 8"}]}},{"type":"result","subtype":"success","is_error":false,"result":""}]'
CAP_LE_HELPER='[{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"onda 1/2 — M1, M2 rodando (opus, sonnet)"}]}},{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"head -40 scripts/ll-tools.js"}}]}},{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"▶ Next — /clear, then /ll-implement 8"}]}},{"type":"result","subtype":"success","is_error":false,"result":""}]'
printf 'onda 1/2 — M1, M2 rodando (opus, sonnet)\nonda 1/2 — M1 ok (smoke test OK)\n## Epilogue — phase 07 — 2026-09-11\n▶ Next — `/clear`, then `/ll-implement 8`\n' > "$EV/onda.txt"
printf '## Epilogue — phase 07 — 2026-09-11\n▶ Next — `/clear`, then `/ll-implement 8`\n' > "$EV/sem-onda.txt"
isn_assert() { # isn_assert <arquivo de resposta> [captura]
  local w="$EV/implement-stops-at-next"
  rm -rf "$w"; mkdir -p "$w"
  printf '%s' "${2:-$CAP_ONDA}" > "$w/out.json"
  bash "$ROOT/scripts/evals/cases/implement-stops-at-next/assert.sh" "$w" "$w/out.json" "$1" \
    > "$EV/implement-stops-at-next.log" 2>&1
}
check "assert implement-stops-at-next aceita onda antes do epílogo" \
  'isn_assert "$EV/onda.txt"'
check "assert implement-stops-at-next rejeita saída sem linha de onda" \
  '! isn_assert "$EV/sem-onda.txt"'
check "assert implement-stops-at-next rejeita captura que lê o helper com head" \
  '! isn_assert "$EV/onda.txt" "$CAP_LE_HELPER"'

# decide-final-round: contagem em palavras simples e o caminho das opções antes da 1ª pergunta
printf 'docs/decide/OPTIONS.html — as opções lado a lado\nquestions asked 2 / assumptions 3 / owner decisions open 1\n**Pergunta 1/2 — limite de título (impacto MÉDIO · desfazer: barato)**\n' > "$EV/round-ok.txt"
printf 'questions asked 2 / assumptions 3 / owner decisions open 1\n**Pergunta 1/2 — limite de título (impacto MÉDIO · desfazer: barato)**\ndocs/decide/OPTIONS.html — as opções lado a lado\n' > "$EV/round-tarde.txt"
printf 'questions asked 2 / assumptions 3 / band-1 open 1\n**Pergunta 1/2 — limite de título**\n' > "$EV/round-jargao.txt"
dfr_assert() { # dfr_assert <arquivo de resposta>
  local w="$EV/decide-final-round"
  rm -rf "$w"; mkdir -p "$w"
  git -C "$w" init -q -b main
  printf '%s' "$CAP_CLEAN" > "$w/out.json"
  bash "$ROOT/scripts/evals/cases/decide-final-round/assert.sh" "$w" "$w/out.json" "$1" \
    > "$EV/decide-final-round.log" 2>&1
}
check "assert decide-final-round aceita a rodada com o caminho antes da pergunta" \
  'dfr_assert "$EV/round-ok.txt"'
check "assert decide-final-round rejeita o caminho depois da primeira pergunta" \
  '! dfr_assert "$EV/round-tarde.txt"'
check "assert decide-final-round rejeita a contagem com o rótulo antigo" \
  '! dfr_assert "$EV/round-jargao.txt"'
fi

# ---------------------------------------------------------------------------
# lint-scratch. a regra 1 do lint-prompts contra SKILL.md ruins, numa árvore de rascunho
# ---------------------------------------------------------------------------
if section lint-scratch; then
cd "$ROOT"
LSCR="$TMP/lint-bad-scratch"
mkdir -p "$LSCR"
git ls-files -z | xargs -0 cp --parents -t "$LSCR"
git -C "$LSCR" init -q
mkdir -p "$LSCR/skills/ll-fake"
# lint_bad <caso> <trecho esperado no FAIL>: planta a fixture como skills/ll-fake e roda a regra 1
lint_bad() {
  cp "$ROOT/scripts/fixtures/lint-bad/$1/SKILL.md" "$LSCR/skills/ll-fake/SKILL.md"
  git -C "$LSCR" add -A
  bash "$LSCR/scripts/lint-prompts.sh" --rule 1 > "$TMP/lint-bad-$1.out" 2>&1 && return 1
  grep -q "^FAIL 1 .*skills/ll-fake/SKILL.md: $2" "$TMP/lint-bad-$1.out"
}
check "lint 1: descrição dobrada (>) em mais de uma linha reprova" \
  'lint_bad folded-description "description is not one line"'
check "lint 1: disable-model-invocation: false reprova" \
  'lint_bad model-invocation-false "disable-model-invocation: true missing"'
# lint_bad9 <caso> <trecho esperado no FAIL>: a mesma fixture contra a regra 9
lint_bad9() {
  cp "$ROOT/scripts/fixtures/lint-bad/$1/SKILL.md" "$LSCR/skills/ll-fake/SKILL.md"
  git -C "$LSCR" add -A
  bash "$LSCR/scripts/lint-prompts.sh" --rule 9 > "$TMP/lint-bad9-$1.out" 2>&1 && return 1
  grep -q "^FAIL 9 .*skills/ll-fake/SKILL.md: line [0-9]*: .*$2" "$TMP/lint-bad9-$1.out"
}
check "lint 9: id de decisão no cabeçalho da pergunta reprova" \
  'lint_bad9 jargon-in-questions "\[DEC-"'
check "lint 9: a linha de contagem com o rótulo antigo reprova" \
  'lint_bad9 jargon-in-questions "band-1 open"'
# sem a fixture a mesma árvore passa: o FAIL vem da SKILL.md ruim, não da cópia
rm -rf "$LSCR/skills/ll-fake"
git -C "$LSCR" add -A
check "lint 1: a árvore de rascunho sem a fixture passa" \
  'bash "$LSCR/scripts/lint-prompts.sh" --rule 1 > "$TMP/lint-bad-clean.out" 2>&1'
check "lint 9: a árvore de rascunho sem a fixture passa" \
  'bash "$LSCR/scripts/lint-prompts.sh" --rule 9 > "$TMP/lint-bad9-clean.out" 2>&1'
fi

# ---------------------------------------------------------------------------
# no-talk. o modo silencioso continua declarado no argument-hint de quem o implementa
# ---------------------------------------------------------------------------
if section no-talk; then
cd "$ROOT"
hint_has_no_talk() { # hint_has_no_talk <SKILL.md>
  sed -n '/^argument-hint:/p' "$1" > "$TMP/hint.txt"
  grep -q -- "--no-talk" "$TMP/hint.txt"
}
for s in ll-decide ll-close; do
  check "argument-hint de $s declara --no-talk" 'hint_has_no_talk "skills/'"$s"'/SKILL.md"'
done
# a checagem não é vazia: sem a flag na linha, ela reprova
NT="$TMP/no-talk"
mkdir -p "$NT"
sed 's/ \[--no-talk\]//' skills/ll-decide/SKILL.md > "$NT/SKILL.md"
check "a checagem reprova quando --no-talk some do hint" '! hint_has_no_talk "$NT/SKILL.md"'
fi

echo "smoke test OK — $N checks"
