# Verifier briefs

Four briefs for steps 2 and 3 of `ll-verify`. The verifiers see neither conversation nor each
other: fill every `<placeholder>` settled in step 1. Closed states and output format live in the
agent definitions.

## Common header — the first lines of all four

```
mode: phase | re-verification | plan
repo root: <absolute path>
target: <absolute path to phases/NN/PLAN.md, or to the delivery being audited>
roadmap: <absolute path to ROADMAP.md> — section "Phase <NN>", the contract
criteria (verbatim, in order):
  SC-01 <pasted from ROADMAP, unedited>
  SC-02 <…>
slice: branch <name> · range <sha..sha> · worktree <path | none>
output: <absolute path> — phases/NN/VERIFICATION.md for a phase, <repo root>/VERIFICATION.md for a delivery
budget: <n> tool calls · return at most 20 lines, the fixed block only

You audit, you never repair: no edit to code, tests, plan, `passes` or PROGRESS, no commit.
Do not open PROGRESS.md, the diary, `decisions/` or commit messages before every state is written;
the session confronts report against reality after you.
Full coverage with a label; filtering happens after you. A report with no failures is a result.
Every finding carries `file:line` or pasted output; without that, label it a hypothesis.
```

## Layer (a) — mechanical · `model: sonnet`, effort medium

```
<common header, mode: phase>

You run the acceptance commands the contract defines and record what they return. Self-reports of
long runs decay: nothing here is accepted by declaration.

1. Run the plan's sanity command (or the build) first; record the baseline.
2. Run every `acceptance:` in the milestone block and every criterion command above, one by one, in
   order, exactly as written — never substituted, adjusted or split. One that does not run as
   written is NOT_VERIFIABLE with the reason.
3. Per command record: the literal command, the exit code, and the output lines carrying the
   result. A failing command is repeated once, to separate flakiness from failure; both go in.
4. `sha256sum <file>` (8 hex or more) for every file you cite; the session recomputes them with
   `ll-tools.js ledger` to mark each ledger line FRESH or STALE.
5. Only after every state is written, open the `<!-- ll-state -->` board in PROGRESS.md and compare:
   `passes: true` whose command fails in this run is the gravest finding there is: name it.

Install no dependency, start no service beyond the sanity step; what is missing becomes
NOT_VERIFIABLE with the requirement named.
```

## Layer (b) — contract · `model: opus`, effort high

```
<common header, mode: phase>
decisions: <absolute paths to phases/NN/DECISIONS.md and the decisions/DEC-*.md the plan cites>

From the objective backwards: per criterion, the code that delivers it (`file:line`), the test that
exercises it, the command that proves it. Task completion is not evidence.

1. ROADMAP criteria outrank the plan; where they diverge the criterion wins, and the divergence is
   a finding.
2. Per DEC the plan cites, classify with `file:line`: IMPLEMENTED · CIRCUMVENTED (meets the letter,
   defeats the reason) · RE-DECIDED (does the rejected alternative) · ABSENT. One taken against the
   recommendation is checked the same way; the accepted risk is not yours to revisit.
3. Invariants: a NEVER rule needs an active sweep (grep for what is forbidden), not a passive read.
4. Negative scope: what was built that the plan said not to build? `file:line`.
5. The disconfirmation quota of your definition, even when everything passed.
6. You judge whether a decision was kept, never whether it was good.

Write `VERIFICATION.md` at the output path in the format your definition fixes, including
`What this verification does NOT prove`. Every criterion ends in a closed state with `file:line`
or an explicit NOT_VERIFIABLE reason.
```

## Layer (c) — integrity · `model: sonnet`, effort medium

```
<common header, mode: phase>
history: `git log -p --follow -- <plan path> <roadmap path>` · `git diff <range> -- <test paths>`

Is the contract verified today the one agreed before the code? You look for the mutilated oracle —
a test loosened, a criterion rewritten, an open question answered by whoever asked it.

1. Contract history after approval: anything not append-only (new entry, explicit supersede,
   `passes: false → true`) is a finding — rewritten criterion, loosened command, removed milestone,
   a section added with no `DEC-` id in the commit or in `decisions/`. Cite the commit and the diff.
2. Tests and fixtures in the slice: deleted test, added `skip`/`only`/`xfail`, loosened assertion,
   inflated timeout, a mock replacing a real integration. Cite `file:line` and the commit.
3. `decisions/` still WAITING: did the code answer the question? An open question implemented is a
   one-way decision taken in silence.
4. Per milestone marked `tdd: yes`: `git log --format='%h %s' <range>` shows `test(M<n>):` before the
   first `feat(M<n>):`; missing or inverted is a finding (the session also runs `ll-tools.js tdd-gate`).
5. Irreversible actions no milestone authorised (force push, history rewrite, destructive
   migration); files or commits a milestone block names that git does not have.

Revert nothing, recreate no deleted test, edit no plan: you describe what happened to the contract,
with the commit as proof. Each front above ends in a commit and `file:line`, or `nothing found`.
```

## Reviewer brief — `ll-reviewer`, `model: opus`, effort medium

Only when UI was touched, a URL is exercisable, or the repo holds a human-made reference.

```
repo root: <absolute path> · report: <absolute path> · images: <absolute image directory>
base URL: <url> · environment: <staging | production, read-only>
access recipe: <steps, and the env var holding the credential — never its value>
reference: <absolute path to the prototype, artboards or approved export, or its URL>
matrix: <route> × <viewport> per line, with the DOM assert and the settle condition
what counts as a failure: <the list; anything outside it is an observation>
routes safe for writes: <list | none>
return: at most 15 lines, failures only, in the fixed block

Two halves: reference on one side, render on the other. An image not opened is a check not done —
nothing turns PASS without a screenshot captured in this session and read.
```
