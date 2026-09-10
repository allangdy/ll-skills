# BACKLOG

| id | born (phase / commit) | type | closing condition (executable) | state |
|---|---|---|---|---|
| B-001 | 01 / 3197200 | hygiene | `git check-ignore -q .claude/agent-memory/ll-verifier` exit 0 (add `.claude/agent-memory/` to .gitignore) | OPEN |
| B-002 | 01 / 122a3bb | test-gap | a scratch SKILL.md with a folded (`>`) multi-line description makes `bash scripts/lint-prompts.sh --rule 1` exit 1 (rule 1 "one line" guard, scripts/lint-prompts.sh:139-140) | OPEN |
| B-003 | 01 / 122a3bb | test-gap | `no_tool_use` on a missing or malformed out.json exits 1 instead of ok (scripts/evals/lib/assert.sh:69) | OPEN |
| B-004 | 01 / 122a3bb | test-gap | a scratch SKILL.md with `disable-model-invocation: false` makes `bash scripts/lint-prompts.sh --rule 1` exit 1 | OPEN |
