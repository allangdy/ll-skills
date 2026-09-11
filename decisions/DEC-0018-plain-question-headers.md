# DEC-0018 — question headers and count lines carry no internal ids or jargon

- Date: 2026-09-11
- Decided by: Claude (owner feedback recorded on 2026-09-10: never "banda 1", "DEC-", "ASM-", "regime" on screen), flagged for the owner's review
- Status: DECIDED · [decided by absence — revisable]

## Decision

Every skill prints questions as `Pergunta n/N — <title> (impacto ALTO|MÉDIO|BAIXO · desfazer: <cost>)`
and the count line as `perguntas N / assunções M · decisões só suas em aberto K`; files keep
`questions asked N / assumptions M / owner decisions open K`. The `DEC-`/`D-NN-kk` id is written in
the file that records the answer, never in the header or an option label. Lint rule 9 pins it.
