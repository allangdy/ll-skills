#!/usr/bin/env bash
# Builds a throwaway git repo from scripts/fixtures/project/ into <target-dir>.
# Five commits on five distinct days inside a nine-day span, in the order
#   test(M1) -> feat(M1) -> feat(M10) -> feat(M2) -> test(M2)
# so that `tdd-gate M1` passes, `tdd-gate M2` fails and `phase-stats` reports 5 days with work.
# src/pay.ts is never touched after the first commit: VERIFICATION.md records its sha256.
set -euo pipefail

TARGET="${1:-}"
if [ -z "$TARGET" ]; then
  echo "usage: git-history.sh <target-dir>" >&2
  exit 2
fi

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$HERE/project"

rm -rf "$TARGET"
mkdir -p "$TARGET"
cp -R "$SRC/." "$TARGET/"
cd "$TARGET"

G() { git -c user.name=fixture -c user.email=fixture@example.com -c commit.gpgsign=false "$@"; }

commit_on() { # commit_on <day-offset> <subject>
  local day="$1" subject="$2" stamp
  stamp="2026-09-0${day}T10:00:00+00:00"
  GIT_AUTHOR_DATE="$stamp" GIT_COMMITTER_DATE="$stamp" G commit -q -m "$subject"
}

git init -q -b main .
G add -A
commit_on 1 "test(M1): red cases"

printf '\nexport const RECONCILE_VERSION = 2;\n' >> src/a.ts
G add src/a.ts
commit_on 3 "feat(M1): reconcile"

printf 'export const UNRELATED = true;\n' > src/unrelated.ts
G add src/unrelated.ts
commit_on 5 "feat(M10): unrelated"

printf 'export function ingest(lines: string[]): number {\n  return lines.length;\n}\n' > src/ingest.ts
G add src/ingest.ts
commit_on 7 "feat(M2): thing"

printf "import { ingest } from '../src/ingest';\n\ntest('ingest counts lines', () => {\n  expect(ingest(['a'])).toBe(1);\n});\n" > test/ingest.test.ts
G add test/ingest.test.ts
commit_on 9 "test(M2): late test"
