# Phase 01 — Decisions · 2026-09-10 · ll-implement

## Score
questions asked 0 / assumptions 3 / band-1 open 0. `--no-talk`: A ratified whole; no B item exists for this phase (nothing leaves the repo, no money, no customer data, no scope cut).

## Locked
- D-01-01 — every `skills/*/SKILL.md` gets `disable-model-invocation: true` · class RULE · band 2 · impact HIGH · revert 1 commit · backing: DEC-0002; `scripts/lint-prompts.sh` rule 1 `NO_INVOCATION` list (today 3 names) becomes "all skills" · decided by: owner (DEC-0002) · consequences: rule 1 inverted; the installed copies under `~/.claude/skills` change on the next install.
- D-01-02 — descriptions become one plain line, 60–300 chars, third-person verb, no "Use when" · class RULE · band 2 · impact MED · revert 1 commit · backing: ASM-1 in PLAN §3; rule 1 today requires 200–1024 chars and "Use when" · decided by: Claude · consequences: rule 1 thresholds change; every SKILL.md frontmatter is rewritten.
- D-01-03 — `assets/preamble.md` keeps `<!-- ll-skills:preamble v1 -->` markers and the Skills, Delegation, Decisions, Proof sections; the "Route every request before acting" section and the "One word from the owner beats the classifier" paragraph are removed; the Skills section states the manual-only rule (DEC-0002) and names `ll-auto` as the single place that follows another skill's instructions · class RULE · band 2 · impact HIGH · revert 1 commit · backing: DEC-0002, ASM-2 · decided by: owner (DEC-0002) · consequences: rule 3 "exactly 70 lines" becomes a ceiling `≤ 70`; the marker version stays `v1` so the installer replaces the block in place.
- D-01-04 — the four router eval cases are rewritten, not deleted: the first assistant text names the `/ll-<skill>` command (research → `/ll-research`, execute → `/ll-implement 7`), no `Skill` tool_use appears, and the SMALL cases drop the regime word and keep "nothing written / no ceremony" · class RULE · band 2 · impact MED · revert 1 commit · backing: ASM-3; `scripts/evals/cases/router-*/assert.sh`, `scripts/evals/lib/assert.sh` · decided by: Claude · consequences: `case.json` notes updated; `--dry-run --all` must stay green.
- D-01-05 — README and CHANGELOG follow: the "roteador" paragraphs and the regime table go; a "3.0.0 — Unreleased" entry is opened; `package.json` version is bumped only in phase 05 · class RULE · band 2 · impact LOW · revert 1 commit · backing: README lines 3, 13, 40–53, 61 · decided by: Claude.
- D-01-06 — no executor edits `hooks/ll-state.js`, `hooks/ll-precompact.js` or `scripts/smoke-test.sh` (owner's uncommitted work) · class RULE · band 2 · backing: PLAN §2 I-09 · consequences: the preamble line-count check in smoke-test.sh, if any, is not touched in this phase; a needed change becomes a backlog row.

## Implementer freedoms
Wording of each description; order of sections inside the preamble; whether the lint rule reads the list of skills from disk or hardcodes "all".

## Revisable
- D-01-02 thresholds (60–300 chars). Review trigger: the owner asks for trigger phrases back, or the `/` menu truncates descriptions.

## Deferred
- Moving Delegation/Decisions/Proof out of the preamble into the skills. Resume condition: the owner asks, after phase 03 shows how `ll-auto` reads the skills.

## Against the recommendation
none

## Owner's free answers (verbatim)
- "Eu não quero mais que rode de forma automática, eu quero que seja, que tenha que rodar manualmente. Isso eu acho que tem que tirar daí aquela questão do global" (2026-09-10)

## Accepted risks
- Sessions installed with the 2.x preamble keep routing until the owner reinstalls; the installer replaces the block in place on the next `npx ll-skills@latest`.
