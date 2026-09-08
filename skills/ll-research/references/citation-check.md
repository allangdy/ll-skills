# Citation check — the verifier

Runs after SUMMARY.md is written, never during. Discovering and attributing are different jobs; mixing them is what produces the plausible, wrong citation. The verifier gets paths only — no history, no thesis.

## Brief

<brief>
You are verifying citations for a research you did not run. You receive file paths and nothing else; do not research the topic, do not add findings, do not fix prose.

INPUT
- `{destination}/SUMMARY.md`
- `{destination}/evidence/F0n-*.md` (all of them)
- `{destination}/sources.md`

TASK
1. **Liveness.** For every URL in `sources.md`, WebFetch it. Live = it resolves and the page still contains the cited excerpt. Record the status code or the failure. A URL that never appeared in a tool result during the research is a fabrication — flag it as such.
2. **Claim → source.** For every `A-nn` referenced in SUMMARY.md, open the front note and compare the claim against the **literal excerpt saved there**, not against your own reading of the topic. Three outcomes: the excerpt supports the claim; the excerpt supports something narrower (quote what it does support); the excerpt does not support it at all.
3. **Independence.** Two sources that cite the same third count as one. Collapse them and say so.
4. **Labels.** Apply the rules below and return the table. Do not edit any file.

LABEL RULES
- `[VERIFIED]` — live URL, and either one tier 1–2 source (official spec/docs/changelog, or a paper with declared method and N) or two independent tier 3–4 sources agreeing, and the excerpt supports the claim as written.
- `[UNVERIFIED]` — anything else, always with a reason from this list: dead URL · no saved excerpt · excerpt narrower than the claim · single tier 3–6 source · sources not independent · date outside the validity window declared in the header · claim about the owner's own system with no `file:line`.
- A claim about the owner's system is verified in the code, never on the web.

OUTPUT — one table, then nothing
| Claim | Source | Liveness | Excerpt supports? | Label | Reason |
|---|---|---|---|---|---|
| A-03 | S3 | 200 | yes | [VERIFIED] | — |
| A-07 | S21 | 404 | yes | [UNVERIFIED] | dead URL; excerpt saved, use Wayback |
| A-11 | S14 | 200 | narrower | [UNVERIFIED] | source counts one vendor, claim says "most vendors" |

Close with a count line: `n claims · n [VERIFIED] · n [UNVERIFIED] · n fabricated URLs`.
</brief>

## What the session does with the result

A claim labelled `[UNVERIFIED]` is rewritten to what the excerpt supports, or moves to `## What the evidence does NOT cover`. It never stays under `## Apply`. A dead URL keeps its saved excerpt and is usable, but `sources.md` records the status and an archive link beside it. Fabricated URLs are removed together with everything that rested on them.
