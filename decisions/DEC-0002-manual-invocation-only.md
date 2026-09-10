# DEC-0002 — ll skills run only when the owner types them, or under ll-auto

- Date: 2026-09-10
- Decided by: the owner, in free text
- Status: accepted

## Decision

No ll skill is ever started by the model on its own. A skill runs in exactly two cases:
the owner typed `/ll-<name>` in the session, or `ll-auto` is driving the run.
The global router in `~/.claude/CLAUDE.md` that sends a request to a skill without the owner
typing its name is removed.

## Why

Automatic routing plus model-invocable skills is what turns a research run into an
implementation the owner did not ask for. The owner wants the manual flow to be manual.

## Consequence

- every `skills/ll-*/SKILL.md` gets `disable-model-invocation: true`
- `ll-auto` cannot use the Skill tool on locked skills; it reads each stage's SKILL.md as a
  workflow file and follows it in place (the way GSD includes its workflow files)
- the preamble keeps the house rules (delegation, proof, decisions) and loses the regime
  router and "one word from the owner beats the classifier"
- skill descriptions stop being trigger phrases and become plain one-line descriptions
- installer and README stop promising "the right skill without typing its name"
- `ll-goal` overlaps with `ll-auto --auto-decision`; its fate is decided in the plan
