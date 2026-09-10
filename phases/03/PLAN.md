# Phase 03 — ll-auto skill
Objective (from ROADMAP): `/ll-auto` drives the cycle from the state on disk, with the flags of the design page, and reports what it decided alone · Success criteria: SC-01 `node skills/ll-auto/scripts/ll-auto.js detect --json` on `scripts/fixtures/project` prints one status per stage (research, brainstorm, decide, phase N…, verify N…, close) with `decide: done`, and on `scripts/fixtures/empty` prints every stage `todo` · SC-02 `skills/ll-auto/SKILL.md` documents `"<objective>"`, `--research`, `--brainstorm`, `--interactive`, `--auto-decision`, `--pause-at`, `--from`, `--to`, `--only`, `--verify all`, `--redo`, `--dry-run`, `--resume`, and the empty-repo behaviour (print the command to complete, stop, no question) · SC-03 the skill writes `docs/AUTO.md` (objective, flags, roteiro, status per stage) and an end-of-run block listing every decision file carrying `[decided by absence — revisable]` · SC-04 `ll-auto` has `disable-model-invocation: true`, follows each stage's SKILL.md in place, and the lint allows it (and only it) to reference other skills · SC-05 `npm run lint && npm test` exit 0, with smoke checks for the new helper ·
Decisions: phases/03/DECISIONS.md · Context: phases/03/CODE-CONTEXT.md · Contract: PLAN.md §2, §3, §7
## Milestones
<!-- ll-milestones -->
milestones:
  - id: M1
    name: helper detect — the stage table from disk
    files: [skills/ll-auto/scripts/ll-auto.js, scripts/smoke-test.sh]
    depends_on: []
    tdd: yes
    acceptance: "node skills/ll-auto/scripts/ll-auto.js detect --cwd scripts/fixtures/project --json | node -e 'const d=JSON.parse(require(\"fs\").readFileSync(0,\"utf8\"));const s=Object.fromEntries(d.stages.map(x=>[x.id,x.status]));process.exit(s.research===\"todo\"&&s.brainstorm===\"todo\"&&s.decide===\"done\"&&s[\"phase-05\"]===\"done\"&&s[\"phase-06\"]===\"done\"&&s[\"phase-07\"]===\"half\"&&s[\"phase-08\"]===\"todo\"&&s.close===\"todo\"?0:1)' && node skills/ll-auto/scripts/ll-auto.js detect --cwd scripts/fixtures/empty --json | node -e 'const d=JSON.parse(require(\"fs\").readFileSync(0,\"utf8\"));process.exit(d.stages.length>0&&d.stages.every(x=>x.status===\"todo\")?0:1)' && bash -n scripts/smoke-test.sh"
    stop: none
    truths: [T3]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2
    name: helper roteiro, next-cmd, report, auto-md
    files: [skills/ll-auto/scripts/ll-auto.js, scripts/smoke-test.sh, scripts/fixtures/auto-decisions/decisions/DEC-0001-taken-alone.md, scripts/fixtures/auto-decisions/decisions/DEC-0002-owner.md]
    depends_on: [M1]
    tdd: yes
    acceptance: "node skills/ll-auto/scripts/ll-auto.js roteiro --cwd scripts/fixtures/project --flags '--verify all' --json | node -e 'const d=JSON.parse(require(\"fs\").readFileSync(0,\"utf8\"));const ids=d.roteiro.map(x=>x.stage).join(\",\");process.exit(ids===\"phase-07,verify-07,phase-08,verify-08,close\"?0:1)' && node skills/ll-auto/scripts/ll-auto.js roteiro --cwd scripts/fixtures/project --flags '--only 8' --json | node -e 'const d=JSON.parse(require(\"fs\").readFileSync(0,\"utf8\"));process.exit(d.roteiro.map(x=>x.stage).join(\",\")===\"phase-08\"?0:1)' && test \"$(node skills/ll-auto/scripts/ll-auto.js next-cmd scripts/fixtures/project/PROGRESS.md)\" = 'll-implement 8' && node skills/ll-auto/scripts/ll-auto.js report --cwd scripts/fixtures/auto-decisions --json | node -e 'const d=JSON.parse(require(\"fs\").readFileSync(0,\"utf8\"));process.exit(d.decisions.length===1&&/DEC-0001/.test(d.decisions[0].file)?0:1)' && node skills/ll-auto/scripts/ll-auto.js auto-md --cwd scripts/fixtures/project --objective 'x' --flags '--only 8' > /tmp/ll-auto-md.txt && for h in '^## Objective' '^## Flags' '^## Roteiro' '^## Decisions taken alone' '^## Log' '^| 1 | phase-08 | ll-implement 08 --no-talk | todo |' '^x$' '^--only 8$'; do grep -qE \"$h\" /tmp/ll-auto-md.txt || { echo \"auto-md missing $h\"; exit 1; }; done && bash -n scripts/smoke-test.sh"
    stop: none
    truths: [T3]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M3
    name: the ll-auto skill text and the lint exceptions
    files: [skills/ll-auto/SKILL.md, skills/ll-auto/references/stages.md, skills/ll-auto/references/run.md, scripts/lint-prompts.sh, scripts/smoke-test.sh]
    depends_on: [M2]
    tdd: yes
    acceptance: "npm run lint && bash scripts/smoke-test.sh --only lint-orquestrador && grep -q '^disable-model-invocation: true' skills/ll-auto/SKILL.md && for f in -- '--research' '--brainstorm' '--interactive' '--auto-decision' '--pause-at' '--from' '--to' '--only' '--verify all' '--redo' '--dry-run' '--resume' 'docs/AUTO.md' 'decided by absence'; do grep -q -- \"$f\" skills/ll-auto/SKILL.md || { echo \"missing $f\"; exit 1; }; done && ! grep -q 'Skill(' skills/ll-auto/SKILL.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M4
    name: installer mode bits, README, CHANGELOG, installed-copy check
    files: [bin/install.js, README.md, CHANGELOG.md, scripts/smoke-test.sh]
    depends_on: [M2, M3]
    tdd: no
    acceptance: "npm run lint && npm test && grep -q '/ll-auto \"' README.md && ! grep -q 'em desenvolvimento' README.md && grep -q 'll-auto' CHANGELOG.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
<!-- /ll-milestones -->

### M1 — helper detect — the stage table from disk
read_first:
  - scripts/ll-tools.js:99-180 — `gitTop`, `readAnchoredBlock`, `parseStateBlockLite`: copy the functions (never `require` ll-tools.js — the helper is self-contained, `fs` and `path` only)
  - scripts/ll-tools.js:670-678 — `state`: the `--json` / human dual output and the `{"ok":false,"reason":…}` shape on a broken input; read commands always exit 0
  - scripts/ll-tools.js:545 — how `epilogue` finds `## Epilogue — phase NN`
  - scripts/smoke-test.sh:109-120 — the `check "…" '$HELPER … --json | grep -q "…"'` shape for helper checks against `scripts/fixtures/project`; line 237 counts the installed skills (11 → 12 once `skills/ll-auto/` exists, which M1 creates)
  - scripts/fixtures/project/ROADMAP.md, PROGRESS.md — the rows (05 DONE, 06 DONE, 07 ACTIVE, 08 PLANNED), the epilogue heading `## Epilogue — phase 07`, `phases/07/PLAN.md` present, no `phases/07/VERIFICATION.md`, no `docs/`
action: create `skills/ll-auto/scripts/ll-auto.js` [DECISIONS D-03-01] (executable, `#!/usr/bin/env node`, Node ≥ 18, no dependencies, ≤ 400 lines for the whole phase) with the command `detect [--cwd <dir>] [--json]` implementing DECISIONS D-03-02: stages in order `research`, `brainstorm`, `decide`, then one `phase-NN` per ROADMAP table row (or per PLAN §8 inline phase when there is no ROADMAP; none when there is no PLAN), one `verify-NN` per phase row, `close`; each `{id, status: todo|half|done, evidence: "<path or rule>"}`; JSON `{"ok":true,"root":…,"stages":[…]}`; human output one line per stage. `verify-NN` is `done` when `phases/NN/VERIFICATION.md` exists, else `todo`. Phase rule, refined from D-03-02 (the fixture's phase 07 carries an epilogue while its board still shows M2/M3 red): `done` when the ROADMAP row state starts with `DONE`, or when `## Epilogue — phase NN` exists and the `ll-state` block is either for another phase or shows every milestone `passes: true`; `half` when `phases/NN/PLAN.md` exists and the phase is not done; else `todo` [DECISIONS D-03-02 amended, 2026-09-10]. TDD: commit `test(M1)` first — the smoke checks (`ll-auto detect: fixture project → decide done, 07 half`, `ll-auto detect: fixture empty → tudo todo`, `ll-auto detect --json é JSON válido`) and the count bump to 12 — red because the helper does not exist; then `feat(M1)`.
behavior (tdd: yes): fixture project → research todo · brainstorm todo · decide done · phase-05 done · phase-06 done · phase-07 half · phase-08 todo · verify-05..08 todo · close todo · fixture empty → every stage todo (research, brainstorm, decide, close; no phases) · `--cwd` on a path that is not a directory → `{"ok":false,"reason":…}` exit 0 · running twice on the same tree gives byte-identical JSON (R-02)
acceptance: the M1 acceptance command in the block above, exit 0; last line pasted in the return block
truths: T3
stop: none

### M2 — helper roteiro, next-cmd, report, auto-md
read_first:
  - skills/ll-auto/scripts/ll-auto.js (after M1) — extend, keep `detect` untouched
  - ~/.claude/gsd-core/workflows/autonomous.md:22-36, 145-151 — the `--from/--to/--only` filter semantics to mirror (numeric compare on the phase number, `--only` implies from=to and skips close)
  - scripts/lint-contract.cjs rule 6 (after phase 02) — the ▶ Next grammar `next-cmd` parses: `/clear, then <cmd>` with an optional trailing parenthetical to strip
  - scripts/fixtures/project/PROGRESS.md:56-64 — the epilogue whose last ▶ Next line names `ll-implement 8`
action: add `roteiro --flags "<args>" [--objective "<text>"] [--cwd] [--json]` per DECISIONS D-03-04/D-03-08: parse the flags string (`--research`, `--brainstorm`, `--interactive`, `--auto-decision`, `--pause-at <x>` repeatable, `--from N`, `--to N`, `--only N`, `--verify all`, `--redo <stage>` repeatable, `--dry-run`, `--resume`); build the ordered list from `detect`: research only with `--research` and status todo (or `--redo research`); brainstorm only with `--brainstorm` likewise; decide when todo; every phase row not done, filtered by from/to/only, `half` ones first as resume; `verify-NN` right after its phase when `--verify all` or when the NN epilogue's next-cmd names `ll-verify NN`; close last unless `--only`/`--to` cut before the last row; each entry `{stage, command, status, pause_after: bool}` with the command from D-03-04 (`--no-talk` dropped on brainstorm and implement under `--interactive`); `needs_objective: true` and an empty roteiro when the repo is empty (no research, no OPENING, no PLAN) and no objective was given. Add `next-cmd <file>`: prints the command of the last `▶ Next — /clear, then <cmd>` line (parenthetical stripped, trimmed), empty output and exit 0 when none. Add `report [--cwd] [--json]`: `{"decisions":[{file, title, line}]}` for every `decisions/*.md` containing `[decided by absence — revisable]`. Add `auto-md --objective … --flags … [--cwd]`: prints the `docs/AUTO.md` body of D-03-07 — `## Objective` (the objective on its own line), `## Flags` (the flags string on its own line), `## Roteiro` table `| # | stage | command | status | evidence |` with one row per roteiro entry (the phase number zero-padded as in ROADMAP: `ll-implement 08 --no-talk`), `## Decisions taken alone` (empty until the end), `## Log` (empty until the first transition). New fixture `scripts/fixtures/auto-decisions/decisions/`: `DEC-0001-taken-alone.md` carries the marker, `DEC-0002-owner.md` does not. TDD: `test(M2)` first — the fixture and smoke checks for the four commands (roteiro on the project fixture with `--verify all` and with `--only 8`; next-cmd on the fixture PROGRESS; report on the new fixture; auto-md prints `## Roteiro`) — then `feat(M2)`.
behavior (tdd: yes): project fixture, flags `--verify all` → `phase-07, verify-07, phase-08, verify-08, close` · flags `--only 8` → `phase-08` · flags `--from 8 --to 8` → `phase-08` (close cut by --to) · flags `` on the empty fixture without objective → `needs_objective: true`, roteiro empty · flags `--research --brainstorm` with objective on the empty fixture → `research, brainstorm, decide, close` · next-cmd on fixture PROGRESS → `ll-implement 8` · report on auto-decisions → one entry, DEC-0001
acceptance: the M2 acceptance command in the block above, exit 0; last line pasted
truths: T3
stop: none

### M3 — the ll-auto skill text and the lint exceptions
read_first:
  - skills/ll-implement/SKILL.md:1-19 — frontmatter with `allowed-tools`, the `Current state: !\`…\`` preprocessor line, the boundary bullets, the Deliverables table header `| File | Role | Mutability |`, `## Flow`, `## Completion criterion` ending in a ▶ Next line in the phase-02 grammar, `## References`
  - scripts/lint-prompts.sh:27,144-145 — `ALLOWED_TOOLS` equality; :273-279 — rule 5 (`Skill(`, `^\s*/ll-`, run `ll-x`); :16-17 `EXCEPT_DELIVERABLES` (ll-auto is not exempt: it writes docs/AUTO.md); :177-179 ceilings 200/150; :335-345 rule 7 language
  - scripts/lint-contract.cjs:112-128 — rule 1: every `references/x.md` named in SKILL.md exists and every file under references/ is named
  - phases/03/DECISIONS.md — D-03-03..D-03-08 are the text to write
action: write `skills/ll-auto/SKILL.md` (≤ 200 lines): frontmatter `name: ll-auto`, one-line description (60–300 chars, third-person verb, no "Use when"), `argument-hint: "[\"<objective>\"] [--research] [--brainstorm] [--interactive] [--auto-decision] [--pause-at <stage|N>] [--from N] [--to N] [--only N] [--verify all] [--redo <stage>] [--dry-run] [--resume]"`, `disable-model-invocation: true`, `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)`; `Current state: !\`${CLAUDE_SKILL_DIR}/scripts/ll-auto.js detect\``; boundaries (never the Skill tool; a stage is run by reading `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/<skill>/SKILL.md` with Read and following its Flow in place with the stage's arguments; only this skill may do so, and only because the owner typed `/ll-auto`; no spending ceiling ever, I-05); Deliverables (`docs/AUTO.md`, plus what each stage writes by its own skill); Flow: 0 detect + flags → roteiro; empty repo without objective → print the two lines of D-03-06 (the Portuguese sentence inside backticks, rule 7) and stop, no question; `--dry-run` → print the roteiro table and stop; 1 write `docs/AUTO.md` via `auto-md`; 2 per stage: mark running in AUTO.md, read the stage SKILL.md, follow it with the command's arguments, then `detect` again, mark done/half, append the Log line, list WAITING DECs — without `--auto-decision` skip dependent stages and stop when nothing else can run (D-03-05); with it resolve each WAITING DEC as D-03-05 says; `--pause-at` → stop after the stage with `▶ Next — /clear, then ll-auto --resume`; 3 end: `report`, print the "Decisions taken alone" block, write it into AUTO.md, `▶ Next — /clear, then ll-resume`. Questions: none ever, except what a stage run under `--interactive` asks. Completion criterion. References: `references/stages.md` (the detection table of D-03-02, the command per stage of D-03-04, the flag table of D-03-08) and `references/run.md` (the AUTO.md template of D-03-07, the WAITING handling of D-03-05, the end block). Lint: in `scripts/lint-prompts.sh` rule 1, accept `Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)` for `ll-auto` only (a map `ALLOWED_TOOLS_BY_SKILL` with the default for everyone else); rule 5: an `ORCHESTRATOR = ["ll-auto"]` list whose SKILL.md and references may contain lines starting with `/ll-` and the phrase run `ll-x`; `Skill(` stays forbidden everywhere. Rule 5 walks only `SKILL.md` files, so the exception is scoped to `skills/ll-auto/SKILL.md`; references are outside rule 5 today and stay so. TDD [PLAN §7: lint rules with fixtures]: commit `test(M3)` first — in `scripts/smoke-test.sh`, a section `lint-orquestrador` that copies the tracked tree into `$TMP/lint-scratch` (`git ls-files -z | xargs -0 cp --parents -t`, then `git init -q && git add -A` so `git ls-files` inside the copy sees it), adds `skills/ll-fake/SKILL.md` with the ll-auto `allowed-tools` value and a body line starting with `/ll-research`, and checks that `bash $TMP/lint-scratch/scripts/lint-prompts.sh --rule 1` and `--rule 5` both exit 1 there while the same two rules exit 0 on the real tree; give `smoke-test.sh` an `--only <section>` switch (runs one named section; no argument runs everything as today) — then `feat(M3)` with the skill text and the two lint changes. Commit naming only these 5 files.
behavior (tdd: yes): scratch tree with `skills/ll-fake/SKILL.md` carrying `allowed-tools: Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)` → rule 1 exit 1 naming ll-fake · the same file with a body line `/ll-research x` → rule 5 exit 1 naming ll-fake · real tree → rules 1 and 5 exit 0 with `skills/ll-auto/SKILL.md` present · `bash scripts/smoke-test.sh --only lint-orquestrador` runs only that section and exits 0
acceptance: the M3 acceptance command in the block above, exit 0; last line pasted
truths: T6
stop: none

### M4 — installer mode bits, README, CHANGELOG, installed-copy check
read_first:
  - bin/install.js:171-183, 208-211 — `walk` copies every file under `skills/<name>/` with no mode; the `HELPER_SKILLS` branch sets `mode: 0o755`; add a general branch: any `skills/*/scripts/*.js` gets `mode: 0o755`
  - scripts/smoke-test.sh:230-266 — the install block: count of installed skills (12 after M1), the `-x` and sha256 checks per helper copy (262-266) — add the same two assertions for `skills/ll-auto/scripts/ll-auto.js`
  - README.md — the skills table and the "Como as skills são chamadas" section (ll-auto "em desenvolvimento" → available), the helper table (a second helper now exists)
  - CHANGELOG.md — the `## [3.0.0] - Unreleased` entry: add `### Adicionado` with ll-auto
action: installer: general `mode: 0o755` for `skills/*/scripts/*.js`; smoke test: installed `skills/ll-auto/scripts/ll-auto.js` is executable and byte-identical to the source; README (Portuguese): ll-auto row in the skills table (quando: `/ll-auto "<objetivo>" [flags]`; entrega: `docs/AUTO.md` e o ciclo inteiro), the "Como as skills são chamadas" paragraph updated (ll-auto exists, one place that follows the other skills, only when you type it), a short "Fluxo autônomo" subsection with the flag table (10 lines), and the helper section mentions `skills/ll-auto/scripts/ll-auto.js` with its five commands; CHANGELOG `### Adicionado`. Commit `feat(M4): ll-auto shipped — installer, README, CHANGELOG` naming only these 4 files.
acceptance: `npm run lint && npm test && grep -q '/ll-auto "' README.md && ! grep -q 'em desenvolvimento' README.md && grep -q 'll-auto' CHANGELOG.md` exit 0; last line pasted
truths: T6
stop: none

## Errata
- 2026-09-10 — PLAN-REVIEW REJECTED, four gaps applied: G-1/G-3 M3 is `tdd: yes` with a `lint-orquestrador` smoke section on a scratch tree (rule 1 and rule 5 reject the ll-auto exceptions on any other skill) and `smoke-test.sh --only <section>` · G-2 M2's acceptance asserts the five AUTO.md sections, the objective, the flags and one roteiro row · G-4 M4 greps the flag table and the absence of "em desenvolvimento"; D-03-01 cited in M1; `read_first` line numbers corrected to :670-678 and :545.
## Waves
| wave | milestones | builds |
|---|---|---|
| 1 | M1 | helper detect |
| 2 | M2 | helper roteiro, next-cmd, report, auto-md |
| 3 | M3 | the ll-auto skill text and the lint exceptions |
| 4 | M4 | installer, README, CHANGELOG, installed-copy check |
