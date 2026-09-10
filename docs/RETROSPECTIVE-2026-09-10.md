# RETROSPECTIVE — ll-skills 3.0.0 (phases 01–05) — 2026-09-10

## What the numbers say
- 33 commits in 1 day, span 1 day, idle 0 (`phase-stats --since 2026-09-09`): the whole delivery ran in one owner session plus one `/goal` run.
- By type: feat 19 · test 5 · docs 7 · fix 1 · chore 1; test/feat ratio 0.26 — five milestones were `tdd: yes` and each has its `test()` before its `feat()` (tdd-gate pass ×5); the rest were prose, config and docs.
- 19 milestones passed out of 19, none after a verification gap; all five plan reviews came back REJECTED first (5, 5, 4, 4, 4 gaps) and every gap was applied before wave 1.
- Questions asked to the owner: 1 (phase 01, "Pode corrigir" on smoke-test.sh); assumptions recorded: 27; band-1 open at close: 0. Target was ≤ 4 questions per phase.
- Verifications: 2 APPROVED, 3 APPROVED_WITH_RESERVATIONS; the recurring reservation (clean checkout) closed at the very end with one two-line commit.
- Eval reps: 4 real runs of the two auto cases, 8/8 PASS, about USD 0.45 each (subscription; not a decision input).

## What cost prompts
- "Não tem a mínima ideia o que significa banda 1 … para de usar esses termos malucos": a question written in house jargon cost one full turn and a correction. Rule now in memory (`feedback-no-jargon-with-owner`).
- "quanto pode gastar" was asked once and answered "não importa, a gente paga assinatura": a cost question the owner never wanted (DEC-0003, memory `user-subscription-no-cost-questions`).
- The owner answered "Continue" twice between phases and then wrote a `/goal` himself to stop being asked: the phase-by-phase hand-off is a prompt cost the autonomous mode now removes.
- "por que eu tenho que fazer isso e você não consegue fazer?": the epilogues listed owner actions (commit hooks, reinstall) that the session could have done after one question. Ask once, then do.

## Rules that became permanent
- A skill starts only when typed; the session never starts one — incident: research chaining into implementation (owner, 2026-09-10); lives in `assets/preamble.md` "## Skills" and lint rule 1.
- `ll-auto` is the single place that follows another skill's instructions — DEC-0002/DEC-0005; lives in the preamble and `ORCHESTRATOR` in `scripts/lint-prompts.sh`.
- The clean checkout is the proof — incident: three phases carried the same reservation because two hook lines were never committed; lives in project `CLAUDE.md` (this close) and in `docs/DELIVERY.md` §3.
- No jargon in questions to the owner; no cost questions — memories `feedback-no-jargon-with-owner`, `user-subscription-no-cost-questions`.

## What to stop doing
- Reading the acceptance out of the plan's YAML with a hand-written regex: it returned `\\[` unescaped and produced a false red on phase 05 M4 (heartbeat PROGRESS.md:102). Replacement: `ll-tools.js` should expose `acceptance <M>`; until then `JSON.parse` the quoted string.
- Running `passes` before switching the board to the new phase: phase 04 M1 landed on the phase 03 board (heartbeat PROGRESS.md:88). Replacement: the board switch is step 0 of the next phase, before any `passes`.
- Carrying an owner action in three epilogues in a row. Replacement: one question with a recommendation at the first epilogue, then do it.
- Backlog conditions written as prose: `backlog-reconcile --run` parsed 0 of 20 conditions (`unparsable-condition`). Replacement: the condition is exactly `` `<command>` exit 0 ``; the helper's parser or the rows have to meet.

## Lessons
- A plan review always finds gaps in acceptance commands that pass on absence (5 of 5 reviews); write the negative case into the acceptance before the review — evidence: phases/03–05/PLAN-REVIEW.md G-1 lines. [general]
- A verification that names an uncommitted dependency is a two-line fix, not a reservation to carry — evidence: 1efc0c9. [general]
- Eval prompts that are the exact command the owner types (`/ll-auto --dry-run`) are expanded by `claude -p` and cost 3–7 turns — evidence: RESULTS.md 2026-09-10-1542/1543/1548.
- Fixtures with Portuguese text must live under `scripts/fixtures/`; `scripts/evals/fixtures/` is lint-scanned — evidence: D-05-03 amendment, `scripts/lint-prompts.sh:23-24`.
- A helper with a `--json` and a human output needs the human shape in the eval answer fixture, or the assert regex drifts — evidence: phase 05 M1 not_verified line.
- The 12-field executor brief with absolute paths and a `DETAILS` line produced 13 milestones with zero `questions:` — evidence: PROGRESS.md `### M` blocks, phases 03–05.
- The owner's free text is the best source of the acceptance criterion — evidence: F-04 in docs/DELIVERY.md is his sentence, turned into `auto-empty-repo`. [general]
- The same policy question is never asked twice; the second time it is a memory — evidence: the two memories above. [general]

## Cost and deferred
- Cost: 1 owner session, 1 `/goal` run; 13 executor runs (7 opus, 6 sonnet), 5 scouts (sonnet), 10 verifier runs (opus); 4 real eval reps ≈ USD 1.8 total (subscription).
- Deferred: implement-to-close rep of `ll-auto` on a bigger fixture (ROADMAP deferred, no id); `--interactive` beyond brainstorm and the phase conversation; B-016 `goal-autonomous` eval.
- Open backlog: B-002..B-020 (18 rows, all test or eval gaps with a command); B-001 closed. WAITING decisions: none.
- Next: `ll-close --milestone 3.0.0` when the owner wants the phases archived, or `ll-decide project` for the next milestone.
