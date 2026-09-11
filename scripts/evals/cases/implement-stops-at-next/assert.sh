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

# The waves are visible while they run, not only in the epilogue (F-4).
# The wave line is printed mid-run, so it lives in an earlier assistant text block, not in the final
# answer: scan the capture in order and map it onto the same scale as the epilogue check.
onda="$(node -e '
  const fs = require("fs");
  let data; try { data = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); } catch { process.exit(0); }
  const events = Array.isArray(data) ? data : [data];
  let n = 0, hit = 0, epi = 0;
  for (const ev of events) {
    if (!ev || ev.type !== "assistant") continue;
    const content = ev.message && ev.message.content;
    if (!Array.isArray(content)) continue;
    for (const b of content) {
      if (!b) continue;
      // a one-shot run prints no mid-run text: the wave heartbeat is the proxy; the screen line is checked by the lab rubric
      if (b.type === "tool_use" && !hit && /heartbeat\s+\\?"(wave|onda) 1\//.test(JSON.stringify(b.input || {}))) hit = n + 1;
      if (b.type !== "text") continue;
      n++;
      if (!hit && /(^|\n)onda 1\//.test(b.text || "")) hit = n;
      if (!epi && /## Epilogue|▶ Next/.test(b.text || "")) epi = n;
    }
  }
  if (hit) process.stdout.write(String(hit));
' "$OUT_JSON")"
close_block="$(node -e '
  const fs = require("fs");
  let data; try { data = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); } catch { process.exit(0); }
  const events = Array.isArray(data) ? data : [data];
  let n = 0;
  for (const ev of events) {
    if (!ev || ev.type !== "assistant") continue;
    const content = ev.message && ev.message.content;
    if (!Array.isArray(content)) continue;
    for (const b of content) {
      if (!b || b.type !== "text") continue;
      n++;
      if (/## Epilogue|▶ Next/.test(b.text || "")) { process.stdout.write(String(n)); process.exit(0); }
    }
  }
' "$OUT_JSON")"
close="$(grep -nE '^## Epilogue|▶ Next' "$OUT_TXT" | head -1 | cut -d: -f1)"
if [ -z "$onda" ]; then
  fail 'no "onda 1/M" line: the first wave ran with no visible progress'
elif [ -n "$close_block" ] && [ "$onda" -gt "$close_block" ]; then
  fail "the onda 1/M line (text block $onda) comes only after the epilogue (text block $close_block)"
else
  ok "the first wave is announced on screen (line $onda), before the epilogue"
fi

# The helper is called, never read (F-7): no shell that cats/seds/greps it, no Read of it.
reads="$(node -e '
  const fs = require("fs");
  let data; try { data = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); }
  catch { process.stdout.write("unparseable out.json"); process.exit(0); }
  const events = Array.isArray(data) ? data : [data];
  const shell = /(^|[\s;|&(])(cat|sed|grep|head|tail|less)\b[^\n;|&]*ll-tools\.js/; // the reading verb starts a command and the helper is its argument
  for (const ev of events) {
    if (!ev || ev.type !== "assistant") continue;
    const content = ev.message && ev.message.content;
    if (!Array.isArray(content)) continue;
    for (const b of content) {
      if (!b || b.type !== "tool_use") continue;
      const input = b.input || {};
      if (b.name === "Bash" && shell.test(String(input.command || ""))) {
        process.stdout.write("a Bash call reads the helper: " + String(input.command).slice(0, 80));
        process.exit(0);
      }
      if (b.name === "Read" && /ll-tools\.js$/.test(String(input.file_path || ""))) {
        process.stdout.write("a Read call opens the helper: " + String(input.file_path));
        process.exit(0);
      }
    }
  }
  process.stdout.write("");
' "$OUT_JSON")"

if [ -z "$reads" ]; then
  ok 'the helper was called, never read'
else
  fail "$reads"
fi

finish
