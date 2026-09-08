#!/usr/bin/env bash
# The final round is always sent, with the counter, before anything is frozen.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

contains "$OUT_TXT" 'questions asked' 'the answer carries the counter "questions asked"'
contains "$OUT_TXT" 'band-1 open'     'the answer carries "band-1 open"'

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
