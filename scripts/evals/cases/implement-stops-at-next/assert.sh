#!/usr/bin/env bash
# "▶ Next" ends the turn: no tool call follows it.
. "$(cd "$(dirname "${BASH_SOURCE[0]}")/../../lib" && pwd)/assert.sh"

WORK="$1"; OUT_JSON="$2"; OUT_TXT="$3"

verdict="$(node -e '
  const fs = require("fs");
  let data; try { data = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); }
  catch { process.stdout.write("unparseable out.json"); process.exit(0); }
  const events = Array.isArray(data) ? data : [data];

  let nextAt = -1;          // index of the assistant text block carrying the marker
  let toolAfter = null;     // the first tool_use seen after it
  events.forEach((ev, i) => {
    if (!ev || ev.type !== "assistant") return;   // hook context and tool results are not assistant text
    const content = ev.message && ev.message.content;
    if (!Array.isArray(content)) return;
    for (const b of content) {
      if (!b) continue;
      if (b.type === "text" && /▶ Next/.test(b.text || "")) { if (nextAt < 0) nextAt = i; }
      else if (b.type === "tool_use" && nextAt >= 0 && !toolAfter) toolAfter = b.name;
    }
  });

  if (nextAt < 0) { process.stdout.write("no assistant text carries the ▶ Next marker"); process.exit(0); }
  if (toolAfter)  { process.stdout.write("a " + toolAfter + " tool call follows the ▶ Next line"); process.exit(0); }
  process.stdout.write("");
' "$OUT_JSON")"

if [ -z "$verdict" ]; then
  ok 'the ▶ Next line is the last thing the invocation does'
else
  fail "$verdict"
fi

contains "$OUT_TXT" '/clear' 'the next command is handed over with /clear'

finish
