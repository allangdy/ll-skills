# Changelog

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/). A skill `ll-atualizar` lê este arquivo para mostrar o que mudou entre a versão instalada e a publicada.

## [1.0.1] - 2026-09-07

### Adicionado

- Publicação no npm pela CI via Trusted Publishing (`.github/workflows/publish.yml`): tag `vX.Y.Z` confere tag × package.json × CHANGELOG, roda o smoke test e publica com proveniência.
- `npm test` roda `scripts/smoke-test.sh`, que instala num `CLAUDE_CONFIG_DIR` isolado e verifica poda, preservação de hooks alheios, idempotência, hook de aviso e `--uninstall`.

### Alterado

- README: rotina de release com `npm version` + `git push --follow-tags`.

## [1.0.0] - 2026-09-06

### Alterado

- Distribuição passa de plugin/marketplace para pacote npm: `npx ll-skills@latest` instala skills standalone em `~/.claude/skills/`, sem o prefixo `ll-skills:`.
- Skills renomeadas para `ll-<nome>` (`ll-pesquisar-mercado`, `ll-voltar-do-futuro`, `ll-desarmar`, `ll-decidir-antes`, `ll-verificar-entrega`, `ll-pesquisar`, `ll-orquestrar`, `ll-atualizar`); agente renomeado para `ll-implementador`.
- Instalador limpa a instalação anterior: desinstala o plugin legado `ll-skills@ll-skills`, poda arquivos órfãos de instalações standalone anteriores e apaga o cache antigo.
- Hook de aviso de atualização reescrito em Node; compara a versão instalada com a publicada no npm.
- `ll-atualizar` passa a rodar `npx --yes ll-skills@latest` e mostra o changelog a partir deste arquivo.

### Removido

- Manifesto de plugin (`.claude-plugin/`) e `hooks/hooks.json`.
