# PROGRESS — ll-auto: manual skills, one orchestrator

<!-- ll-state -->
phase: 05
milestones:
  M1: { passes: true, commit: 8e93103, accepted_at: 2026-09-10T18:39:33Z }
  M2: { passes: true, commit: ed715a9, accepted_at: 2026-09-10T18:39:33Z }
  M3: { passes: true, commit: ac13af4, accepted_at: 2026-09-10T18:45:03Z }
  M4: { passes: true, commit: 4519fe9, accepted_at: 2026-09-10T18:47:37Z }
<!-- /ll-state -->

## History
- 2026-09-10 — phase 02 closed (4/4, APPROVED_WITH_RESERVATIONS); phase 03 opened.
- 2026-09-10 — phase 01 closed (5/5, APPROVED_WITH_RESERVATIONS); phase 02 opened.
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

- [2026-09-10T16:28:57Z] wave 1/3 — rule 6 enforces the Next grammar, fixture-tested (M1)

- [2026-09-10T16:32:53Z] wave 2/3 — every Next line rewritten to the grammar (M2)

- [2026-09-10T16:37:24Z] wave 3/3 — ll-decide project --no-talk (M3) · ll-close --no-talk (M4)

- [2026-09-10T17:04:28Z] wave 1/4 — helper detect (M1)

- [2026-09-10T17:11:17Z] wave 2/4 — helper roteiro, next-cmd, report, auto-md (M2)

- [2026-09-10T17:17:56Z] wave 3/4 — the ll-auto skill text and the lint exceptions (M3)

- [2026-09-10T17:26:03Z] wave 4/4 — installer mode bits, README, CHANGELOG, installed-copy check (M4)

- [compaction 2026-09-10T17:26:03Z · auto · HEAD c309e5d] re-read phases/03/PLAN.md and the milestone board before continuing.

- [2026-09-10T17:31:49Z] phase 03: waves done 4/4 — clean-context verification dispatched (slice 1773a63..d6cf404)

- [2026-09-10T18:10:56Z] wave 1/2 — the autonomous variant, the mode in SKILL.md, the smoke section (M1)

- [2026-09-10T18:17:31Z] wave 2/2 — README and CHANGELOG for the autonomous mode (M2)

- [2026-09-10T18:17:45Z] board switched to phase 04 (M1 true, M2 false) — the earlier passes M1 had landed on the phase 03 board; phase 03 M1 is 8201453 as recorded in its ### M1 block

- [2026-09-10T18:19:43Z] phase 04: waves done 2/2 — clean-context verification dispatched (slice ae68dce..dcea559)

- [2026-09-10T18:35:50Z] wave 1/3 — the two eval cases and their offline answers (M1, M2)

- [2026-09-10T18:39:33Z] wave 2/3 — offline smoke section evals-auto and the real rep of both cases (M3)

- [2026-09-10T18:45:03Z] wave 3/3 — release 3.0.0: package.json, CHANGELOG dated, evals README (M4)

- [2026-09-10T18:47:00Z] phase 05: waves done 3/3 — clean-context verification dispatched (slice d19dd49..4519fe9)

- [2026-09-10T18:47:37Z] M4: the session's first acceptance run extracted the YAML string without unescaping \\[ — rerun with the YAML value exit=0

- [2026-09-10T19:32:33Z] backlog round — B-002..B-020 dispatched to three executors (lint · ll-auto helper · evals+docs), HEAD d8c7735

- [2026-09-11T19:17:26Z] 3.1.0 round — wave 1: four executors on disjoint files (helper+smoke+fixtures · ll-implement · ll-decide+policy · brainstorm/close/resume/agents/preamble), from lab/runs/2026-09-11-notes-api/CHANGE-PLAN.md

- [compaction 2026-09-11T19:19:15Z · auto · HEAD a63db54] re-read phases/05/PLAN.md and the milestone board before continuing.

- [2026-09-11T19:28:49Z] 3.1.0 round — wave 2: lint rule 9, helper ceiling 760/36000 (DEC-0016), eval asserts for the new wording, new case router-large-opener

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

## Phase 02

### M1 — 2026-09-10 18:05
built: rule 6 (`next-targets`) enforces the grammar `▶ Next — /clear, then <cmd>` per marker occurrence (existing ll-skill + args, `/goal <text>`, or one `<placeholder>`; alternatives only inside one trailing parenthetical; prose only after the closing backtick of a quoted handoff); `--root <dir>` retargets the whole run before the ROOT-derived consts; an empty root is a FAIL; bad/good fixtures plus three smoke checks pin it.
commits: 6fb21d5 test(M1): fixtures and smoke checks for the ▶ Next grammar of rule 6 · db36d39 feat(M1): rule 6 enforces the ▶ Next grammar and takes --root
commands: acceptance → "acceptance exit=0" (next-bad: 3 FAILs; next-good: "ok   6 next-targets (5 checked)"; empty: "no skills tree under …") · red proof before feat: "acceptance exit=1" · `npm run lint` → "FAIL — 7 rule(s), 13 violation(s)" (the 13 package-tree Next lines M2 rewrites)
deviations: none
questions: none
backlog: none
not_verified: `npm test` as a whole (red by design until M2) · rule 6 on the package tree (M2)

### M2 — 2026-09-10 21:40
built: all 13 non-conformant ▶ Next handoffs (11 skill files + assets/preamble.md spec line) rewritten to `▶ Next — /clear, then <cmd>`; alternatives folded into one trailing parenthetical; quoted-in-prose handoffs keep their backtick wrap; rule 6 finds 0 violations on the package tree.
commits: e844650 feat(M2): every Next line in the grammar
commands: `node scripts/lint-contract.cjs --rule 6` → "ok — 1 rule(s), 0 violation(s)" · `npm run lint` → "ok — 7 rule(s), 0 violation(s)"
deviations: ll-close/SKILL.md:32 — the backtick pair around `<motivo em uma linha>` (before the marker) was restored after lint-prompts rule 7 flagged the line; outside the handoff grammar.
questions: none
backlog: none
not_verified: `npm test` as a whole (M4)

### M4 — 2026-09-10 22:10
built: `ll-close --no-talk` documented — argument-hint gains `[--no-talk]`; step 7 and --milestone step 6 say the block is not asked and the same items are written under the epilogue and in DELIVERY.md §5, each marked `[decided by absence — revisable]` with the date; the gate is unchanged.
commits: f23742d feat(M4): ll-close --no-talk
commands: acceptance chain → "smoke test OK — 177 checks" (exit=0)
deviations: none
questions: DEC-0011 — D-02-04 paraphrased the marker as "ratified by absence"; the house string `[decided by absence — revisable]` was used (band 2, session: D-02-04 amended, DEC-0011 released unused)
backlog: none
not_verified: end-to-end run of `ll-close --no-talk` against a real repo state

### M3 — 2026-09-10 22:10
built: `ll-decide --no-talk` documented end to end — argument-hint gains `[--no-talk]`; premise gate, interview and final round take the recommendation as `ASM-n [decided by absence — revisable]` and turn every band-1 item into a `WAITING` `decisions/DEC-NNNN-*.md`; the final round is printed as a report and the contract freezes even with K > 0; hand-off names each WAITING DEC and the phase carrying `stop: owner`; feedback triage follows the same rule; the three byte-identical decision-policy.md copies gain the immediate-silence bullet (md5 f0e02923… ×3).
commits: a852fcc feat(M3): ll-decide --no-talk
commands: acceptance → "acceptance exit=0" (lint last line "ok — 7 rule(s), 0 violation(s)") · `wc -l` → SKILL.md 137/200, interview.md 112/150, premise-gate.md 90/150, decision-policy.md 121/150
deviations: none
questions: none
backlog: WAITING DEC state has no schema in plan-skeleton.md and no lint check
not_verified: `npm test` as a whole (M4) · runtime behaviour of `--no-talk` (documentation only; phase 05 exercises it)

## Epilogue — phase 02 — 2026-09-10
passed: M1, M2, M3, M4 (4/4) — rule 6 enforces the ▶ Next grammar with fixtures and smoke checks; every handoff line rewritten; `--no-talk` documented in ll-decide (gate, interview, final round, feedback) and ll-close (ratification), with the house marker `[decided by absence — revisable]`.
left: none.
waiting: none.
new backlog: B-005 WAITING DEC shape in plan-skeleton · B-006 rule 6 and a repeated skill outside a parenthetical · B-007 next-bad smoke check counts the FAILs · B-008 regression cover for the `--no-talk` argument-hints.
verification: phases/02/VERIFICATION.md APPROVED_WITH_RESERVATIONS — same reservation as phase 01: a clean checkout fails `npm test` until the owner commits the two hook files; `--no-talk` is proven as documentation only (phase 05 exercises it).
actions that need you:
- commit your two hook edits: `git add hooks/ll-state.js hooks/ll-precompact.js && git commit -m "fix(hooks): skip PROGRESS.md under fixtures/ and test dirs"` (or say "pode commitar")
- reinstall when convenient so the installed skills carry the new ▶ Next lines: `node bin/install.js`
milestones passed 4/4 · questions asked 0 / assumptions 5 / band-1 open 0 · amendments 0 · verification: phases/02/VERIFICATION.md APPROVED_WITH_RESERVATIONS
▶ Next — /clear, then ll-implement 3

## Phase 03

### M1 — 2026-09-10 18:05
built: `skills/ll-auto/scripts/ll-auto.js` (new, mode 100755, 199 lines, `fs`+`path` only) with `detect [--cwd <dir>] [--json]` — ordered stage table (research, brainstorm, decide, `phase-NN` per ROADMAP row, `verify-NN` per row, close), `{id,status,evidence}`; `{"ok":false,"reason":…}` exit 0 on a bad `--cwd`; smoke section 4c plus the installed-skill count 11→12.
commits: 606a9db test(M1): smoke checks for ll-auto detect on both fixtures and the 12-skill install count · 8201453 feat(M1): ll-auto detect reads the stage table from disk
commands: M1 acceptance chain → "exit=0" · red proof before feat → "FALHOU: ll-auto detect: fixture project → decide done, 07 half" · detect twice + cmp → "byte-identical twice" · `npm test` → "FALHOU: contrato 1: references citadas existem e são citadas" (exit 1; `skills/ll-auto/` without SKILL.md until M3)
deviations: contract rule 1 red until M3 writes SKILL.md (outside FILES) · `gitTop` not copied (needs child_process); root is `path.resolve(--cwd || cwd)` · state parsers copied without the `<ll-shared:state>` markers
questions: none
backlog: none
not_verified: `npm test` as a whole (M3 closes it) · installed-copy assertions (M4) · phase rows from PLAN §8 without ROADMAP (no fixture) · `close: done` (no fixture with docs/DELIVERY.md)

### M2 — 2026-09-10 18:12
built: `ll-auto.js` (340 lines, `fs`+`path` only, `detect` untouched) serves `roteiro --flags/--objective`, `next-cmd <file>`, `report` and `auto-md`; smoke section 4d (8 checks) and the `scripts/fixtures/auto-decisions/decisions/` fixture prove the PLAN behavior cases.
commits: 9c228db test(M2): smoke section 4d proves roteiro, next-cmd, report and auto-md, with the auto-decisions fixture · 3549e7b feat(M2): ll-auto gains roteiro, next-cmd, report and auto-md
commands: M2 acceptance chain → "exit=0" · `npm test` → "FALHOU: contrato 1: …" (the M3-owned missing SKILL.md; every check through section 4d passed)
deviations: close enters only when `--only` is absent and no still-open phase row was cut by `--from/--to` (ll-auto.js:262) — reconciles the PLAN's behavior line (`--from 8 --to 8` → no close, 07 still open) with its action line.
questions: none
backlog: `--pause-at`, `--redo`, `--interactive` parsed but not smoke-checked · the "epilogue names ll-verify NN" branch not covered
not_verified: `npm test`/`npm run lint` green (M3) · `docs/AUTO.md` written to disk (M3's Flow)

### M3 — 2026-09-10 14:25
built: `skills/ll-auto/SKILL.md` (74 lines: locked frontmatter, `detect` preprocessor line, four boundaries incl. never the Skill tool, Deliverables, Flow 0-3, Completion criterion ending `▶ Next — /clear, then ll-resume`) plus `references/stages.md` (65) and `references/run.md` (75); `lint-prompts.sh` gained `ALLOWED_TOOLS_BY_SKILL` and `ORCHESTRATOR = ["ll-auto"]`; `smoke-test.sh` gained `--only <seção>` and the `lint-orquestrador` section.
commits: 3623265 test(M3): smoke section lint-orquestrador and the --only switch prove the ll-auto exceptions are scoped · c309e5d feat(M3): the ll-auto skill text, its two references and the lint exceptions scoped to ll-auto
commands: M3 acceptance chain → "exit=0" ("ok — 7 rule(s), 0 violation(s)", "smoke test OK — 4 checks") · `npm test` → "smoke test OK — 192 checks" · red proof before feat → "FAIL 1 skill frontmatter: … allowed-tools is 'Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)'" and "FAIL 5 forbidden strings: … line 19 invokes a skill as a command"
deviations: none
questions: none
backlog: `--only` on sections 5-8 untested
not_verified: the Flow itself never executed (`/ll-auto` on a real repo — phase 05 evals) · installed copy (M4)

### M4 — 2026-09-10 19:40
built: installer gives `mode: 0o755` to every `skills/*/scripts/*.js` (general branch, `HELPER_SKILLS` injection untouched); `smoke-test.sh` gained a `-x` + sha256-identical check for the installed `skills/ll-auto/scripts/ll-auto.js`; README (Portuguese) updated — skills table row, install table (12 skills + ll-auto.js row), "Como as skills são chamadas" paragraph (no more "em desenvolvimento"), a new "Fluxo autônomo" 10-row flag table with the empty-repo and decided-by-absence sentences, and a helper subsection listing ll-auto.js's five commands; CHANGELOG `## [3.0.0] - Unreleased` gained `### Adicionado` (ll-auto skill + helper + flags, and `--no-talk` in ll-decide/ll-close, which existed in those SKILL.md files but was not yet logged).
commits: d6cf404 feat(M4): ll-auto shipped — installer, README, CHANGELOG
commands: `npm run lint && npm test && grep -q '/ll-auto "' README.md && ! grep -q 'em desenvolvimento' README.md && grep -q 'll-auto' CHANGELOG.md` → "smoke test OK — 194 checks" → exit=0 · `bash -n scripts/smoke-test.sh && node -c bin/install.js` → "SYNTAX_OK"
deviations: none
questions: none
backlog: none
not_verified: the real `/ll-auto` Flow never executed against a live repo (that is phase 05 per M3's not_verified, out of this milestone's scope)

## Epilogue — phase 03 — 2026-09-10
passed: M1, M2, M3, M4 (4/4) — `skills/ll-auto/` ships: helper `scripts/ll-auto.js` (detect, roteiro, next-cmd, report, auto-md), SKILL.md with the 12 flags and the empty-repo rule, references/stages.md and run.md, lint exceptions scoped to ll-auto only (`ORCHESTRATOR`, `ALLOWED_TOOLS_BY_SKILL`), installer mode bits for every `skills/*/scripts/*.js`, README "Fluxo autônomo", CHANGELOG 3.0.0 `### Adicionado`.
left: none.
waiting: none.
new backlog: B-009..B-012 (helper edge cases, from M1/M2) · B-013 `--only` on sections 5-8 · B-014 exact-status assertion for detect on the empty fixture · B-015 smoke cover for the `{"ok":false}` branch.
verification: phases/03/VERIFICATION.md APPROVED — 5/5 criteria VERIFIED, no BLOCKS; not proven: the `/ll-auto` Flow as a run (SC-03 write and SC-04 "in place" are helper output plus prompt text — phase 05 evals `auto-dry-run` and `auto-empty-repo` close it); the WAITING/`--auto-decision` path has no fixture; a clean `git archive HEAD` checkout still fails `npm test` at the hook check that depends on the owner's uncommitted hooks edits (same reservation as phases 01 and 02).
actions that need you:
- commit your two hook edits: `git add hooks/ll-state.js hooks/ll-precompact.js && git commit -m "fix(hooks): skip PROGRESS.md under fixtures/ and test dirs"` (or say "pode commitar")
- reinstall so `/ll-auto` exists in your session: `node bin/install.js`
milestones passed 4/4 · questions asked 0 / assumptions 8 / band-1 open 0 · amendments 0 · verification: phases/03/VERIFICATION.md APPROVED
▶ Next — /clear, then ll-implement 4

## Phase 04
### M1 — 2026-09-10 15:40
built: `ll-goal --autonomous ["<objective>"]` exists as a documented mode — SKILL.md gains `## Autonomous mode` (5 differences: pre-flight on PLAN.md+ROADMAP.md at the git top, stages from `ll-auto.js detect --json`, step 2 skipped, the variant of the template, `mode: autonomous` + commit `docs: goal for the whole delivery`), goal-template.md gains `## Autonomous variant` (five-field frontmatter without `ceiling_usd`, the eight parts, EXECUTION at `ll-auto --auto-decision`) plus `## Autonomous example` (1,489-byte text rendered for scripts/fixtures/project) and checklist lines 11-13, and smoke-test.sh gains the standalone section `goal-autonomo` with 4 checks
commits: 09c9441 test(M1): smoke section goal-autonomo proves the --autonomous mode is missing · 3b6198a feat(M1): ll-goal --autonomous — the variant in the template and the mode in SKILL.md
commands: [red, before feat] bash scripts/smoke-test.sh --only goal-autonomo → "FALHOU: ll-goal argument-hint aceita --autonomous" exit=1 · [M1 acceptance, after last commit] → "ok — 7 rule(s), 0 violation(s)" exit=0 (smoke last line: "smoke test OK — 4 checks") · npm test → "smoke test OK — 198 checks" exit=0
deviations: the variant's frontmatter is one prose line (five fields, no `ceiling_usd`) instead of a second fenced yaml block — the 150-line ceiling (file now 147 lines); Deliverables row for `docs/GOAL.md` reads `ceiling_usd` or `mode` so the table stays true in both modes (skills/ll-goal/SKILL.md:21)
questions: none
backlog: none
not_verified: no session ever emitted the text (deferred eval case B-016) · clean-checkout lint/test (Errata G-2, I-09) — run in this worktree only
### M2 — 2026-09-10 16:05
built: README.md's `ll-goal` row now names `ll-goal --autonomous ["<objetivo>"]` and a new "Para rodar sem parar" subsection under "Fluxo autônomo" explains the loop (`ll-goal --autonomous` writes the text, `/goal <texto>` keeps restarting `ll-auto --auto-decision` until delivery, decisions listed at the end); CHANGELOG.md's `### Adicionado` gains one bullet for `ll-goal --autonomous`
commits: dcea559 feat(M2): ll-goal --autonomous documented — README, CHANGELOG
commands: npm run lint && npm test && grep -q -- 'll-goal --autonomous' README.md && grep -q -- '--autonomous' CHANGELOG.md → "smoke test OK — 198 checks" exit=0
deviations: none
questions: none
backlog: none
not_verified: none

## Epilogue — phase 04 — 2026-09-10
passed: M1, M2 (2/2) — `ll-goal --autonomous ["<objective>"]`: the `## Autonomous mode` section in SKILL.md, the `## Autonomous variant` and `## Autonomous example` in goal-template.md (EXECUTION at `ll-auto --auto-decision`, no BUDGET, `mode: autonomous`), smoke section `goal-autonomo` (4 checks), README "Para rodar sem parar", CHANGELOG bullet.
left: none.
waiting: none.
new backlog: B-016 eval case `goal-autonomous` · B-017 smoke check for the variant frontmatter rule.
verification: phases/04/VERIFICATION.md APPROVED_WITH_RESERVATIONS — 3/3 criteria VERIFIED, 1 NOT_VERIFIABLE (clean-checkout `npm test`, blocked by the owner's uncommitted hooks, same as phases 01–03); the 4,000-char cap is measured on the static example (1,489 bytes), never on an emission.
actions that need you:
- commit your two hook edits: `git add hooks/ll-state.js hooks/ll-precompact.js && git commit -m "fix(hooks): skip PROGRESS.md under fixtures/ and test dirs"` (or say "pode commitar")
- reinstall so `ll-goal --autonomous` exists in your session: `node bin/install.js`
milestones passed 2/2 · questions asked 0 / assumptions 5 / band-1 open 0 · amendments 0 · verification: phases/04/VERIFICATION.md APPROVED_WITH_RESERVATIONS
▶ Next — /clear, then ll-implement 5

## Phase 05
### M1 — 2026-09-10 18:42
built: eval case `auto-dry-run` (case.json, prompt.txt, assert.sh), its offline answer fixture `scripts/fixtures/evals-auto/auto-dry-run/pass.txt` captured from the real helper, and SKILL.md step 0 now says the dry run prints the stage table from `detect` plus the roteiro, then stops.
commits: 8e93103 feat(M1): eval case auto-dry-run
commands: M1 acceptance, verbatim → "ok — 7 rule(s), 0 violation(s)" · exit=0 · negative control (a scratch tree holding `docs/AUTO.md`) → "FAIL: the working tree was changed: ?? docs/" exit 1
deviations: the acceptance writes `out.json`/`fail.txt` inside the scratch work tree, so `assert.sh:18-25` filters out only the two paths handed in as `$OUT_JSON`/`$OUT_TXT`; anything else the run wrote still fails (negative control above)
questions: none
backlog: none
not_verified: never run against a real `claude -p` (M3) · a model that reformats the roteiro into a markdown table is covered only in the "stage and command on one line" shape · smoke section `evals-auto` (M3)
### M2 — 2026-09-10 15:40
built: eval case auto-empty-repo (case.json, prompt.txt, assert.sh, fixture/.gitkeep) plus its offline pass.txt fixture, proving the "/ll-auto" empty-repo stop (two exact lines, no question, no path written) both offline and via `--dry-run`.
commits: ed715a9 feat(M2): eval case auto-empty-repo
commands: M2 acceptance, verbatim → exit=0 ("ok — 7 rule(s), 0 violation(s)")
deviations: assert.sh filters git status output by `$(basename "$OUT_JSON")` before checking it is empty (scripts/evals/cases/auto-empty-repo/assert.sh:15-20), same reason as M1
questions: none
backlog: none
not_verified: the real `claude -p` rep (M3) · npm test as a whole
### M3 — 2026-09-10 15:44
built: `scripts/smoke-test.sh` gained the standalone section `evals-auto` (4 Portuguese-labelled checks: each auto assert accepts its `scripts/fixtures/evals-auto/<case>/pass.txt` and rejects `I ran nothing and wrote nothing.` against a fresh `git init` scratch tree with a minimal `out.json`), registered in the header comment and selectable with `--only evals-auto`; and both auto cases passed one real `claude -p` rep with the prompts and turn caps as M1/M2 shipped them.
commits: ac13af4 feat(M3): smoke section evals-auto; real rep of the auto cases
commands: M3 acceptance, verbatim (executor) → "total cost USD 0.5073 · exit 0" · exit=0 · session rerun → exit=0, `results : /home/greenn/.claude/ll-skills-evals/2026-09-10-1543` (RESULTS.md there), `auto-dry-run rep 1 PASS turns 5`, `auto-empty-repo rep 1 PASS turns 3` · `results : /home/greenn/.claude/ll-skills-evals/2026-09-10-1542` (RESULTS.md at /home/greenn/.claude/ll-skills-evals/2026-09-10-1542/RESULTS.md) · `auto-dry-run rep 1 PASS cost 0.2473 22.7s turns 4` · `auto-empty-repo rep 1 PASS cost 0.2600 19.9s turns 7` · earlier confirming rep (pre-commit) → /home/greenn/.claude/ll-skills-evals/2026-09-10-1541, both PASS · `bash scripts/smoke-test.sh --only evals-auto` → "smoke test OK — 4 checks"
deviations: none
questions: none
backlog: `auto-empty-repo` reported `turns 7` against `max_turns 4` — the cap and the reported turn count do not line up
not_verified: `npm test` as a whole (session runs it below) · `claude -p` slash-command expansion proven on this CLI version only · reps beyond 1
### M4 — 2026-09-10 15:52
built: package.json at 3.0.0 with 12-skill description, CHANGELOG.md dated 2026-09-10 with the auto-eval bullet, scripts/evals/README.md updated to twelve cases plus an "Autonomous cases" paragraph
commits: 4519fe9 feat(M4): release 3.0.0 — package.json, CHANGELOG, evals README
commands: M4 acceptance, verbatim → "smoke test OK — 202 checks" · exit=0
deviations: none
questions: none
backlog: none
not_verified: no git tag or npm publish performed (owner's); the RESULTS.md path was read from PROGRESS.md, not regenerated

## Epilogue — phase 05 — 2026-09-10
passed: M1, M2, M3, M4 (4/4) — eval cases `auto-dry-run` and `auto-empty-repo` (slash command as the owner types it, offline answers under `scripts/fixtures/evals-auto/`), smoke section `evals-auto` (4 checks), real reps PASS/PASS three times (executor /home/greenn/.claude/ll-skills-evals/2026-09-10-1542/RESULTS.md · session /home/greenn/.claude/ll-skills-evals/2026-09-10-1543/RESULTS.md · verifier /home/greenn/.claude/ll-skills-evals/2026-09-10-1548/RESULTS.md), `ll-auto --dry-run` prints the stage table, package.json 3.0.0 (12 skills), CHANGELOG `## [3.0.0] - 2026-09-10`, evals README twelve cases.
left: none in this phase. ROADMAP's "to a closed delivery" half of the phase objective is the deferred implement-to-close rep.
waiting: none.
new backlog: B-018 turn count vs cap in `auto-empty-repo` · B-019 offline capture with one assistant event · B-020 `no_tool_use` on a missing out.json.
verification: phases/05/VERIFICATION.md APPROVED — 5/5 VERIFIED, no BLOCKS; not proven: clean-checkout `npm test` (owner's uncommitted hooks, I-09) and any stage transition inside `ll-auto` (both cases assert a stop).
actions that need you:
- commit your two hook edits: `git add hooks/ll-state.js hooks/ll-precompact.js && git commit -m "fix(hooks): skip PROGRESS.md under fixtures/ and test dirs"` (or say "pode commitar")
- reinstall: `node bin/install.js`
- publish when you want: `git tag v3.0.0 && npm publish` (never done by a session)
milestones passed 4/4 · questions asked 0 / assumptions 6 / band-1 open 0 · amendments 0 · verification: phases/05/VERIFICATION.md APPROVED
▶ Next — /clear, then ll-close

## Epilogue — delivery 3.0.0 — 2026-09-10
gate: phases/05/VERIFICATION.md APPROVED (newest by mtime); reservations of phases 01, 02 and 04 accepted in decisions/DEC-0012-reservations-accepted.md — the clean-checkout one closed by 1efc0c9 and proven (`npm test` → `smoke test OK — 202 checks` on a `git archive HEAD` tree).
passed: phases 01–05, milestones 19/19; 33 commits on 2026-09-10 (feat 19 · test 5 · docs 7 · fix 1 · chore 1; test/feat 0.26); questions asked 1 / assumptions 27 / band-1 open 0.
left: implement-to-close rep of `ll-auto` on a bigger fixture and `--interactive` beyond brainstorm (ROADMAP deferred); B-016 goal-autonomous eval.
waiting: none.
backlog: reconciled — B-001 closed; B-002..B-020 open, every row with a command; `backlog-reconcile --run` parsed none of the conditions (prose around the command) — rule added to the project CLAUDE.md, rows to be tightened at the next close.
written: docs/DELIVERY.md · docs/RETROSPECTIVE-2026-09-10.md · CLAUDE.md (project, new: current state + 2 rules) · ROADMAP rows 01–05 marked DONE.
actions that need you: `git tag v3.0.0 && npm publish` when you want the team on 3.0.0 (never done by a session).
▶ Next — /clear, then ll-close --milestone 3.0.0
### BL-A — 2026-09-10 18:20
built: seven backlog gaps closed — rule 6 of lint-contract now rejects a handoff that names the same skill twice outside a parenthetical (uniq-based count fixed), smoke `--only` pulls the state prerequisites of sections 6 and 8, and five new/tightened smoke checks cover lint rule 1 against scratch SKILL.md fixtures, the pinned next-bad FAIL count, the `--no-talk` argument-hints and a no-longer-vacuous `no_tool_use`.
commits: 509d18a test(BL-A): lint and smoke gaps B-002, B-004, B-006, B-007, B-008, B-019 · 9108fbb feat(BL-A): rule 6 rejects a repeated skill and --only pulls its prerequisite
commands: B-002/B-004 `--only lint-scratch` → "smoke test OK — 3 checks" exit=0 · B-006 repeated skill → "FAIL — 1 rule(s), 1 violation(s)" (rejected) · B-007 `--only 10` → "smoke test OK — 11 checks" (next-bad pinned at 4 FAIL) · B-008 `--only no-talk` → "smoke test OK — 3 checks" · B-013 sections 5,6,7,8 alone → exit 0 each · B-019 `--only evals-auto` → "smoke test OK — 7 checks" · clean checkout `npm test` → "smoke test OK — 212 checks"
deviations: B-002, B-004, B-008, B-019 were pure test gaps, shipped in the test commit; no `--root` added to lint-prompts.sh (scratch-tree copy pattern used instead)
questions: none
backlog: `for s in 1 2 3 4 4b 4c 4d; do bash scripts/smoke-test.sh --only $s; done` not run alone · no check pins that two different skills in one ▶ Next line still fail
not_verified: final acceptance ran with BL-C's d847466 already in HEAD
### BL-C — 2026-09-10 16:50
built: `no_tool_use` fails on a missing or unparsable capture; new eval case `goal-autonomous` with its own healthy fixture (the shared one is broken on purpose and ll-goal refuses it), offline pass.txt, cap 20; `auto-empty-repo` cap pinned to 10 with the turn count explained; plan-skeleton.md documents the WAITING DEC; evals README thirteen cases.
commits: bb164ff test(BL-C) · 4ba1096 feat(BL-C): no_tool_use fails on a missing capture · d847466 feat(BL-C): caps, WAITING DEC, thirteen cases · 3871fc3 fix(BL-C): healthy fixture for goal-autonomous
commands: B-003/B-020 missing capture → "FAIL: … no capture at /nonexistent" exit=1 · B-005 grep → exit=0 · B-016 dry-run → "1 case blocks printed" exit=0 · B-018 real rep → "auto-empty-repo rep 1 PASS turns 3" (≤ 10) · real rep `goal-autonomous` + `auto-empty-repo` → PASS/PASS, results /home/greenn/.claude/ll-skills-evals/2026-09-10-1646 · `--only evals-auto` → "smoke test OK — 7 checks"
deviations: goal-autonomous moved from the shared fixture to its own (first paid rep FAILed on the broken shared fixture); EXECUTION check reads the answer flattened; max_turns 12 → 20
questions: none
backlog: evals-auto smoke section has no goal-autonomous pair (routed to BL-D)
not_verified: `npm test` as a whole (session runs it below) · the other eleven cases not re-run after the no_tool_use change
### BL-B — 2026-09-10 18:05
built: the six ll-auto helper gaps are smoke checks (sections 4c/4d, +9) over three new fixtures (auto-noroadmap, auto-closed, auto-verify-next); one real defect fixed — without ROADMAP.md the `## §8` slice of PLAN ended empty and no `phase-NN` was detected; next-bad gained the two-different-skills line (FAIL 4 → 6); `--only 4` and `--only 4d` run alone.
commits: a265e93 test(BL-B) · af02554 feat(BL-B): PLAN §8 without ROADMAP.md renders phases again
commands: B-009 → 2 `phase-NN` rows exit=0 · B-010 → `close: done` exit=0 · B-011/B-012 `--only 4d` → "smoke test OK — 10 checks" · B-014 `--only 4c` → "smoke test OK — 6 checks" · B-015 → `{"ok":false,"reason":"not a directory: /nonexistent"}` exit=0 · sections 1..4d alone → all exit 0 · next-bad → 6 FAIL · `npm test` → "smoke test OK — 218 checks" · clean checkout → same
deviations: `AUTO=` moved to the top of smoke-test.sh with a `4) "2 3"` prereq; the next-bad check writes to a file instead of `| grep -q` (SIGPIPE under pipefail); §8 table shape documented in the helper comment
questions: DEC-0015 — §8 inline phases: the table is canonical (decided; doc follow-ups routed to BL-D)
backlog: none
not_verified: a prose §8 still yields zero phases (by design after DEC-0015: prose is no longer a valid shape) · `--pause-at` end-to-end through the skill · new fixtures only exercised offline
### BL-D — 2026-09-10 15:47
built: smoke section evals-auto asserts the goal-autonomous pair (9 checks); plan-skeleton.md §8 and stages.md describe the inline phases as the ROADMAP table (DEC-0015).
commits: ebfeef2 feat(BL-D): evals-auto covers goal-autonomous; PLAN §8 inline phases are a table
commands: BL-D acceptance → exit=0 (`npm test` → "smoke test OK — 220 checks")
deviations: one unconditional echo at the end of the section so a green run names the pair
questions: none
backlog: none
not_verified: none

## Epilogue — backlog round — 2026-09-10
passed: B-002..B-020 closed (18 rows), four executors (BL-A lint/smoke, BL-B ll-auto helper, BL-C evals/docs, BL-D follow-ups); two real defects fixed on the way — rule 6 accepted the same skill twice in one ▶ Next line (9108fbb) and `detect` found no phases in a PLAN §8 without ROADMAP.md (af02554); `no_tool_use` no longer passes on a missing capture (4ba1096).
new: eval case `goal-autonomous` (own healthy fixture, real rep PASS, /home/greenn/.claude/ll-skills-evals/2026-09-10-1646/RESULTS.md); fixtures auto-noroadmap, auto-closed, auto-verify-next, lint-bad; DEC-0015 (§8 inline phases are a table).
left: none. waiting: none. backlog open: 0.
smoke: 202 → 220 checks; lint 0 violations; clean checkout green.
▶ Next — /clear, then ll-close --milestone 3.0.0
### HF-1 — 2026-09-10 19:15
built: lint rule 3 parses `npm pack --dry-run --json` in both shapes (npm ≤ 11 list, npm 12 object keyed by package name) and honours `LL_PACK_JSON=<file>` for tests — the publish workflow (npm@latest = 12.0.2) failed on the object shape (run 34535624727).
commits: 53ee836 test(HF-1) · 236a38c feat(HF-1)
commands: `npm run lint` → "ok — 7 rule(s), 0 violation(s)" · `npm test` → "smoke test OK — 222 checks" · `LL_PACK_JSON=/tmp/pack12.json bash scripts/lint-prompts.sh` exit=0
deviations: none · questions: none · backlog: none
not_verified: the GitHub run itself — the tag v3.0.0 is moved to this commit and pushed again to retrigger publish.yml
### HF-2 — 2026-09-10 19:12
built: publish.yml confirmation step polls up to 5 min (30 × 10 s) — run 34536013259 published `ll-skills@3.0.0` (provenance signed) but the 60 s window expired before the registry served it.
commits: b549a0e fix(ci): publish confirmation waits up to 5 minutes for the registry
commands: yaml parse + greps → exit=0 · `npm view ll-skills version` → 3.0.0 (19:11:41) · `CLAUDE_CONFIG_DIR=<tmp> node package/bin/install.js --yes --no-settings` on the published tarball → "Pronto." VERSION 3.0.0 · `npx -y ll-skills@3.0.0` → same (the first npx attempt seconds after publish failed with "command not found", a cache race; the retry passed)
deviations: none · questions: none · backlog: none
not_verified: the widened window on a real run (next release)

## 3.1.0 round — 2026-09-11
Source: lab/runs/2026-09-11-notes-api/CHANGE-PLAN.md (findings F-1..F-12, D-2..D-5). Wave 1: four executors on disjoint files. Decisions DEC-0016..0019 written by the session.
### W1-A — 2026-09-11 16:52
built: `ll-tools.js board-switch NN --milestones …` (rewrites `phase:`, drops the old phase's `M*`/`G-*` lines, seeds `{ passes: false, reason: "not started" }`, idempotent), `passes --phase NN` refusing another phase's board with exit 1, `epilogue` reporting `unparsable:` ids, day-inclusive `phase-stats --since`, count-line regex accepting both wordings, D-2 duplicate `write` gone; 10 new smoke checks in section 4; fixture BACKLOG with a `note` column + prose-condition row B-017.
commits: 05af5d2 test(W1-A) · 87c8491 feat(W1-A)
commands: `bash scripts/smoke-test.sh --only 4` → "smoke test OK — 70 checks" exit 0 (was 60) · `bash scripts/lint-prompts.sh --rule 3` → FAIL: 711 lines / 34624 bytes over 700 / 32768 · `node scripts/lint-contract.cjs --rule 2` → ok · sizes 682 l / 32763 B → 678 / 32527 after shrinks → 711 / 34624 with the features.
deviations: `<ll-shared:state>` comment not shrunk (region compared byte-for-byte with hooks/ll-state.js); last-resort shrink not taken (would delete two green checks); seeded shape per CHANGE-PLAN `{ passes: false, reason: "not started" }`; `TARGETS` keys renamed `questions/owner_prompts/owner_open_at_close`; fixture PROGRESS carries the new wording, one check proves the old one still parses.
questions: DEC-0016 — raise the ceiling to 760 / 36000 → decided by the session (decisions/DEC-0016-helper-ceiling-760-36000.md), applied in W2.
backlog: none (fixtures auto-closed/auto-verify-next keep `band-1 open` as the proof the old wording parses; rule 9 exempts fixtures)
not_verified: board-switch and `--phase` only on a fixture copy, never in a real wave; `npm test` end-to-end blocked by the ceiling until W2.
### W1-B — 2026-09-11 15:40
built: ll-implement SKILL.md + three references: board-switch step, every `passes` example with `--phase NN`, parseable BACKLOG row shape (`note` column, exact condition cell, dry-run `backlog-reconcile` before the epilogue), count line `owner decisions open K` / `decisões só suas em aberto K` (zero `band-1`), visible `onda i/M` lines, fifth boundary "the helper is called, never read" + Helper contract table, portable-acceptance-script rule, briefs.md DO NOT against absolute paths / `pkill` / `killall`.
commits: fe20540 feat(W1-B)
commands: lint-prompts rules 1,2,4,5,6,7 ok (rule 3 red only on ll-tools.js) · `node scripts/lint-contract.cjs` → "ok — 7 rule(s), 0 violation(s)" · greps: board-switch 3, `--phase NN` 6, never read 2, onda 2, show-toplevel 1, pkill 1, band-1 0/0, owner decisions open 2 · wc -l 121/134/124/77 under ceilings.
deviations: none · questions: none · backlog: none · not_verified: full lint until W2.
### W1-C — 2026-09-11 20:42
built: ll-decide SKILL.md, interview.md, decision-room.md and decision-policy.md ×3 (byte-identical): `owner decisions open K` / `owner-only item`, header `Pergunta n/N — <title> (impacto … · desfazer: …)` with the id in the recording file only, `docs/decide/OPTIONS.html` handed over in its own message before the first question with no Artifact publish and no other skill, never-ask item 11 (options differing only in rigor).
commits: 9c36ad3 feat(W1-C)
commands: md5sum ×3 identical · band-1 0/0/0 · only in rigor 1/1/1 · artifact-design 0/0 · Pergunta n/N 1 · wc -l 137/118/64/128 · lint rules 5/6/7 ok.
deviations: the pre-existing `Artifact` read-a-reference row in SKILL.md step 0 stays (same row as ll-brainstorm/ll-refine; unrelated to F-5) — accepted by the session. questions: none · backlog: none · not_verified: live ll-decide run (the lab rerun).
### W1-D — 2026-09-11
built: ll-brainstorm SKILL.md plain count lines (5 spots), ll-close step 1 BACKLOG columns with `note` and step 7 options without bare ids, `BLOCKS: process` rule for non-portable committed scripts in agents/ll-verifier.md and verifier-briefs.md, preamble caps a skill-shaped answer at the command + five decision-free lines, `memory/*.md` deliverable rows in ll-brainstorm/ll-close, ll-resume appends `status: DECIDED` to the answered DEC file (completion criterion updated).
commits: d19dc72 feat(W1-D)
commands: band-1 0/0 · owner decisions open 3 · pkill 1/1 · memory/ 1/1 · status: DECIDED 1 · five lines 1 · note 1 · inclusive 1 · wc -l 182/70/80/119/128/97/66 under ceilings · lint-contract rules 3,5,6 ok.
deviations: every hyphenated `band-1` in ll-brainstorm replaced (acceptance grep = 0); ll-resume completion criterion acknowledges the one DEC write. questions: none · backlog: none · not_verified: full lint until W1-C/W2 landed.
