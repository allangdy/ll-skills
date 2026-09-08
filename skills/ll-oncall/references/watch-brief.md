# Watch brief

Five elements, in the repo before the first cycle. Any missing and the watch does not start — a vigil
without a hypothesis reports weather, one without an automatic action wakes the owner for nothing.

```
# WATCH — <slug> — opened <date>
1. Target      — the systems in scope, by name: Lia, Luzia, n8n, the book being generated
2. Hypothesis  — what is under test: "the shop worker is degrading the shared database"
3. Action      — what happens automatically on confirmation: "ask it to stop, or stop the worker"
4. Channel     — where the notice goes: the owner here; the peer by role prefix
5. Frequency   — every 1h                       probe: scripts/<slug>-check.sh
Baseline       — <window> of history, with the normal range per signal
Trigger        — <condition A> AND <condition B>          (both written before cycle 1)
```

**Baseline before cycle 1** — enough history to know what normal is, ranged per signal, recorded here;
always-present errors are not an incident, and without the baseline every cycle is one.

**Two conditions, joined by AND** — the anomaly outside the baseline *and* a second signal pointing at
the suspect ("errors above the historical band" *and* "the suspect's jobs are slow in the same
window"). Three days and 50 cycles ran with no false positive on that rule: 9 errors in 173 executions
did not fire, because the suspect's jobs all finished within 4 seconds.

**Probe in `scripts/`**, versioned, idempotent, exit 0 green and exit 1 fires; one written to the
session scratchpad vanishes on restart and the watch stops without saying so. **Each cycle**: run it,
append one heartbeat line, resolve the recipient by role prefix through `ListAgents`, and act only
when both conditions hold.

## Degradation

- Three cycles in the same blocked state → change channel, tell the owner directly, stop repeating the
  line. 35 identical hourly messages produced 35 blind hours; the command ran fine when finally tried.
- Five green cycles → double the interval, up to the ceiling the brief names. The state goes in the
  heartbeat line, so a later session reads the sequence rather than the last message.

## Running it

`/loop 1h ll-oncall watch <slug>`, or a session cron. Either way the recipient is stored as a role
prefix and resolved at each firing — a stored session name forces a delete-and-recreate to change it.
