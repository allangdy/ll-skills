#!/usr/bin/env bash
# "pesquise" gets the command to paste, not a skill started on the session's behalf.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

first_text_contains "$OUT_JSON" '/ll-research' 'the first assistant message names the /ll-research command to paste'

no_tool_use "$OUT_JSON" Skill 'no Skill tool call anywhere in the capture'

finish
