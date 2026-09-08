#!/usr/bin/env bash
# "implementa a fase N" with a milestone at passes:false -> EXECUTE, ll-implement 7.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

line="$(first_text "$OUT_JSON" | tr "\n" " " | cut -c1-200)"
case "$line" in
  *EXECUTE*) ok "the first assistant message declares the regime" ;;
  *)         fail "first assistant message does not declare EXECUTE: ${line:-<empty>}" ;;
esac

# The skill is named with the phase number; 7 and 07 both count.
first_text_contains "$OUT_JSON" 'll-implement 0?7' 'the routing line names ll-implement 7'

finish
