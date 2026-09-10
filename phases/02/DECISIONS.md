# Phase 02 — Decisions · 2026-09-10 · ll-implement

## Score
questions asked 0 / assumptions 5 / band-1 open 0. `--no-talk`: A ratified whole; no B item (nothing leaves the repo, no money, no customer data, no scope cut).

## Locked
- D-02-01 — the ▶ Next grammar is `▶ Next — /clear, then <cmd>` where `<cmd>` is `ll-<skill>[ args]`, `/goal <text>` or a `<placeholder>`; an optional trailing parenthetical `(…)` may carry prose; no backticks around `/clear` or the command; one command per line (alternatives are separate lines or parenthetical prose) · class RULE · band 2 · impact HIGH · revert 1 commit · backing: PLAN §4 R-05; today's lines vary between "`/clear` then `ll-x`", "/clear then ll-x" and "/clear, then ll-x" (grep ▶ Next over skills/, 2026-09-10) · decided by: Claude · consequences: 10 SKILL.md lines and `assets/preamble.md:21` rewritten; `lint-contract.cjs` rule 6 enforces the shape, not only the target.
- D-02-02 — rule 6 is fixture-tested: `scripts/lint-contract.cjs` accepts `--root <dir>`; two fixture trees `scripts/fixtures/next-bad/` (one malformed line, rule 6 exits 1) and `scripts/fixtures/next-good/` (one line per allowed form, exits 0); `scripts/smoke-test.sh` gains the two checks · class RULE · band 2 · impact MED · revert 1 commit · backing: ROADMAP SC-01 "fixture-tested"; `scripts/lint-contract.cjs:17` (`ROOT` from `__dirname`), `scripts/smoke-test.sh:378-379` (`contract()` helper) · decided by: Claude · consequences: `scripts/smoke-test.sh` is editable in this phase — it is committed and clean since `122a3bb` (I-09 covered the owner's uncommitted state, which no longer exists for this file; `hooks/*` stay untouched).
- D-02-03 — `ll-decide project --no-talk`: the premise gate, the interview and the final round send no question; band-2/3 items take the recommendation as `ASM-n` with `[decided by absence — revisable]`; band-1 items become `decisions/DEC-NNNN-*.md` in state `WAITING`, listed in PLAN §3, and the phase whose work depends on them carries `stop: owner` in ROADMAP; the final round is printed as a report, the contract is written and frozen. Feedback mode: the triage battery follows the same rule · class RULE · band 2 · impact HIGH · revert 1 commit · backing: DEC-0001 ("without the flag: go as far as possible, then stop"); ROADMAP phase 02 SC-02; `skills/ll-decide/SKILL.md:51-71` (the three blocking steps) · decided by: Claude · consequences: `argument-hint` gains `[--no-talk]`; `references/interview.md` and `references/premise-gate.md` get one paragraph each; the resolution of WAITING items under `--auto-decision` belongs to phase 03.
- D-02-04 — `ll-close --no-talk`: the one block of ratification is not asked; its content is written under the epilogue as `ratified by absence — revisable` with the same items; the gate (verification verdict) is unchanged and still stops on REJECTED · class RULE · band 2 · impact MED · revert 1 commit · backing: DEC-0001; `skills/ll-close/SKILL.md:43` (step 7) and `:56` (--milestone step 6) · decided by: Claude.
- D-02-05 — `references/decision-policy.md` (three identical copies, lint-prompts rule 6) gains one sentence: under `--no-talk` the silence rule applies immediately — the recommended option is taken and recorded `[decided by absence — revisable]`, band 1 stays WAITING · class RULE · band 2 · impact LOW · revert 1 commit · backing: `scripts/lint-prompts.sh` rule6 (3 copies must stay byte-identical) · decided by: Claude · consequences: all three copies change in the same milestone.

## Implementer freedoms
Exact regex of rule 6; wording of the paragraphs; whether `--root` is a flag or an env var (flag recommended: `--root <dir>`); names inside the fixture trees.

## Revisable
- D-02-01 parenthetical allowance. Review trigger: phase 03's parser cannot extract one command from a line with a parenthetical.

## Deferred
- How `ll-auto --auto-decision` resolves WAITING DECs left by `--no-talk`. Resume condition: phase 03 plan.

## Against the recommendation
none

## Owner's free answers (verbatim)
none this phase

## Accepted risks
- Skills installed under `~/.claude` keep the old ▶ Next wording until the owner reinstalls.
- D-02-04 (amended 2026-09-10): the marker is the house string `[decided by absence — revisable]`, never "ratified by absence"; the PLAN-REVIEW gap G-2 and M4 apply this.
