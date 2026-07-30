---
name: sda-sdd-generate-task-plan
description: Decompõe uma Tech Spec aprovada em plano e tasks SDD v2 atômicas.
---

# Gerar tasks SDD

1. Leia `../_shared/task-generation-core.md`.
2. Use `assets/task_plan_template.md` e `assets/task_template.md`.

   > **Template registry**: templates registrados como `sdd-task-plan` e `sdd-task`. Use `sda-template-resolve <template-id>` para resolver com suporte a overrides/presets/extensions.
3. **Exemplos canônicos**: ao especificar implementação nas tasks, referencie exemplos canônicos via `sda-example-lookup <contexto> <stack>` para garantir padrão consistente entre features.
4. Gere o plano, o grafo de dependências e uma task por unidade verificável.
5. Valide que toda task declara `risk` e `validation` e não contém campos v1.

Entrada: path da Tech Spec informado na solicitação atual.