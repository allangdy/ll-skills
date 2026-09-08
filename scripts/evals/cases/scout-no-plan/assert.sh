#!/usr/bin/env bash
# The scout writes CODE-CONTEXT.md within its cap and never opens the project PLAN.md.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"
CTX="$WORK/phases/07/CODE-CONTEXT.md"

if [ -f "$CTX" ]; then
  n="$(wc -l < "$CTX")"
  ok "phases/07/CODE-CONTEXT.md exists ($n lines)"
  if [ "$n" -le 120 ]; then ok "the file is within its 120-line cap"; else fail "CODE-CONTEXT.md has $n lines, cap is 120"; fi
else
  fail 'phases/07/CODE-CONTEXT.md was not written'
fi

# No Read tool_use whose file_path is the project PLAN.md at the root of the work tree.
offenders="$(node -e '
  const fs = require("fs");
  const work = process.argv[2];
  let data; try { data = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); } catch { process.exit(0); }
  const events = Array.isArray(data) ? data : [data];
  const hits = [];
  for (const ev of events) {
    const content = ev && ev.message && ev.message.content;
    if (!Array.isArray(content)) continue;
    for (const b of content) {
      if (!b || b.type !== "tool_use" || b.name !== "Read") continue;
      const p = (b.input && b.input.file_path) || "";
      if (p === work + "/PLAN.md" || p === "PLAN.md" || p === "./PLAN.md") hits.push(p);
    }
  }
  process.stdout.write(hits.join(" "));
' "$OUT_JSON" "$WORK")"

if [ -z "$offenders" ]; then
  ok 'no Read of the project PLAN.md at the work-tree root'
else
  fail "the scout read the project PLAN.md: $offenders"
fi

finish
