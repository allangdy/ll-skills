# DEC-0015 — PLAN §8 inline phases are a table, the same shape as ROADMAP.md

- Date: 2026-09-10
- Decided by: Claude (band 2: the house pattern — ROADMAP.md already uses the table and `ll-auto.js phaseRows` reads it in both places), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

When a project has no ROADMAP.md (three phases or fewer), `PLAN.md` §8 lists its phases as the
same table ROADMAP.md uses (`| phase | name | depends_on | requirements | state |`), never as
prose. `skills/ll-decide/references/plan-skeleton.md` §8 and `skills/ll-auto/references/stages.md`
say so; `ll-auto.js detect` reads that table (fixture `scripts/fixtures/auto-noroadmap`).

## Why

The helper found zero phases on a prose §8 (BL-B, af02554). One shape, read by one function, in
both files, is cheaper than teaching the helper prose.
