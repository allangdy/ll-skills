#!/usr/bin/env bash
# Deterministic lint over the prompt texts: skill frontmatter (every skill locked
# with disable-model-invocation: true and a plain one-line description, 60-300
# chars, no trigger phrase), agent frontmatter, line ceilings and the preamble
# without a router, section shape, forbidden strings, identical copies, language
# an optional private word list and plain questions (no band label, decision id,
# question id or assumption id on a question header or a count line, and no
# Portuguese band label anywhere in the prose). One line per rule; exit 1 on any FAIL.
# Usage: lint-prompts.sh [--rule N]   (no flag runs every rule)
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

exec python3 - "$ROOT" "${@}" <<'PYTHON'
import fnmatch, hashlib, json, os, re, subprocess, sys

ROOT = sys.argv[1]

# Skills that write no repository file: no Deliverables table.
EXCEPT_DELIVERABLES = ["ll-resume", "ll-update"]
# Skills whose step-by-step section carries another heading.
EXCEPT_FLOW = ["ll-resume"]
# Skills with no closing section on disk today.
EXCEPT_COMPLETION = []
# Files written in Portuguese by design.
EXCEPT_LANGUAGE = ["scripts/smoke-test.sh"]
EXCEPT_LANGUAGE_GLOB = ["scripts/evals/cases/*/prompt.txt"]  # owner-shaped inputs, Portuguese by design

FORBIDDEN = ["MUST", "CRITICAL", "verify carefully", "as discussed", "IMPORTANT:"]
ALLOWED_TOOLS = "Bash(${CLAUDE_SKILL_DIR}/scripts/ll-tools.js *)"
# A skill that ships its own helper declares it here; every other skill gets ALLOWED_TOOLS.
ALLOWED_TOOLS_BY_SKILL = {"ll-auto": "Bash(${CLAUDE_SKILL_DIR}/scripts/ll-auto.js *)"}
# The one skill that follows another skill's instructions, and only while the owner typed it.
ORCHESTRATOR = ["ll-auto"]
# Strings the global preamble must not carry: they route a request to a skill.
PREAMBLE_FORBIDDEN = ["Route every request", "One word from the owner"]
# Rule 9 — the owner's screen carries no internal vocabulary (DEC-0018): a question
# header or a count line never names a band, a decision id or an assumption id, and
# the retired count wording is gone from the prose.
QUESTION_LINE = re.compile(r"Pergunta [0-9]+/|Question [0-9]+/|questions asked|perguntas [0-9N]+")
JARGON = ["band-1", "[DEC-", "[D-", "[PG-", "ASM-"]
OLD_COUNT = "band-1 open"
# The same label in Portuguese is never on the owner's screen, question line or not.
BAND_PT = re.compile(r"banda[ -]1", re.IGNORECASE)
BAND_PT_TREES = ("skills", "agents", "assets")

PT = re.compile(r"[ãõçáéíóúâêô"
                r"ÃÕÇÁÉÍÓÚÂÊÔ]")

rule_arg = None
if "--rule" in sys.argv:
    rule_arg = int(sys.argv[sys.argv.index("--rule") + 1])

def sh(args, cwd=ROOT):
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True)

TRACKED = sh(["git", "ls-files"]).stdout.split()

def path(rel):
    return os.path.join(ROOT, rel)

def read(rel):
    with open(path(rel), encoding="utf-8") as fh:
        return fh.read()

def under(prefix):
    return [f for f in TRACKED if f.startswith(prefix)]

SKILLS = sorted(f for f in TRACKED if re.fullmatch(r"skills/[^/]+/SKILL\.md", f))
AGENTS = sorted(f for f in TRACKED if re.fullmatch(r"agents/[^/]+\.md", f))
SKILL_NAMES = [f.split("/")[1] for f in SKILLS]

try:
    import yaml
except ImportError:
    yaml = None

def strip_comment(value):
    quote = None
    for i, ch in enumerate(value):
        if quote:
            if ch == quote and value[i - 1] != "\\":
                quote = None
        elif ch in "\"'":
            quote = ch
        elif ch == "#" and (i == 0 or value[i - 1] in " \t"):
            return value[:i]
    return value

def unquote(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        body = value[1:-1]
        if value[0] == '"':
            body = body.replace('\\"', '"').replace("\\\\", "\\")
        return body
    return value

def mini_yaml(block):
    out = {}
    for line in block.split("\n"):
        if not line.strip() or line.lstrip().startswith("#") or line[0] in " \t":
            continue
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        out[key.strip()] = unquote(strip_comment(value).strip())
    return out

def frontmatter(text):
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return None, None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            block = "\n".join(lines[1:i])
            body = "\n".join(lines[i + 1:])
            if yaml is not None:
                try:
                    data = yaml.safe_load(block)
                    if isinstance(data, dict):
                        return {str(k): v for k, v in data.items()}, body
                except Exception:
                    return None, body
            return mini_yaml(block), body
    return None, None

def body_start(text):
    lines = text.split("\n")
    if lines and lines[0].strip() == "---":
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                return i + 1
    return 0

def truthy(value):
    return str(value).strip().lower() in ("true", "yes")

def rule1():
    bad = []
    for f in SKILLS:
        name = f.split("/")[1]
        fm, _ = frontmatter(read(f))
        if fm is None:
            bad.append((f, "frontmatter does not parse"))
            continue
        if fm.get("name") != name:
            bad.append((f, "name is %r, directory is %r" % (fm.get("name"), name)))
        desc = str(fm.get("description", ""))
        if not 60 <= len(desc) <= 300:
            bad.append((f, "description is %d chars, expected 60-300" % len(desc)))
        first = desc.split(" ")[0] if desc else ""
        if not re.fullmatch(r"[A-Z][a-z]+s", first):
            bad.append((f, "description starts with %r, expected a third-person verb" % first))
        if "Use when" in desc:
            bad.append((f, "description carries a trigger phrase (\"Use when\")"))
        if "\n" in desc.strip():
            bad.append((f, "description is not one line"))
        if not str(fm.get("argument-hint", "")).strip():
            bad.append((f, "argument-hint missing"))
        expected = ALLOWED_TOOLS_BY_SKILL.get(name, ALLOWED_TOOLS)
        if "allowed-tools" in fm and str(fm["allowed-tools"]) != expected:
            bad.append((f, "allowed-tools is %r, expected %r" % (str(fm["allowed-tools"]), expected)))
        declared = "disable-model-invocation" in fm and truthy(fm["disable-model-invocation"])
        if not declared:
            bad.append((f, "disable-model-invocation: true missing"))
        for key in ("model", "effort", "context"):
            if key in fm:
                bad.append((f, "%s: is not a skill frontmatter key" % key))
    return bad, len(SKILLS)

def rule2():
    bad = []
    for f in AGENTS:
        name = os.path.basename(f)[:-3]
        fm, _ = frontmatter(read(f))
        if fm is None:
            bad.append((f, "frontmatter does not parse"))
            continue
        if fm.get("name") != name:
            bad.append((f, "name is %r, file is %r" % (fm.get("name"), name)))
        model = str(fm.get("model", "")).strip()
        if model not in ("sonnet", "opus"):
            bad.append((f, "model is %r, expected sonnet or opus" % model))
        if re.search(r"\bAgent\b", str(fm.get("tools", ""))):
            bad.append((f, "tools grants Agent"))
        turns = str(fm.get("maxTurns", "")).strip()
        if not turns.isdigit():
            bad.append((f, "maxTurns is %r, expected an integer" % turns))
    return bad, len(AGENTS)

def rule3():
    bad = []
    checked = 0
    ceilings = [(f, 200) for f in SKILLS]
    ceilings += [(f, 160) for f in AGENTS]
    ceilings += [(f, 150) for f in TRACKED
                 if re.fullmatch(r"skills/[^/]+/references/[^/]+\.md", f)]
    for f, cap in ceilings:
        checked += 1
        n = len(read(f).split("\n")) - 1
        if n > cap:
            bad.append((f, "%d lines, ceiling %d" % (n, cap)))
    checked += 1
    preamble = read("assets/preamble.md")
    n = len(preamble.split("\n")) - 1
    if n > 70:
        bad.append(("assets/preamble.md", "%d lines, ceiling 70" % n))
    checked += 1
    routing = [w for w in PREAMBLE_FORBIDDEN if w in preamble]
    if routing:
        bad.append(("assets/preamble.md",
                    "routes to a skill: contains %s" % ", ".join(repr(w) for w in routing)))
    checked += 1
    helper = read("scripts/ll-tools.js")
    hn = len(helper.split("\n")) - 1
    hb = os.path.getsize(path("scripts/ll-tools.js"))
    if hn > 760:
        bad.append(("scripts/ll-tools.js", "%d lines, ceiling 760" % hn))
    if hb > 36000:
        bad.append(("scripts/ll-tools.js", "%d bytes, ceiling 36000" % hb))
    checked += 1
    pack_json_override = os.environ.get("LL_PACK_JSON")
    if pack_json_override:
        with open(pack_json_override, encoding="utf-8") as fh:
            out = fh.read()
    else:
        out = sh(["npm", "pack", "--dry-run", "--json"]).stdout
    starts = [i for i in (out.find("["), out.find("{")) if i != -1]
    start = min(starts) if starts else -1
    try:
        data = json.loads(out[start:])
        # npm <= 11 prints a list; npm 12 prints an object keyed by package name.
        if isinstance(data, list):
            entry = data[0]
        elif isinstance(data, dict):
            pkg_name = json.loads(read("package.json"))["name"]
            entry = data[pkg_name] if pkg_name in data else next(iter(data.values()))
        else:
            raise ValueError("unexpected npm pack --dry-run --json shape")
        size = entry["unpackedSize"]
    except Exception:
        bad.append(("package.json", "npm pack --dry-run --json did not report unpackedSize"))
    else:
        if size > 921600:
            bad.append(("package.json", "unpackedSize %d bytes, ceiling 921600" % size))
    return bad, checked

def sections(body):
    out = {}
    current = None
    for line in body.split("\n"):
        if line.startswith("## "):
            current = line[3:].strip()
            out[current] = []
        elif current is not None:
            out[current].append(line)
    return {k: "\n".join(v) for k, v in out.items()}

def sec_get(sec, *names):
    # a heading may be qualified by a mode: "## Flow — project"
    found = [body for heading, body in sec.items()
             if any(heading == n or heading.startswith(n + " ") for n in names)]
    return "\n".join(found) if found else None

def rule4():
    bad = []
    for f in SKILLS:
        name = f.split("/")[1]
        _, body = frontmatter(read(f))
        body = body or ""
        sec = sections(body)
        if name not in EXCEPT_DELIVERABLES:
            deliverables = sec_get(sec, "Deliverables")
            if deliverables is None:
                bad.append((f, "no ## Deliverables"))
            elif "| File | Role | Mutability |" not in deliverables:
                bad.append((f, "Deliverables has no | File | Role | Mutability | header"))
        if name not in EXCEPT_FLOW and sec_get(sec, "Flow") is None:
            bad.append((f, "no ## Flow"))
        if name not in EXCEPT_COMPLETION:
            # the closing section carries either heading
            closing = sec_get(sec, "Completion criterion", "Closing criterion")
            if closing is None:
                bad.append((f, "no ## Completion criterion"))
            elif "▶ Next —" not in closing:
                bad.append((f, "Completion criterion has no ▶ Next —"))
        if under("skills/%s/references/" % name) and sec_get(sec, "References") is None:
            bad.append((f, "no ## References while references/ has files"))
    return bad, len(SKILLS)

def rule5():
    files = [f for f in TRACKED
             if f.startswith("skills/") or f.startswith("agents/")] + ["assets/preamble.md"]
    files = sorted(set(files))
    bad = []
    invoke = re.compile(r"run `(ll-[a-z-]+)`")
    for f in files:
        text = read(f)
        for i, line in enumerate(text.split("\n"), 1):
            for word in FORBIDDEN:
                if word in line:
                    bad.append((f, "line %d contains %r" % (i, word)))
        if not f.endswith("SKILL.md"):
            continue
        if "Skill(" in text:
            bad.append((f, "contains Skill("))
        # The orchestrator names the other skills' commands; nobody else may.
        if f.split("/")[1] in ORCHESTRATOR:
            continue
        for i, line in enumerate(text.split("\n")[body_start(text):], body_start(text) + 1):
            if "▶ Next" in line:
                continue
            if re.match(r"^\s*/ll-", line):
                bad.append((f, "line %d invokes a skill as a command" % i))
            for hit in invoke.findall(line):
                if hit in SKILL_NAMES:
                    bad.append((f, "line %d tells the session to run `%s`" % (i, hit)))
    return bad, len(files)

def region(rel):
    keep, out = False, []
    for line in read(rel).split("\n"):
        if line.strip() == "// <ll-shared:state>":
            keep = True
        if keep:
            out.append(line)
        if line.strip() == "// </ll-shared:state>":
            keep = False
    return "\n".join(out)

def rule6():
    bad = []
    copies = sorted(f for f in TRACKED
                    if re.fullmatch(r"skills/[^/]+/references/decision-policy\.md", f))
    if len(copies) != 3:
        bad.append(("skills/*/references/decision-policy.md", "%d copies, expected 3" % len(copies)))
    digests = {f: hashlib.md5(read(f).encode("utf-8")).hexdigest() for f in copies}
    if len(set(digests.values())) > 1:
        for f, d in sorted(digests.items()):
            bad.append((f, "md5 %s differs from the other copies" % d))
    a, b = region("scripts/ll-tools.js"), region("hooks/ll-state.js")
    if not a or not b:
        bad.append(("scripts/ll-tools.js", "ll-shared:state region is empty in one of the two files"))
    elif a != b:
        bad.append(("hooks/ll-state.js", "ll-shared:state region differs from scripts/ll-tools.js"))
    return bad, len(copies) + 2

def rule7():
    files = [f for f in TRACKED
             if f.split("/")[0] in ("skills", "agents", "assets", "hooks", "scripts")
             and not f.startswith("scripts/fixtures/")
             and f not in EXCEPT_LANGUAGE
             and not any(fnmatch.fnmatch(f, g) for g in EXCEPT_LANGUAGE_GLOB)]
    bad = []
    for f in sorted(files):
        fenced = False
        for i, line in enumerate(read(f).split("\n"), 1):
            if f.endswith(".md") and line.strip().startswith("```"):
                fenced = not fenced
                continue
            if fenced:
                continue
            if PT.search(line) and '"' not in line and "`" not in line:
                bad.append((f, "line %d is unquoted Portuguese prose" % i))
    return bad, len(files)

def rule8():
    words = os.environ.get("LL_FORBIDDEN_FILE", "")
    if not words or not os.access(words, os.R_OK):
        print("skip private word list (LL_FORBIDDEN_FILE unset)")
        return None, 0
    files = [f for f in TRACKED if f != ".gitignore"]
    res = sh(["grep", "-n", "-i", "-w", "-E", "-f", words] + files)
    bad = []
    for line in res.stdout.split("\n"):
        if not line.strip():
            continue
        parts = line.split(":", 2)
        bad.append((parts[0], "line %s matches the private word list" % (parts[1] if len(parts) > 1 else "?")))
    return bad, len(files)

def rule9():
    # The prose the owner reads. Fixtures are exempt: scripts/fixtures/*/PROGRESS.md
    # keeps the old wording as the proof that a 3.0.0 file still parses.
    prose = [f for f in TRACKED
             if f.split("/")[0] in ("skills", "agents", "assets")
             or f.startswith("scripts/evals/cases/")]
    # The helper is scanned for the retired wording only: its epilogue regex reads both
    # spellings on purpose, so the alternation is not a question line on anyone's screen.
    # An eval assert is not a screen: it names the forbidden id inside the pattern it
    # scores, so the question-line scan skips it. The retired count wording is still
    # scanned there, and in the helper, for everyone.
    files = sorted(f for f in set(prose)
                   if not re.fullmatch(r"scripts/evals/cases/[^/]+/assert\.sh", f))
    extra = sorted(f for f in set(prose) if f not in files)
    bad = []
    for f in files + extra + ["scripts/ll-tools.js"]:
        # The Portuguese label is prose the owner reads: scanned over skills/, agents/ and
        # assets/ whole, not only on a question line, and not over the helper.
        scan_band = f.split("/")[0] in BAND_PT_TREES
        for i, line in enumerate(read(f).split("\n"), 1):
            if OLD_COUNT in line:
                bad.append((f, "line %d: the retired count wording %r is still here" % (i, OLD_COUNT)))
            if scan_band:
                hit = BAND_PT.search(line)
                if hit:
                    bad.append((f, "line %d: the internal label %r is on the owner's screen"
                                % (i, hit.group(0))))
            if f not in files or not QUESTION_LINE.search(line):
                continue
            for word in JARGON:
                if word in line:
                    bad.append((f, "line %d: a question or count line names %r" % (i, word)))
    return bad, len(files) + len(extra) + 1

RULES = [
    (1, "skill frontmatter", rule1),
    (2, "agent frontmatter", rule2),
    (3, "line ceilings", rule3),
    (4, "skill shape", rule4),
    (5, "forbidden strings", rule5),
    (6, "identical copies", rule6),
    (7, "language", rule7),
    (8, "private word list", rule8),
    (9, "plain questions", rule9),
]

failed = False
for number, label, fn in RULES:
    if rule_arg is not None and rule_arg != number:
        continue
    bad, n = fn()
    if bad is None:
        continue
    if bad:
        failed = True
        for f, detail in bad:
            print("FAIL %d %s: %s: %s" % (number, label, f, detail))
    else:
        print("ok   %d %s (%d files)" % (number, label, n))

sys.exit(1 if failed else 0)
PYTHON
