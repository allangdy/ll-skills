#!/usr/bin/env bash
# A skill runs only when the owner types it: a plain research request is answered here and
# now — no command handed back to paste, no ▶ Next, no Skill tool call — even though the
# fixture carries ll-skills state (PLAN.md, decisions/).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

# The queue engines a real answer names. Longest alternative first: grep -E is leftmost-longest,
# so "bullmq" never scores as "bull".
QUEUES='bullmq|bee-queue|pg-boss|rabbitmq|graphile|bull|redis|sqs|kafka|agenda'

absent "$OUT_TXT" '▶ Next' 'the answer ends in no ▶ Next: this turn is not a skill hand-off'

if [ -f "$OUT_TXT" ] && grep -Eqi -- 'cole:|cole isto|cole o comando|paste this' "$OUT_TXT"; then
  fail "the answer hands a command back to paste: $(grep -Eio -- 'cole:|cole isto|cole o comando|paste this' "$OUT_TXT" | head -1)"
else
  ok 'the answer hands no command back to paste'
fi

n="$(grep -Eoi -- "$QUEUES" "$OUT_TXT" 2>/dev/null | tr 'A-Z' 'a-z' | sort -u | wc -l)"
if [ "${n:-0}" -ge 2 ]; then
  ok "the research was done here: $n queue options named"
else
  fail "the answer names $n queue option(s): the research was not done"
fi

no_tool_use "$OUT_JSON" Skill 'no Skill tool call anywhere in the capture'

no_path "$WORK/PROGRESS.md" 'no PROGRESS.md was created'
no_path "$WORK/phases"      'no phases/ was created'

finish
