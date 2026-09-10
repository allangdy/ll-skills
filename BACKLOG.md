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
| B-009 | 03 / 8201453 | test-gap | a fixture without ROADMAP.md and with PLAN §8 inline phases makes `ll-auto.js detect --json` list `phase-NN` rows | OPEN |
| B-010 | 03 / 8201453 | test-gap | a fixture with docs/DELIVERY.md and the last-phase epilogue makes `ll-auto.js detect --json` report `close: done` | OPEN |
| B-011 | 03 / 3549e7b | test-gap | `node skills/ll-auto/scripts/ll-auto.js roteiro --cwd scripts/fixtures/project --flags "--interactive --redo phase-05 --pause-at 8" --json` asserted in the smoke test: `ll-implement 05` without `--no-talk`, `pause_after:true` on phase-08 | OPEN |
| B-012 | 03 / 3549e7b | test-gap | a fixture whose epilogue names `ll-verify NN` makes `roteiro` insert `verify-NN` without `--verify all` | OPEN |
| B-013 | 03 / c309e5d | test-gap | `for s in 5 6 7 8; do bash scripts/smoke-test.sh --only $s || exit 1; done` exit 0 (sections that share state run alone) | OPEN |
| B-014 | 03 / d6cf404 | test-gap | `bash scripts/smoke-test.sh --only 4c` asserts the exact stage ids and statuses of `detect --json` on `scripts/fixtures/empty` (a renamed status or a dropped stage fails) · exit 0 | OPEN |
| B-015 | 03 / d6cf404 | test-gap | a smoke check covers the `{"ok":false}` branch of `ll-auto.js` (`detect --cwd /nonexistent --json` → `"ok":false`) · exit 0 | OPEN |
| B-016 | 04 / plan | eval-gap | `bash scripts/evals/run.sh --dry-run --case goal-autonomous` exit 0 (renders `ll-goal --autonomous` on a fixture and measures ≤ 4000 chars) | OPEN |
| B-017 | 04 / 3b6198a | test-gap | a smoke check asserts the autonomous frontmatter rule of `goal-template.md` (`mode: autonomous`, no `ceiling_usd` in the variant section) · exit 0 | OPEN |
