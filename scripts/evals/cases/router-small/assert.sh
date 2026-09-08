#!/usr/bin/env bash
# SMALL: verb + addressable target -> answer with a number, write nothing.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

line="$(first_text_line "$OUT_JSON")"
case "$line" in
  *SMALL*) ok "the first assistant message declares the regime: $line" ;;
  *)       fail "first assistant message does not declare SMALL: ${line:-<empty>}" ;;
esac

contains "$OUT_TXT" '[0-9]+' 'the answer carries a number'

dirty="$(git -C "$WORK" status --porcelain)"
if [ -z "$dirty" ]; then
  ok 'git status --porcelain is empty: nothing was written'
else
  fail "the working tree was changed: $(printf '%s' "$dirty" | tr '\n' ' ')"
fi

no_path "$WORK/PROGRESS.md" 'no PROGRESS.md was created'
no_path "$WORK/phases"      'no phases/ was created'

finish
