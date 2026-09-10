#!/usr/bin/env bash
# --dry-run: the stage table and the roteiro are printed, nothing is written, no skill starts.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

# The roteiro of the shared fixture, tolerant to a table or a numbered list:
# each stage and its command on one line.
contains "$OUT_TXT" 'phase-07.*ll-implement 0?7' 'the roteiro carries the phase-07 row with ll-implement 07'
contains "$OUT_TXT" 'phase-08.*ll-implement 0?8' 'the roteiro carries the phase-08 row with ll-implement 08'
contains "$OUT_TXT" 'close.*ll-close'            'the roteiro carries the close row with ll-close'

# CA-04: the stage table from detect is printed too, decide already done.
contains "$OUT_TXT" 'decide.*done' 'the stage table is printed with decide: done'

no_path "$WORK/docs/AUTO.md" 'docs/AUTO.md was not written: the dry run stopped before opening the run'

# The capture files are the harness's, not the run's: a real rep keeps them under
# the results dir, the offline check hands them inside the scratch work tree.
dirty="$(git -C "$WORK" status --porcelain | while IFS= read -r line; do
  path="${line#???}"
  [ "$WORK/$path" = "$OUT_JSON" ] || [ "$path" = "$OUT_JSON" ] && continue
  [ "$WORK/$path" = "$OUT_TXT" ]  || [ "$path" = "$OUT_TXT" ]  && continue
  printf '%s\n' "$line"
done)"
if [ -z "$dirty" ]; then
  ok 'git status --porcelain is empty: nothing was written'
else
  fail "the working tree was changed: $(printf '%s' "$dirty" | tr '\n' ' ')"
fi

no_tool_use "$OUT_JSON" Skill           'no Skill tool call anywhere in the capture'
no_tool_use "$OUT_JSON" AskUserQuestion 'no AskUserQuestion tool call anywhere in the capture'

finish
