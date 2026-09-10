# DEC-0001 — retry policy for the provider adapter

- Date: 2026-09-10
- Decided by: the run, under `--auto-decision`
- status: DECIDED — three retries with exponential backoff [decided by absence — revisable]

## Decision

The adapter retries a failed provider call three times with exponential backoff.

## Why

The recommended option of the open question; nobody answered before the run reached the stage.
