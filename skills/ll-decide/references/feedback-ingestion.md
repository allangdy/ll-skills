# Feedback ingestion — recipes, inventory, anchoring, veracity

Read at feedback steps 1–4. The material is taken apart, not read: a `.docx` read as text loses
its comments, a PDF read as text loses its annotations, and an unreadable annotation that is
skipped is a decision the team made that nobody will implement. Ingestion runs on Sonnet in a
subagent when the material exceeds ~10 pages; the session reads only the inventory it returns.
Working directory: `<scratchpad>/feedback/<name>/`; nothing from it is committed.

## .docx — comments with their anchor text
```
unzip -o -q "<file>.docx" -d "<dir>/docx"
python3 - "<dir>/docx" <<'PY'
import re, sys, html
d = sys.argv[1]; T = lambda s: html.unescape(re.sub(r'<[^>]+>', '', s))
doc = open(f'{d}/word/document.xml', encoding='utf-8').read()
try: com = open(f'{d}/word/comments.xml', encoding='utf-8').read()
except FileNotFoundError: com = ''
comments = {m.group(1): T(m.group(2)) for m in re.finditer(r'<w:comment\b[^>]*\bw:id="(\d+)"[^>]*>(.*?)</w:comment>', com, re.S)}
for cid, text in comments.items():
    a = re.search(rf'<w:commentRangeStart\b[^>]*\bw:id="{cid}"[^>]*/>(.*?)<w:commentRangeEnd\b[^>]*\bw:id="{cid}"', doc, re.S)
    print(f'C{cid} | anchor: "{T(a.group(1))[:160] if a else "(no range)"}" | comment: {text}')
print(f'{len(comments)} comments')
PY
```
Attribute order inside `<w:comment>` varies between editors — the regexes above match by name,
not position (the first attempt in the real case failed on this). Images in `word/media/` are read
with the `Read` tool; the document body is read as text with `T(doc)` split on `</w:p>` when the
flow (which paragraph an image or comment sits in) matters.

## PDF — visual read
`Read` the file with `pages` (≤20 per call); annotations, highlights and hand-drawn marks live in
the rendered page, not in the text layer. For a page with many small marks: `pdftoppm -r 200 -f N
-l N -png "<file>.pdf" "<dir>/page"` and `Read` the PNG.

## .xlsx — cell dump
```
python3 - "<file>.xlsx" <<'PY'
import sys, openpyxl
wb = openpyxl.load_workbook(sys.argv[1], data_only=True)
for ws in wb:
    print(f'## {ws.title} ({ws.max_row}x{ws.max_column})')
    for row in ws.iter_rows(values_only=True):
        if any(c is not None for c in row): print(' | '.join('' if c is None else str(c) for c in row))
PY
```
Without openpyxl: `unzip -p "<file>.xlsx" xl/sharedStrings.xml | sed 's/<[^>]*>/ /g'` (strings only).

## Image the model cannot read
Crop the region and upscale before reading again — never guess the text:
```
python3 - "<in>.png" "<dir>/crop.png" X Y W H <<'PY'
import sys; from PIL import Image
i, o, x, y, w, h = sys.argv[1], sys.argv[2], *map(int, sys.argv[3:7])
Image.open(i).crop((x, y, x+w, y+h)).resize((w*3, h*3), Image.LANCZOS).save(o)
PY
```
A region still unreadable after two crops is inventoried as "illegible — asked".

## Inventory (the rule that nothing disappears)
Return one table before any question:
```
| id | source | kind (comment · annotation · cell · map item · illegible) | anchor text / location | proposal (verbatim) |
Total: N comments, M visual annotations, K items, J illegible.
```
The count is announced to the owner and reconciled at the end: decisions logged + deferred +
rejected = N + M + K + J. A mind-map or a list of bullets counts each leaf as an item.

## Anchoring in the code (Sonnet, automatic)
For each item: `file:line` of the current copy, price or element; the current value beside the
proposed one; the repo convention that binds it (a tracking parameter, a components' prop, a
price table). Searches run over the whole site, not only the page named — the same price or
claim usually lives in the menu, the hub, the README and a sibling page. An item with no anchor
is a question ("the review mentions X; I found no X — where does it live, or is it new?").

## Veracity gate
Before any question, list the factual claims the material introduces or changes: durations
("published in 30 minutes"), prices, counts, names, bios, credits, guarantees. Check each against
`PRODUCT.md`, the project CLAUDE.md, the code and the owner's memories. Output:
```
| claim | source in the material | what the product says (file:line) | status: matches · diverges · unknown |
```
Diverging and unknown claims are the first questions of the triage, ahead of money; the real case
had "livro publicado em 30 minutos" pass through a judge brief before the owner caught that only
the file is ready in 30 minutes. A brief that carried a wrong fact is rebuilt, not patched.

## Delivery format for humans
When the request names a recipient outside the session ("para o time", "compartilhar", a person's
name), ask the format once before building anything: `.xlsx`/`.csv` in `docs/` (recommended:
importable into Google Sheets, comes back filled), an artifact, an issue. The file is born in the
repo and committed; sending a copy is not the destination.
