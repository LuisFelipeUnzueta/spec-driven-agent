---
name: sda-minispec-generate-tasks
description: Decompõe um scope aprovado em plano e tasks miniSpec v2 atômicas.
---

# Gerar tasks miniSpec

1. Leia `../_shared/task-generation-core.md`.
2. Use `assets/task_plan_template.md` e `assets/task_template.md`.

   > **Template registry**: templates registrados como `minispec-task-plan` e `minispec-task`. Use `sda-template-resolve <template-id>` para resolver com suporte a overrides/presets/extensions.
3. **Exemplos canônicos**: ao especificar implementação nas tasks, referencie exemplos canônicos via `sda-example-lookup <contexto> <stack>` para garantir padrão consistente entre features.
4. Gere o plano, o grafo de dependências e uma task por unidade verificável.
5. Valide que toda task declara `risk` e `validation` e não contém campos v1.

Entrada: path do scope informado na solicitação atual.