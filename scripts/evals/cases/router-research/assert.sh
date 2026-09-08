#!/usr/bin/env bash
# "pesquise" beats the classifier: the regime is RESEARCH and the next command is ll-research.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

line="$(first_text_line "$OUT_JSON")"
case "$line" in
  *RESEARCH*) ok "the first assistant message declares the regime: $line" ;;
  *)          fail "first assistant message does not declare RESEARCH: ${line:-<empty>}" ;;
esac

first_text_contains "$OUT_JSON" 'll-research' 'the routing line names the ll-research skill'

finish
