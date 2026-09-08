#!/usr/bin/env bash
# The typo is fixed and no ceremony file is born.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

contains "$WORK/src/a.ts" 'receive' 'src/a.ts now spells receive'
absent   "$WORK/src/a.ts" 'recieve' 'no occurrence of the typo is left'

no_path "$WORK/PROGRESS.md"     'no PROGRESS.md was created'
no_path "$WORK/VERIFICATION.md" 'no VERIFICATION.md was created'
no_path "$WORK/phases"          'no phases/ was created'
no_path "$WORK/PLAN.md"         'no PLAN.md was created'

finish
