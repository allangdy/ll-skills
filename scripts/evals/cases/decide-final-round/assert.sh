#!/usr/bin/env bash
# The final round is always sent, with the counter, before anything is frozen.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

# a one-shot run has no owner to answer: either the final round (counter) or a blocking gate block (≤ 4 questions) is the correct stop
if grep -qE 'questions asked' "$OUT_TXT"; then
  contains "$OUT_TXT" 'band-1 open' 'the final round carries "band-1 open"'
else
  contains "$OUT_TXT" '\[PG-1\]|Pergunta 1/|Question 1/' 'the gate asks its first question instead of assuming'
  n="$(grep -cE '^\*\*\[PG-[0-9]+\]|^\*\*Pergunta [0-9]+/|^\*\*Question [0-9]+/' "$OUT_TXT")"
  if [ "$n" -le 4 ]; then ok "the block carries $n questions (≤ 4)"; else fail "the block carries $n questions (> 4)"; fi
  no_path "$WORK/PLAN.md" 'nothing frozen while the gate is open'
fi

# The contract is only scored when it was written: with a band-1 item open, nothing freezes.
if [ -f "$WORK/PLAN.md" ]; then
  contains "$WORK/PLAN.md" '^## ' 'PLAN.md carries ## sections'
  if [ -d "$WORK/decisions" ]; then
    ok 'decisions/ exists beside the frozen PLAN.md'
  else
    fail 'PLAN.md was written but decisions/ does not exist'
  fi
else
  ok 'no PLAN.md written — nothing was frozen, so the contract is not scored'
fi

# The phase plan is never written by this skill.
no_path "$WORK/phases/01/PLAN.md" 'no phases/NN/PLAN.md was written here'

finish
