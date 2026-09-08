# Review spec — 7 sections, blind arbitration, external contract

Read at feedback steps 5–7. Output: `docs/review-<date>.md` and `docs/<slug>.xlsx`. The spec is
the executors' only source: none of them opens the `.docx`, the PDF or the map — half the context,
and no two agents reading one ambiguous annotation two ways.

## The 7 sections
~~~
# Review — <site/product> — <date>
This document is self-contained: every approved copy block is embedded verbatim. The implementer
does NOT need to read the review files under <source paths>. Copy disputes were settled by
independent blind judges; the verdicts below are final — do not re-litigate them.
Source material: <files, with the inventory count>. Decisions: <n> · rejected: <r> · deferred: <d>.

## Decision log
| # | item (inventory id) | reviewer's proposal | decision | by | note |
| 1 | C3 | "R$ 297 → R$ 247" | rejected — price stays (owner, Q2/16) | owner | Greenn is the source of truth |
(every inventory item appears here or in §Deferred; rejected items stay, with the reason)

## §1 <Page or area> — <target file(s)>
Conventions that bind: <tracking params, component, price table, max title/description length>.
### <block name> (replaces <file:line>)
```text
<final copy, verbatim, in the site's language>
```

## §Sweep — what became obsolete
| grep | expected hits after the change | where else it lives |
| `grep -rn "R\$ 297" src/` | 0 | menu, hub, README |
(after any change of price, offer, name or claim; 9 real divergences sat in files nobody would open)

## §External dependencies
| dependency | section | detail needed | owner (person) | placeholder in the code |
| checkout link for <product> | §2 | Greenn URL | Lucas | `TODO(checkout): <product>` + WhatsApp CTA |
Placeholder rule: never ship a dead button or a guessed URL — the CTA points to a working
fallback and the code carries `TODO(<kind>): <item>` so `grep -rn "TODO(checkout)"` is the index
of what the sheet closes.

## §Deferred — do NOT implement
| item | reason | cost of deferring | resume condition |

## §Verification contract
Commands: `<typecheck>` · `<build>` · `<deterministic gate, e.g. node perf/seo-audit/run.mjs>` with
baseline: the gate runs before any edit, its output is saved, only NEW errors block.
Routes × viewports: <list> × 390/820/1440 — DOM asserts (exact text, `scrollWidth === 390`,
negative matches for removed claims), each screenshot read by the agent that took it.
Sweep greps of §Sweep at 0 hits. Placeholders remaining: listed by grep in the delivery report.
Executor slices: <§ → files allowed (ONLY these) → model>.
~~~

## Blind arbitration (automatic when ≥ 2 versions of conversion copy compete)
One judge per item, Fable high, clean context, versions unattributed and shuffled (the team's
version and Claude's are "A", "B", "C" in random order). Brief:
```
You judge copy for <product>: <two lines of product facts, already through the veracity gate>.
Audience: <who, what they know, what they fear>. Goal of the block: <click, trust, clarity>.
Criteria: <truthfulness to the facts above · clarity for a lay reader · specificity · length limit>.
Versions (authorship unknown to you):
A) <…>   B) <…>   C) <…>
You may propose a version D if it beats all of them on the criteria.
<output_contract>
At most 150 words, in this order:
1. VERDICT: A | B | C | D
2. Rationale: which criterion decided, in two sentences.
3. Version D: the exact text, only if the verdict is D.
</output_contract>
Do not restate the versions; do not soften the verdict to a tie.
```
4 of 5 judges in the real case proposed a better D. The verdict comes back into the numbered
question as "(retomada)" with D as an option; the owner decides; the log records "settled by
blind judge — final".

## External contract — the .xlsx
Generated from §External dependencies, committed in `docs/`, one row per dependency:
```
python3 - "docs/<slug>.xlsx" <<'PY'
import sys, openpyxl
wb = openpyxl.Workbook(); ws = wb.active; ws.title = "Pending"
ws.append(["item", "section", "current value", "detail needed", "owner", "done ✔", "link / value", "integrated ✔"])
how = wb.create_sheet("How to use")
for line in ["Fill 'link / value' and tick 'done' when the item exists.",
             "Leave 'integrated' to the implementer: it is ticked when the placeholder is replaced.",
             "Return the file as-is (same columns); it is read back automatically."]:
    how.append([line])
wb.save(sys.argv[1])
PY
```
Commit: `docs(review): external dependencies sheet <date>`. When it comes back filled, the
placeholder grep is the work list: each `TODO(<kind>)` takes the sheet's value with the repo
convention applied (checked in the code first), then the verification contract runs again.
