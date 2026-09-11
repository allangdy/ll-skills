# Lab — on-demand simulation of the whole skill set

The lint, the smoke test and the one-turn evals prove shape and stops. They do not measure quality:
whether the questions were worth asking, whether the plan made sense, whether the product runs at
the end. Only a simulated project measures that, and it costs hours of agent time. So it runs on
demand, when the owner decides, never on every change. Nothing in `lab/` ships in the package
(`package.json` `files` does not list it).

## How a run works

1. **A scenario** (`lab/scenarios/<name>.md`) is the script of a human: the project idea, who the
   owner is, how they answer the questions the skills are likely to ask, what they decide, when they
   say "continua". Same script, different skill versions, comparable runs.
2. **The driver** is this session (the one that develops ll-skills), running inside herdr. It creates
   a throwaway project, starts a fresh Claude Code in it through herdr, and types the commands and
   answers exactly as the scenario says. To the session under test, the input is keystrokes in its
   terminal: it cannot tell a script from a person, and nothing in the prompts says it is a test.
3. **The evaluator** is a subagent with a fixed rubric (`lab/rubric.md`). It reads the transcript on
   disk — the session file and every subagent file — and writes `lab/runs/<date>-<scenario>/REPORT.md`.
   The driver never reads the transcripts itself; it reads the report.
4. **The decision round**: the owner and the driver go through the report finding by finding —
   fix (a BACKLOG row or a phase), keep as is, or change the scenario.

Two scenarios share one project so the results compare: `notes-api` (manual, skill by skill) and
`notes-api-auto` (`/ll-auto` only).

## herdr — what the driver uses

herdr (https://herdr.dev, `herdr --skill` prints its own agent instructions) is the terminal
workspace this session already runs in (`HERDR_ENV=1`). It organizes workspaces → tabs → panes,
recognizes a Claude Code running in a pane and exposes it over a local socket:

| need | command |
|---|---|
| a new workspace in the throwaway project | `herdr workspace create --cwd <dir> --label lab-<scenario> --no-focus` → `.result.root_pane.pane_id` |
| start Claude Code there, named | `herdr agent start lab --kind claude --pane <pane-id>` (returns when the prompt is ready) |
| type a command or an answer, then wait | `herdr agent prompt lab "<text>" --wait --timeout <ms>` (text + Enter, bracketed paste: indistinguishable from typing) |
| wait for a question | `herdr agent wait lab --until blocked --timeout <ms>` (`blocked` = an approval or question UI is up) |
| see the question and its options | `herdr agent read lab --source recent-unwrapped --lines 60` |
| choose an option | `herdr agent send-keys lab down down enter` (or `herdr agent prompt lab "<free text>"` for "Other") |
| state of the agent | `herdr agent get lab` (`idle`, `working`, `blocked`, `done`, `unknown`) |
| the session id for the transcript | `herdr agent list` → `.agent_session.value` |

Rules the driver follows: `--no-focus` everywhere (the owner keeps their own pane); never close a
pane it did not create; every wait has a timeout; a `blocked` state is answered from the scenario
table, never improvised — an unscripted question is itself a finding, recorded in the run log and
answered with the scenario's default line.

## Driver protocol — isolated session, trust, polling

The session under test never runs inside the driver's own `~/.claude`: it gets its own
`CLAUDE_CONFIG_DIR`, so nothing it does touches the driver's own skills, memory or settings, and
nothing it reads can leak the driver's credentials by accident.

- **Isolated config.** `export CLAUDE_CONFIG_DIR=$(mktemp -d)` before `herdr agent start`, then seed
  it the way `bin/install.js` would (`skills/`, `agents/`, `CLAUDE.md` copied in from the package
  under test, or `CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR node bin/install.js --yes` run against this
  checkout) so the session under test sees the same skill set the driver develops, not the driver's.
- **Trust pre-accepted.** Before turn 1, write the key the trust dialog reads inside that same
  `CLAUDE_CONFIG_DIR`: `.claude.json` → `projects["<throwaway project dir>"].hasTrustDialogAccepted:
  true`. Fallback, if a Claude Code version moved the key and the dialog still appears (this is what
  happened in the 2026-09-11 run, `lab/runs/2026-09-11-notes-api/RUN.md` 14:05:42–14:06:32): expect
  the dialog on turn 1 and answer it with `herdr agent send-keys lab down enter` before the scripted
  first prompt goes in.
- **Polling, never a foreground wait above 5 minutes.** A turn that can run long (`ll-implement`, a
  waited `/goal`, `ll-auto --pause-at/--resume`) is not one multi-hour `herdr agent prompt --wait`;
  poll instead with `herdr agent wait lab --until idle --timeout 300000` in a loop and stop the loop
  when the state is `idle`, `blocked` or `done`.
- **Per-turn logging.** Every 5 minutes the loop is still `working`, append the last 5 lines of
  `herdr agent read lab --source recent-unwrapped --lines 5` to `RUN.md` as `silence <n> min` since
  the last owner-facing line. After the loop ends, read both `herdr pane read <pane-id> --source
  recent-unwrapped --lines 200` (plain text, for the owner-facing screen and jargon checks) and
  `herdr agent read lab` (JSON, for tool-call counts) and append both to `RUN.md`.
- **Per-turn assertions**, run right after the state goes `idle`/`done`, before the next prompt:
  `ll-tools.js state --json` — the phase equals the phase just run and no earlier `M*` line was
  overwritten; `ll-tools.js backlog-reconcile --json` — no `unparsable` row; the plain-text pane read
  — no `band-1`, `banda 1`, `DEC-`, `ASM-` on screen; after `ll-decide`, the `OPTIONS.html` path line
  in the transcript comes before the first question line; after a `--milestone` turn, `docs/history/`
  exists on disk. Log every assertion's pass/fail in `RUN.md`, not only the failures.

## Where the evidence is

- Session transcript: `~/.claude/projects/<cwd with / replaced by ->/<session-id>.jsonl`
- Subagents: `~/.claude/projects/<…>/<session-id>/subagents/agent-*.jsonl` (+ `.meta.json`)
- Cost and turns: the `usage` fields inside those files; the evaluator sums them.
- The product: the throwaway project itself (`npm test` there is the last proof).

Transcripts stay where they are (they are large); the report links them by absolute path.

## Run log

Every run gets `lab/runs/<YYYY-MM-DD>-<scenario>/`: `RUN.md` (what the driver typed, in order,
with timestamps and every `blocked` it answered), `REPORT.md` (the evaluator's), and `metrics.json`.

## Ready commands — manual scenario `notes-api`

```bash
# 0. throwaway project (outside every real repo) + isolated config dir
D=~/projects/temp/$(date +%Y-%m-%d)-notes-api && mkdir -p "$D" && git -C "$D" init -q -b main
R=lab/runs/$(date +%Y-%m-%d)-notes-api && mkdir -p "$R" && printf '# RUN — notes-api — %s\n\n' "$(date +%F)" > "$R/RUN.md"
export CLAUDE_CONFIG_DIR=$(mktemp -d)
node bin/install.js --yes   # seeds skills/agents/CLAUDE.md into $CLAUDE_CONFIG_DIR
node -e 'const fs=require("fs"),p=process.env.CLAUDE_CONFIG_DIR+"/.claude.json",d=process.env.D||process.argv[1];
  const j=fs.existsSync(p)?JSON.parse(fs.readFileSync(p)):{};
  j.projects=j.projects||{}; j.projects[d]=Object.assign({hasTrustDialogAccepted:true}, j.projects[d]);
  fs.writeFileSync(p, JSON.stringify(j,null,2));' "$D"

# 1. workspace + agent (read the pane id from the JSON)
P=$(herdr workspace create --cwd "$D" --label lab-notes-api --no-focus | node -pe 'JSON.parse(require("fs").readFileSync(0)).result.root_pane.pane_id')
herdr agent start lab --kind claude --pane "$P"
SID=$(herdr agent list | node -pe 'JSON.parse(require("fs").readFileSync(0)).result.agents.find(a=>a.name==="lab").agent_session.value')

# 2. the human's turns — one line each, in the order of the scenario file; after each, poll + log + read
herdr agent prompt lab "<turn text from lab/scenarios/notes-api.md>"
until [ "$(herdr agent get lab)" != working ]; do sleep 300; herdr agent read lab --source recent-unwrapped --lines 5 >> "$R/RUN.md"; done
herdr agent read lab --source recent-unwrapped --lines 200 >> "$R/RUN.md"
herdr agent read lab >> "$R/RUN.md"
# when the state is blocked: read, pick the scripted answer, then
herdr agent send-keys lab down enter        # or: herdr agent prompt lab "<free-text answer>" --wait

# 3. between skills, as a human would
herdr agent prompt lab "/clear" --wait --timeout 60000

# 4. at the end: the product proof, then the evaluator
(cd "$D" && npm test 2>&1 | tail -3)
# Agent(general-purpose, opus) with lab/rubric.md, the transcript paths and $R/RUN.md → writes $R/REPORT.md
```

The autonomous scenario replaces step 2 with a single `/ll-auto "<objective>" --auto-decision`
turn and the same polling loop up to 7 200 000 ms; questions should not appear — every `blocked` is
a finding.
