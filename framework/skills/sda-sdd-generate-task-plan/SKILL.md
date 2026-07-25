---
name: sda-sdd-generate-task-plan
description: Decompõe uma Tech Spec aprovada em plano e tasks SDD v2 atômicas.
---

# Gerar tasks SDD

1. Leia `../_shared/task-generation-core.md`.
2. Use `assets/task_plan_template.md` e `assets/task_template.md`.
3. Gere o plano, o grafo de dependências e uma task por unidade verificável.
4. Valide que toda task declara `risk` e `validation` e não contém campos v1.

Entrada: path da Tech Spec informado na solicitação atual.