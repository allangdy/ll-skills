# DEC-0041 — cents divergence: reject the line or accept and flag?

- class: QUESTION · layer: product · impact: HIGH · revert: 1 migration
- grounding: internal (src/pay.ts:1; 3 cases in test/) | external (research-billing/F02, 2026-09-05)
- options:

  | option | what starts to hold | cost | what is lost | revert |
  |---|---|---|---|---|
  | A accept + flag (recommended) | the KPI the owner reads stays whole | 1 day | strict totals | 1 commit |
  | B reject the line | totals are exact | 2 days | manual queue grows | 1 migration |

- depends_on: — · conditions: M3, M5
- status: WAITING — asked 2026-09-03T11:05Z, no answer yet
- owner's words (verbatim): —
- consequences by rule: SC-03 in ROADMAP measures "tolerated rows" only under option A.
- superseded_by: —
