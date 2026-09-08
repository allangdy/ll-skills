---
name: ll-update
description: Updates the installed ll-skills package to the latest published version — reads the installed and published versions, shows the CHANGELOG entries between them before touching anything, asks once, runs the installer and reports which skills changed. Use when the owner says "atualiza o ll-skills", "atualizar as skills", "tem versão nova do ll-skills?", or when the session warning says "ll-skills desatualizado (instalado X, disponível Y) — rode /ll-update". It installs nothing else — every mutation goes through the package installer, and no project file is touched.
argument-hint: "[--no-preamble]"
disable-model-invocation: true
---

# Update

Compare the installed version with the published one, show what changed between them, ask once,
then let `npx ll-skills@latest` perform every mutation. Nothing under the config dir —
`skills/ll-*`, `ll-skills/`, `settings.json`, `CLAUDE.md` — is edited by hand. Reply to the owner
in Portuguese.

## Flow

**1. Versions.** One Bash call:

```bash
D="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/ll-skills"
cat "$D/VERSION"; npm view ll-skills version
grep -o '"skills/[^/]*/' "$D/manifest.json" | cut -d/ -f2 | sort -u
```

No `VERSION`: ll-skills was not installed by this mechanism — say so, point at
`npx ll-skills@latest`, stop. No network or npm answers `E404`: say the registry could not be
read and stop, without guessing a version. Same version on both sides: say it is already on the
latest, name it, end here. Otherwise keep that skill list for step 5.

**2. Changelog.**

```bash
curl -sf https://raw.githubusercontent.com/allangdy/ll-skills/main/CHANGELOG.md
```

Keep a Changelog format: one `## [x.y.z] - date` section per version, newest first. Show only the
sections above the installed version and up to the published one, oldest to newest. If the fetch
fails, continue and say the changelog could not be loaded.

**3. Ask once.** A single AskUserQuestion with three options: apply, apply without the preamble
(`--no-preamble`), not now. Say what the preamble is when offering it — the installer writes a
block between `<!-- ll-skills:preamble v1 -->` and `<!-- /ll-skills:preamble -->` in
`~/.claude/CLAUDE.md`, replacing only that range and backing the file up to
`CLAUDE.md.ll-skills.bak`; `--no-preamble` installs skills, hooks and state only. The suggested
settings policy is printed by the installer either way and never written.

**4. Apply.**

```bash
npx --yes ll-skills@latest --yes          # append --no-preamble when chosen
```

The outer `--yes` belongs to npx (fetch the package without prompting); the inner one to the
installer — this session is not a TTY, and without it the installer prints the preamble diff and
writes nothing. Show the installer output as it came. On failure, show the error and stop; do not
work around it by copying files.

**5. Preamble.** If the output carries a preamble diff, show that diff and say whether it was
written, left unchanged, declined or refused (a half-block with one sentinel missing is refused
and the installer prints the snippet instead). Text outside the sentinels is untouched.

**6. Report.** Re-read `VERSION`, and re-read `manifest.json` with the same `grep` from step 1.
Report: old version → new version; a summary of the changelog entries applied; skills added,
removed and kept, from the two lists; the preamble outcome; and that the current session still
carries the old skills — new or renamed skills appear after restarting Claude Code, while edited
content of an existing skill is read on its next invocation. If `VERSION` did not change, say
that instead of declaring success.

## Migration from 1.x

The first 2.x install removes the eight Portuguese skills — `ll-orquestrar`, `ll-pesquisar`,
`ll-pesquisar-mercado`, `ll-decidir-antes`, `ll-desarmar`, `ll-voltar-do-futuro`,
`ll-verificar-entrega`, `ll-atualizar` — and `agents/ll-implementador.md`, by manifest, and by
name when no manifest is present. Nothing else to do: no project file is touched, and the
CHANGELOG 2.0.0 table maps each old name to its replacement.
