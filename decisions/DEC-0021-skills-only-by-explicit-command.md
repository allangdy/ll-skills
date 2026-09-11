# DEC-0021 — skills run only by explicit command; the preamble never routes a request

- Date: 2026-09-11
- Decided by: the owner ("Quero que seja apenas com comando … n deveria ser forçado, isso estraga o contexto, quero isso removido"), recorded by Claude
- Status: DECIDED (owner)

## Decision

`assets/preamble.md` carries no router: no "Commands to name" list, no LARGE/RESEARCH/EXECUTE classes,
no "answer with the command and stop". A request is answered or done as asked in any repository, with
or without ll-skills state; a command is named only when the owner asks which one. Eval cases that
scored the session for naming a command (`router-research`, `router-execute`, `router-large-opener`)
were deleted; `router-no-skill` scores the opposite.

## Why

Forced routing blocked ordinary work in other projects and wasted the owner's context inside
ll-skills projects when he did not want a skill at that moment.
