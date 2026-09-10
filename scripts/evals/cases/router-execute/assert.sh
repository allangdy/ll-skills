#!/usr/bin/env bash
# "implementa a fase N" with a milestone at passes:false gets the /ll-implement command to paste.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

# The skill is named with the phase number; 7 and 07 both count.
first_text_contains "$OUT_JSON" '/ll-implement 0?7' 'the first assistant message names /ll-implement 7 to paste'

no_tool_use "$OUT_JSON" Skill 'no Skill tool call anywhere in the capture'

finish
