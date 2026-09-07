---
name: ll-atualizar
description: Atualiza o ll-skills para a última versão publicada, mostrando o changelog do que mudou antes de aplicar. Use quando o pedido for "atualizar o ll-skills", "atualiza as skills", "ll-skills desatualizado", "tem versão nova do ll-skills?" ou quando o aviso de sessão disser que o ll-skills está desatualizado.
---

# Atualizar o ll-skills

O ll-skills é distribuído como pacote npm e instalado por `npx ll-skills@latest`, que copia
as skills `ll-*` para `~/.claude/skills/` e grava a versão instalada. Este fluxo compara a
versão instalada com a publicada, mostra o que mudou entre elas e aplica a atualização
rodando o instalador de novo.

Toda mutação acontece pelo instalador. Nada em `~/.claude/skills/ll-*`, `~/.claude/ll-skills/`
ou `~/.claude/settings.json` é editado à mão.

## 1. Versão instalada

```bash
cat "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/ll-skills/VERSION"
```

Se o arquivo não existir, o ll-skills não está instalado por este mecanismo. Diga isso,
indique `npx ll-skills@latest` e pare.

## 2. Versão publicada

```bash
npm view ll-skills version
```

Sem rede, ou se o npm devolver `E404` (pacote ainda não publicado): diga que não deu para
consultar o registro e pare — não adivinhe.

**Se as versões coincidirem**: diga que o ll-skills já está na última versão, cite a
versão, e encerre. Nada mais a fazer.

## 3. Changelog

```bash
curl -sf https://raw.githubusercontent.com/allangdy/ll-skills/main/CHANGELOG.md
```

O arquivo segue Keep a Changelog: uma seção `## [x.y.z] - data` por versão, da mais nova
para a mais antiga. Mostre apenas as seções com versão maior que a instalada e menor ou
igual à publicada, do mais antigo ao mais recente. Se a chamada falhar, siga para a
atualização avisando que o changelog não pôde ser carregado.

## 4. Aplicar

```bash
npx --yes ll-skills@latest
```

O instalador sobrescreve as skills, poda arquivos órfãos da versão anterior, atualiza o
hook de aviso e regrava `VERSION`. Se falhar, mostre a saída de erro e pare — não tente
contornar copiando arquivos à mão.

## 5. Confirmar e encerrar

Releia `VERSION` e confirme que agora bate com a versão publicada. Reporte:

- versão antiga → versão nova
- resumo do changelog aplicado
- que a sessão atual ainda carrega as skills antigas: skills novas ou renomeadas só
  aparecem depois de reiniciar o Claude Code (conteúdo alterado de uma skill que já
  existia é lido na próxima invocação)

Se `VERSION` não mudou, diga isso claramente em vez de declarar sucesso.
