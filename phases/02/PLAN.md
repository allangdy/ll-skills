# Phase 02 — next contract and --no-talk
Objective (from ROADMAP): every skill hands over one machine-readable `▶ Next` line, and the two skills that still interview can run without asking · Success criteria: SC-01 `node scripts/lint-contract.cjs --rule 6` fails on a `▶ Next` line that is not `▶ Next — /clear, then ll-<skill> [args]` (fixture-tested) and passes on the tree · SC-02 `ll-decide project --no-talk` and `ll-close --no-talk` are documented in their SKILL.md and argument-hint: the recommendation is followed and recorded with `[decided by absence — revisable]` · SC-03 `npm run lint && npm test` exit 0 ·
Decisions: phases/02/DECISIONS.md · Context: phases/02/CODE-CONTEXT.md · Contract: PLAN.md §2, §3, §7
## Milestones
<!-- ll-milestones -->
milestones:
  - id: M1
    name: rule 6 enforces the Next grammar, fixture-tested
    files: [scripts/lint-contract.cjs, scripts/smoke-test.sh, scripts/fixtures/next-bad/skills/ll-bad/SKILL.md, scripts/fixtures/next-good/skills/ll-good/SKILL.md]
    depends_on: []
    tdd: yes
    acceptance: "! node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-bad && node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-good | grep -q '(5 checked)' && ! node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/empty && bash -n scripts/smoke-test.sh"
    stop: none
    truths: [T4]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M2
    name: every Next line rewritten to the grammar
    files: [assets/preamble.md, skills/ll-brainstorm/SKILL.md, skills/ll-close/SKILL.md, skills/ll-decide/SKILL.md, skills/ll-goal/SKILL.md, skills/ll-implement/SKILL.md, skills/ll-oncall/SKILL.md, skills/ll-refine/SKILL.md, skills/ll-research/SKILL.md, skills/ll-resume/SKILL.md, skills/ll-update/SKILL.md, skills/ll-verify/SKILL.md]
    depends_on: [M1]
    tdd: no
    acceptance: "node scripts/lint-contract.cjs --rule 6 && npm run lint"
    stop: none
    truths: [T4, T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
  - id: M3
    name: ll-decide project --no-talk
    files: [skills/ll-decide/SKILL.md, skills/ll-decide/references/interview.md, skills/ll-decide/references/premise-gate.md, skills/ll-decide/references/decision-policy.md, skills/ll-brainstorm/references/decision-policy.md, skills/ll-implement/references/decision-policy.md]
    depends_on: [M2]
    tdd: no
    acceptance: "npm run lint && grep -qE '^argument-hint:.*--no-talk' skills/ll-decide/SKILL.md && grep -q 'decided by absence' skills/ll-decide/SKILL.md && grep -q -- '--no-talk' skills/ll-decide/references/interview.md && grep -q -- '--no-talk' skills/ll-decide/references/premise-gate.md && grep -q -- '--no-talk' skills/ll-decide/references/decision-policy.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: opus/high
    verification: internal
  - id: M4
    name: ll-close --no-talk
    files: [skills/ll-close/SKILL.md, skills/ll-close/references/delivery.md]
    depends_on: [M2]
    tdd: no
    acceptance: "npm run lint && npm test && grep -qE '^argument-hint:.*--no-talk' skills/ll-close/SKILL.md && grep -q 'decided by absence — revisable' skills/ll-close/SKILL.md"
    stop: none
    truths: [T6]
    exclusive: []
    model: sonnet/medium
    verification: internal
<!-- /ll-milestones -->

### M1 — rule 6 enforces the Next grammar, fixture-tested
read_first:
  - scripts/lint-contract.cjs:17 — `const ROOT = path.resolve(__dirname, '..')`: becomes the value of `--root <dir>` when given (parsed from `process.argv` right there, before line 60), else the same default
  - scripts/lint-contract.cjs:60-70 — the consts built from ROOT at module load (SKILL_TREE, AGENT_FILES, README…): they must see the overridden ROOT, so `--root` is parsed above them
  - scripts/lint-contract.cjs:309-334 — `rule6` today: keep `result()`, `refCount`, `matches`, `rel`, `text`; replace the anchoring test by the grammar match
  - scripts/lint-contract.cjs:385-408 — RULES table and `--rule`/`--json` parsing in `main()`: the flat `argv.indexOf` style to copy for `--root`
  - scripts/smoke-test.sh:378-386 — section 10: `contract()` helper and one `check` line per rule; add a `contract_root()` helper and two checks
  - skills/ll-goal/SKILL.md:1-6 — the minimal frontmatter shape for the two fixture skills
action: grammar [DECISIONS D-02-01]: on every line of every `.md` under `<root>/skills`, each occurrence of `▶ Next —` opens a handoff; the text after the em dash (trimmed, with one optional wrapping backtick pair removed when the marker itself sits inside backticks) must be `/clear, then <cmd>` followed by nothing, or by one parenthetical `(…)`, or — only when the handoff was backtick-wrapped inside prose — by free prose after the closing backtick. `<cmd>` is one of: `ll-<skill>` that exists as `<root>/skills/<skill>/SKILL.md`, optionally followed by arguments that contain no backtick and no parenthesis; `/goal` followed by text; a single `<placeholder>` in angle brackets. Backticks around `/clear` or around the command, "then" without the comma, "paste", "or `ll-x`" alternatives outside a parenthetical, and a command that names no existing skill are FAILs, each with `file: Next … ` + the reason. Prose that merely mentions "▶ Next" without the em dash is ignored (ll-implement/SKILL.md:96 today); every line with the em dash is a handoff and is checked, including quoted spec lines such as ll-resume/SKILL.md:76. Add `--root <dir>`: replaces ROOT for the whole run (fixtures are scanned instead of the package). Write the two fixtures: `next-bad` has one line in the old shape naming the fixture's own skill (`` ▶ Next — `/clear` then `ll-bad` ``), one bare `▶ Next — ll-bad`, and one in the new grammar naming a skill that does not exist (`▶ Next — /clear, then ll-nope`) — the existing "names a skill that is not a skill" check stays (I-01); a `--root` whose `skills/` directory is missing or holds no `.md` is a FAIL (`no skills tree under <root>`), never a vacuous `0 checked` green; `next-good` has one line per allowed form (plain `ll-good`, `ll-good 3 --wave 2 (or ll-good --resume)`, `/goal <text>`, `<the command the epilogue names>`, and one backtick-wrapped handoff inside prose). TDD: commit `test(M1)` first — the two fixtures plus the two smoke-test checks (`contrato 6: next-bad falha`, `contrato 6: next-good passa`) — then `feat(M1)` with the rule and `--root`. Keep the RULES table shape; rule 6's name stays `next-targets`.
behavior (tdd: yes): `--rule 6 --root scripts/fixtures/next-bad` → exit 1, three FAIL lines naming `skills/ll-bad/SKILL.md` (old shape, bare command, unknown skill) · `--rule 6 --root scripts/fixtures/next-good` → exit 0, `ok   6 next-targets (5 checked)` · `--rule 6 --root scripts/fixtures/empty` → exit 1, `no skills tree under …` · `--rule 6` without `--root` → scans the package tree as today (expected red until M2 rewrites the lines; do not run it as your acceptance) · `--rule 2` unaffected
acceptance: `! node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-bad && node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/next-good | grep -q '(5 checked)' && ! node scripts/lint-contract.cjs --rule 6 --root scripts/fixtures/empty && bash -n scripts/smoke-test.sh` exit 0; last line pasted in the return block. Smoke checks: three (`next-bad falha`, `next-good passa`, `raiz sem skills falha`).
truths: T4
stop: none

### M2 — every Next line rewritten to the grammar
read_first:
  - phases/02/CODE-CONTEXT.md:27-58 — the table of all 25 occurrences with their kind; only the "handoff" rows change, the two "prose about the line" rows and the preamble spec line follow the note below
  - scripts/lint-contract.cjs (after M1) — the grammar as implemented; run `node scripts/lint-contract.cjs --rule 6` before and after: it lists every offending line
action: rewrite each handoff to `▶ Next — /clear, then <cmd>` with no backticks around `/clear` or the command; alternatives move into one parenthetical, e.g. ll-brainstorm:173 → `▶ Next — /clear, then ll-implement NN (phase route; project route: ll-decide project)`, ll-implement:95 → `▶ Next — /clear, then ll-implement N+1 (or ll-verify NN --external, or ll-close, as the epilogue says)`, ll-decide:108 → `▶ Next — /clear, then ll-implement 1 (feedback mode: ll-implement NN, the phase appended in step 7)`, ll-refine:111 → two forms in one parenthetical, ll-oncall:117 likewise, ll-goal:58 → `▶ Next — /clear, then /goal <text>`, ll-resume:51 → `▶ Next — /clear, then <the command the epilogue names>`, ll-resume:76 → `` last line `▶ Next — /clear, then <cmd>` ``, ll-update:72 keeps its parenthetical, ll-brainstorm:127 → `▶ Next — /clear, then ll-implement NN (or "adjust X" if something is wrong)`, ll-research:82 → `▶ Next — /clear, then ll-decide project (reading docs/research-<topic>/SUMMARY.md)`, ll-close:32 (inside the blockquote) → `> Não fecho: <motivo em uma linha>. ▶ Next — /clear, then ll-verify NN (or record the reservations in a DEC and run ll-close again)`. Inline handoffs quoted in prose (ll-implement:13,42,79,88; ll-verify:33; ll-decide:102; ll-close:62-64; ll-verify:71-72) keep their backtick wrapping but the inside becomes the grammar (`` `▶ Next — /clear, then ll-implement NN --wave i+1` ``). `assets/preamble.md:21` becomes `prints "▶ Next — /clear, then <command>"`. Do not change any other sentence. Commit `feat(M2): every Next line in the grammar` naming only these 12 files.
acceptance: `node scripts/lint-contract.cjs --rule 6 && npm run lint` exit 0; last line pasted
truths: T4, T6
stop: none

### M3 — ll-decide project --no-talk
read_first:
  - skills/ll-decide/SKILL.md:4 — `argument-hint: "[project | feedback] [--measure]"` → add `[--no-talk]`
  - skills/ll-decide/SKILL.md:51-54 (premise gate), 65-69 (interview), 70-71 (final round), 76-79 (hand off), 110-116 (Questions) — the sentences that say "blocking" and "asked anyway"
  - skills/ll-decide/references/interview.md "## Blanket delegation" (lines ~19-29) and premise-gate.md:8-17 "The gate blocks" — where the flag's rule is spelled out in full
  - skills/ll-decide/references/decision-policy.md:61-71 "Silence, delegation, directives" — the `[decided by absence — revisable]` house string, line 62; the three copies are byte-identical (md5 7cb5e151…), lint-prompts rule 6
  - decisions/DEC-0001-auto-decision-flag.md — "without the flag: go as far as possible, then stop"
action: document `--no-talk` [DECISIONS D-02-03]: with it, steps 1, 5 and 6 send no AskUserQuestion. Premise gate: each premise without a source takes the recommended answer as `ASM-n [decided by absence — revisable]`; PG-1/PG-2 (band 1) are still written as premises but also as `decisions/DEC-NNNN-*.md` in state WAITING. Interview: band-2/3 items → `ASM-n [decided by absence — revisable]`; band-1 items → a WAITING DEC each, listed in PLAN §3, and `ROADMAP.md` marks the first phase whose work depends on one with `stop: owner` in its section. Final round: printed as a report (same content, counter `questions asked 0 / assumptions M / band-1 open K`), not asked; the contract is written and frozen even with K > 0 — the WAITING DECs are what stops later work, not this skill. Hand off: the report names each WAITING DEC with its file. Feedback mode: the triage battery follows the same rule (one sentence). Add one sentence to the "Silence, delegation, directives" section of decision-policy.md: under `--no-talk` the ten-minute silence is not waited for — the recommended option is taken at once and recorded `[decided by absence — revisable]`; band 1 stays WAITING. Copy that file byte-for-byte to the other two paths (`cp`), then `md5sum` the three. Keep every file under its lint-prompts ceiling (SKILL.md 200, references 150 lines). Commit `feat(M3): ll-decide --no-talk` naming only these 6 files.
acceptance: `npm run lint && grep -qE '^argument-hint:.*--no-talk' skills/ll-decide/SKILL.md && grep -q 'decided by absence' skills/ll-decide/SKILL.md && grep -q -- '--no-talk' skills/ll-decide/references/interview.md && grep -q -- '--no-talk' skills/ll-decide/references/premise-gate.md && grep -q -- '--no-talk' skills/ll-decide/references/decision-policy.md` exit 0; last line pasted
truths: T6
stop: none

### M4 — ll-close --no-talk
read_first:
  - skills/ll-close/SKILL.md:4 — `argument-hint: "[--milestone <name>]"` → `"[--milestone <name>] [--no-talk]"`
  - skills/ll-close/SKILL.md:44 (step 7 "One block of ratification") and :56 (--milestone step 6) — the two places the question is asked; :28-34 the gate, which does not change
  - skills/ll-close/references/delivery.md:41-44 "## 5. Assumptions to ratify" — where the written-instead-of-asked block lands
action: document `--no-talk` [DECISIONS D-02-04]: the ratification block is not asked; the same items (open pendings with conditions, accepted risks, recommendation) are written under the epilogue in PROGRESS.md and in DELIVERY.md §5 with the line `[decided by absence — revisable]` and the date; the gate is unchanged (REJECTED, STALE, missing verification still stop the close); `--milestone` step 6 follows the same rule. Two sentences in SKILL.md, one in delivery.md; keep the 200/150-line ceilings. Commit `feat(M4): ll-close --no-talk` naming only these 2 files.
acceptance: `npm run lint && npm test && grep -qE '^argument-hint:.*--no-talk' skills/ll-close/SKILL.md && grep -q 'decided by absence — revisable' skills/ll-close/SKILL.md` exit 0; last line pasted
truths: T6
stop: none

## Errata
- 2026-09-10 — PLAN-REVIEW REJECTED, five gaps applied: G-1 ll-resume:76 is a checked handoff, M2 rewrites it · G-2 M4 uses the house string `[decided by absence — revisable]` · G-3 M2 names ll-close:32, ll-brainstorm:127, ll-research:82 explicitly · G-4 next-bad gains the unknown-skill line, an empty root is a FAIL, acceptance greps `(5 checked)` · G-5 authority for scripts/smoke-test.sh recorded in DEC-0009 (project PLAN Errata).
## Waves
| wave | milestones | builds |
|---|---|---|
| 1 | M1 | rule 6 enforces the Next grammar, fixture-tested |
| 2 | M2 | every Next line rewritten to the grammar |
| 3 | M3, M4 | ll-decide project --no-talk · ll-close --no-talk |
