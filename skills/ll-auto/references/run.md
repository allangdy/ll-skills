# The run — `docs/AUTO.md`, decisions, end block

## The file

`ll-auto.js auto-md --objective "<objective>" --flags "<the arguments>"` prints the body; step 1
redirects it to `docs/AUTO.md`. Five sections, no frontmatter:

```
# AUTO — autonomous run

## Objective

<the objective, on its own line>

## Flags

<the flags string, on its own line>

## Roteiro

| # | stage | command | status | evidence |
|---|---|---|---|---|
| 1 | phase-08 | ll-implement 08 --no-talk | todo | ROADMAP row: PLANNED |

## Decisions taken alone

(filled at the end of the run)

## Log

(one dated line per stage transition)
```

Status of a row: `todo` · `half` · `running` · `done` · `skipped` · `waiting`. Exactly one row is
`running` at a time. The `evidence` column is the one `detect` gave for that stage, refreshed when
the row is marked `done` or `half`.

A log line is `<YYYY-MM-DD HH:MM> <stage> <status> — <evidence or the stage's last line>`, appended,
never rewritten. The `## Flags` section is what `--resume` reads, so it is written once and left
alone; a run restarted with different flags rewrites the whole file.

## Decisions only the owner can take

After every stage, list the `decisions/*.md` whose status is `WAITING`.

Without `--auto-decision`:
- the run continues through the stages that do not depend on them; a phase whose ROADMAP section
  carries `stop: owner` is skipped and its row is marked `skipped`;
- the rows that depend on a WAITING decision are marked `waiting`;
- when nothing else can run, print the WAITING list — one line per file, with the question and the
  recommended option — and stop with `▶ Next — /clear, then ll-auto --resume`.

With `--auto-decision`:
- append to each WAITING decision file a dated line
  `status: DECIDED — <the recommended option> [decided by absence — revisable]`;
- clear the `stop: owner` marks those decisions held in ROADMAP;
- continue the roteiro; the marker is what the end block lists.

Nothing is decided outside these two paths: a decision that has no recommended option stays
`WAITING` and stops the run even under `--auto-decision`, because there is nothing to pick.

## The end block

`ll-auto.js report --json` answers `{"decisions":[{file, title, line}]}` for every `decisions/*.md`
carrying `[decided by absence — revisable]`. Print it, and write the same lines into the
`## Decisions taken alone` section:

```
Decisions taken alone — review them:
- decisions/DEC-0007-retry-policy.md — retry policy for the provider adapter (line 12)
- decisions/DEC-0009-report-window.md — the window the report counts (line 9)
```

An empty list is printed as `Decisions taken alone: none`. Then the count line of the Completion
criterion, then the handover. The run ends there: the next command belongs to the owner.
