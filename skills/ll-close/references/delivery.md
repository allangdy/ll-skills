# docs/DELIVERY.md — the eight sections

The format the owner asks for by pointing at an exemplar. Its reader is a manager who did not watch
the work: he wants to know what changed for him, what was proven, and what he is being asked to
accept. Eight sections, in this order, no others. A section with nothing in it says so in one line
and stays — an absent section reads as an oversight.

Ledger, table and prose rules: every claim about behaviour names the command or the `file:line`
behind it. What was not run goes to §5 as an assumption, never to §4 as a result.

```markdown
# DELIVERY — <phase NN | round N | milestone name> — <YYYY-MM-DD>
verification: <path to VERIFICATION.md> · verdict <APPROVED|APPROVED_WITH_RESERVATIONS> ·
product <OK|FAIL> · process <OK|FAIL> · slice <branch> <sha..sha>

## 1. What changed, for the manager
<3 to 8 lines, no jargon: what a person can now do that they could not before, where, and from
when. Numbers where the change is numeric (a report that took 4h now takes 82 min). No file names
here — this section survives being pasted into a message.>

## 2. Findings → done
| # | finding (as reported) | what was done | evidence |
|---|---|---|---|
| F-03 | "os números do topo não batem com o relatório" | recalculation moved to the same query | `npm test -- kpi.test.ts` exit 0 |
<One row per finding that entered this round, including the ones deliberately left out — those get
"not done, see §6" in the third column. The finding is quoted as it was reported, in the words used.>

## 3. New rules, with an example
<Rules this delivery makes permanent: an invariant, a naming convention, a forbidden command, an
access recipe. One line per rule, each followed by one concrete example of the rule applied — a
rule with no example is not yet a rule. These are the same lines that go to CLAUDE.md in step 5.>

## 4. Verification
| criterion | command | exit | last output line |
|---|---|---|---|
| SC-01 | `npm test -- reconcile.test.ts` | 0 | `Tests: 3 passed, 3 total` |
<Plus the screenshots that were opened, by path, with what each one shows in a few words: an image
not opened is a check not done. Commands that were not run appear here with `not run` and the
reason, never omitted.>

## 5. Assumptions to ratify
<What was decided on the owner's behalf while he was not there, one per line: the assumption, the
DEC that records it, what breaks if it is wrong, and how expensive it is to reverse. This section
feeds the ratification block; if it is empty, say "none — every decision in this delivery is in
decisions/".>

## 6. Out of this round, and why
<What was asked for or found and deliberately not done. One line each: what, why (cost, risk,
depends on an open decision), and the BACKLOG id or the phase where it will be picked up. "Out of
scope" with no id is how work disappears.>

## 7. Deploy risks
<Only what is real for this delivery: migrations that are hard to reverse, new environment
variables, jobs added or renamed, rate limits, data written on first run, order of deploy between
repos, what to watch in the first hour and where. Each risk names its rollback, or says there is
none. If the push is the deploy, that sentence appears here explicitly.>

## 8. File inventory
| path | what it does | new / changed |
|---|---|---|
| `src/billing/reconcile.ts` | idempotent reconciliation by (provider, event_id) | new |
<Every path the delivery touched, grouped by area, from `git diff --stat <range>`. Generated files
and lockfiles are one line, not one row each.>
```

## Rules per section, in short

1. **What changed** — the manager's language; no file names; numbers where there are numbers.
2. **Findings → done** — the finding quoted as reported; one row each, including the refused ones.
3. **New rules** — one rule, one example; these become the CLAUDE.md lines.
4. **Verification** — commands, exit codes, last lines, screenshots seen; `not run` stays visible.
5. **Assumptions** — what was decided for him, with the cost of being wrong.
6. **Out of this round** — with a reason and an id.
7. **Deploy risks** — each with its rollback, or an explicit "none".
8. **Inventory** — everything touched, from the diff, not from memory.
