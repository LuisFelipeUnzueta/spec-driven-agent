---
description: Regras compartilhadas entre os workflows do framework sda (SDD, miniSpec, TaskCard, ADR e skills auxiliares de spec) — apenas conteúdo cross-workflow. Regras específicas de cada workflow ficam nos respectivos arquivos workflow-rules. Carregada automaticamente quando qualquer skill desses workflows está em execução.
paths:
  - ".claude/skills/sda-sdd-*/**"
  - ".claude/skills/sda-minispec-*/**"
  - ".claude/skills/sda-taskcard-*/**"
  - ".claude/skills/sda-adr-*/**"
  - ".claude/skills/sda-pre-refinement/**"
  - ".claude/skills/sda-generate-tech-alignment/**"
  - ".claude/skills/sda-generate-design/**"
  - ".claude/skills/sda-design-system-bootstrap/**"
  - ".claude/skills/sda-challenge-spec/**"
  - ".claude/skills/sda-backend-contract-handoff/**"
  - ".claude/skills/sda-debt-resolution/**"
---

# Regras Compartilhadas — Workflows sda

> Carregada automaticamente quando qualquer skill SDD, miniSpec, TaskCard, ADR ou skill auxiliar de spec (sda-pre-refinement, sda-generate-tech-alignment, sda-challenge-spec, sda-backend-contract-handoff) está em execução. Centraliza apenas conteúdo **cross-workflow** (válido em qualquer um deles). Conteúdo específico de cada workflow fica nos respectivos `sda-{workflow}-workflow-rules.md`.

---

## Regra de Acentuação (pt-BR)

Todo artefato gerado pelos skills (`prd.md`, `tech_spec.md`, `task_plan.md`, `tasks/TN.md`, `intent.md`, `scope.md`, `taskcard.md`, ADRs em `docs/adr/`, `domain-glossary.md`, `pre-refinement.md`, `tech-alignment.md`, `design.md`, `design-system.md`) é em português brasileiro com acentuação correta:

- Títulos/seções: `Descrição`, `Restrições`, `Instruções`, `Validação`, `Configuração`
- Corpo: `não`, `é`, `está`, `será`, `também`, `através`, `após`, `até`, `único`
- Termos técnicos em pt-BR: `autenticação`, `paginação`, `migração`, `funcionalidade`

Apenas nomes de código (funções, variáveis, structs, pacotes) permanecem em inglês sem acento.
