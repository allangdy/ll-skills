# LL Skills

Coleção de skills para [Claude Code](https://claude.com/claude-code), distribuída como plugin.

## Instalação

Dentro do Claude Code, rode:

```
/plugin marketplace add allangdy/ll-skills
/plugin install ll-skills@ll-skills
```

> Substitua `allangdy/ll-skills` pelo caminho real `usuario/repositorio` no GitHub, se for diferente.

Pronto — as skills ficam disponíveis automaticamente nas suas sessões.

## Atualizações

O plugin não fixa versão, então cada `git push` no repositório já conta como uma nova versão.

- **Atualização automática**: no Claude Code, abra `/plugin` → aba **Marketplaces** → ative
  *auto-update* para o marketplace `ll-skills`. Com isso, o Claude Code verifica atualizações
  ao iniciar a sessão, baixa em segundo plano e mostra um aviso; rode `/reload-plugins`
  (ou reinicie) para ativar a nova versão.
- **Atualização manual**:

  ```
  /plugin marketplace update ll-skills
  /plugin update ll-skills@ll-skills
  ```

## Skills incluídas

| Skill | Descrição |
|---|---|
| `orquestrar` | Regras de orquestração multi-agente: quando delegar, briefs, roteamento de modelos e verificação |
| `pesquisa-de-mercado` | Pesquisa de mercado completa antes de qualquer código: dossiê indexado em `docs/`, preços sem âncora, força de evidência, decisões em aberto → teste empírico |
| `voltar-do-futuro` | Premortem narrado do futuro: por que o projeto morreu, atacando o que nunca foi medido, com teste barato e critério de aceite para cada falha |
| `exemplo` | Skill de exemplo para testar se o plugin está funcionando |

## Adicionando novas skills

1. Crie `skills/<nome-da-skill>/SKILL.md`
2. No frontmatter, preencha `name` e `description` (a descrição diz ao Claude **quando** usar a skill)
3. Escreva as instruções no corpo do arquivo
4. Atualize a tabela acima e faça commit + push
