#!/usr/bin/env bash
# The executor returns exactly one block with the seven fields, and the TDD order holds.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

contains "$OUT_TXT" '^### M1'          'the return opens with the ### M1 heading'
for f in built commits commands deviations questions backlog not_verified; do
  contains "$OUT_TXT" "^${f}:" "the return carries the field ${f}:"
done

# TDD order over the whole history: a test(M1) commit exists and precedes the first feat(M1).
log="$(git -C "$WORK" log --format=%s --reverse)"
t="$(printf '%s\n' "$log" | grep -n '^test(M1): ' | head -1 | cut -d: -f1)"
f="$(printf '%s\n' "$log" | grep -n '^feat(M1): ' | head -1 | cut -d: -f1)"
if [ -n "$t" ] && [ -n "$f" ] && [ "$t" -lt "$f" ]; then
  ok "git log shows test(M1) at #$t before feat(M1) at #$f"
else
  fail "git log does not show a test(M1) commit before a feat(M1) commit (test=${t:-none} feat=${f:-none})"
fi

# The executor owns no state file.
base="$(base_sha "$WORK")"
if [ -n "$base" ]; then
  touched="$(git -C "$WORK" diff --name-only "$base" HEAD -- PROGRESS.md PLAN.md ROADMAP.md BACKLOG.md decisions)"
  if [ -z "$touched" ]; then
    ok 'no state file was committed by the executor'
  else
    fail "the executor committed a state file: $(printf '%s' "$touched" | tr '\n' ' ')"
  fi
fi

finish
