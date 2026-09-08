# Back from the future — premortem

Read at project step 2. The project is dead; the narrators explain why. A project rarely dies where
it was measured: it dies at the frontier between what was audited and what was taken on faith, so
the exercise measures that asymmetry first and attacks only the delta. Output:
`docs/decide/PREMORTEM.md`, whose failures become PLAN §4 requirements.

## 1. Inventory — measured × faith (written by the session, first section of PREMORTEM.md)
```
## Inventory
### Measured
| element | measurement (number, sample, method) | exact scope (layer, environment, sample, regime) |
### On faith
- <claim without measurement>: source of the belief (citation, analogy, projection, "it is standard")
### Confessions
- "<literal quote>" — <file> §<section>   (out-of-scope, limitations, TODO, known risks, footnotes)
### The frontier sentence
We measured X with rigor; the product depends on Y; X and Y are different things.
### Attack zone
A1..An — the delta, enumerated.  Out of target: <what was audited, and where>.
```
Research summaries (`docs/research-*/SUMMARY.md`) feed the faith column directly: high
importance + low evidence premises go there. Horizon and date of the narrative are chosen here —
the point where the project would have proven its central thesis.

## 2. Narrators — 3 to 5, Opus, clean context, one persona each
Personas by what the project actually has: engineering/data, operations and scale, unit
economics, legal/dependencies, end user, competitor. Narrators never see this conversation nor
each other's files; each writes `docs/decide/narrators/<persona>.md` and returns only the path
and the titles. Brief (fill every `<...>`, paths absolute):
```
You are the <persona> of <project>. It is <date/horizon> and the project died — not "could die":
it is a consummated fact and you saw the body. Report, in the past tense, what happened.
This report decides this week which cheap tests run before anything is built; the more specific
and painful, the more months it saves. Softening is the only way to fail this task.
Read, in order: <abs>/docs/decide/PREMORTEM.md (inventory, frontier, attack zone) · <artifact
paths for this persona>. Attack only the attack zone; what is listed as audited is out of target.
Cover at least these vectors: <3 from the list below>.
Write 3–5 deaths, each a concrete scene: who noticed, through which channel, when, which number
appeared, what the business damage was. End on the damage, not the defect.
For each death quote literally a passage of a project file that already warned, with file and
section; if none does, write exactly "no artifact of the project mentions this point". Never
put between quotes anything that is not literally in the file. Name the bias that explains why
the warning, existing, was not acted on. Propose no mitigation; propose only the cheap test.
Output — one section per death, exactly:
## ☠️ N. <one-line title with the number that defines it>
**(a)** <scene in the past tense, 1–5 sentences, numbers and damage>
**(b)** "<literal quote>" — `<file>` §<section> (or the blind-spot declaration) · bias: <name>
**(c)** test: <falsifiable claim · adversarial sample · independent ground truth · numeric
acceptance · "fails if ___" · deadline and cost · pre-committed decision on both branches · what
it blocks>
**Confidence:** high | medium | low — <one sentence>
Limits: edit no other file; read no other narrator; propose no roadmap or architecture.
Return only the file path and the death titles.
```
Attack vectors (generators, not text to copy): confidence transferred between layers · proxy
metric passing while the metric that matters fails · imported evidence under other boundary
conditions · identity/key that does not link contexts · regime change (batch → continuous) ·
unit economics measured in a subsidized environment · statistical underdetermination · sample
availability bias · dependency treated as a checkbox (legal, data contract, license) · plan B
never evaluated · silent failure (rot, drift, bleeding cost) · an omen already observed in a
low-risk context.

## 3. Convergence (session)
Read the narrator files. The same premise in different clothes is one failure: keep the best
scene and the best quote. Cut commonplaces (a sentence that fits any project unchanged) and
catastrophes without a cheap test. Open every cited file and check the quote literally; a
quote that does not match becomes the blind-spot declaration or leaves. Land on 5–8 failures
`F-01..F-0n`, each keeping the three blocks, ordered by lethality with the TOP 3 marked.
Lethality factors: kills or hurts (delay is not lethality) · retrofit cost and irreversibility ·
how many future decisions depend on the premise · probability given that nobody looked · time
to detection. Convergence count (how many narrators hit the same premise) is recorded per
failure — it is the recommendation's grounding in the interview.

## 4. The missing rule
The single process cause that explains every failure at once, and one policy stated as a
verifiable check, never an exhortation:
```
## The missing rule
Diagnosis: <one paragraph>
Rule: <one line> — check: "<yes/no question answerable by opening a file or running a command>"
Applies to: PLAN §2 as I-nn [source: PREMORTEM.md]
```

## PREMORTEM.md layout and done check
Inventory → `## Failures` (F-01..F-0n, TOP 3 marked, three blocks each, convergence count) →
`## The missing rule`. Done when: every quote was checked by opening the file (say how many, and
which failures have no documented warning); no failure survives the "fits any project" test; every
failure has a number in the scene and one in the acceptance; TOP 3 tests together fit in ~2 weeks
without building the product. Filling a gap with a plausible quote voids the exercise.
