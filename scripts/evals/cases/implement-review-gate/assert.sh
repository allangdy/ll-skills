#!/usr/bin/env bash
# The review gate opens wave 1: PLAN-REVIEW.md exists, and no feat( commit of this run
# predates it. Only phase 07 is planned.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"
REVIEW="phases/07/PLAN-REVIEW.md"

if [ -f "$WORK/$REVIEW" ]; then
  ok "$REVIEW exists"
else
  fail "$REVIEW does not exist: the gate before wave 1 was not written"
fi

base="$(base_sha "$WORK")"
# Only commits this run added count; the fixture history already carries feat( commits.
range="${base:+$base..HEAD}"
first_feat="$(git -C "$WORK" log ${range:+"$range"} --reverse --format='%ct %s' | grep -m1 ' feat(' | cut -d' ' -f1)"

if [ -z "$first_feat" ]; then
  ok 'this run committed no feat(: nothing could precede the gate'
else
  # The review is written once by the verifier and committed later with the phase state, so the
  # earliest evidence dates it: the file mtime, or its commit when that is older.
  review_ct="$(stat -c %Y "$WORK/$REVIEW" 2>/dev/null)"
  review_commit="$(git -C "$WORK" log --diff-filter=A --format=%ct -- "$REVIEW" | tail -1)"
  if [ -n "$review_commit" ] && { [ -z "$review_ct" ] || [ "$review_commit" -lt "$review_ct" ]; }; then review_ct="$review_commit"; fi
  if [ -n "$review_ct" ] && [ "$review_ct" -le "$first_feat" ]; then
    ok "the gate ($review_ct) precedes the first feat( of this run ($first_feat)"
  else
    fail "a feat( commit at $first_feat precedes the review gate at ${review_ct:-none}"
  fi
fi

no_path "$WORK/phases/08" 'nothing was written under phases/08/'

finish
