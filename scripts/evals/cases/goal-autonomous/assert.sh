#!/usr/bin/env bash
# `/ll-goal --autonomous "<objective>"`: one pasted /goal text for the whole delivery,
# docs/GOAL.md written with `mode: autonomous` and `phase: all`, nothing asked, no skill started.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

contains "$OUT_TXT" '/goal'                   'the answer carries the /goal text to paste'
# EXECUTION carries `ll-auto` with `--auto-decision`; the objective and `--verify all` may sit
# between them and the text wraps, so the answer is read flattened.
if tr '\n' ' ' < "$OUT_TXT" 2>/dev/null | grep -Eq 'll-auto.{0,80}--auto-decision'; then
  ok 'EXECUTION runs the delivery with ll-auto --auto-decision'
else
  fail 'EXECUTION runs the delivery with ll-auto --auto-decision'
fi

# The pasted block is what the owner copies: from the /goal line to the `▶ Next` line, or to the
# end when there is none. The goal text is a pointer, never a copy of PLAN.md: it stays small.
block="$(awk '/\/goal/ { on = 1 } on && /▶ Next/ { exit } on { print }' "$OUT_TXT" 2>/dev/null)"
n="$(printf '%s' "$block" | wc -c)"
if [ "$n" -ge 400 ] && [ "$n" -le 4000 ]; then
  ok "the pasted /goal text measures $n chars (400..4000)"
else
  fail "the pasted /goal text measures $n chars, outside 400..4000"
fi

if [ -f "$WORK/docs/GOAL.md" ]; then ok 'docs/GOAL.md exists in the work tree'
else fail 'docs/GOAL.md exists in the work tree'; fi
contains "$WORK/docs/GOAL.md" '^mode: autonomous$' 'docs/GOAL.md frontmatter carries mode: autonomous'
contains "$WORK/docs/GOAL.md" '^phase: all$'       'docs/GOAL.md frontmatter carries phase: all (the whole delivery)'

no_tool_use "$OUT_JSON" Skill           'no Skill tool call anywhere in the capture'
no_tool_use "$OUT_JSON" AskUserQuestion 'no AskUserQuestion tool call anywhere in the capture'

finish
