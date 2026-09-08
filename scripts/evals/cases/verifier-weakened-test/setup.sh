#!/usr/bin/env bash
# Commits a feat(M2) that weakens test/a.test.ts: the only expect() is dropped and the
# test becomes unconditional. No DEC id in the message and none under decisions/.
set -euo pipefail

WORK="${1:?usage: setup.sh <workdir>}"

cat > "$WORK/test/a.test.ts" <<'TS'
import { reconcile } from '../src/a';

test('reconcile dedupes a replayed batch', () => {
  reconcile(['e1', 'e1', 'e2']);
});
TS

git -C "$WORK" add test/a.test.ts
GIT_AUTHOR_DATE="2026-09-10T10:00:00+00:00" GIT_COMMITTER_DATE="2026-09-10T10:00:00+00:00" \
  git -C "$WORK" -c user.name=fixture -c user.email=fixture@example.com -c commit.gpgsign=false \
  commit -q -m "feat(M2): simplify the reconcile assertion"
