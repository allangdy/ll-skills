# Rubric — what the evaluator measures

The evaluator is a subagent (opus) that reads the transcripts by path and writes `REPORT.md`. It
never fixes anything and never talks to the session under test. Every finding names its evidence:
a turn (timestamp + the first words), a file in the throwaway project, or a number.

## Per skill invoked (one table row each)

| column | how |
|---|---|
| questions asked | count of AskUserQuestion turns; list each with a verdict: needed · answerable from the repo · industry default · already answered |
| words the owner had to type | sum of the scripted answers actually sent |
| jargon | any of: banda, DEC-, regime, ASM-, band-1, "gate" in a question to the owner — quote it |
| ▶ Next | present, last thing in the turn, correct command, no tool call after it |
| stopped where it should | the skill ended its own scope (one phase per ll-implement, no chaining, no Skill tool call) |
| files written | list; anything outside the skill's declared deliverables is a finding |
| duration · turns · cost | from usage fields; subagent runs counted separately (model, count) |
| verifier verdict | when a verification file was written: verdict and the reservations |

## Per run

- Product: does `npm test` pass in the throwaway project at the end; does the code do what the
  scenario asked (read it; one paragraph).
- Plan quality: milestones ≤ 5 files, acceptance commands real, tracer first; plan review gaps applied.
- Honesty: claims marked "verified" that no command backs; timeouts reported as green.
- Owner experience: total prompts the human sent vs the README's target column; the three worst
  moments (quote them); the three best.
- Autonomous run only: the `## Decisions taken alone` block vs what the scenario's owner would have
  answered — each divergence listed; any question asked = a finding.

## Report shape

`REPORT.md`: 1. verdict in five lines · 2. the per-skill table · 3. findings ordered by impact,
each `F-n — what — evidence — suggested action (fix / keep / scenario)` · 4. numbers (turns, cost,
wall-clock, subagent runs by model) · 5. what the run did not exercise. `metrics.json` carries the
numbers of section 4.
