#!/usr/bin/env bash
# LARGE: the opener names the command that owns the request and stops there — at most
# five lines of plan, naming no library, id format, storage API or file layout.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

# What belongs to the skill, never to the opener.
DECIDED='express|fastify|prisma|sqlite|postgres|uuid|nanoid|localStorage|src/'

first_text_contains "$OUT_JSON" 'll-decide project|ll-research' \
  'the first message names the command that owns the request'
contains "$OUT_TXT" 'll-decide project|ll-research' 'the answer hands the command over'

# The opener and the final answer are scored the same way: a router answer is one message.
OPENER="$(mktemp)"
first_text "$OUT_JSON" > "$OPENER"
for src in "$OPENER" "$OUT_TXT"; do
  [ -s "$src" ] || continue
  what='the answer'; [ "$src" = "$OUT_TXT" ] || what='the first message'
  n="$(grep -cv '^[[:space:]]*$' "$src" || true)"
  if [ "${n:-0}" -le 8 ]; then
    ok "$what carries $n non-empty lines (command plus at most five lines of plan)"
  else
    fail "$what carries $n non-empty lines: more than the command plus five lines"
  fi
  if grep -Eqi -- "$DECIDED" "$src"; then
    fail "$what decides for the skill: $(grep -Eoi -- "$DECIDED" "$src" | head -1)"
  else
    ok "$what names no library, id format, storage API or file layout"
  fi
done
rm -f "$OPENER"

no_tool_use "$OUT_JSON" Skill 'no Skill tool call anywhere in the capture'

dirty="$(git -C "$WORK" status --porcelain 2>/dev/null)"
if [ -z "$dirty" ]; then
  ok 'git status --porcelain is empty: nothing was written'
else
  fail "the working tree was changed: $(printf '%s' "$dirty" | tr '\n' ' ')"
fi

no_path "$WORK/PLAN.md"     'no PLAN.md was created'
no_path "$WORK/PROGRESS.md" 'no PROGRESS.md was created'
no_path "$WORK/phases"      'no phases/ was created'

finish
