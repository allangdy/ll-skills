# Phase 04 — ll-goal autonomous mode
Objective (from ROADMAP): `ll-goal` can emit a `/goal` text that keeps `ll-auto --auto-decision` running until the delivery is closed · Success criteria: SC-01 `grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md` ≥ 1 · SC-02 `ll-goal --autonomous` (or the mode the plan names) is documented in SKILL.md and argument-hint, and emits ≤ 4,000 chars · SC-03 `npm run lint && npm test` exit 0 ·
Decisions: phases/04/DECISIONS.md · Context: phases/04/CODE-CONTEXT.md · Contract: PLAN.md §2, §3, §7
## Milestones
<!-- ll-milestones -->
milestones:
  - id: M1
    name: the autonomous variant — template, SKILL.md mode, smoke section
    files: [skills/ll-goal/SKILL.md, skills/ll-goal/references/goal-template.md, scripts/smoke-test.sh]
    depends_on: []
    tdd: yes
    acceptance: "npm run lint && bash scripts/smoke-test.sh --only goal-autonomo 2>&1 | tee /tmp/ll-goal-smoke.txt | tail -1 | grep -q 'smoke test OK — 4 checks' && grep -q '^## Autonomous mode' skills/ll-goal/SKILL.md && [ \"$(grep -c -- '--autonomous' skills/ll-goal/SKILL.md)\" -ge 2 ] && grep -q -- '--autonomous' <(sed -n '/^argument-hint:/p' skills/ll-goal/SKILL.md) && grep -q '^## Autonomous variant$' skills/ll-goal/references/goal-template.md && grep -q '^## Autonomous example$' skills/ll-goal/references/goal-template.md && [ \"$(grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md)\" -ge 1 ] && n=$(awk '/^## Autonomous example$/{f=1;next} f&&/^```/{if(b){exit}b=1;next} f&&b' skills/ll-goal/references/goal-template.md | wc -c) && [ \"$n\" -ge 500 ] && [ \"$n\" -le 4000 ] && ! grep -q 'Skill(' skills/ll-goal/SKILL.md && [ \"$(wc -l < skills/ll-goal/references/goal-template.md)\" -le 150 ]"
    stop: none
    truths: [T5]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2
    name: README and CHANGELOG for the autonomous mode
    files: [README.md, CHANGELOG.md]
    depends_on: [M1]
    tdd: no
    acceptance: "npm run lint && npm test && grep -q -- 'll-goal --autonomous' README.md && grep -q -- '--autonomous' CHANGELOG.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
<!-- /ll-milestones -->

### M1 — the autonomous variant — template, SKILL.md mode, smoke section
read_first:
  - skills/ll-goal/SKILL.md:1-6, 24-59 — the frontmatter (`argument-hint: "[phase-number]"`), the Flow steps 1-5 and the Completion criterion; the mode is a second path through the same five steps, not a new skill
  - skills/ll-goal/references/goal-template.md:1-90 — the frontmatter block, the 9 parts, the fixed invalidating block and the 10-line checklist; the variant is appended after the checklist
  - skills/ll-auto/SKILL.md:1-12 and skills/ll-auto/references/stages.md — the flags `ll-auto` accepts and what `--auto-decision` means (the text must cite the exact command shape `ll-auto --auto-decision`, with `"<objective>"` and `--verify all` as optional additions)
  - scripts/smoke-test.sh:12-19, 281-289, 497-505 — how `--only <section>` selects a section, the grep-on-generated-text shape (section 4d) and the newest standalone section (`lint-orquestrador`) to copy for a new section `goal-autonomo`
  - scripts/lint-prompts.sh:264-291 — rule 5: in SKILL.md no line starts with `/ll-` unless it carries `▶ Next`, and the pattern run `ll-x` (with backticks) is forbidden; goal-template.md is exempt from those two checks but not from the FORBIDDEN list at :26
action: `goal-template.md` [DECISIONS D-04-02] gains, after the checklist, a section `## Autonomous variant` with (a) the frontmatter for the mode — `date`, `plan: PLAN.md`, `phase: all`, `mode: autonomous`, `max_turns` — five fields, no `ceiling_usd` [DECISIONS D-04-03]; (b) the parts: Objective (deliver everything ROADMAP.md still lists, closed by `docs/DELIVERY.md`), Read first (PLAN.md sections, ROADMAP.md, docs/AUTO.md when it exists), Done when [DECISIONS D-04-05: DELIVERY.md exists · epilogue of the last ROADMAP phase in PROGRESS.md · every phases/NN/VERIFICATION.md of the run APPROVED or APPROVED_WITH_RESERVATIONS · docs/AUTO.md rows all done or skipped and `## Decisions taken alone` filled · build command exit 0 · `git status --porcelain` empty], Invalidating (the fixed block, verbatim), Execution (`skill ll-auto --auto-decision` — plus `"<objective>"` and `--verify all` when given — restarted by the /goal loop whenever the session stops before Done when: the text never asks the owner to paste a command, `ll-auto` itself carries the stages [skills/ll-auto/SKILL.md, Flow]; models per role from PLAN.md §7), Decisions (every decision that stays inside the repository is taken, recorded `[decided by absence — revisable]` and listed at the end; the run stops only for money leaving the account, production data, credentials, anything irreversible), State (docs/AUTO.md log line per stage, PROGRESS.md per wave), Stop (external block = record and stop) — no BUDGET part; (c) a section `## Autonomous example` holding exactly one fenced block: the text rendered for `scripts/fixtures/project` (phases 07 and 08 left, close) — the block is what the smoke check measures, ≤ 4,000 chars; (d) three extra checklist lines for the variant (EXECUTION names `ll-auto --auto-decision`; no BUDGET part; DONE WHEN ends at DELIVERY.md). Line budget: the variant section ≤ 30 lines, the example block ≤ 25 lines (≈ 2,500 chars — the 4,000-char cap is on bytes of the block, the 150-line cap on the file; 60 lines of headroom today), the extra checklist 3 lines; whole file ≤ 150 lines. `SKILL.md` [DECISIONS D-04-01/D-04-04]: `argument-hint: "[phase-number | --autonomous [\"<objective>\"]]"`; description keeps one line and mentions the autonomous mode; one paragraph after the Flow intro or a `## Autonomous mode` section before Completion: pre-flight needs `PLAN.md` and `ROADMAP.md` at the git top, no phase plan; the remaining stages come from `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-auto/scripts/ll-auto.js detect --json` when it exists, otherwise from ROADMAP.md and PROGRESS.md; step 2 is skipped (the flag resolves WAITING decisions; the text says the end-of-run block lists them); step 3 asks nothing when an objective is given or PLAN.md §0 has one; step 4 uses the variant of `goal-template.md`; `docs/GOAL.md` carries `mode: autonomous`; commit message `docs: goal for the whole delivery`. Never start a line with `/ll-auto`, never write run `ll-auto` with backticks in SKILL.md (rule 5). `smoke-test.sh`: new standalone section `goal-autonomo` (registered in the header comment and in `--only`) with checks: `ll-goal argument-hint aceita --autonomous`, `goal-template cita ll-auto --auto-decision`, `exemplo autônomo ≤ 4000 chars` (awk extraction of the first fenced block under `## Autonomous example`, `wc -c` ≤ 4000), `goal-template ≤ 150 linhas`. TDD: commit `test(M1)` with the smoke section first (red: no `--autonomous`, no example) then `feat(M1)`. Commit with `--no-verify` naming only these three files.
behavior (tdd: yes): `bash scripts/smoke-test.sh --only goal-autonomo` red before the feat (missing `--autonomous`, missing example) and green after · the example block measures ≤ 4,000 bytes · `grep -c 'll-auto --auto-decision' goal-template.md` ≥ 1 · `npm run lint` stays at 0 violations (rule 5 on SKILL.md, ceilings 200/150)
acceptance: the M1 acceptance command in the block above, exit 0; last line pasted
truths: T5
stop: none

### M2 — README and CHANGELOG for the autonomous mode
read_first:
  - README.md:53, 80, 92-110 — the `ll-goal` row, the "Como as skills são chamadas" paragraph and the "Fluxo autônomo" subsection written by phase 03; keep the register
  - CHANGELOG.md:1-20 — `## [3.0.0] - Unreleased` with `### Quebras`, `### Alterado`, `### Adicionado`
action: README (Portuguese): the `ll-goal` row gains the autonomous mode (`ll-goal --autonomous ["<objetivo>"]` → o texto de `/goal` que mantém `ll-auto --auto-decision` rodando até a entrega fechar); the "Fluxo autônomo" subsection gains one short paragraph "Para rodar sem parar" explaining the pair: `ll-goal --autonomous` writes the text, `/goal <texto>` keeps the session restarting `ll-auto --auto-decision` when it stops halfway; decisions taken alone are listed at the end. CHANGELOG `### Adicionado`: one bullet for `ll-goal --autonomous`. Commit `feat(M2): ll-goal --autonomous documented — README, CHANGELOG` naming only these two files, `--no-verify`.
acceptance: the M2 acceptance command in the block above, exit 0; last line pasted
truths: T6
stop: none

## Errata
- 2026-09-10 — PLAN-REVIEW REJECTED, four gaps applied: G-1 M1's acceptance no longer passes on absence — it requires `smoke test OK — 4 checks` from the section, the headings `## Autonomous mode`, `## Autonomous variant`, `## Autonomous example`, ≥ 2 mentions of `--autonomous` in SKILL.md and a 500-byte floor on the example · G-3 folded into the same command (SC-02 "documented in SKILL.md") · G-4 the `/clear` sentence was replaced by the sourced rule (the text never asks the owner to paste a command; `ll-auto` carries the stages) and M1 states its line budget · G-2 SC-03 is green only in this worktree: the clean-checkout proof (`git archive HEAD | tar -x -C <tmp> && cd <tmp> && git init -q && npm run lint && npm test`) is blocked by I-09 — `hooks/ll-state.js` is the owner's uncommitted work and no executor or session commits it (DEC-0009 lifted I-09 for `scripts/smoke-test.sh` only) — so M2 keeps its worktree acceptance, the phase verification records the clean-checkout result as NOT_VERIFIABLE by the session, and the epilogue repeats the owner action `git add hooks/ll-state.js hooks/ll-precompact.js && git commit`. Backlog row B-016 opened for the deferred `goal-autonomous` eval case.
## Waves
| wave | milestones | builds |
|---|---|---|
| 1 | M1 | the autonomous variant, the mode in SKILL.md, the smoke section |
| 2 | M2 | README, CHANGELOG |
