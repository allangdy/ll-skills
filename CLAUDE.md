# ll-skills — project notes

## Current state
3.0.0 delivered on 2026-09-10 (phases 01–05 closed, `docs/DELIVERY.md`, `docs/RETROSPECTIVE-2026-09-10.md`). Every skill is manual (`disable-model-invocation: true`); `ll-auto` drives the cycle when typed. Next: `ll-close --milestone 3.0.0` to archive the phases, or `ll-decide project` for the next milestone. Publishing (`git tag`, `npm publish`) is the owner's.

## Rules
- The clean checkout is the proof: `git archive HEAD` into a scratch dir, `git add -A && git commit`, then `npm run lint && npm test` must pass — a check that depends on an uncommitted file is not green.
- A backlog condition is exactly `` `<command>` exit 0 ``; prose conditions are wishes and `backlog-reconcile` cannot close them.
