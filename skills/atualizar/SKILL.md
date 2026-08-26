---
name: atualizar
description: Atualiza o plugin ll-skills para o último commit do repositório, mostrando o changelog do que mudou antes de aplicar. Use quando o pedido for "atualizar o plugin", "atualiza as skills", "ll-skills desatualizado", "tem versão nova do ll-skills?" ou quando o aviso de sessão disser que o plugin está desatualizado.
---

# Atualizar o plugin ll-skills

O ll-skills é distribuído por marketplace git e versionado por commit SHA — cada push é
uma versão. Este fluxo compara o SHA instalado com o SHA remoto, mostra o que mudou entre
eles e aplica a atualização pelo CLI oficial.

Toda mutação acontece via `claude plugin ...`. Nada dentro de `~/.claude/plugins/` é
editado, movido ou apagado à mão — nem o registro, nem o clone do marketplace, nem o
cache do plugin.

## 1. SHA instalado

A entrada `ll-skills@ll-skills` em `~/.claude/plugins/installed_plugins.json` é um array
com um objeto; `gitCommitSha` traz o SHA completo:

```bash
grep -A8 '"ll-skills@ll-skills"' ~/.claude/plugins/installed_plugins.json
```

Se `gitCommitSha` não aparecer, use o fallback do mesmo bloco: o basename de
`installPath` é o SHA curto (12 caracteres). Sem nenhum dos dois, diga que o plugin não
parece instalado por marketplace e pare.

## 2. SHA remoto

```bash
git ls-remote https://github.com/allangdy/ll-skills.git HEAD
```

Sem rede ou sem resposta: diga que não deu para consultar o remoto e pare — não
adivinhe.

**Se os SHAs coincidirem** (comparando pelo prefixo, quando o instalado for curto): diga
que o plugin já está na última versão, cite o SHA curto, e encerre. Nada mais a fazer.

## 3. Changelog

Peça os commits entre os dois SHAs à API pública do GitHub — leitura pura, não depende de
nem toca no clone local do marketplace:

```bash
curl -sf "https://api.github.com/repos/allangdy/ll-skills/compare/<sha-instalado>...<sha-remoto>"
```

De `.commits[]` extraia a primeira linha de `commit.message` e apresente como lista, do
mais antigo ao mais recente, com o total (`.ahead_by` commits novos). Se a chamada falhar
(offline, rate limit, SHA já coletado por garbage collection), siga para a atualização
avisando que o changelog não pôde ser carregado.

## 4. Aplicar

```bash
claude plugin marketplace update ll-skills
claude plugin update ll-skills@ll-skills -y
```

O primeiro comando atualiza o clone do marketplace; o segundo instala o commit novo. Se
qualquer um falhar, mostre a saída de erro e pare — não tente contornar por fora.

## 5. Confirmar e encerrar

Releia `gitCommitSha` no `installed_plugins.json` e confirme que agora bate com o SHA
remoto. Reporte:

- SHA antigo → SHA novo (curtos)
- quantos commits entraram
- que o plugin carregado na sessão atual ainda é o antigo: rodar `/reload-plugins` ou
  reiniciar o Claude Code aplica a versão nova

Se o SHA no registro não mudou, diga isso claramente em vez de declarar sucesso.
