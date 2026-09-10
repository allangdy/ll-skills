# PROGRESS — ll-auto: manual skills, one orchestrator

<!-- ll-state -->
phase: 01
milestones:
  M1: { passes: true, commit: ca1ee3b, accepted_at: 2026-09-10T15:22:44Z }
  M2: { passes: true, commit: 14f67e8, accepted_at: 2026-09-10T15:24:48Z }
  M3: { passes: true, commit: 15775f9, accepted_at: 2026-09-10T15:27:00Z }
  M4: { passes: true, commit: 3197200, accepted_at: 2026-09-10T15:22:44Z }
  M5: { passes: true, commit: 122a3bb, accepted_at: 2026-09-10T15:29:09Z }
<!-- /ll-state -->

## History
- 2026-09-10 — PLAN.md, ROADMAP.md and decisions DEC-0001..0004 written from the design page; phase 01 opened.
- [2026-09-10T15:03:10Z] wave 1/4 — lock every skill and invert the lint (M1) · router eval cases assert the manual contract (M4)

## Phase 01

### M1 — 2026-09-10 18:32
built: all 11 `skills/*/SKILL.md` carry `disable-model-invocation: true` and a plain one-line English description (176–210 chars, third-person verb, no "Use when", bodies byte-identical); `scripts/lint-prompts.sh` rule 1 now requires the lock on every skill and bounds descriptions 60–300 chars with "Use when" as a FAIL, rule 3 turns the preamble line count into a ceiling and FAILs while the preamble still routes.
commits: ca1ee3b feat(M1): lock every skill, invert lint rule 1
commands: `for r in 1 2 4 5 6 7; do bash scripts/lint-prompts.sh --rule $r || exit 1; done && test "$(grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l)" = 0` → "ok   7 language (80 files)" (exit 0, run after the commit) · `bash scripts/lint-prompts.sh --rule 3` → "FAIL 3 line ceilings: assets/preamble.md: routes to a skill: contains 'Route every request', 'One word from the owner'" (exit 1, expected until M2)
deviations: none — one extra guard added to rule 1, "description is not one line" (scripts/lint-prompts.sh:139-140); `NO_INVOCATION` replaced by `PREAMBLE_FORBIDDEN`
questions: none
backlog: none
not_verified: `npm run lint` / `npm test` as a whole (M5) · descriptions read in a real `/` menu (owner: `head -6 skills/*/SKILL.md`) · a `disable-model-invocation: false` value hitting the FAIL path

### M4 — 2026-09-10 14:15
built: eval cases router-research/router-execute/router-small/preamble-no-ritual now assert the manual contract (command named, no Skill tool_use) via a new no_tool_use helper in lib/assert.sh, exercised green/red by a new fixture pair scripts/evals/fixtures/manual-contract/{out.json,with-skill.json,out.txt}.
commits: 3197200 feat(M4): eval cases for the manual contract
commands: acceptance chain → "# dry run: 10 case blocks printed, no claude call made" (exit 0) · bash -n on all 5 touched assert.sh files → ok
deviations: none
questions: none
backlog: none
not_verified: the four cases against a real `claude` call — closing command: `bash scripts/evals/run.sh --case router-research --reps 1` · router-execute/router-small/preamble-no-ritual against their own recorded fixtures (none exist)
- [2026-09-10T15:22:44Z] wave 2/4 — preamble without a router (M2)

### M2 — 2026-09-10 15:31
built: `assets/preamble.md` is 64 lines with no router — regime list and "One word from the owner" gone; `## Skills` opens with the manual-only contract (skill runs only when the owner types `/ll-<name>`, the session starts none, never calls the Skill tool on an ll skill, answers with the exact command to paste and stops; `ll-auto` is the only follower of another skill's instructions, under `/ll-auto`), then a "commands to name, never to run" map; Delegation verbatim; Decisions minus money/ceiling clauses (DEC-0003); Proof plus the two-failed-attempts evidence rule.
commits: 14f67e8 feat(M2): preamble without a router
commands: acceptance → "ok   3 line ceilings (46 files)" (exit 0) · `bash scripts/lint-prompts.sh` → all rules ok (exit 0)
deviations: none
questions: none (DEC-0008 unused)
backlog: none
not_verified: installed `~/.claude/CLAUDE.md` still carries the old block (closing: `node bin/install.js` then `grep -c 'Route every request' ~/.claude/CLAUDE.md` → 0) · eval cases against a real `claude` run (`bash scripts/evals/run.sh --case router-research --reps 1`) · `npm run lint && npm test` as a whole (M5)
- [2026-09-10T15:24:48Z] wave 3/4 — README and CHANGELOG follow the new contract (M3)

### M3 — 2026-09-10 15:24
built: README.md describes the preamble as the house-rules block (no router); "Como funciona" regime table replaced by "Como as skills são chamadas" (manual invocation, one skill per turn, `▶ Next`, `ll-auto` phase 03 "em desenvolvimento"); "ideia" row names `/ll-brainstorm`/`/ll-research`; CHANGELOG.md gained `## [3.0.0] - Unreleased` with `### Quebras` and `### Alterado`.
commits: 15775f9 feat(M3): README and CHANGELOG for the manual contract
commands: acceptance → "ok — 7 rule(s), 0 violation(s)" (exit 0, after the commit)
deviations: none
questions: none (DEC-0008 unused)
backlog: none
not_verified: README rendering read by a human · `npm test` as a whole (M5)
- [2026-09-10T15:27:00Z] wave 4/4 — lint and smoke test green (M5, owner lifted I-09 for smoke-test.sh, DEC-0007)

### M5 — 2026-09-10 15:42
built: scripts/smoke-test.sh's nested-fixtures check moves $NEST/docs/state aside (mv, not rm -rf) for the "hook ignora PROGRESS.md dentro de fixtures/" check and restores it after, so the later nested backlog-reconcile finds it; the owner's three lines committed with the fix (DEC-0007).
commits: 122a3bb feat(M5): smoke test green
commands: `npm run lint && npm test` → "smoke test OK — 174 checks" exit=0
deviations: none
questions: none
backlog: none
not_verified: nothing for this milestone

## Epilogue — phase 01 — 2026-09-10
passed: M1, M2, M3, M4, M5 (5/5) — every skill locked, preamble without a router, README/CHANGELOG updated, router eval cases assert the manual contract, lint and smoke test green in this worktree.
left: none.
waiting: none.
new backlog: B-001 gitignore `.claude/agent-memory/` · B-002 lint rule 1 folded-description guard · B-003 `no_tool_use` on a malformed capture · B-004 `disable-model-invocation: false` coverage.
verification: phases/01/VERIFICATION.md APPROVED_WITH_RESERVATIONS — SC-04 is green only with the owner's uncommitted `hooks/ll-state.js` (the fixtures/ skip the committed smoke check relies on); a clean checkout of 122a3bb fails `npm test`.
actions that need you:
- commit your two hook edits so `npm test` is green for anyone who clones: `git add hooks/ll-state.js hooks/ll-precompact.js && git commit -m "fix(hooks): skip PROGRESS.md under fixtures/ and test dirs"` (or say "pode commitar" and the next session does it)
- reinstall so your own `~/.claude/CLAUDE.md` loses the old router block: `node bin/install.js` (then `grep -c 'Route every request' ~/.claude/CLAUDE.md` → 0)
- optional, real check of the new preamble wording: `bash scripts/evals/run.sh --case router-research --reps 1`
milestones passed 5/5 · questions asked 1 / assumptions 3 / band-1 open 0 · amendments 0 · verification: phases/01/VERIFICATION.md APPROVED_WITH_RESERVATIONS
▶ Next — /clear, then ll-implement 2
