# CODE-CONTEXT — phase 04 — 2026-09-10

No project `CLAUDE.md` found at repo root [verified: `find ... -iname CLAUDE.md` returned nothing]. Constraints
below come from the lint scripts, which are this repo's enforced house rules.

## Constraints (enforced by lint, in place of a missing CLAUDE.md)
- `skills/ll-goal/SKILL.md` line ceiling 200 [verified: scripts/lint-prompts.sh:182]; currently 64 lines
  [verified: `wc -l skills/ll-goal/SKILL.md`].
- `skills/ll-goal/references/goal-template.md` (matches `skills/[^/]+/references/[^/]+\.md`) ceiling 150
  [verified: scripts/lint-prompts.sh:184-185]; currently 90 lines [verified: `wc -l ...goal-template.md`].
- FORBIDDEN literal strings anywhere in any line under `skills/` or `agents/`: `MUST`, `CRITICAL`,
  `verify carefully`, `as discussed`, `IMPORTANT:` [verified: scripts/lint-prompts.sh:26]. Applies to both
  files.
- `Skill(` anywhere in a `SKILL.md` fails [verified: scripts/lint-prompts.sh:278-279]. Applies only to
  `SKILL.md`, not to `references/*.md`.
- Lines starting with `/ll-` (ignoring leading whitespace) and the pattern `` run `ll-<name>` `` fail
  **only inside `SKILL.md` files that are not the orchestrator** (`ORCHESTRATOR = ["ll-auto"]`)
  [verified: scripts/lint-prompts.sh:31,264-291]. `ll-goal` is not the orchestrator, so its own
  `SKILL.md` is subject to this; the naming loop starts at `body_start(text)` so frontmatter/heading
  lines are exempt, and lines containing `▶ Next` are explicitly skipped [verified:
  scripts/lint-prompts.sh:283-286].
- `references/goal-template.md` does **not** end in `SKILL.md`, so the `/ll-` and `` run `ll-x` ``
  checks do not apply to it — only the FORBIDDEN-string check does [verified:
  scripts/lint-prompts.sh:276-277]. `grep -c 'll-auto --auto-decision' ...goal-template.md ≥ 1`
  (SC-01) is therefore lint-safe as long as none of the FORBIDDEN words sit on the same or another
  line of that file.
- `▶ Next` lines must match grammar `▶ Next — /clear, then <cmd>`; `<cmd>` may be an existing
  `ll-<skill>` (checked against `skills/<name>/SKILL.md` existing) or `/goal <text>` (must have text
  after it), one command only, no backticks around it [verified: scripts/lint-contract.cjs:315-358].
  The current `SKILL.md:58` line `▶ Next — /clear, then /goal <text>` already satisfies this — any new
  autonomous-variant `▶ Next` line must follow the same grammar.

## Analog per file — M1 (autonomous variant)

### skills/ll-goal/SKILL.md
- analog: itself, section `## Flow` step 5 and `## Completion criterion` [verified:
  skills/ll-goal/SKILL.md:48-59]
- the shape to copy: a numbered flow step describes what is assembled and written; the completion
  criterion is prose ending in a fenced `▶ Next —` block. The `--autonomous` flag belongs beside
  `argument-hint: "[phase-number]"` [verified: skills/ll-goal/SKILL.md:4] — extend that hint string,
  same one-line frontmatter shape as `skills/ll-auto/SKILL.md`'s `argument-hint` uses for its own flags
  (not opened this session; infer by name only) [assumed: exact `argument-hint` string ll-auto uses for
  its flags — not opened].
- differs in: `ll-goal` is not the orchestrator (`ORCHESTRATOR` list), so any prose sentence naming
  `ll-auto` must avoid the literal pattern `` run `ll-auto` `` and must not start a line with `/ll-`.

### skills/ll-goal/references/goal-template.md
- analog: itself, `## The 9 parts` fenced block (EXECUTION part) [verified:
  skills/ll-goal/references/goal-template.md:41-43]
- the shape to copy: the EXECUTION line already names `skill ll-implement <NN>` inside the fenced
  `/goal` text — the autonomous variant's mention of `ll-auto --auto-decision` belongs in an analogous
  fenced block, not as a bare prose line, matching the template's existing pattern of one fenced
  9-part text plus a checklist below it [verified: skills/ll-goal/references/goal-template.md:18-58,
  76-90].
- differs in: today the template has exactly one 9-part example; SC-01 requires the string
  `ll-auto --auto-decision` at least once — brief's suggested smoke section also checks a second,
  separate fenced example block under a fixed heading, ≤4000 chars via `wc -c` [assumed: the fixed
  heading name the smoke test will grep for — not given in the brief, pick and document it in the
  plan].

### scripts/smoke-test.sh (new section, suggested name `goal-autonomo`)
- analog: section `lint-orquestrador`, a standalone section at file end that does not depend on state
  from earlier numbered blocks [verified: scripts/smoke-test.sh:497-500]; and section `4d` for the
  grep-on-generated-text pattern [verified: scripts/smoke-test.sh:281-289].
- the shape to copy: `if section goal-autonomo; then ... fi`, guarded by `section()` (`[ -z "$ONLY" ] ||
  [ "$ONLY" = "$1" ]`) [verified: scripts/smoke-test.sh:19]; sections are named by number or word
  (`4b`,`lint-orquestrador`) and selected via `--only <seção>` [verified: scripts/smoke-test.sh:12-19];
  each `check "<label>" '<eval'd bash>'` increments `$N` and exits hard on first failure [verified:
  scripts/smoke-test.sh:25]. Header comment at top of file lists all section names — add
  `goal-autonomo` there too [verified: scripts/smoke-test.sh:5-7].
- the checks named in the brief: `grep -q -- '--autonomous' skills/ll-goal/SKILL.md` (argument-hint),
  `grep -q 'll-auto --auto-decision' skills/ll-goal/references/goal-template.md`, and a `wc -c` ≤ 4000
  check on the fenced example block under the (still-to-be-named) fixed heading — use `awk
  '/^## <heading>$/,/^## /'`-style extraction if the block needs isolating, mirroring `region()` at
  scripts/smoke-test.sh:28, or a plain `grep -A` if one fenced block is enough [assumed: whether the
  ≤4000 check targets the whole template file's one example or a second, autonomous-specific example —
  not resolved by the brief].

## Analog per file — M2 (docs)

### README.md
- analog: existing `ll-goal` row and paragraph [verified: README.md:53,80]; existing `ll-auto` flag
  documentation paragraph [verified: README.md:92,107]
- the shape to copy: one short table row plus one prose sentence in the flags/behaviour section,
  Portuguese, same terse register as the `ll-auto` `--auto-decision` description at README.md:107.
- differs in: README.md is not lint-checked for the FORBIDDEN/`/ll-` rules (rule5 files list is
  `skills/`, `agents/`, `assets/preamble.md` only) [verified: scripts/lint-prompts.sh:265-266], so no
  constraint carries over here besides accuracy.

### CHANGELOG.md
- analog: the `[3.0.0] - Unreleased` → `### Adicionado` bullet for `ll-auto`'s flags [verified:
  CHANGELOG.md:7]
- the shape to copy: one bullet, bold skill name, en-dash-free prose listing the new flag and what it
  writes, same sentence shape as the `ll-auto` bullet.
- differs in: SC in ROADMAP phase 05 (not this phase) ties the 3.0.0 changelog entry to `package.json`
  version — this phase only adds the bullet under the existing Unreleased/3.0.0 heading, does not bump
  version [assumed: from ROADMAP phase 05 SC-03, not opened beyond the phase-04 section per the brief's
  read restriction].

## Readers of the symbols that change
No named symbols change (brief: `SYMBOLS none`). The only reader-relevant fact: `--only <section>` in
smoke-test.sh is read by CI/dev invocations of the whole file with no argument (runs everything) or
`--only <name>` (runs one). No other script parses smoke-test.sh section names [verified: grep across
scripts/ for `smoke-test.sh --only` found only the header comment and CLI itself, no other caller
found in this session's search scope].

## Traps
- Writing `ll-auto --auto-decision` as a bare line (not inside a fenced block, not preceded by
  `` run ` ``) in `SKILL.md` is safe; writing it as prose `` run `ll-auto --auto-decision` `` in
  `SKILL.md` fails rule 5 because `ll-goal` is not in `ORCHESTRATOR` [verified:
  scripts/lint-prompts.sh:31,288-290].
- A line starting with `/ll-auto` (not `/goal`) anywhere in `SKILL.md`'s body fails rule 5 unless it
  contains `▶ Next` [verified: scripts/lint-prompts.sh:283-286] — do not paste an example invocation as
  a bare command line.
- goal-template.md is exempt from the `/ll-` and `` run `ll-x` `` checks (not a `SKILL.md`), so the
  9-part fenced EXECUTION/other parts may freely say `ll-auto --auto-decision` — do not over-hedge the
  wording there. [verified: scripts/lint-prompts.sh:276-277]

## Values with provenance
| value | where it lives | verified/assumed |
|---|---|---|
| SKILL.md line ceiling | 200 | verified: scripts/lint-prompts.sh:182 |
| references/*.md line ceiling | 150 | verified: scripts/lint-prompts.sh:184-185 |
| current SKILL.md length | 64 lines | verified: `wc -l` |
| current goal-template.md length | 90 lines | verified: `wc -l` |
| FORBIDDEN strings | MUST, CRITICAL, verify carefully, as discussed, IMPORTANT: | verified: scripts/lint-prompts.sh:26 |
| ORCHESTRATOR exception list | ["ll-auto"] only | verified: scripts/lint-prompts.sh:31 |
| ▶ Next grammar | /clear, then <cmd>; /goal needs trailing text | verified: scripts/lint-contract.cjs:336-358 |
| smoke section selector | `--only <section>`, matched by exact string in `section()` | verified: scripts/smoke-test.sh:12-19 |
| fixed heading name for the ≤4000-char example block | not given by the brief | assumed: plan must name it |
| project CLAUDE.md | does not exist at repo root | verified: find returned nothing |
