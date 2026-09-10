---
name: ll-goal
description: Writes the unattended-run text for /goal, with one numbered objective, literal proofs, invalidating rules, budget, decisions and a stop rule, saved as a versioned docs/GOAL.md.
argument-hint: "[phase-number]"
disable-model-invocation: true
---

# Goal

One file and one pasted text, in one turn. The text is a pointer: it says what "delivered" means,
which proofs count and where the details live — never what PLAN.md already says. The `/goal`
evaluator is a Haiku turn that judges only what appeared in the conversation, so every proof is a
command whose output the running session pastes back.

Reply to the owner in Portuguese; docs/GOAL.md is in English.

## Deliverables

| File | Role | Mutability |
| --- | --- | --- |
| `docs/GOAL.md` | frontmatter (`date`, `plan`, `phase`, `ceiling_usd`, `max_turns`) + the 9-part text | rewritten whole on each run, committed |
| the text in the conversation | what the owner copies into `/goal` | ≤4,000 chars, no fence, no commentary around it |

The goal is a versioned file. A goal aimed at a published artifact or an untracked path has no
contract behind it: every path it names is tracked, or the goal is not emitted.

## Flow

1. **Pre-flight PLAN ↔ PROGRESS ↔ code.** Read `phases/NN/PLAN.md` (or `PLAN.md` when there are no
   phases), `PROGRESS.md`, `ROADMAP.md`, and the files under `decisions/`. The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent,
   read the same facts out of the files. With it, run `state --json` and, when a phase plan exists,
   `plan-lint phases/NN/PLAN.md --json`. Report divergences in two lines: milestones marked
   `passes: true` with no commit behind them, acceptance criteria that are not commands, milestones
   in the plan absent from the board, `plan-lint` answering `verdict: fail`. A plan that fails there
   does not become a goal — say what to fix and stop.
2. **Blocking decisions.** WAITING decisions under `decisions/` that gate a milestone of this phase
   are resolved before emitting, in one AskUserQuestion battery of at most 4. An unattended run
   cannot answer them.
3. **The missing questions — one block, 0 to 2.** Ask only what no file answers, in a single
   AskUserQuestion: the number that decides success; what counts as delivered and which states are
   FAILURE; the ceiling and whether it is a target or a limit; the fan-out scope (how many executors
   on disjoint files); who decides in the hot window. Never ask whether you may emit the text.
4. **Assemble the 9 parts** from `references/goal-template.md`: Objective · Read first · Done when ·
   Invalidating rules · Execution · Budget · Decisions · State · Stop. Carry only what no document
   holds; everything else is a path with a section number. The invalidating block is copied verbatim
   and stays non-operational — rules about `.env`, deploys, killing processes or forbidden
   directories belong in CLAUDE.md and `settings.json`, not in a prompt retyped every night.
5. **Write, check, paste.** Write `docs/GOAL.md` with the frontmatter and commit it
   (`docs: goal for phase NN`). Run the 10-line checklist at the end of the template; fix what it
   catches. Then paste the text into the conversation as plain lines, and print the next step.

## Completion criterion

`docs/GOAL.md` exists and is committed; the text is in the conversation at ≤4,000 chars (`wc -c`);
the checklist passed. Close with:

```
▶ Next — /clear, then /goal <text>
```

## References

- `references/goal-template.md` — the literal 9-part template, the fixed invalidating block, and the
  pre-emission checklist.
