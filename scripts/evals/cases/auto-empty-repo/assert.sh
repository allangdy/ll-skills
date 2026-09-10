#!/usr/bin/env bash
# "/ll-auto" on an empty repository -> the two-line stop, no question, nothing written.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

contains "$OUT_TXT" 'Nada encontrado neste reposit' 'the answer carries the empty-repository line'
contains "$OUT_TXT" '/ll-auto "<objetivo>"' 'the answer carries the command to complete'

no_path "$WORK/docs" 'no docs/ was created'
no_path "$WORK/PLAN.md" 'no PLAN.md was created'

# OUT_JSON may sit inside WORK for an offline check; exclude it by name so the
# capture file itself is not read as a change to the work tree.
dirty="$(git -C "$WORK" status --porcelain 2>/dev/null | grep -v -- " $(basename "$OUT_JSON")\$")"
if [ -z "$dirty" ]; then
  ok 'git status --porcelain is empty: nothing was written'
else
  fail "the working tree was changed: $(printf '%s' "$dirty" | tr '\n' ' ')"
fi

no_tool_use "$OUT_JSON" AskUserQuestion 'no AskUserQuestion tool call anywhere in the capture'
no_tool_use "$OUT_JSON" Skill 'no Skill tool call anywhere in the capture'

finish
