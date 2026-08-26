---
name: exemplo
description: Skill de exemplo do plugin ll-skills. Use quando o usuário pedir para testar se o plugin ll-skills está instalado e funcionando.
---

# Skill de exemplo

Esta é uma skill de exemplo do plugin **ll-skills**.

Quando esta skill for invocada, responda ao usuário confirmando que o plugin
ll-skills está instalado e funcionando corretamente, e liste as skills
disponíveis neste plugin.

## Como criar suas próprias skills

Para adicionar uma nova skill a este plugin:

1. Crie uma pasta em `skills/<nome-da-skill>/`
2. Dentro dela, crie um arquivo `SKILL.md` com frontmatter:
   - `name`: nome da skill (kebab-case)
   - `description`: descrição clara de QUANDO usar a skill — o Claude usa
     este texto para decidir quando invocá-la automaticamente
3. O corpo do arquivo contém as instruções que o Claude seguirá
4. Faça commit e push — quem tem o plugin instalado recebe a atualização
