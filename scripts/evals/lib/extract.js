#!/usr/bin/env node
'use strict';

// Reads one field of the `type: "result"` element of a `claude --output-format json`
// capture. The capture is either a single object or an array of events
// (system/init … assistant … result); only the result element carries the totals.
//
//   node extract.js <out.json> [field]     field defaults to "result"
//
// Exits 1 when the file is not JSON or has no result element, so the caller can
// tell "the run produced nothing" from "the run produced an empty answer".

const fs = require('fs');

const file = process.argv[2];
const field = process.argv[3] || 'result';

let raw;
try {
  raw = fs.readFileSync(file, 'utf8');
} catch (e) {
  process.stderr.write(`extract: cannot read ${file}: ${e.message}\n`);
  process.exit(1);
}

let data;
try {
  data = JSON.parse(raw);
} catch {
  process.stderr.write(`extract: ${file} is not valid JSON\n`);
  process.exit(1);
}

const events = Array.isArray(data) ? data : [data];

const assistantTexts = () => {
  const out = [];
  for (const ev of events) {
    if (!ev || ev.type !== 'assistant') continue;
    const content = ev.message && ev.message.content;
    if (!Array.isArray(content)) continue;
    const t = content.filter((b) => b && b.type === 'text').map((b) => b.text).join('\n');
    if (t.trim()) out.push(t);
  }
  return out;
};

// Pseudo-field: the first non-empty assistant message. The regime line is stated
// "before doing anything", so it lives in the first turn, not in the final result.
// Needs --verbose on the run, without which the capture holds only the result element.
if (field === 'first_text') {
  const texts = assistantTexts();
  process.stdout.write(texts.length ? texts[0] : '');
  process.exit(0);
}

const result = events.find((e) => e && e.type === 'result');
if (!result) {
  process.stderr.write(`extract: no element with type "result" in ${file}\n`);
  process.exit(1);
}

let value = result[field];

// A run stopped by --max-turns closes with subtype "error_max_turns" and no usable
// `result`, even though assistant text was produced. Fall back to the text blocks of the
// last assistant message so the case is scored on what the session actually said.
if (field === 'result' && (value === undefined || value === null || value === 'undefined')) {
  const texts = assistantTexts();
  value = texts.length ? texts[texts.length - 1] : '';
}

process.stdout.write(value === undefined || value === null ? '' : String(value));
