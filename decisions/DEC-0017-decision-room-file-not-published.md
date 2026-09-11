# DEC-0017 — the decision room is a local file handed over before the first question, never published

- Date: 2026-09-11
- Decided by: Claude (house pattern: every skill ends in a repository file; option (b) of CHANGE-PLAN §F-5), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

`ll-decide` writes `docs/decide/OPTIONS.html` with Write, sends its path in one message of its own
before the first question of the interview, and calls no Artifact tool and no other skill. Under
`--no-talk` the same path line is printed.

## Why

In the notes-api lab run the room was published through the Artifact tool after the questions had
started, so the owner saw the options after answering them; loading `artifact-design` doubled the
turn's context. The file is the deliverable; the owner opens it locally.
