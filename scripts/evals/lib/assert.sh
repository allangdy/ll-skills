#!/usr/bin/env bash
# Sourced by every cases/<id>/assert.sh.
#
# Contract of an assert script:
#   bash assert.sh <workdir> <out.json> <out.txt>   -> exit 0 pass, 1 fail
# It prints one line per check: "ok: <what>" or "FAIL: <what>".
# run.sh reads the first FAIL line into the results table.
#
# Provided helpers:
#   ok <msg>                     record a passed check
#   fail <msg>                   record a failed check
#   check <cond-exit> <msg>      record from an exit code already computed
#   contains <file> <regex> <msg>    grep -Eq
#   absent <file> <regex> <msg>      grep -Eq must not match
#   no_path <path> <msg>         path must not exist
#   no_tool_use <out.json> <tool-name> <msg>   no tool_use block named <tool-name> anywhere
#   finish                       exit with the verdict

EVAL_FAILURES=0

ok()   { printf 'ok: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1"; EVAL_FAILURES=$((EVAL_FAILURES + 1)); }

check() { # check <exit-code> <msg>
  if [ "$1" -eq 0 ]; then ok "$2"; else fail "$2"; fi
}

contains() { # contains <file> <extended-regex> <msg>
  if [ -f "$1" ] && grep -Eq -- "$2" "$1"; then ok "$3"; else fail "$3"; fi
}

absent() { # absent <file> <extended-regex> <msg>
  if [ ! -f "$1" ] || ! grep -Eq -- "$2" "$1"; then ok "$3"; else fail "$3"; fi
}

no_path() { # no_path <path> <msg>
  if [ ! -e "$1" ]; then ok "$2"; else fail "$2"; fi
}

first_line() { # first_line <file> -> first non-empty line
  [ -f "$1" ] || return 0
  grep -m1 -v '^[[:space:]]*$' "$1" 2>/dev/null || true
}

# The regime is stated "before doing anything": it belongs to the first assistant
# message of the run, not to the final answer. This reads it out of the capture.
first_text() { # first_text <out.json> -> the whole first assistant message
  node "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/extract.js" "$1" first_text 2>/dev/null || true
}

first_text_line() { # first_text_line <out.json> -> first non-empty line of the first assistant text
  first_text "$1" | grep -m1 -v '^[[:space:]]*$' || true
}

first_text_contains() { # first_text_contains <out.json> <extended-regex> <msg>
  if first_text "$1" | grep -Eq -- "$2"; then ok "$3"; else fail "$3"; fi
}

# no_tool_use <out.json> <tool-name> <msg>
# Scans every assistant event's message.content for a tool_use block whose
# `name` equals <tool-name>. Passes when none is found; fails naming the
# first hit (the manual contract: no skill is started by a tool call).
no_tool_use() {
  local file="$1" name="$2" msg="$3" hit
  hit="$(node -e '
    const fs = require("fs");
    let data;
    try { data = JSON.parse(fs.readFileSync(process.argv[1], "utf8")); }
    catch { process.exit(0); }
    const events = Array.isArray(data) ? data : [data];
    const wanted = process.argv[2];
    for (const ev of events) {
      if (!ev || ev.type !== "assistant") continue;
      const content = ev.message && ev.message.content;
      if (!Array.isArray(content)) continue;
      for (const b of content) {
        if (b && b.type === "tool_use" && b.name === wanted) {
          process.stdout.write(b.name);
          process.exit(0);
        }
      }
    }
  ' "$file" "$name" 2>/dev/null)"
  if [ -z "$hit" ]; then ok "$msg"; else fail "$msg: found a $hit tool_use call"; fi
}

base_sha() { # base_sha <workdir> -> the HEAD recorded before the run, or empty
  [ -f "$1/.eval-base-sha" ] && cat "$1/.eval-base-sha"
}

finish() {
  if [ "$EVAL_FAILURES" -eq 0 ]; then exit 0; fi
  exit 1
}
