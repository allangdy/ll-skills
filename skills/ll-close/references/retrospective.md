# docs/RETROSPECTIVE-<date>.md

About 60 lines. It is the only document the next milestone is expected to read, so it holds what
changes behaviour next time and nothing else: no narrative of the phase, no praise, no repetition
of what `DELIVERY.md` already says. One lesson per line, each with the evidence that produced it —
a sha, a `file:line`, a number from `phase-stats`, a quoted turn. A lesson with no evidence is an
opinion and stays out.

```markdown
# RETROSPECTIVE — <phase NN | milestone> — <YYYY-MM-DD>

## What the numbers say
<From `ll-tools.js phase-stats --since <YYYY-MM-DD>`: days with work vs. span vs. idle days; commits by
type; test/feat ratio; milestones passed on the first verification vs. after gaps. 5-8 lines, each
a number and what it implies. An idle span is data about the process, not a reproach.>

## What cost prompts
<Where the owner had to intervene, and why: a question that should have been decided by rule, a
status he had to ask for, a correction of course, a re-run he paid for twice. Cite the turn or the
command. This is the section that shrinks the next phase — it is written even when the delivery
went well.>

## Rules that became permanent
<Each line: the rule, the incident that created it, and where it now lives (project CLAUDE.md,
PLAN §invariants, an access recipe in PROGRESS). Only rules that are written somewhere by the end
of this close; a rule that exists only here will not survive.>

## What to stop doing
<Practices this delivery proved expensive: a command that lies, a parallelism that collided on an
exclusive resource, a verification that never fires, a document nobody read. Name it and name the
cheaper replacement. Without a replacement it is a complaint, not a lesson.>

## Lessons
<One per line, ordered by how much they change the next phase, at most 10:
- <lesson in one sentence> — evidence: <sha | file:line | number | quoted turn>
Lessons that generalise beyond this repository are marked `[general]`; those go to memory. The
rest stay local and are read by whoever plans the next phase.>

## Cost and deferred
<What the delivery cost where it is measurable (agent runs, wall-clock days, tokens of scaffolding,
paid API calls) and what stayed open: BACKLOG ids, criteria deferred with their resume command,
decisions still WAITING. This section is the handoff — the next milestone starts from it.>
```

Writing rules: past tense, one subject per line, no adjectives of intensity. Never attribute to the
owner a decision he did not take. Quote his words verbatim where they are the lesson. If a section
has nothing, write `none this round` and keep the heading — the empty section is itself a finding
when it repeats.
