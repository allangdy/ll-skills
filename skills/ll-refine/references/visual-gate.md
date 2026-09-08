# Visual gate

Two halves: a deterministic comparison with calibrated numbers, then a clean-context validator that
looks at the images. Neither replaces the other — the gate catches displacement the eye forgives, the
validator catches the wrong content in the right place.

## The ruler

Written once, before the first delivery, at the top of the round file. Reference by path, never by
description — no ruler means no delivery, and "looks close enough" becomes the acceptance criterion.

```
Judge:     clean-context Opus validator — never the agent that rendered the element
Reference: docs/<area>/reference/<type>/p-NN.png   (rasterized from the source canvas at 96 dpi)
Verdict:   FIEL / NÃO FIEL, per page, with the divergence in mm and the SSIM value
```

## Reading the reference

| Reference | How to read it |
|---|---|
| `https://claude.ai/code/artifact/<id>` | `Artifact` tool, `action: read`, `url` — returns the HTML; pixels via Playwright on a local copy |
| Local file (html, png, pdf, docx) | `Read` (pdf by `pages`) |
| Other URL | Playwright MCP headless: `mcp__plugin_playwright_playwright__browser_navigate`, then snapshot or screenshot |
| Page behind the owner's login | Chrome MCP (`mcp__claude-in-chrome__*`), only then |

None works → band-1 question (attach or paste), never an assumption; "fiel" makes the content read the premise.

## Calibration

Starting defaults, recorded in the round's calibration file and adjusted by the pass below:

| Signal | Threshold | Role |
|---|---|---|
| element displacement vs reference | ≤ 1.5 mm | decides |
| SSIM of the full page | ≥ 0.55 | floor — below it the page is `NÃO FIEL` regardless |
| bleed | coverage of the 3 mm bands | decides at the edges |

Calibrate before the first milestone, never during a round: take one pair the owner already called
faithful and one he already called wrong, measure both, set the threshold between the two values and
record both next to it. A threshold that passes the known-bad pair, or fails the known-good one, is
noise, and by the third round nobody reads it. Anti-aliasing and scrollbars are not divergences.

## Validator brief — 11 checks

Clean-context subagent, opus, effort medium, one per milestone round, receiving the reference paths,
the render paths and this list. Golden rule at the top of its prompt: **an image not seen is a check
not done** — no page turns `FIEL` without both images opened with `Read` in that session.

```
For each page, compare render against reference and report per item:
 1. page inventory — every reference page has a render, and no render is orphan
 2. block order — the sequence of blocks top to bottom is the reference's
 3. block position — origin of each block within ≤ 1.5 mm of the reference
 4. block size — width and height within ≤ 1.5 mm
 5. margins and gutters — the four margins and the column gutter, in mm
 6. baseline grid — first and last line of each column sit on the reference's grid
 7. typography — family, size, weight and case per role (title, body, caption, note)
 8. content — the text is the same text; no truncation, no placeholder, no lorem
 9. images and rules — present, cropped as in the reference, with the same aspect ratio
10. color and tone — fills and strokes by declared token, not by eye
11. bleed and safe area — nothing live outside the safe area, bleed covered in the 3 mm band
Not a divergence: anti-aliasing, hinting differences, scrollbars, cursor, selection highlight.
Verdict per page: FIEL | NÃO FIEL — <item n> — <what differs> — <measurement>
Return: the report path, pages FIEL n / NÃO FIEL n, and the failing lines only.
```

## Dispatch to the area owner

A divergence goes by `SendMessage` to the persistent agent that owns the area, never to a new one — it
already holds the code in context, and a fresh agent pays for that context again. The message carries a
pointer, not the report:

```
Round <n> of fidelity, area <engine|web|server>. An independent validator compared the render
against the reference and wrote <path>/REPORT.md (<n> screenshots, same paths).
NÃO FIEL: <page> — item <n> — <what differs> — <measured>
Fix and re-render the listed pages only. Reply: DONE / EVIDENCE / REFERENCE / PENDING.
```

Then re-render, re-run the gate, re-validate — with a validator that has not seen the previous round.

## `validation/E<n>/REPORT.md`

```
# Validation E<n> — <milestone> — <date>
gate: displacement ≤ 1.5 mm · SSIM ≥ 0.55 · bleed 3 mm      (<calibration file>)
| page | reference | render | displacement | SSIM | verdict | item |
| p-04 | ref/a/p-04.png | out/a/p-04.png | 0.4 mm | 0.91 | FIEL | — |
| p-07 | ref/a/p-07.png | out/a/p-07.png | 3.2 mm | 0.62 | NÃO FIEL | 3 — caption block 3.2 mm low |
FIEL <n>/<total> · rounds run: <n> · validator: <agent id, clean context>
Not covered: <pages not rendered this milestone, with why>
```

One report per round, appended as `E1 … En`, never rewritten — the sequence is the evidence the loop
converged, and the milestone's closing commit cites the path. Goldens are recorded only after the
milestone reads `FIEL` on every page; one taken from an unvalidated render freezes the defect in.

At the end of each wave, stop the agents whose area is closed — nothing else ends a background watcher,
and they outlive the round. `TaskOutput {block:true}` is the wait; a Bash polling loop is not.
