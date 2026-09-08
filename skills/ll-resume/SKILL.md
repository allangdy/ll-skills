---
name: ll-resume
description: Reconstructs where a project stands in a fixed reading order and answers with a briefing of at most 20 lines — where we are, what changed since the owner last took part, what it cost, what is blocked, what waits on him, and the next command. Use when it is the first turn in a repo that has PROGRESS.md, or when the owner asks "Como está o status e qual o próximo passo?", "Qual o estado atual?", "O que tenho pra decidir?", "onde paramos?", "what is the status", "where did we stop", "what do I have to decide" — the RESUME regime. It does not write anything; for closing a phase and recording the delivery use ll-close.
argument-hint: "[--decisions]"
---

# Resume

One briefing in the conversation: ≤20 lines, ≤5 tool calls, nothing written to disk. The
SessionStart hook already injected the epilogue, the last PROGRESS lines, the dirty files, the
worktrees, the WAITING names and the board — report what changed, do not paste it back. Reply to
the owner in Portuguese. `--decisions` narrows the answer to the WAITING queue.

## Reading order

Fixed; batch it into one Bash with several commands plus one parallel block of Reads.

1. **Epilogue** — already in context. Never re-read it.
2. **Project memory** — content plus its age in days; memory older than the newest commit is a
   suspect, not a source (8 days stale once produced a plausible, wrong status).
3. **`git log` across all refs**, not only the current branch — work lands on agent branches:
   `git log --all --oneline -25 --format='%h %ad%d %s' --date=short`.
4. **Dirty worktrees and branches ahead of main** — `git status --short`, `git worktree list`,
   `git branch -vv`. 651 finished lines were once lost in a forgotten agent worktree.
5. **State** — The helper `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/ll-implement/scripts/ll-tools.js` is used only if it exists — this skill does not ship it; when it is absent,
   read the `<!-- ll-state -->` block of PROGRESS. With it, `state --json` → `{phase,
   milestones:{total,passed,list}, last_commit, git, waiting, epilogue_present, active_phase_plan}`.
6. **WAITING decisions** — the files under `decisions/`, with what each one blocks.
7. **Live parallel sessions** — `ListAgents`, when that tool is available.
8. **Active goal** — is there a `docs/GOAL.md`, and does the evidence say it is still running?

Confront the owner's premise against the evidence before asking anything — "em prod foi abortado"
and "o goal foi marcado como concluído" were both false, and each cost a session. Ask nothing
unless what he stated contradicts what you found; then that one question, isolated, after the
briefing. What no tool showed you goes out as `não verificado`, not as fact.

## Briefing

Render in Portuguese, in this shape, dropping any line with no content:

```
<project> · phase <NN> · <passed>/<total> milestones · HEAD <sha7> (<date>)
Onde estamos — <what the phase is delivering and how far it got>
Desde <last date he took part> — <2-4 lines: commits by sha on any branch, milestones green
  since then, what broke, which worktrees are still open>
Custo — <days with work · span · commits · agent runs, only where measurable>
Bloqueado — <M<n>> por <cause, with evidence>   |   nada
Espera por você — <n> decisões WAITING: <ID> <one line each>   |   nada
Não verificado — <stale memory of N days, orphan worktree, phantom goal, absent verification>
▶ Next — <the command the epilogue names>
```

Every claim carries its evidence — sha, `file:line`, or date; a green milestone with no commit
behind it is an orphan, not a delivery. If there are WAITING decisions, offer them after the
briefing in one `AskUserQuestion` with at most 4, ordered by what they block, each stating the cost
of waiting — never before it, never twice in a turn. Answers stay in the conversation.

## Legacy names

Projects not yet migrated keep the Portuguese names — read them, rename nothing mid-phase.

| Legacy artifact | Read as | Notes |
|---|---|---|
| `PLANO.md` | `PLAN.md` | tasklist §7 = milestone board; Diário §8 = PROGRESS log |
| `SPEC.md` (in `docs/spec-<slug>/`) | `PLAN.md` | the implementation contract |
| `PROGRESS.md` (pt) | `PROGRESS.md` | same role, no `ll-state` block to expect |
| `VERIFICACAO.md` | `VERIFICATION.md` | verdicts and their evidence |
| `RODADAS.md` | refine rounds | equivalent to `### Round N` in `PROGRESS.md` |
| `FILA.md` | `decisions/` | 7-field entries; its open items feed the battery |
| `decisoes/DEC-P-NNN.md` | `decisions/DEC-NNNN-*.md` | "AGUARDANDO <owner>" = WAITING |
| `.planning/` | `STATE.md` + phases | kept until `ll-close --milestone` |

## Completion criterion

Briefing in ≤20 lines, ≤5 tool calls, 0–1 questions, zero files touched, last line `▶ Next — <cmd>`.
