# Phase 01 — lock and unroute
Objective (from ROADMAP): no ll skill can be started by the model, and the global preamble stops routing requests to skills · Success criteria: SC-01 `grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l` prints `0` · SC-02 `grep -c 'Route every request' assets/preamble.md` prints `0`, and the preamble still carries the Skills, Delegation, Decisions and Proof sections · SC-03 every skill description is one plain line (60–300 chars, third-person verb, no "Use when"), enforced by `scripts/lint-prompts.sh` rule 1 · SC-04 `npm run lint && npm test` exit 0 · SC-05 the eval cases `router-research`, `router-execute`, `router-small`, `preamble-no-ritual` assert the new behaviour and `bash scripts/evals/run.sh --dry-run --all` exits 0 ·
Decisions: phases/01/DECISIONS.md · Context: phases/01/CODE-CONTEXT.md · Contract: PLAN.md §2, §3, §7
## Milestones
<!-- ll-milestones -->
milestones:
  - id: M1
    name: lock every skill and invert the lint
    files: [scripts/lint-prompts.sh, skills/ll-brainstorm/SKILL.md, skills/ll-close/SKILL.md, skills/ll-decide/SKILL.md, skills/ll-goal/SKILL.md, skills/ll-implement/SKILL.md, skills/ll-oncall/SKILL.md, skills/ll-refine/SKILL.md, skills/ll-research/SKILL.md, skills/ll-resume/SKILL.md, skills/ll-update/SKILL.md, skills/ll-verify/SKILL.md]
    depends_on: []
    tdd: no
    acceptance: "for r in 1 2 4 5 6 7; do bash scripts/lint-prompts.sh --rule $r || exit 1; done && test \"$(grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l)\" = 0"
    stop: none
    truths: [T1, T6]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2
    name: preamble without a router
    files: [assets/preamble.md]
    depends_on: [M1]
    tdd: no
    acceptance: "bash scripts/lint-prompts.sh --rule 3 && ! grep -q 'Route every request' assets/preamble.md && grep -q '^## Skills' assets/preamble.md && grep -q '^## Delegation' assets/preamble.md && grep -q '^## Decisions' assets/preamble.md && grep -q '^## Proof' assets/preamble.md"
    stop: none
    truths: [T2, T6]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M3
    name: README and CHANGELOG follow the new contract
    files: [README.md, CHANGELOG.md]
    depends_on: [M2]
    tdd: no
    acceptance: "npm run lint && ! grep -qiE 'roteador|sem você digitar o nome' README.md && grep -q '^## \\[3.0.0\\]' CHANGELOG.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
  - id: M4
    name: router eval cases assert the manual contract
    files: [scripts/evals/lib/assert.sh, scripts/evals/cases/router-research/assert.sh, scripts/evals/cases/router-execute/assert.sh, scripts/evals/cases/router-small/assert.sh, scripts/evals/cases/preamble-no-ritual/assert.sh, scripts/evals/cases/router-research/case.json, scripts/evals/cases/router-execute/case.json, scripts/evals/cases/router-small/case.json, scripts/evals/cases/preamble-no-ritual/case.json, scripts/evals/fixtures/manual-contract/out.json, scripts/evals/fixtures/manual-contract/with-skill.json, scripts/evals/fixtures/manual-contract/out.txt]
    depends_on: []
    tdd: no
    acceptance: "bash scripts/evals/run.sh --dry-run --all && bash scripts/evals/cases/router-research/assert.sh scripts/fixtures/empty scripts/evals/fixtures/manual-contract/out.json scripts/evals/fixtures/manual-contract/out.txt && ! bash scripts/evals/cases/router-research/assert.sh scripts/fixtures/empty scripts/evals/fixtures/manual-contract/with-skill.json scripts/evals/fixtures/manual-contract/out.txt"
    stop: none
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
  - id: M5
    name: lint and smoke test green (SC-04)
    files: [scripts/smoke-test.sh]
    depends_on: [M3, M4]
    tdd: no
    acceptance: "npm run lint && npm test"
    stop: owner
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
<!-- /ll-milestones -->

### M1 — lock every skill and invert the lint
read_first:
  - scripts/lint-prompts.sh:26 — `NO_INVOCATION = ["ll-update", "ll-close", "ll-goal"]`: the list that becomes "every skill"
  - scripts/lint-prompts.sh:119-150 — `rule1`: the `bad.append((f, "..."))` shape; lines 130 (200–1024 bound), 135 ("Use when" required), 141-145 (membership test) are the three checks that change
  - scripts/lint-prompts.sh:184-186 — `rule3` preamble check `n != 70`: becomes a ceiling `n > 70`, message "%d lines, ceiling 70"
  - skills/ll-update/SKILL.md:1-6 — the frontmatter shape every skill ends with: `name`, `description` (one line), `argument-hint`, `disable-model-invocation: true`, then `allowed-tools` where it exists
action: (1) in `scripts/lint-prompts.sh` rule 1: require `disable-model-invocation: true` in every SKILL.md (a missing or false value is a FAIL; drop `NO_INVOCATION` or set it to all of `SKILL_NAMES`); description length bound becomes `60 <= len(desc) <= 300` [ROADMAP SC-03]; the check "Use when" inverts: a description containing "Use when" is a FAIL; keep the third-person-verb regex at line 132. Rule 3: the preamble check becomes `n > 70` → FAIL "ceiling 70", and a second check FAILs when `assets/preamble.md` contains `Route every request` or `One word from the owner` [ROADMAP SC-02; DECISIONS D-01-03]. Update the header comment of the script where it describes rule 1. (2) In each of the 11 `skills/*/SKILL.md`: add `disable-model-invocation: true` after `argument-hint` where missing (8 files); rewrite `description:` as one plain line, 60–300 chars, starting with a third-person verb (Runs, Writes, Audits, Researches, Turns, Opens, Reconstructs, Reviews, Updates, Closes…), no "Use when", no trigger phrases [ASM-1] — say what the skill does and what it writes, in English, for a human reading the `/` menu. Keep every other frontmatter line and the whole body untouched. (3) Commit as `feat(M1): lock every skill, invert lint rule 1` with only the 12 files.
acceptance: `for r in 1 2 4 5 6 7; do bash scripts/lint-prompts.sh --rule $r || exit 1; done && test "$(grep -L 'disable-model-invocation: true' skills/*/SKILL.md | wc -l)" = 0` exit 0 (rule 3 is owned by M2, which removes the strings the new check forbids); last line pasted in the return block
truths: T1, T6
stop: none

### M2 — preamble without a router
read_first:
  - assets/preamble.md:1-70 — the current block; lines 1 and 70 are the markers `bin/install.js:520-522` matches verbatim (keep `v1`); line 4 opens "## Route every request before acting", lines 4–27 are the router and the "One word from the owner" paragraph; lines 28–69 are Skills, Delegation, Decisions, Proof
  - decisions/DEC-0002-manual-invocation-only.md — the rule the Skills section must state
action: rewrite `assets/preamble.md` keeping both markers on the first and last line and the four sections `## Skills`, `## Delegation`, `## Decisions`, `## Proof` (their text may be tightened, never weakened). Remove the router section and the "One word from the owner beats the classifier" paragraph entirely. The `## Skills` section opens with the manual-only rule: a skill runs only when the owner types `/ll-<name>`; the session never starts a skill on its own, never suggests running one on the owner's behalf, and when a request looks like a skill's job it answers with the command to paste (`/ll-research <topic>`, `/ll-implement N`…) and stops; `ll-auto` is the single place that follows another skill's instructions, and only while the owner invoked `/ll-auto` [DEC-0002; PLAN §2 I-03]. Keep the `▶ Next` sentence, the state-at-root sentence and the Portuguese-reply sentence. Total ≤ 70 lines. Commit `feat(M2): preamble without a router` naming only `assets/preamble.md` (`git commit -- <file>`, never `-a` or `add -A`: three uncommitted owner files must stay out, PLAN §2 I-09).
acceptance: `bash scripts/lint-prompts.sh --rule 3 && ! grep -q 'Route every request' assets/preamble.md && grep -q '^## Skills' assets/preamble.md && grep -q '^## Delegation' assets/preamble.md && grep -q '^## Decisions' assets/preamble.md && grep -q '^## Proof' assets/preamble.md` exit 0
truths: T2, T6
stop: none

### M3 — README and CHANGELOG follow the new contract
read_first:
  - README.md:3,13,40-53,61 — every sentence that promises routing ("preâmbulo roteador", "cai na skill certa sem você digitar o nome", the regime table, "Uma palavra sua vence o classificador", "ideia → roteador")
  - CHANGELOG.md:1-27 — entry shape `## [X.Y.Z] - YYYY-MM-DD` with `### Alterado` / `### Quebras` subsections in Portuguese
  - assets/preamble.md (after M2) — the wording the README must mirror
action: README (Portuguese, as today): rewrite line 3 so the preamble is described as the house rules block, not a router; line 13 says skills are called by name only; replace the "Como funciona" regime table (lines 40–53) with a short section "Como as skills são chamadas": manual invocation only, one skill per turn, `▶ Next` for the owner to paste, `ll-auto` as the coming orchestrator (phase 03, mark it "em desenvolvimento"); fix line 61 ("ideia → roteador" becomes "ideia → `/ll-brainstorm` ou `/ll-research`"). Keep every other section. CHANGELOG: open `## [3.0.0] - Unreleased` above 2.0.2 with `### Quebras` (skills não são mais invocadas pelo modelo; preâmbulo sem roteador; descrições reescritas) and `### Alterado` (lint rule 1 e 3; casos de eval router-*). Do not touch package.json. Commit `feat(M3): README and CHANGELOG for the manual contract` naming only `README.md CHANGELOG.md` (`git commit -- <files>`, never `-a` or `add -A`; PLAN §2 I-09).
acceptance: `npm run lint && ! grep -qiE 'roteador|sem você digitar o nome' README.md && grep -q '^## \[3.0.0\]' CHANGELOG.md` exit 0
truths: T6
stop: none

### M4 — router eval cases assert the manual contract
read_first:
  - scripts/evals/lib/assert.sh:19-58 — helper shapes (`ok`, `fail`, `contains`, `first_text_line`, `first_text_contains`, `finish`); add the new helper beside `first_text_contains`
  - scripts/evals/cases/implement-stops-at-next/assert.sh — the `node -e` scan over `out.json` events for `b.type === "tool_use"`: the pattern to copy for "no Skill tool_use anywhere"
  - scripts/evals/cases/router-research/assert.sh, router-execute/assert.sh, router-small/assert.sh, preamble-no-ritual/assert.sh — current bodies; the `*RESEARCH*` / `*EXECUTE*` / `*SMALL*` regime matches are what goes
  - scripts/evals/cases/*/case.json — `note` fields describing the old router expectation
action: (1) add `no_tool_use <out.json> <tool-name> <msg>` to `scripts/evals/lib/assert.sh`: scans every assistant event's content for `tool_use` blocks whose `name` equals the argument; `ok` when none, `fail` naming the first hit. (2) Rewrite the four asserts: router-research → `first_text_contains "$OUT_JSON" '/ll-research'` and `no_tool_use "$OUT_JSON" Skill`; router-execute → `first_text_contains "$OUT_JSON" '/ll-implement 0?7'` and `no_tool_use "$OUT_JSON" Skill`; router-small → drop the `*SMALL*` regime match, keep the number check, the clean `git status` and the `no_path` checks, add `no_tool_use "$OUT_JSON" Skill`; preamble-no-ritual → keep every file check, add `no_tool_use "$OUT_JSON" Skill`. (3) Update each `case.json` `note` to describe the manual contract (the session names the command, starts no skill); keep `max_turns`, `min_pass`, `permission_mode` as they are. (4) Check in a recorded-capture fixture under `scripts/evals/fixtures/manual-contract/`: `out.json` — the event array shape `run.sh` writes (`--output-format json --verbose`: one `{type:"assistant", message:{content:[{type:"text", text:…}]}}` event whose text names `/ll-research` and no `tool_use` block); `with-skill.json` — the same plus one `{type:"tool_use", name:"Skill"}` block; `out.txt` — the answer text. Confirm the shape against `scripts/evals/lib/extract.js first_text` and the scan in `implement-stops-at-next/assert.sh`. The acceptance runs the real router-research assert against both fixtures (green on `out.json`, red on `with-skill.json`). Commit `feat(M4): eval cases for the manual contract` naming only the milestone's files (`git commit -- <files>`, never `-a`; PLAN §2 I-09).
acceptance: `bash scripts/evals/run.sh --dry-run --all && bash scripts/evals/cases/router-research/assert.sh scripts/fixtures/empty scripts/evals/fixtures/manual-contract/out.json scripts/evals/fixtures/manual-contract/out.txt && ! bash scripts/evals/cases/router-research/assert.sh scripts/fixtures/empty scripts/evals/fixtures/manual-contract/with-skill.json scripts/evals/fixtures/manual-contract/out.txt` exit 0
truths: T6
stop: none

### M5 — lint and smoke test green (SC-04)
read_first:
  - scripts/smoke-test.sh:186-194 — the owner's uncommitted lines (fixtures/ move + `docs/state` removal) that make `npm test` exit 1 today; PLAN §2 I-09 forbids an executor to touch them
action: only after the owner answers (stop: owner): either the owner fixes the three uncommitted lines themselves and this milestone's executor runs the acceptance, or the owner lifts I-09 for `scripts/smoke-test.sh` (recorded under ## Errata with a DEC id) and the executor repairs the nest step so `backlog-reconcile` runs against a directory that still exists, keeping the owner's intent (hook ignores PROGRESS.md under fixtures/). Never weaken a check (I-01). Commit `feat(M5): smoke test green` naming only `scripts/smoke-test.sh`.
acceptance: `npm run lint && npm test` exit 0
truths: T6
stop: owner

## Errata
- 2026-09-10 — PLAN-REVIEW REJECTED, five gaps applied: G-1 M1 acceptance narrowed to rules 1,2,4–7 (rule 3 proven by M2) · G-2 M5 added for SC-04/T6 with `stop: owner` (smoke-test WIP is the owner's, I-09) · G-3 M4 gains a recorded-capture fixture and runs the real assert · G-4 M2/M3/M4 commit only their files · G-5 "no backticked skill names" dropped (unsourced). Session, no DEC needed (band 2 plan repair).
## Waves
| wave | milestones | builds |
|---|---|---|
| 1 | M1, M4 | lock every skill and invert the lint · router eval cases assert the manual contract |
| 2 | M2 | preamble without a router |
| 3 | M3 | README and CHANGELOG follow the new contract |
| 4 | M5 | lint and smoke test green (owner-gated) |
- 2026-09-10 — I-09 lifted for `scripts/smoke-test.sh` only (owner: "Pode corrigir", DEC-0007); M5 `stop: owner` is answered — the executor repairs the nest step keeping the owner's intent.
