# PROGRESS — ll-auto: manual skills, one orchestrator

<!-- ll-state -->
phase: 02
milestones:
  M1: { passes: true, commit: db36d39, accepted_at: 2026-09-10T16:32:52Z }
  M2: { passes: true, commit: e844650, accepted_at: 2026-09-10T16:37:24Z }
  M3: { passes: true, commit: a852fcc, accepted_at: 2026-09-10T16:40:20Z }
  M4: { passes: true, commit: f23742d, accepted_at: 2026-09-10T16:40:20Z }
<!-- /ll-state -->

## History
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
