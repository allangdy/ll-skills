# VERIFICATION — phase 04 — 2026-09-10
mode: phase · slice: main ae68dce..dcea559

verdict: APPROVED_WITH_RESERVATIONS · product: OK · process: OK

| C | criterion | command | exit | file:line | sha256 | freshness | state |
| SC-01 | `grep -c 'll-auto --auto-decision' goal-template.md` ≥ 1 | `grep -c 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md` → `3` | 0 | skills/ll-goal/references/goal-template.md:91,108,137 | d7733cf7 | FRESH | VERIFIED |
| SC-02 | `--autonomous` documented in SKILL.md + argument-hint, emits ≤ 4,000 chars | `bash scripts/smoke-test.sh --only goal-autonomo` → `smoke test OK — 4 checks`; `sed -n '/^argument-hint:/p' skills/ll-goal/SKILL.md` → `"[phase-number \| --autonomous [\"<objective>\"]]"`; awk-extracted example → `1489` bytes | 0 | skills/ll-goal/SKILL.md:4,52 · skills/ll-goal/references/goal-template.md:95,118 · scripts/smoke-test.sh:549-563 | 2f853b85 · d7733cf7 · 63b9cba0 | FRESH | VERIFIED |
| SC-03 | `npm run lint && npm test` exit 0 (worktree) | `npm run lint && npm test` → `ok — 7 rule(s), 0 violation(s)` / `smoke test OK — 198 checks` | 0 | scripts/smoke-test.sh:547-566 | 63b9cba0 | FRESH | VERIFIED |
| SC-03b | the same green on a clean checkout of HEAD | not run (Errata G-2; blocked by I-09 — smoke-test.sh:213 needs the owner's uncommitted `hooks/ll-state.js` skip set `'fixtures'`, absent from `git show HEAD:hooks/ll-state.js`) | — | hooks/ll-state.js:151 (worktree only) · scripts/smoke-test.sh:213 | — | — | NOT_VERIFIABLE → after the owner runs `git add hooks/ll-state.js hooks/ll-precompact.js && git commit`: `git archive HEAD \| tar -x -C <tmp> && git -C <tmp> init -q && npm --prefix <tmp> run lint && bash <tmp>/scripts/smoke-test.sh` exit 0 |

BLOCKS: none

Process checks
- `git diff ae68dce..dcea559 -- scripts/smoke-test.sh`: additions only (new standalone section `goal-autonomo`, 4 checks, plus the header comment). No assertion loosened, none skipped or deleted.
- M1 `tdd: yes`: `09c9441 test(M1)` precedes `3b6198a feat(M1)` in `git log`. Red reproduced in this session on a clean archive of 09c9441: `FALHOU: ll-goal argument-hint aceita --autonomous`, exit 1. Green at HEAD: `smoke test OK — 4 checks`.
- Every file the M1/M2 blocks name exists at HEAD; every commit they list is in git (09c9441, 3b6198a, dcea559).

Confrontation
- M1 claimed: `## Autonomous mode` in SKILL.md, `## Autonomous variant` + `## Autonomous example` (1,489-byte block) in goal-template.md, checklist lines 11-13, smoke section with 4 checks, file at 147 lines · found: all present, block measures 1489 bytes, file 147 lines, section reports 4 checks. consistent.
- M2 claimed: README `ll-goal` row + "Para rodar sem parar" subsection, CHANGELOG `### Adicionado` bullet, `npm run lint && npm test` exit 0 · found: README.md:80,109-111, CHANGELOG.md:12, suite green in this worktree. consistent.
- One divergence: M2 records `not_verified: none`, but its acceptance embeds `npm test`, which is worktree-only for the same I-09 reason M1 records. Ledger line, not a BLOCKS.

Disconfirmation
- 1 partial requirement: SC-02's "emits ≤ 4,000 chars". Nothing in the repo renders `ll-goal --autonomous`; the 4,000-byte ceiling is measured on a static example block (goal-template.md:121-147), not on a text a session emitted. The variant's own frontmatter rule (five fields, `mode: autonomous`, `phase: all`, no `ceiling_usd` — D-04-03) is prose at goal-template.md:97-99 and checklist line 92 with no check asserting it. DECISIONS "Accepted risks" states the same limit; backlog B-016 holds the eval case.
- 1 test that passes without testing: `check "goal-template ≤ 150 linhas"` (scripts/smoke-test.sh:562-563) could never be red for this phase — the file was 90 lines at ae68dce — and lint rule 3 already caps `skills/*/references/*.md` at 150 (scripts/lint-prompts.sh:184-185). It duplicates an existing gate and asserts nothing new. (The sibling `exemplo autônomo entre 500 e 4000 bytes` does bite: the 500-byte floor makes an empty awk extraction fail.)
- 1 uncovered error path: the autonomous pre-flight failure (SKILL.md:56-59 — `PLAN.md`/`ROADMAP.md` missing at the git top, and the `ll-auto.js detect --json` fallback when the helper is not installed) has no check anywhere; the `goal-autonomo` section only reads strings out of two prose files and never exercises a failure branch beyond the absence of `--autonomous`.

What this verification does NOT prove
- that any session ever emitted the autonomous `/goal` text, or that the emitted text (frontmatter + eight parts, not just the example block) stays ≤ 4,000 chars.
- that `docs/GOAL.md` in autonomous mode carries `mode: autonomous`/`phase: all` and the commit message `docs: goal for the whole delivery` — documented, never executed.
- that the `/goal` loop actually restarts `ll-auto --auto-decision` after a session stops: the whole mode is prose, verification: internal, and no eval covers it (B-016).
- that `npm run lint && npm test` is green outside this worktree (SC-03b).

Deferred
- a `goal-autonomous` eval case rendering and measuring the text — until phase 05+ (BACKLOG B-016).
- the clean-checkout suite — until the owner commits `hooks/ll-state.js` and `hooks/ll-precompact.js` (I-09, Errata G-2).

Gaps: none
