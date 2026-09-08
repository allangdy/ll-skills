#!/usr/bin/env bash
# Behavioural eval harness for this package.
#
#   run.sh [--all | --case <id>...] [--reps N] [--model <id>] [--dry-run]
#
# Installs the package into a throwaway CLAUDE_CONFIG_DIR, runs each case against
# a throwaway copy of a fixture repository with `claude -p`, and scores the answer
# with the case's assert.sh. Nothing is written inside the git index of this repo:
# results go to $LL_EVAL_RESULTS (default ~/.claude/ll-skills-evals)/<YYYY-MM-DD-HHMM>/ and the work
# trees to a mktemp directory outside the repo, so the session under test never
# discovers this project's own .claude/ or CLAUDE.md.
#
# Exit 0 when every selected case passed in at least min_pass reps (case.json,
# capped at the number of reps actually run).

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CASES_DIR="$HERE/cases"
LIB="$HERE/lib"
SHARED_FIXTURE="$REPO/scripts/fixtures/project"
GIT_HISTORY="$REPO/scripts/fixtures/git-history.sh"
PREAMBLE="$REPO/assets/preamble.md"
INSTALLER="$REPO/bin/install.js"

REPS=3
MODEL=""
DRY_RUN=0
SELECTED=()

die() { printf 'run.sh: %s\n' "$1" >&2; exit 2; }

usage() {
  sed -n '2,16p' "$HERE/run.sh" | sed 's/^# \{0,1\}//'
  exit 0
}

# ---------------------------------------------------------------------------
# arguments
# ---------------------------------------------------------------------------

while [ $# -gt 0 ]; do
  case "$1" in
    --all)      SELECTED=(); shift ;;
    --case)     [ $# -ge 2 ] || die "--case needs an id"; SELECTED+=("$2"); shift 2 ;;
    --reps)     [ $# -ge 2 ] || die "--reps needs a number"; REPS="$2"; shift 2 ;;
    --model)    [ $# -ge 2 ] || die "--model needs an id"; MODEL="$2"; shift 2 ;;
    --dry-run)  DRY_RUN=1; shift ;;
    -h|--help)  usage ;;
    *)          die "unknown argument: $1 (use --help)" ;;
  esac
done

case "$REPS" in (''|*[!0-9]*) die "--reps must be a positive integer" ;; esac
[ "$REPS" -ge 1 ] || die "--reps must be at least 1"

[ -d "$CASES_DIR" ] || die "no cases directory at $CASES_DIR"
[ -f "$PREAMBLE" ]  || die "no preamble at $PREAMBLE"
[ -f "$INSTALLER" ] || die "no installer at $INSTALLER"
command -v node >/dev/null 2>&1 || die "node is required"
command -v claude >/dev/null 2>&1 || [ "$DRY_RUN" -eq 1 ] || die "claude CLI is not on PATH"

all_cases() {
  local d
  for d in "$CASES_DIR"/*/; do
    [ -f "${d}case.json" ] || continue
    basename "$d"
  done
}

if [ "${#SELECTED[@]}" -eq 0 ]; then
  mapfile -t SELECTED < <(all_cases)
fi
[ "${#SELECTED[@]}" -gt 0 ] || die "no cases selected"

for id in "${SELECTED[@]}"; do
  [ -f "$CASES_DIR/$id/case.json" ] || die "unknown case: $id"
  [ -f "$CASES_DIR/$id/prompt.txt" ] || die "case $id has no prompt.txt"
  [ -f "$CASES_DIR/$id/assert.sh" ] || die "case $id has no assert.sh"
done

# A case with "reuse" runs no claude call: it re-scores the work dir and the
# capture of the case it names. Order the selection so the source runs first.
reuse_of() { node -e '
  const c = require(process.argv[1]);
  process.stdout.write(c.reuse || "");
' "$CASES_DIR/$1/case.json"; }

field() { # field <case-id> <name> <default>
  node -e '
    const c = require(process.argv[1]);
    const v = c[process.argv[2]];
    process.stdout.write(v === undefined || v === null ? process.argv[3] : String(v));
  ' "$CASES_DIR/$1/case.json" "$2" "$3"
}

ORDERED=()
for id in "${SELECTED[@]}"; do [ -n "$(reuse_of "$id")" ] || ORDERED+=("$id"); done
for id in "${SELECTED[@]}"; do [ -z "$(reuse_of "$id")" ] || ORDERED+=("$id"); done

# ---------------------------------------------------------------------------
# results directory (outside the git index) and work root (outside the repo)
# ---------------------------------------------------------------------------

STAMP="$(date +%Y-%m-%d-%H%M)"
RESULTS="${LL_EVAL_RESULTS:-$HOME/.claude/ll-skills-evals}/$STAMP"
mkdir -p "$RESULTS" || die "cannot create $RESULTS"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/ll-evals.XXXXXXXX")" || die "cannot create a work root"
CONFIG="$TMP/config"

printf 'results : %s\n' "$RESULTS"
printf 'work    : %s\n' "$TMP"
printf 'cases   : %s (reps %s)\n' "${#ORDERED[@]}" "$REPS"
printf '\n'

# ---------------------------------------------------------------------------
# install the package into the throwaway config dir
# ---------------------------------------------------------------------------

install_cmd() {
  printf 'CLAUDE_CONFIG_DIR=%s node %s --yes --no-settings' "$CONFIG" "$INSTALLER"
}

if [ "$DRY_RUN" -eq 1 ]; then
  printf '# install\n%s\n\n' "$(install_cmd)"
else
  mkdir -p "$CONFIG"
  # The credentials live in the real config dir; a fresh CLAUDE_CONFIG_DIR has no auth
  # of its own. A symlink, not a copy: a copy is a snapshot that goes stale as soon as
  # the OAuth token is refreshed, and a long run then dies with "session expired".
  # ANTHROPIC_API_KEY, when set, covers the same ground.
  if [ -f "$HOME/.claude/.credentials.json" ] && [ ! -e "$CONFIG/.credentials.json" ]; then
    ln -s "$HOME/.claude/.credentials.json" "$CONFIG/.credentials.json"
  fi
  if ! CLAUDE_CONFIG_DIR="$CONFIG" node "$INSTALLER" --yes --no-settings > "$RESULTS/install.log" 2>&1; then
    cat "$RESULTS/install.log" >&2
    die "the installer failed; see $RESULTS/install.log"
  fi
  printf 'installed into %s (%s skills)\n\n' "$CONFIG" "$(ls -1 "$CONFIG/skills" 2>/dev/null | wc -l)"
fi

# ---------------------------------------------------------------------------
# one rep
# ---------------------------------------------------------------------------

prepare_workdir() { # prepare_workdir <case-id> <workdir> <history>
  local id="$1" work="$2" history="$3" fixture="$CASES_DIR/$1/fixture"

  if [ "$history" = "true" ]; then
    # git-history.sh rebuilds <target> from the shared fixture and commits five times.
    bash "$GIT_HISTORY" "$work" >/dev/null 2>&1 || return 1
  else
    [ -d "$fixture" ] || fixture="$SHARED_FIXTURE"
    rm -rf "$work"; mkdir -p "$work"
    cp -R "$fixture/." "$work/" 2>/dev/null || true
    git -C "$work" init -q -b main
    git -C "$work" add -A
    git -C "$work" -c user.name=eval -c user.email=eval@example.com \
      -c commit.gpgsign=false commit -q -m "chore: eval fixture" --allow-empty
  fi

  if [ -f "$CASES_DIR/$id/setup.sh" ]; then
    bash "$CASES_DIR/$id/setup.sh" "$work" > "$work/.eval-setup.log" 2>&1 || return 1
  fi

  # The sha the run starts from, so an assert can look only at what the run added.
  git -C "$work" rev-parse HEAD > "$work/.eval-base-sha" 2>/dev/null || echo "" > "$work/.eval-base-sha"
  printf '.eval-base-sha\n.eval-setup.log\n' >> "$work/.git/info/exclude"
  return 0
}

# prompt.txt may carry {{WORK}}, replaced with the absolute path of the work tree —
# a brief passes absolute paths and no `cd`, and the work tree is created per rep.
prompt_text() { # prompt_text <case-id> <workdir>
  sed "s|{{WORK}}|$2|g" "$CASES_DIR/$1/prompt.txt"
}

claude_cmd() { # claude_cmd <case-id> <workdir> <max_turns> <agent> <permission_mode>
  local id="$1" work="$2" turns="$3" agent="$4" perm="$5"
  local cmd="env -u CLAUDECODE CLAUDE_CONFIG_DIR=$CONFIG claude -p \"\$(sed 's|{{WORK}}|$work|g' $CASES_DIR/$id/prompt.txt)\""
  cmd="$cmd --max-turns $turns --output-format json"
  cmd="$cmd --append-system-prompt \"\$(cat $PREAMBLE)\""
  cmd="$cmd --permission-mode $perm --strict-mcp-config --verbose"
  [ -n "$agent" ] && cmd="$cmd --agent $agent"
  [ -n "$MODEL" ] && cmd="$cmd --model $MODEL"
  printf '(cd %s && %s > %s/%s/rep1/out.json)' "$work" "$cmd" "$RESULTS" "$id"
}

run_claude() { # run_claude <case-id> <workdir> <turns> <agent> <perm> <out.json>
  local id="$1" work="$2" turns="$3" agent="$4" perm="$5" outjson="$6"
  local args=(-p "$(prompt_text "$id" "$work")"
              --max-turns "$turns"
              --output-format json
              --append-system-prompt "$(cat "$PREAMBLE")"
              --permission-mode "$perm"
              --strict-mcp-config
              --verbose)
  [ -n "$agent" ] && args+=(--agent "$agent")
  [ -n "$MODEL" ] && args+=(--model "$MODEL")
  ( cd "$work" && env -u CLAUDECODE CLAUDE_CONFIG_DIR="$CONFIG" claude "${args[@]}" ) \
    > "$outjson" 2>"${outjson%.json}.stderr"
}

# ---------------------------------------------------------------------------
# the loop
# ---------------------------------------------------------------------------

ROWS=()          # "case|rep|PASS/FAIL|cost|duration|turns|first failure"
declare -A PASSES=() MINPASS=()
TOTAL_COST=0

for id in "${ORDERED[@]}"; do
  MAX_TURNS="$(field "$id" max_turns 20)"
  HISTORY="$(field "$id" history false)"
  MIN_PASS="$(field "$id" min_pass 2)"
  AGENT="$(field "$id" agent '')"
  PERM="$(field "$id" permission_mode bypassPermissions)"
  REUSE="$(reuse_of "$id")"
  [ "$AGENT" = "null" ] && AGENT=""
  MINPASS["$id"]="$MIN_PASS"
  PASSES["$id"]=0

  if [ "$DRY_RUN" -eq 1 ]; then
    work="$TMP/work-$id-1"
    printf '# case %s  (max_turns %s · history %s · min_pass %s%s)\n' \
      "$id" "$MAX_TURNS" "$HISTORY" "$MIN_PASS" "${AGENT:+ · agent $AGENT}"
    if [ -n "$REUSE" ]; then
      printf '# no claude call: re-scores the work dir and capture of %s\n' "$REUSE"
      printf 'bash %s/assert.sh %s %s %s\n\n' \
        "$CASES_DIR/$id" "$TMP/work-$REUSE-1" "$RESULTS/$REUSE/rep1/out.json" "$RESULTS/$REUSE/rep1/out.txt"
      continue
    fi
    if [ "$HISTORY" = "true" ]; then
      printf 'bash %s %s\n' "$GIT_HISTORY" "$work"
    else
      src="$CASES_DIR/$id/fixture"; [ -d "$src" ] || src="$SHARED_FIXTURE"
      printf 'cp -R %s/. %s/ && git -C %s init -q -b main && git -C %s commit -m "chore: eval fixture"\n' \
        "$src" "$work" "$work" "$work"
    fi
    [ -f "$CASES_DIR/$id/setup.sh" ] && printf 'bash %s/setup.sh %s\n' "$CASES_DIR/$id" "$work"
    rep1="$RESULTS/$id/rep1"
    printf '%s\n' "$(claude_cmd "$id" "$work" "$MAX_TURNS" "$AGENT" "$PERM")"
    printf 'node %s/extract.js %s/out.json result > %s/out.txt\n' "$LIB" "$rep1" "$rep1"
    printf 'bash %s/assert.sh %s %s/out.json %s/out.txt\n\n' "$CASES_DIR/$id" "$work" "$rep1" "$rep1"
    continue
  fi

  for rep in $(seq 1 "$REPS"); do
    repdir="$RESULTS/$id/rep$rep"
    mkdir -p "$repdir"
    outjson="$repdir/out.json"
    outtxt="$repdir/out.txt"
    cost="-" ; dur="-" ; turns="-" ; firstfail="" ; verdict="FAIL"

    if [ -n "$REUSE" ]; then
      work="$TMP/work-$REUSE-$rep"
      src="$RESULTS/$REUSE/rep$rep"
      if [ ! -d "$work" ] || [ ! -f "$src/out.json" ]; then
        firstfail="source case $REUSE was not run in this invocation"
        ROWS+=("$id|$rep|FAIL|-|-|-|$firstfail")
        printf '  %-26s rep %s  FAIL  (%s)\n' "$id" "$rep" "$firstfail"
        continue
      fi
      cp "$src/out.json" "$outjson"; cp "$src/out.txt" "$outtxt"
    else
      work="$TMP/work-$id-$rep"
      if ! prepare_workdir "$id" "$work" "$HISTORY"; then
        firstfail="fixture preparation failed"
        ROWS+=("$id|$rep|FAIL|-|-|-|$firstfail")
        printf '  %-26s rep %s  FAIL  (%s)\n' "$id" "$rep" "$firstfail"
        continue
      fi
      run_claude "$id" "$work" "$MAX_TURNS" "$AGENT" "$PERM" "$outjson"
      if ! node "$LIB/extract.js" "$outjson" result > "$outtxt" 2>"$repdir/extract.err"; then
        firstfail="no result element in out.json ($(head -c 120 "$repdir/extract.err" | tr '\n' ' '))"
        ROWS+=("$id|$rep|FAIL|-|-|-|$firstfail")
        printf '  %-26s rep %s  FAIL  (%s)\n' "$id" "$rep" "$firstfail"
        continue
      fi
    fi

    cost="$(node "$LIB/extract.js" "$outjson" total_cost_usd 2>/dev/null)"; [ -n "$cost" ] || cost="-"
    ms="$(node "$LIB/extract.js" "$outjson" duration_ms 2>/dev/null)"
    turns="$(node "$LIB/extract.js" "$outjson" num_turns 2>/dev/null)"; [ -n "$turns" ] || turns="-"
    if [ -n "$ms" ]; then dur="$(node -e 'process.stdout.write((Number(process.argv[1])/1000).toFixed(1))' "$ms")"; fi
    if [ "$cost" != "-" ]; then
      TOTAL_COST="$(node -e 'process.stdout.write((Number(process.argv[1])+Number(process.argv[2])).toFixed(4))' "$TOTAL_COST" "$cost")"
      cost="$(node -e 'process.stdout.write(Number(process.argv[1]).toFixed(4))' "$cost")"
    fi

    bash "$CASES_DIR/$id/assert.sh" "$work" "$outjson" "$outtxt" > "$repdir/assert.log" 2>&1
    arc=$?
    if [ "$arc" -eq 0 ]; then
      verdict="PASS"
      PASSES["$id"]=$(( ${PASSES["$id"]} + 1 ))
    else
      firstfail="$(grep -m1 '^FAIL: ' "$repdir/assert.log" | sed 's/^FAIL: //')"
      [ -n "$firstfail" ] || firstfail="assert.sh exited non-zero with no FAIL line"
      # A run cut short by the turn cap is a budget problem, not a behavioural one: say so.
      sub="$(node "$LIB/extract.js" "$outjson" subtype 2>/dev/null)"
      [ "$sub" = "success" ] || [ -z "$sub" ] || firstfail="[$sub] $firstfail"
    fi

    ROWS+=("$id|$rep|$verdict|$cost|$dur|$turns|$firstfail")
    printf '  %-26s rep %s  %s  cost %s  %ss  turns %s%s\n' \
      "$id" "$rep" "$verdict" "$cost" "$dur" "$turns" "${firstfail:+  — $firstfail}"
  done
done

if [ "$DRY_RUN" -eq 1 ]; then
  printf '# dry run: %s case blocks printed, no claude call made\n' "${#ORDERED[@]}"
  exit 0
fi

# ---------------------------------------------------------------------------
# RESULTS.md and summary.json
# ---------------------------------------------------------------------------

EXIT=0
{
  printf '# Eval results — %s\n\n' "$STAMP"
  printf 'model: %s · reps: %s · cases: %s · total cost: USD %s\n\n' \
    "${MODEL:-default}" "$REPS" "${#ORDERED[@]}" "$TOTAL_COST"
  printf '| case | rep | verdict | cost USD | duration s | turns | first assert failure |\n'
  printf '|---|---|---|---|---|---|---|\n'
  for row in "${ROWS[@]}"; do
    IFS='|' read -r c r v co du tu ff <<< "$row"
    printf '| %s | %s | %s | %s | %s | %s | %s |\n' "$c" "$r" "$v" "$co" "$du" "$tu" "${ff:-—}"
  done
  printf '\n## Case verdicts\n\n'
  printf '| case | passed | of reps | min_pass | verdict |\n|---|---|---|---|---|\n'
  for id in "${ORDERED[@]}"; do
    need="${MINPASS[$id]}"
    [ "$need" -le "$REPS" ] || need="$REPS"
    got="${PASSES[$id]}"
    if [ "$got" -ge "$need" ]; then v=PASS; else v=FAIL; EXIT=1; fi
    printf '| %s | %s | %s | %s | %s |\n' "$id" "$got" "$REPS" "$need" "$v"
  done
  printf '\nWork trees kept at `%s`.\n' "$TMP"
} > "$RESULTS/RESULTS.md"

node - "$RESULTS/summary.json" "$STAMP" "${MODEL:-default}" "$REPS" "$TMP" "$RESULTS" "$TOTAL_COST" "$EXIT" <<'NODE' "${ROWS[@]}"
const fs = require('fs');
const [out, stamp, model, reps, tmp, results, cost, exitCode, ...rows] = process.argv.slice(2);
const byCase = {};
for (const row of rows) {
  const [id, rep, verdict, c, d, t, ff] = row.split('|');
  (byCase[id] = byCase[id] || []).push({
    rep: Number(rep), pass: verdict === 'PASS',
    cost_usd: c === '-' ? null : Number(c),
    duration_s: d === '-' ? null : Number(d),
    turns: t === '-' ? null : Number(t),
    first_failure: ff || null,
  });
}
fs.writeFileSync(out, JSON.stringify({
  stamp, model, reps: Number(reps), results_dir: results, work_dir: tmp,
  total_cost_usd: Number(cost), exit_code: Number(exitCode),
  cases: Object.entries(byCase).map(([id, r]) => ({
    id, passed: r.filter((x) => x.pass).length, reps: r,
  })),
}, null, 2) + '\n');
NODE

printf '\n%s\n' "$RESULTS/RESULTS.md"
printf 'total cost USD %s · exit %s\n' "$TOTAL_COST" "$EXIT"
exit "$EXIT"
