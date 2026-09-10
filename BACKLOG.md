# BACKLOG

| id | born (phase / commit) | type | closing condition (executable) | state |
|---|---|---|---|---|
| B-001 | 01 / 3197200 | hygiene | `git check-ignore -q .claude/agent-memory/ll-verifier` exit 0 (add `.claude/agent-memory/` to .gitignore) | OPEN |
| B-002 | 01 / 122a3bb | test-gap | a scratch SKILL.md with a folded (`>`) multi-line description makes `bash scripts/lint-prompts.sh --rule 1` exit 1 (rule 1 "one line" guard, scripts/lint-prompts.sh:139-140) | OPEN |
| B-003 | 01 / 122a3bb | test-gap | `no_tool_use` on a missing or malformed out.json exits 1 instead of ok (scripts/evals/lib/assert.sh:69) | OPEN |
| B-004 | 01 / 122a3bb | test-gap | a scratch SKILL.md with `disable-model-invocation: false` makes `bash scripts/lint-prompts.sh --rule 1` exit 1 | OPEN |
| B-005 | 02 / a852fcc | schema | `grep -q "status: WAITING" skills/ll-decide/references/plan-skeleton.md` exit 0 (the WAITING DEC shape `--no-talk` writes is documented in the skeleton) | OPEN |
| B-006 | 02 / db36d39 | test-gap | `printf '▶ Next — /clear, then ll-good or ll-good --resume\n' >> <scratch next-good SKILL.md> && ! node scripts/lint-contract.cjs --rule 6 --root <scratch>` exit 0 (rule 6 rejects a repeated skill outside a parenthetical; matches() is uniq-based, lint-contract.cjs:55,355) | OPEN |
| B-007 | 02 / db36d39 | test-gap | smoke check `contrato 6: next-bad falha` asserts the FAIL count is 3, not only a non-zero exit (scripts/smoke-test.sh:390) | OPEN |
| B-008 | 02 / a852fcc | test-gap | a smoke or lint check fails when `--no-talk` is absent from the argument-hint of ll-decide or ll-close | OPEN |
