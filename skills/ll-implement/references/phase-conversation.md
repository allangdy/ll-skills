# Phase conversation — step 1 of `ll-implement`, inline

The phase route of `ll-brainstorm`, condensed for use inside `ll-implement` when
`phases/NN/DECISIONS.md` does not exist yet: same file, same schema, same closing conditions, no
agent. Reduced to the battery with "pode ir", "você decide", "just do it" or a pasted complete
plan: the map is skipped and A is ratified whole, B is still asked in one block of ≤4 (band 1 is
never delegated by a blanket phrase), the file is written, one line says what was locked.
With `--no-talk` nothing is asked and nothing waits on an answer: A is ratified on its
recommendations and each owner-only item becomes its own `decisions/DEC-NNNN-<slug>.md` in state
`WAITING` (id from `ll-tools.js dec-reserve`), listed in the Deferred section with its resume
condition, while every milestone whose work depends on it carries `stop: owner` in
`phases/NN/PLAN.md`; the file is written and step 2 of the skill runs.

## 1. Scout before speaking (≤10% of context)

Read the project CLAUDE.md, `git log --oneline -30`, `decisions/`, the phase section of
`ROADMAP.md`, PLAN §2/§3 and the documents the request cites; directed grep in the modules the
phase touches. One goal: a repo analog at `file:line` for every item going to A. An answer that
lives in the repo, the database or the infrastructure is looked up, not asked; a recorded
previous attempt is read and cited.

## 2. The queue (never shown whole)

List every open point of phase NN — and only of NN: a point that belongs to a later phase goes to
C as one word, never into A, never into a plan for that phase. Then classify with
`references/decision-policy.md`:
Mechanical (band 2) → A; Taste (band 3) → A marked `[revisable]` with the reason; Blocking (band 1:
money above the ceiling, irreversible outside the repo, price or promise, scope cut, the number the
owner will look at, a recorded rule contradicted by evidence) → B, at most 4, by impact. A band 1
item in A is a bug. What earlier DECISIONS, PLAN §3 or an external document settled is cited by id.

## 3. The map (the first visible message, ≤35 lines)

```
Phase NN — <title>.  (phase · ~<size> · <n> points mapped)
PREMISES — 1. <what I take as given>. 2. <…> — correct me if any is wrong.
A) I DECIDE, LIKE THIS — <k> points. Correct anything; silence = ok.
   1. <decision>. Analog: <file:line>.                                [reversible]
   2. <decision>. [no analog — my call]                                [revisable]
   3. <decision>. [revisable — a constraint I am inventing out of caution;
      it is not a rule of yours. Say so if you don't want it.]
B) I NEED YOU — <j ≤ 4> points. Batched right below.
   1. <the decision in business words>                                 [money]
   2. <the number you will look at: X or Y?>
C) LATER — <m> points: <name>, <name>.
Reply "ok" for all of A, or name only what you want changed (e.g. "A2 no backoff, drop A3").
"pode ir" / "você decide" closes A on my recommendations; B is asked anyway. To talk first, just write.
```

Every A item cites its analog or says `[no analog — my call]` (→ revisable); C is recorded, never discussed.

## 4. Battery B (once, ≤4) and the owner's replies

No B items, or `--no-talk`: no battery — under `--no-talk` each B item is recorded as a `WAITING`
decision instead of a question, and the phase goes on. Otherwise one AskUserQuestion call in the canonical format of
`references/decision-policy.md` — the header is `Pergunta n/N — <título> (impacto ALTO|MÉDIO|BAIXO
· desfazer: <custo>)`; the id (`D-NN-kk`) stays in the file, never in the header or the options.
The measured fact with its source, 2–3 options each with `<what becomes true> · <cost> · <what is
lost>`, the recommended one first, a "Claude decides" option that records the delegation.
- "ok" → A ratified in bulk, B as answered. "pode ir" / "você decide" → A closed on the
  recommendations and the delegation recorded; B still goes out, one block of ≤4, because band 1 is
  never delegated. A point correction ("A2 no backoff") → only that item.
- free text → stop the question tool, reflect in one line what was understood, continue in text;
  a new requirement becomes a new item with its own id; an order against the recommendation gets
  one challenge naming the cost, then obedience and a faithful record. Ten minutes of silence in
  the hot window ratifies A, never B.

## 5. Close

Closes when: zero Blocking items open (answered or deferred by the owner — under `--no-talk`,
every one of them is deferred as a `WAITING` decision and the milestones that depend on it get
`stop: owner`); A ratified; every locked item has backing (`file:line`, a measurement, the
owner's words) or sits under Revisable; names stable across the last two exchanges. Cap: two map rounds, then close A as it stands and
carry the rest into execution as `stop: owner`.

Write `phases/NN/DECISIONS.md` — under the repository root, beside `PROGRESS.md`, never in a
`docs/` subtree — with the 8 sections of the `ll-brainstorm` schema — header
`# Phase NN — Decisions · <date> · ll-implement`; Score · Locked (`D-NN-kk`: class, band,
impact, revert, backing, decided by, consequences) · Implementer freedoms · Revisable with
`Review trigger:` · Deferred with resume condition · Against the recommendation · Owner's free
answers verbatim · Accepted risks. Append-only, ids never recycled, supersession by a new line;
band 1 items also get `decisions/DEC-NNNN-<slug>.md` under an id from `ll-tools.js dec-reserve`.
Print the score and, on its own line, the counter `questions asked N / assumptions M / owner decisions open K`,
then continue to step 2 of the skill.
