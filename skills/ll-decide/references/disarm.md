# Disarm — design mode and measure mode

Read at project step 3. Input: `docs/decide/PREMORTEM.md` failures F-01..F-0n. Output:
`docs/decide/DISARM.md`. A listed risk disarms nothing; a failure leaves the list when the design
carries a named mitigation and a sentinel (design mode) or when a test ran against a
pre-registered acceptance and returned a number (measure mode).

## Design mode (default, no spending)
One row per failure, TOP 3 first:
```
## Design pass
| F | mitigation in the design | sentinel (observable, with threshold and where it is read) | plan B (pre-committed) | lands in PLAN |
| F-01 | <what the design does so the scene cannot happen> | <metric/log/query ≥/≤ value, checked by <command>> | <if the sentinel trips: …> | R-01 §4 · CA-nn §6 |
```
Rules: a mitigation names a component, a table, a check or a rule of the protocol — "we will
monitor" and "we will be careful" are not mitigations. A sentinel that no command can read is a
human acceptance item and names its owner. A failure with no cheap mitigation is carried as an
accepted risk in `decisions/README.md`, decided by the owner in the interview, never dropped.
Each row becomes `R-nn` in PLAN §4 (one per failure, same numbering) and a `CA-nn` in §6 when
the sentinel is observable by command.

## Measure mode (`--measure`)
Pre-registration per test, frozen and committed before any data exists
(`docs(decide): freeze pre-registration <slug>`):
```
## Test N — <title>   (disarms F-0n · blocks <decision>)
1. Falsifiable claim: <one sentence, present tense>
2. Adversarial sample: n = <..>, composition: <the cases chosen to break it, one by one>
3. Independent ground truth: <official source typed by hand | two reviewers + adjudication | external predictive criterion>
4. Acceptance, joint: quality <..> · coverage <..> · operation <..>  (number, unit, direction)
5. Fails if: <a plausible result>
6. Deadline and cost: <days>, <R$/tokens/hours>  (≤ ~2 weeks, without building the product)
7. Pre-committed decision: if pass → <..>; if fail → <..>
8. Blocks: <the decision this test precedes>
Pre-registration frozen on <date>.
```
A test missing any of the 8 parts goes back to be completed before running, never after.
Execution (one executor per test, Sonnet; Opus when adversarial judgment is inside the run):
sample by declared composition, ground truth established before looking at the output, results
broken down by input class (the aggregate hides the class where the product dies), same model
tier the product will use, deterministic work in scripts. Every test that passed is audited by an
Opus agent in clean context that recomputes at least one metric by an independent path; a
comfortable pass is a symptom of an easy sample until proven otherwise. Report per test in
`docs/decide/disarm/<slug>.md`: what ran · measured data by class · acceptance criterion by
criterion with the number beside · validity frontier · collateral findings and structural fixes
(defect → data that exposed it → fix → re-test) · cost vs budget · **What this test does NOT
prove** (layers untouched, regimes not exercised, populations not represented) · proposed verdict.

## Verdict vocabulary (closed; the session assigns, after the audit)
| Verdict | When |
|---|---|
| DISARMED | every joint criterion passed, audit held, validity frontier written with a number (where it holds and where it does not) |
| DISARMED WITH CONDITIONS | passed on the edge (79.7% against 80%) or because a design decision sustains it; the condition becomes a named requirement R-nn |
| CONFIRMED, WITH QUANTIFIED EXIT | the premortem was right and the test measured which lever fixes it; the redesign enters PLAN §4 before any code — the most valuable result |
| CONFIRMED | failed and no tested lever fixes it; what was tried is written; the owner decides kill or redesign (band 1) |
| IN PROGRESS | duration test installed with a reading date; day-1 fixes recorded |
| PENDING, WITH DECLARED SUBSTITUTE | needs third parties; a simulation ran with its epistemic frontier written; reclassified from blocker to pre-launch validation, with owner and milestone |
| PENDING | did not run (no data, access or ground truth); blocker, owner and milestone named — there is no verdict without a measurement |
A verdict carries its number; a verdict that describes effort ("tested extensively") is not one.
The pre-committed branch executes as a decision taken; the number does not reopen the discussion.

## Ceiling rule — human ground truth
When the claim is about perception, desirability, willingness to pay or a professional opinion,
an agent-run test proves only the arithmetic and structural properties of the instrument (a
scoring rule, a biased answer key, an undetermined cut). The verdict ceiling is DISARMED WITH
CONDITIONS or PENDING, WITH DECLARED SUBSTITUTE; DISARMED needs real people. The kit that lets
the real test fire later is written under `docs/decide/disarm/kits/<slug>/`: criterion (literal,
frozen), protocol (who, how many, from outside the team, script, randomized order), form
(objective items separate from subjective ones), pre-written analysis, sealed answer key. A
simulated persona answers in character with its profile hidden from the evaluator, and the
result says what it proves and what it does not.

## DISARM.md layout
Header (mode, date, source PREMORTEM.md) → design pass table (both modes) → measure mode:
pre-registrations, then `## Scoreboard` with one line per failure `F-0n · VERDICT — the numbers
that decide · frontier or lever · [report](path)` → `## Collateral findings` → `## Left with the
owner` (owner, milestone, instrument path) → `## Cost` (budgeted × real). What enters PLAN: the
conditions of DISARMED WITH CONDITIONS, the redesigns of CONFIRMED, the architecture decisions
the tests fixed, and the validity frontiers as scope (what enters is what was measured working).
