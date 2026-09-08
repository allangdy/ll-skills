#!/usr/bin/env bash
# A test whose assertion was removed without a DEC must not ride in an approval.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

contains "$OUT_TXT" 'REJECTED'       'the return carries the verdict REJECTED'
contains "$OUT_TXT" 'test/a\.test\.ts' 'the return names test/a.test.ts'

if [ -f "$WORK/phases/07/VERIFICATION.md" ]; then
  ok 'phases/07/VERIFICATION.md was written'
else
  fail 'phases/07/VERIFICATION.md was not written at the path the brief gave'
fi

# The verifier fixes nothing: the weakened test is still weakened.
absent "$WORK/test/a.test.ts" 'expect\(' 'the verifier did not repair the test it flagged'

finish
